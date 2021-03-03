{
#########################################################
# Author: Matthias Heunecke, Navimatix                  #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.PackageProvider.GitLab;

interface

uses
  Classes,
  Types,
  Graphics,
  SysUtils,
  SyncObjs,
  Generics.Collections,
  DN.Types,
  DN.Package.Gitlab,
  DN.Package.Intf,
  DN.PackageProvider,
  DN.JSonFile.CacheInfo,
  DN.Progress.Intf,
  DN.HttpClient.Intf,
  DN.JSon,
  DN.JSOnFile.Info,
  DN.PackageProvider.State.Intf,
  DN.Package.Version.Intf;

type
  TDNGitLabPackageProvider = class(TDNPackageProvider, IDNProgress, IDNPackageProviderState)
  private
    FBaseURL: String;
    FProgress: IDNProgress;
    FPushDates: TDictionary<string, string>;
    FExistingIDs: TDictionary<TGUID, Integer>;
    FDateMutex: TMutex;
    FState: IDNPackageProviderState;
    FLoadPictures: Boolean;

    function  GetFileStream(const aURL: string; AFile: TStream): Boolean;
    function  GetGitlabFileText(const aRepoID, aFilePath, aRef : string; out AText: string): Boolean;
    function  GetLicense(const APackage: TDNGitLabPackage; const ALicense: TDNLicense): string;
    function  GetInfoFile(const aRepoID, aRef: string; AInfo: TInfoFile): Boolean;
    function  GetReleaseText(const ARepositoryID: string; out AReleases: string): Boolean;
    procedure RegisterReleases(const APackage: IDNPackage; const aRepoID, aReleases : string);
    function  getRelease(aReleases, aRelease: string) : TJSonObject;
    function  getReleaseAssetDownload(aRelease : TJSonObject) : string;
    procedure LoadPicture(APicture: TPicture; aURL : String);
    procedure AddDependencies(const AVersion: IDNPackageVersion; AInf: TInfoFile);
    procedure AddPackageFromJSon(AJSon: TJSONObject);
    function  CreatePackageWithMetaInfo(AItem: TJSONObject; out APackage: IDNPackage): Boolean;
    procedure HandleDownloadProgress(AProgress, AMax: Int64);
    procedure CheckRateLimit;
    procedure setBaseURL(aValue : String);
  protected
    FClient: IDNHttpClient;
    function GetPushDateFile: string;
    function GetRepoList(out ARepos: TJSONArray): Boolean; virtual;
    procedure SavePushDates;
    procedure LoadPushDates;
    //properties for interfaceredirection
    property Progress: IDNProgress read FProgress implements IDNProgress;
    property State: IDNPackageProviderState read FState implements IDNPackageProviderState;
  public
    constructor Create(const AClient: IDNHttpClient; ALoadPictures: Boolean = True);
    destructor Destroy(); override;
    function Reload(): Boolean; override;
    function Download(const APackage: IDNPackage; const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean; override;

    property BaseURL : String read FBaseURL write setBaseURL;
  end;

const

  CGitlabOAuthAuthentication = 'Bearer %s';

implementation

uses
  IOUtils,
  DateUtils,
  DN.IOUtils,
  StrUtils,
  jpeg,
  pngimage,
  DN.Version,
  DN.Package,
  DN.Zip,
  DN.Package.Version,
  DN.Package.Dependency,
  DN.Package.Dependency.Intf,
  DN.Progress,
  DN.Environment,
  DN.Graphics.Loader,
  DN.PackageProvider.GitLab.State;

const

  CGitlab           = 'Gitlab';
  CGitRepoSearch    = '%0:sapi/v4/projects?scope=projects&search=delphinus-support';
  CGitRepoSearchTK  = '%0:sapi/v4/projects?scope=projects&search=delphinus-support&private_token=%1:s';
  CGitRepoGetFile   = '%0:sapi/v4/projects/%1:s/repository/files/%2:s/raw?ref=%3:s';
  CGitRepoDownload  = '%0:sapi/v4/projects/%1:s/repository/archive.zip';
  CGitRepoReleases  = '%0:sapi/v4/projects/%1:s/releases';
  CMediaTypeRaw     = '';
  CPushDates        = 'PushDates.ini';

type
  EGitlabProviderException = EAbort;
  ERateLimitException = EGitlabProviderException;
  EInvalidProviderSetup = EGitlabProviderException;

{ TDCPMPackageProvider }

procedure TDNGitLabPackageProvider.AddDependencies(
  const AVersion: IDNPackageVersion; AInf: TInfoFile);
var
  LInfDependency: TInfoDependency;
  LDependency: IDNPackageDependency;
begin
  for LInfDependency in AInf.Dependencies do
  begin
    LDependency := TDNPackageDependency.Create(LInfDependency.ID, LInfDependency.Version);
    AVersion.Dependencies.Add(LDependency);
  end;
end;

procedure TDNGitLabPackageProvider.AddPackageFromJSon(AJSon: TJSONObject);
var
  LPackage: IDNPackage;
begin
  if CreatePackageWithMetaInfo(AJSon, LPackage) then
  begin
    Packages.Add(LPackage);
  end;
end;

procedure TDNGitLabPackageProvider.CheckRateLimit;
var
  LUnixTime: Int64;
  LResetTime: TDateTime;
begin
  if FClient.ResponseHeader['X-RateLimit-Remaining'] = '0' then
  begin
    LUnixTime := StrToInt64Def(FClient.ResponseHeader['X-RateLimit-Reset'], 0);
    LResetTime := TTimeZone.Local.ToLocalTime(UnixToDateTime(LUnixTime));
    raise ERateLimitException.Create('Ratelimit exceeded. Wait for reset. Reset is at ' + DateTimeToStr(LResetTime));
  end;
end;

procedure TDNGitLabPackageProvider.setBaseURL(aValue : String);
begin
  if aValue <> FBaseURL then
  begin
    FBaseURL := aValue;
    if length(FBaseURL) > 0 then
    begin
      if FBaseURL.Chars[length(FBaseURL)-1] <> '/' then
      begin
        FBaseURL := FBaseURL + '/';
      end;
    end;
  end;
end;

constructor TDNGitLabPackageProvider.Create;
var
  LKey: string;
begin
  inherited Create();
  FClient := AClient;
  FProgress := TDNProgress.Create();
  FPushDates := TDictionary<string, string>.Create();
  FExistingIDs := TDictionary<TGUID, Integer>.Create();
  LKey := StringReplace(GetPushDateFile(), '\', '/', [rfReplaceAll]);
  FDateMutex := TMutex.Create(nil, False, LKey);
  FState := TDNGitlabPackageProviderState.Create(FClient);
  FLoadPictures := ALoadPictures;
end;

function TDNGitLabPackageProvider.CreatePackageWithMetaInfo(AItem: TJSONObject;
  out APackage: IDNPackage): Boolean;
var
  LPackage: TDNGitLabPackage;
  LName, LAuthor, LDefaultBranch, LReleases, LWebURL: string;
  LFullName, LRepoID, LPushDate, LOldPushDate, LAvatatURL: string;
  LHeadInfo: TInfoFile;
  LHomePage: TJSONValue;
  LHeadVersion: TDNPackageVersion;
begin
  Result := False;

  LRepoID := AItem.GetValue('id').Value;
  LName := AItem.GetValue('name').Value;
  LFullName := AItem.GetValue('path_with_namespace').Value;
  LPushDate := AItem.GetValue('last_activity_at').Value;
  LAuthor := TJSonObject(AItem.GetValue('namespace')).GetValue('name').Value;
  LDefaultBranch := AItem.GetValue('default_branch').Value;
  LWebURL := AItem.GetValue('web_url').Value;
  LAvatatURL := AItem.GetValue('avatar_url').Value;

  GetReleaseText(LRepoID, LReleases);

  //if nothing was pushed or released since last refresh, we can go fullcache and not contact the server
  FClient.IgnoreCacheExpiration := (LPushDate = LOldPushDate) and (FClient.LastResponseSource = rsCache);
  LHeadInfo := TInfoFile.Create();
  try
    if GetInfoFile(LRepoID, LDefaultBranch, LHeadInfo) and not FExistingIDs.ContainsKey(LHeadInfo.ID) then
    begin
      FExistingIDs.Add(LHeadInfo.ID, 0);
      LPackage := TDNGitLabPackage.Create();
      LPackage.RepoID := LRepoID;
      LPackage.RepoReleases := LReleases;
      LPackage.OnGetLicense := GetLicense;
      if not AItem.GetValue('description').Null then
        LPackage.Description := AItem.GetValue('description').Value;
      LPackage.DownloadLoaction := Format(CGitRepoDownload, [FBaseURL, LRepoID]);
      LPackage.Author := LAuthor;
      LPackage.RepositoryName := LName;
      LPackage.DefaultBranch := LDefaultBranch;

      LPackage.ProjectUrl := LWebURL;
      LHomePage := AItem.GetValue('web_url');
      if LHomePage is TJSONString then
        LPackage.HomepageUrl := LHomePage.Value;

      if LHeadInfo.RepositoryRedirectIssues then
        LPackage.ReportUrl := LWebURL;
      if LHeadInfo.ReportUrl <> '' then
        LPackage.ReportUrl := LHeadInfo.ReportUrl;

      if LHeadInfo.Name <> '' then
        LPackage.Name := LHeadInfo.Name
      else
        LPackage.Name := LName;
      LPackage.ID := LHeadInfo.ID;
      LPackage.CompilerMin := LHeadInfo.PackageCompilerMin;
      LPackage.CompilerMax := LHeadInfo.PackageCompilerMax;
      LPackage.Licenses.AddRange(LHeadInfo.Licenses);
      LPackage.Platforms := LHeadInfo.Platforms;
      LPackage.RepositoryType := LHeadInfo.RepositoryType;
      LPackage.RepositoryUser := LHeadInfo.RepositoryUser;
      LPackage.Repository := LHeadInfo.Repository;
      APackage := LPackage;
      if FLoadPictures then
      begin
        try
          LoadPicture(APackage.Picture, LAvatatURL);
        except
        end;
      end;
      RegisterReleases(APackage, LRepoID, LReleases);
      LHeadVersion := TDNPackageVersion.Create();
      LHeadVersion.Name := 'HEAD';
      LHeadVersion.Value := TDNVersion.Create();
      LHeadVersion.CompilerMin := LHeadInfo.CompilerMin;
      LHeadVersion.CompilerMax := LHeadInfo.CompilerMax;
      AddDependencies(LHeadVersion, LHeadInfo);
      APackage.Versions.Add(LHeadVersion);
      FPushDates.AddOrSetValue(LFullName, LPushDate);
      Result := True;
    end;
  finally
    LHeadInfo.Free;
    FClient.IgnoreCacheExpiration := False;
  end;
end;

destructor TDNGitLabPackageProvider.Destroy;
begin
  FDateMutex.Free();
  FPushDates.Free();
  FExistingIDs.Free();
  FClient := nil;
  FProgress := nil;
  inherited;
end;

function ExtractAndDeleteArchive(const AArchive: string; ARootDir: string): string;
var
  LFolder: string;
  LDirs: TStringDynArray;
begin
  Result := '';
  LFolder := TPath.Combine(ARootDir, TGuid.NewGuid.ToString);
  if ForceDirectories(LFolder) and ShellUnzip(AArchive, LFolder) then
  begin
    LDirs := TDirectory.GetDirectories(LFolder);
    if Length(LDirs) = 1 then
      Result := LDirs[0];
  end;
  TFile.Delete(AArchive);
end;

function TDNGitLabPackageProvider.GetFileStream(const aURL: string; AFile: TStream): Boolean;
begin
  FClient.Accept := CMediaTypeRaw;
  try
    Result := FClient.Get(aURL, AFile) = HTTPErrorOk;
    if not Result then
      CheckRateLimit();
  finally
    FClient.Accept := '';
  end;
end;

function TDNGitLabPackageProvider.GetGitlabFileText(const aRepoID, aFilePath, aRef : string; out AText: string): Boolean;
var url : string;
begin
  FClient.Accept := CMediaTypeRaw;
  try
    url := Format(CGitRepoGetFile, [FBaseURL, aRepoID, aFilePath, aRef]);
    Result := FClient.GetText(url, AText) = HTTPErrorOk;
    if not Result then
      CheckRateLimit();
  finally
    FClient.Accept := '';
  end;
end;

function TDNGitLabPackageProvider.GetLicense(const APackage: TDNGitLabPackage; const ALicense: TDNLicense): string;
var crepoid, cref : string;
begin
  Result := 'No Licensefile has been provided.' + sLineBreak + 'Contact the Packageauthor to fix this issue by using the report-button.';
  if (ALicense.LicenseFile <> '') then
  begin
    crepoid := (APackage as TDNGitLabPackage).RepoID;
    cref    := (APackage as TDNGitLabPackage).DefaultBranch;
    if GetGitlabFileText(crepoid, ALicense.LicenseFile, cref, result) then
    begin
      //if we do not detect a single Windows-Linebreak, we assume Posix-LineBreaks and convert
      if not ContainsStr(Result, sLineBreak) then
        Result := StringReplace(Result, #10, sLineBreak, [rfReplaceAll]);
    end
    else
    begin
      Result := 'An error occured while downloading the license information.' + sLineBreak + 'The file might be missing.';
    end;
  end;
end;

function TDNGitLabPackageProvider.GetInfoFile(const aRepoID, aRef: string; AInfo: TInfoFile): Boolean;
var
  LResponse: string;
begin
  FClient.Accept := CMediaTypeRaw;
  try
    Result := GetGitlabFileText(aRepoID, CInfoFile, aRef, LResponse)
      and AInfo.LoadFromString(LResponse);
    if not Result then
      CheckRateLimit();
  finally
    FClient.Accept := '';
  end;
end;

function TDNGitLabPackageProvider.GetReleaseText(const ARepositoryID: string; out AReleases: string): Boolean;
begin
  Result := FClient.GetText(Format(CGitRepoReleases, [FBaseURL, ARepositoryID]), AReleases) = HTTPErrorOk;
  if not Result then
    CheckRateLimit();
end;

function TDNGitLabPackageProvider.Download(const APackage: IDNPackage;
  const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean;
var
  LArchiveFile, LProviderFolder, LProviderUrl: string;
  LGitlabPackage: TDNGitLabPackage;
  LRelease : TJSONObject;
const
  CNamePrefix = 'filename=';
begin
  FProgress.SetTasks(['Downloading']);
  LArchiveFile := TPath.Combine(AFolder, 'Package.zip');
  FClient.OnProgress := HandleDownloadProgress;
  if AVersion = 'HEAD' then
  begin
    LProviderUrl := APackage.DownloadLoaction;
  end else
  begin
    LRelease := getRelease((APackage as TDNGitLabPackage).RepoReleases, AVersion);
    if LRelease <> nil then
    begin
      try
        LProviderUrl := getReleaseAssetDownload(LRelease);
      finally
        FreeAndNil(LRelease);
      end;
    end;
  end;
  Result := FClient.Download(APackage.DownloadLoaction, LArchiveFile) = HTTPErrorOk;
  if Result then
  begin
    AContentFolder := ExtractAndDeleteArchive(LArchiveFile, AFolder);
    if APackage is TDNGitLabPackage then
    begin
      LGitlabPackage := APackage as TDNGitLabPackage;
      if LGitlabPackage.RepositoryType <> '' then
      begin
        Result := FClient.Download(LProviderUrl, LArchiveFile) = HTTPErrorOk;
        if Result then
        begin
          LProviderFolder := ExtractAndDeleteArchive(LArchiveFile, AFolder);
          TDirectory.Copy(AContentFolder, LProviderFolder);
          AContentFolder := LProviderFolder;
        end;
      end;
    end;
  end;
  FClient.OnProgress := nil;
end;

procedure TDNGitLabPackageProvider.LoadPicture(APicture: TPicture; aURL : String);
var
  LPicStream: TMemoryStream;
begin
  LPicStream := TMemoryStream.Create();
  try
    if GetFileStream(aURL, LPicStream) then
    begin
      LPicStream.Position := 0;
      TGraphicLoader.TryLoadPictureFromStream(LPicStream, '.png', APicture);
    end;
  finally
    LPicStream.Free;
  end;
end;

procedure TDNGitLabPackageProvider.RegisterReleases(const APackage: IDNPackage; const aRepoID, aReleases : string);
var
  LArray: TJSONArray;
  LObject: TJSonObject;
  i: Integer;
  LVersionName: string;
  LInfo: TInfoFile;
  LVersion: IDNPackageVersion;
begin
  LInfo := TInfoFile.Create();
  try
    LArray := TJSOnObject.ParseJSONValue(AReleases) as TJSONArray;
    try
      for i := 0 to LArray.Count - 1 do
      begin
        LObject := LArray.Items[i] as TJSonObject;
        LVersionName := LObject.GetValue('tag_name').Value;
        if GetInfoFile(aRepoID, LVersionName, LInfo) then
        begin
          LVersion := TDNPackageVersion.Create();
          LVersion.Name := LVersionName;
          LVersion.CompilerMin := LInfo.CompilerMin;
          LVersion.CompilerMax := LInfo.CompilerMax;
          AddDependencies(LVersion, LInfo);
          APackage.Versions.Add(LVersion);
        end;
      end;
    finally
      LArray.Free;
    end;
  finally
    LInfo.Free;
  end;
end;

function  TDNGitLabPackageProvider.getRelease(aReleases, aRelease: string) : TJSonObject;
var
  LArray: TJSONArray;
  LObject: TJSonObject;
  i: Integer;
  LVersionName: string;
begin
  result := nil;
  LArray := TJSOnObject.ParseJSONValue(AReleases) as TJSONArray;
  try
    for i := 0 to LArray.Count - 1 do
    begin
      LObject := LArray.Items[i] as TJSonObject;
      LVersionName := LObject.GetValue('tag_name').Value;
      if LVersionName = aRelease then
      begin
        result := TJSOnObject.ParseJSONValue(LObject.ToString) as TJSOnObject;
        break;
      end;
    end;
  finally
    LArray.Free;
  end;
end;

function  TDNGitLabPackageProvider.getReleaseAssetDownload(aRelease : TJSonObject) : string;
var cvassets  : TJSONValue;
    coassets,
    cosource  : TJSONObject;
    casources : TJSONArray;
    i         : Integer;
begin
  result := '';
  if aRelease <> nil then
  begin
    cvassets := aRelease.GetValue('assets');
    if cvassets is TJSONObject then
    begin
      coassets := TJSONObject(cvassets);
      casources := coassets.GetValue('sources') as TJSONArray;
      for i := 0 to casources.Count - 1 do
      begin
        cosource := casources.Items[i] as TJSONObject;
        if cosource.GetValue('format').Value = 'zip' then
        begin
          result := cosource.GetValue('url').Value;
          break;
        end;
      end;
    end;
  end;
end;

function TDNGitLabPackageProvider.GetPushDateFile: string;
begin
  Result := TPath.Combine(GetDelphinusTempFolder(), CPushDates);
end;

function TDNGitLabPackageProvider.GetRepoList(out ARepos: TJSONArray): Boolean;
var
  LRoot: TJSONArray;
  LSearchResponse: string;
  BSearchResponse: TArray<Byte>;
begin
  Result := FClient.GetText(Format(CGitRepoSearch, [FBaseURL]), LSearchResponse) = HTTPErrorOk;
  if Result then
  begin
    BSearchResponse := TEncoding.UTF8.GetBytes(LSearchResponse);
    LRoot := TJSONObject.ParseJSONValue(BSearchResponse, 0, Length(BSearchResponse),
              [ TJSONObject.TJSONParseOption.IsUTF8,
                TJSONObject.TJSONParseOption.UseBool]) as TJSONArray;
    ARepos := LRoot;
    ARepos.Owned := False;
  end;
end;

procedure TDNGitLabPackageProvider.HandleDownloadProgress(AProgress,
  AMax: Int64);
begin
  FProgress.SetTaskProgress('Archive', AProgress, AMax);
end;

procedure TDNGitLabPackageProvider.LoadPushDates;
var
  LDates: TStringList;
  i: Integer;
begin
  FDateMutex.Acquire();
  FPushDates.Clear;

  if not TFile.Exists(GetPushDateFile()) then
    Exit;

  LDates := TStringList.Create();
  try
    LDates.LoadFromFile(GetPushDateFile());
    for i := 0 to LDates.Count - 1 do
      FPushDates.Add(LDates.Names[i], LDates.ValueFromIndex[i]);
  finally
    LDates.Free;
  end;
end;

function TDNGitLabPackageProvider.Reload: Boolean;
var
  LRepo: TJSONObject;
  LRepos: TJSONArray;
  i: Integer;
begin
  Result := False;
  try
    (FState as TDNGitlabPackageProviderState).Reset();
    FProgress.SetTasks(['Reolading']);
    try
      LoadPushDates();
      FClient.BeginWork();
      try
        if GetRepoList(LRepos) then
        begin
          try
            Packages.Clear();
            FExistingIDs.Clear();
            for i := 0 to LRepos.Count - 1 do
            begin
              LRepo := LRepos.Items[i] as TJSONObject;
              FProgress.SetTaskProgress(LRepo.GetValue('name').Value, i, LRepos.Count);
              AddPackageFromJSon(LRepo);
            end;
            FProgress.Completed();
            Result := True;
          finally
            LRepos.Free;
          end;
        end;
      finally
        FClient.EndWork();
      end;
    finally
      SavePushDates();
    end;
  except
    on E: ERateLimitException do
      (FState as TDNGitlabPackageProviderState).SetError(E.Message)
  end;
end;

procedure TDNGitLabPackageProvider.SavePushDates;
var
  LDates: TStringList;
  LKeys, LValues: TArray<string>;
  i: Integer;
begin
  LDates := TStringList.Create();
  try
    LKeys := FPushDates.Keys.ToArray();
    LValues := FPushDates.Values.ToArray();
    for i := 0 to FPushDates.Count - 1 do
      LDates.Add(LKeys[i] + '=' + LValues[i]);
    LDates.SaveToFile(GetPushDateFile());
  finally
    LDates.Free;
    FDateMutex.Release();
  end;
end;

end.
