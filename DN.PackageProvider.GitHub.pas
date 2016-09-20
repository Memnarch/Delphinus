{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.PackageProvider.GitHub;

interface

uses
  Classes,
  Types,
  Graphics,
  SysUtils,
  SyncObjs,
  Generics.Collections,
  DN.Package.Github,
  DN.Package.Intf,
  DN.PackageProvider,
  DN.JSonFile.CacheInfo,
  DN.Progress.Intf,
  DN.HttpClient.Intf,
  DN.JSon,
  DN.JSOnFile.Info;

type
  TDNGitHubPackageProvider = class(TDNPackageProvider, IDNProgress)
  private
    FProgress: IDNProgress;
    FPushDates: TDictionary<string, string>;
    FExistingIDs: TDictionary<TGUID, Integer>;
    FDateMutex: TMutex;
    function LoadVersionInfo(const APackage: IDNPackage; const AAuthor, AName, AFirstVersion, AReleases: string): Boolean;
    procedure AddPackageFromJSon(AJSon: TJSONObject);
    function CreatePackageWithMetaInfo(AItem: TJSONObject; out APackage: IDNPackage): Boolean;
    procedure LoadPicture(APicture: TPicture; AAuthor, ARepository, AVersion, APictureFile: string);
    function GetInfoFile(const AAuthor, ARepository, AVersion: string; AInfo: TInfoFile): Boolean;
    function GetFileText(const AAuthor, ARepository, AVersion, AFilePath: string; out AText: string): Boolean;
    function GetFileStream(const AAuthor, ARepository, AVersion, AFilePath: string; AFile: TStream): Boolean;
    function GetReleaseText(const AAuthor, ARepository: string; out AReleases: string): Boolean;
    procedure HandleDownloadProgress(AProgress, AMax: Int64);
  protected
    FClient: IDNHttpClient;
    function GetLicense(const APackage: TDNGitHubPackage): string;
    function GetPushDateFile: string;
    function GetRepoList(out ARepos: TJSONArray): Boolean; virtual;
    procedure SavePushDates;
    procedure LoadPushDates;
    //properties for interfaceredirection
    property Progress: IDNProgress read FProgress implements IDNProgress;
  public
    constructor Create(const AClient: IDNHttpClient);
    destructor Destroy(); override;
    function Reload(): Boolean; override;
    function Download(const APackage: IDNPackage; const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean; override;
  end;

const
  CGithubOAuthAuthentication = 'token %s';

implementation

uses
  IOUtils,
  DN.IOUtils,
  StrUtils,
  jpeg,
  pngimage,
  DN.Types,
  DN.Package,
  DN.Zip,
  DN.Package.Version,
  DN.Package.Version.Intf,
  DN.Progress,
  DN.Environment,
  DN.Graphics.Loader;

const
  CGithubFileContent = 'https://api.github.com/repos/%s/%s/contents/%s?ref=%s';//user/repo filepath/branch
  CGitRepoSearch = 'https://api.github.com/search/repositories?q="Delphinus-Support"+in:readme&per_page=100';
  CGithubRepoReleases = 'https://api.github.com/repos/%s/%s/releases';// user/repo/releases
  CMediaTypeRaw = 'application/vnd.github.v3.raw';
  CPushDates = 'PushDates.ini';

{ TDCPMPackageProvider }

procedure TDNGitHubPackageProvider.AddPackageFromJSon(AJSon: TJSONObject);
var
  LPackage: IDNPackage;
begin
  if CreatePackageWithMetaInfo(AJSon, LPackage) then
  begin
    Packages.Add(LPackage);
  end;
end;

constructor TDNGitHubPackageProvider.Create;
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
end;

function TDNGitHubPackageProvider.CreatePackageWithMetaInfo(AItem: TJSONObject;
  out APackage: IDNPackage): Boolean;
var
  LPackage: TDNGitHubPackage;
  LName, LAuthor, LDefaultBranch, LReleases: string;
  LFullName, LPushDate, LOldPushDate: string;
  LHeadInfo: TInfoFile;
  LHomePage: TJSONValue;
const
  CArchivePlaceholder = '{archive_format}{/ref}';
begin
  Result := False;
  LFullName := AItem.GetValue('full_name').Value;
  LPushDate := AItem.GetValue('pushed_at').Value;
  if not FPushDates.TryGetValue(LFullName, LOldPushDate) then
    LOldPushDate := '';

  LName := AItem.GetValue('name').Value;
  LAuthor := TJSonObject(AItem.GetValue('owner')).GetValue('login').Value;
  LDefaultBranch := AItem.GetValue('default_branch').Value;
  if not GetReleaseText(LAuthor, LName, LReleases) then
    Exit(False);

  //if nothing was pushed or released since last refresh, we can go fullcache and not contact the server
  FClient.IgnoreCacheExpiration := (LPushDate = LOldPushDate) and (FClient.LastResponseSource = rsCache);
  LHeadInfo := TInfoFile.Create();
  try
    if GetInfoFile(LAuthor, LName, LDefaultBranch, LHeadInfo) and not FExistingIDs.ContainsKey(LHeadInfo.ID) then
    begin
      FExistingIDs.Add(LHeadInfo.ID, 0);
      LPackage := TDNGitHubPackage.Create();
      LPackage.OnGetLicense := GetLicense;
      LPackage.Description := AItem.GetValue('description').Value;
      LPackage.DownloadLoaction := AItem.GetValue('archive_url').Value;
      LPackage.DownloadLoaction := StringReplace(LPackage.DownloadLoaction, CArchivePlaceholder, 'zipball/', []);
      LPackage.Author := LAuthor;
      LPackage.RepositoryName := LName;
      LPackage.DefaultBranch := LDefaultBranch;

      LPackage.ProjectUrl := AItem.GetValue('html_url').Value;
      LHomePage := AItem.GetValue('homepage');
      if LHomePage is TJSONString then
        LPackage.HomepageUrl := LHomePage.Value;

      if AItem.GetValue('has_issues') is TJSONTrue then
        LPackage.ReportUrl := LPackage.ProjectUrl + '/issues';
      
      if LHeadInfo.Name <> '' then
        LPackage.Name := LHeadInfo.Name
      else
        LPackage.Name := LName;
      LPackage.ID := LHeadInfo.ID;
      LPackage.CompilerMin := LHeadInfo.CompilerMin;
      LPackage.CompilerMax := LHeadInfo.CompilerMax;
      LPackage.LicenseType := LHeadInfo.LicenseType;
      LPackage.LicenseFile := LHeadInfo.LicenseFile;
      LPackage.Platforms := LHeadInfo.Platforms;
      APackage := LPackage;
      LoadPicture(APackage.Picture, LAuthor, LPackage.RepositoryName, LPackage.DefaultBranch, LHeadInfo.Picture);
      LoadVersionInfo(APackage, LAuthor, LName, LHeadInfo.FirstVersion, LReleases);
      FPushDates.AddOrSetValue(LFullName, LPushDate);
      Result := True;
    end;
  finally
    LHeadInfo.Free;
    FClient.IgnoreCacheExpiration := False;
  end;
end;

destructor TDNGitHubPackageProvider.Destroy;
begin
  FDateMutex.Free();
  FPushDates.Free();
  FExistingIDs.Free();
  FClient := nil;
  FProgress := nil;
  inherited;
end;

function TDNGitHubPackageProvider.Download(const APackage: IDNPackage;
  const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean;
var
  LArchiveFile, LFolder: string;
  LDirs: TStringDynArray;
const
  CNamePrefix = 'filename=';
begin
  FProgress.SetTasks(['Downloading']);
  LArchiveFile := TPath.Combine(AFolder, 'Package.zip');
  FClient.OnProgress := HandleDownloadProgress;
  Result := FClient.Download(APackage.DownloadLoaction + IfThen(AVersion <> '', AVersion, (APackage as TDNGitHubPackage).DefaultBranch), LArchiveFile) = HTTPErrorOk;
  FClient.OnProgress := nil;
  if Result then
  begin
    LFolder := TPath.Combine(AFolder, TGuid.NewGuid.ToString);
    Result := ForceDirectories(LFolder);
    if Result then
      Result := ShellUnzip(LArchiveFile, LFolder);
  end;

  if Result then
  begin
    LDirs := TDirectory.GetDirectories(LFolder);
    Result := Length(LDirs) = 1;
    if Result then
      AContentFolder := LDirs[0];
  end;
  TFile.Delete(LArchiveFile);
end;

function TDNGitHubPackageProvider.LoadVersionInfo(
  const APackage: IDNPackage; const AAuthor, AName,
  AFirstVersion, AReleases: string): Boolean;
var
  LArray: TJSONArray;
  LObject: TJSonObject;
  i: Integer;
  LVersionName: string;
  LInfo: TInfoFile;
  LVersion: IDNPackageVersion;
begin
  Result := False;
  LInfo := TInfoFile.Create();
  try
    LArray := TJSOnObject.ParseJSONValue(AReleases) as TJSONArray;
    try
      for i := 0 to LArray.Count - 1 do
      begin
        LObject := LArray.Items[i] as TJSonObject;
        LVersionName := LObject.GetValue('tag_name').Value;
        if GetInfoFile(AAuthor, AName, LVersionName, LInfo) then
        begin
          LVersion := TDNPackageVersion.Create();
          LVersion.Name := LVersionName;
          LVersion.CompilerMin := LInfo.CompilerMin;
          LVersion.CompilerMax := LInfo.CompilerMax;
          APackage.Versions.Add(LVersion);
        end;
        if SameText(AFirstVersion, LVersionName) then
          Break;
      end;
    finally
      LArray.Free;
    end;
  finally
    LInfo.Free;
  end;
end;

function TDNGitHubPackageProvider.GetFileStream(const AAuthor, ARepository,
  AVersion, AFilePath: string; AFile: TStream): Boolean;
begin
  FClient.Accept := CMediaTypeRaw;
  try
    Result := FClient.Get(Format(CGithubFileContent, [AAuthor, ARepository, AFilePath, AVersion]), AFile) = HTTPErrorOk;
  finally
    FClient.Accept := '';
  end;
end;

function TDNGitHubPackageProvider.GetFileText(const AAuthor, ARepository,
  AVersion, AFilePath: string; out AText: string): Boolean;
begin
  FClient.Accept := CMediaTypeRaw;
  try
    Result := FClient.GetText(Format(CGithubFileContent, [AAuthor, ARepository, AFilePath, AVersion]), AText) = HTTPErrorOk;
  finally
    FClient.Accept := '';
  end;
end;

function TDNGitHubPackageProvider.GetInfoFile(const AAuthor, ARepository,
  AVersion: string; AInfo: TInfoFile): Boolean;
var
  LResponse: string;
begin
  FClient.Accept := CMediaTypeRaw;
  try
    Result := GetFileText(AAuthor, ARepository, AVersion, CInfoFile, LResponse)
      and AInfo.LoadFromString(LResponse);
  finally
    FClient.Accept := '';
  end;
end;

function TDNGitHubPackageProvider.GetLicense(
  const APackage: TDNGitHubPackage): string;
begin
  Result := '';
  if (APackage.LicenseType <> '') then
  begin
    if GetFileText(APackage.Author, APackage.RepositoryName, APackage.DefaultBranch, APackage.LicenseFile, Result) then
    begin
      //if we do not detect a single Windows-Linebreak, we assume Posix-LineBreaks and convert
      if not ContainsStr(Result, sLineBreak) then
        Result := StringReplace(Result, #10, sLineBreak, [rfReplaceAll]);
    end
    else
    begin
      Result := 'An error occured while doanloading the license information';
    end;
  end;
end;

function TDNGitHubPackageProvider.GetPushDateFile: string;
begin
  Result := TPath.Combine(GetDelphinusTempFolder(), CPushDates);
end;

function TDNGitHubPackageProvider.GetReleaseText(const AAuthor,
  ARepository: string; out AReleases: string): Boolean;
begin
  Result := FClient.GetText(Format(CGithubRepoReleases, [AAuthor, ARepository]), AReleases) = HTTPErrorOk;
end;

function TDNGitHubPackageProvider.GetRepoList(out ARepos: TJSONArray): Boolean;
var
  LRoot: TJSONObject;
  LSearchResponse: string;
begin
  Result := FClient.GetText(CGitRepoSearch, LSearchResponse) = HTTPErrorOk;
  if Result then
  begin
    LRoot := TJSONObject.ParseJSONValue(LSearchResponse)as TJSONObject;
    try
      ARepos := LRoot.GetValue('items') as TJSONArray;
      ARepos.Owned := False;
    finally
      LRoot.Free;
    end;
  end;
end;

procedure TDNGitHubPackageProvider.HandleDownloadProgress(AProgress,
  AMax: Int64);
begin
  FProgress.SetTaskProgress('Archive', AProgress, AMax);
end;

procedure TDNGitHubPackageProvider.LoadPicture(APicture: TPicture; AAuthor, ARepository, AVersion, APictureFile: string);
var
  LPicStream: TMemoryStream;
  LPictureFile: string;
begin
  LPicStream := TMemoryStream.Create();
  try
    LPictureFile := StringReplace(APictureFile, '\', '/', [rfReplaceAll]);
    if GetFileStream(AAuthor, ARepository, AVersion, LPictureFile, LPicStream) then
    begin
      LPicStream.Position := 0;
      TGraphicLoader.TryLoadPictureFromStream(LPicStream, ExtractFileExt(LPictureFile), APicture);
    end;
  finally
    LPicStream.Free;
  end;
end;

procedure TDNGitHubPackageProvider.LoadPushDates;
var
  LDates: TStringList;
  i: Integer;
begin
  FDateMutex.Acquire();

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

function TDNGitHubPackageProvider.Reload: Boolean;
var
  LRepo: TJSONObject;
  LRepos: TJSONArray;
  i: Integer;
begin
  Result := False;
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
end;

procedure TDNGitHubPackageProvider.SavePushDates;
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
