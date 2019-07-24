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
  DN.Types,
  DN.Package.Github,
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
  TDNGitHubPackageProvider = class(TDNPackageProvider, IDNProgress, IDNPackageProviderState)
  private
    FProgress: IDNProgress;
    FPushDates: TDictionary<string, string>;
    FExistingIDs: TDictionary<TGUID, Integer>;
    FDateMutex: TMutex;
    FState: IDNPackageProviderState;
    FLoadPictures: Boolean;
    function LoadVersionInfo(const APackage: IDNPackage; const AAuthor, AName, AFirstVersion, AReleases: string): Boolean;
    procedure AddDependencies(const AVersion: IDNPackageVersion; AInf: TInfoFile);
    procedure AddPackageFromJSon(AJSon: TJSONObject);
    function CreatePackageWithMetaInfo(AItem: TJSONObject; out APackage: IDNPackage): Boolean;
    procedure LoadPicture(APicture: TPicture; AAuthor, ARepository, AVersion, APictureFile: string);
    function GetInfoFile(const AAuthor, ARepository, AVersion: string; AInfo: TInfoFile): Boolean;
    function GetGithubFileText(const AAuthor, ARepository, AVersion, AFilePath: string; out AText: string): Boolean;
    function GetBitbucketFileText(const AAuthor, ARepository, AVersion, AFilePath: string; out AText: string): Boolean;
    function GetFileStream(const AAuthor, ARepository, AVersion, AFilePath: string; AFile: TStream): Boolean;
    function GetReleaseText(const AAuthor, ARepository: string; out AReleases: string): Boolean;
    procedure HandleDownloadProgress(AProgress, AMax: Int64);
    procedure CheckRateLimit;
  protected
    FClient: IDNHttpClient;
    function GetLicense(const APackage: TDNGitHubPackage; const ALicense: TDNLicense): string;
    function GetPushDateFile: string;
    function GetRepoList(out ARepos: TJSONArray): Boolean; virtual;
    function GetRepositoryDownloadUrl(const AName, AUser, ARepo, AVersion: string): string;
    function GetRepositoryIssueUrl(const AName, AUser, ARepo: string): string;
    function GetProjectUrl(const AName, AUser, ARepo: string): string;
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
  end;

const
  CGithubOAuthAuthentication = 'token %s';

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
  DN.PackageProvider.GitHub.State;

const
  CGithup = 'Github';
  CGithubProjectUrl = 'https://github.com/%s/%s';
  CGithubIssueUrl = 'https://github.com/%s/%s/issues';
  CGithubDownloadUrl = 'https://api.github.com/repos/%s/%s/zipball/%s';
  CGithubFileContent = 'https://api.github.com/repos/%s/%s/contents/%s?ref=%s';//user/repo filepath/branch
  CGitRepoSearch = 'https://api.github.com/search/repositories?q="Delphinus-Support"+in:readme&per_page=100';
  CGithubRepoReleases = 'https://api.github.com/repos/%s/%s/releases';// user/repo/releases
  CMediaTypeRaw = 'application/vnd.github.v3.raw';
  CPushDates = 'PushDates.ini';

  CBitbucket = 'Bitbucket';
  CBitbucketDownloadUrl = 'https://bitbucket.org/%s/%s/get/%s.zip';
  CBitbucketIssueUrl = 'https://bitbucket.org/%s/%s/issues';
  CBitbucketFileContent = 'https://bitbucket.org/%s/%s/raw/%s/%s';
  CBitbucketProjectUrl = 'https://bitbucket.org/%s/%s';





type
  EGithubProviderException = EAbort;
  ERateLimitException = EGithubProviderException;
  EInvalidProviderSetup = EGithubProviderException;

{ TDCPMPackageProvider }

procedure TDNGitHubPackageProvider.AddDependencies(
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

procedure TDNGitHubPackageProvider.AddPackageFromJSon(AJSon: TJSONObject);
var
  LPackage: IDNPackage;
begin
  if CreatePackageWithMetaInfo(AJSon, LPackage) then
  begin
    Packages.Add(LPackage);
  end;
end;

procedure TDNGitHubPackageProvider.CheckRateLimit;
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
  FState := TDNGithubPackageProviderState.Create(FClient);
  FLoadPictures := ALoadPictures;
end;

function TDNGitHubPackageProvider.CreatePackageWithMetaInfo(AItem: TJSONObject;
  out APackage: IDNPackage): Boolean;
var
  LPackage: TDNGitHubPackage;
  LName, LAuthor, LDefaultBranch, LReleases: string;
  LFullName, LPushDate, LOldPushDate: string;
  LHeadInfo: TInfoFile;
  LHomePage: TJSONValue;
  LHeadVersion: TDNPackageVersion;
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
      if not AItem.GetValue('description').Null then
        LPackage.Description := AItem.GetValue('description').Value;
      LPackage.DownloadLoaction := AItem.GetValue('archive_url').Value;
      LPackage.DownloadLoaction := StringReplace(LPackage.DownloadLoaction, CArchivePlaceholder, 'zipball/', []);
      LPackage.Author := LAuthor;
      LPackage.RepositoryName := LName;
      LPackage.DefaultBranch := LDefaultBranch;

      LPackage.ProjectUrl := GetProjectUrl(LHeadInfo.RepositoryType, LHeadInfo.RepositoryUser, LHeadInfo.Repository);
      if LPackage.ProjectUrl = '' then
        LPackage.ProjectUrl := AItem.GetValue('html_url').Value;
      LHomePage := AItem.GetValue('homepage');
      if LHomePage is TJSONString then
        LPackage.HomepageUrl := LHomePage.Value;

      if LHeadInfo.RepositoryRedirectIssues then
        LPackage.ReportUrl := GetRepositoryIssueUrl(LHeadInfo.RepositoryType, LHeadInfo.RepositoryUser, LHeadInfo.Repository);
      if LHeadInfo.ReportUrl <> '' then
        LPackage.ReportUrl := LHeadInfo.ReportUrl;
      if (LPackage.ReportUrl = '') and (AItem.GetValue('has_issues') is TJSONTrue) then
        LPackage.ReportUrl := LPackage.ProjectUrl + '/issues';
      
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
        LoadPicture(APackage.Picture, LAuthor, LPackage.RepositoryName, LPackage.DefaultBranch, LHeadInfo.Picture);
      LoadVersionInfo(APackage, LAuthor, LName, LHeadInfo.FirstVersion, LReleases);
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

destructor TDNGitHubPackageProvider.Destroy;
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

function TDNGitHubPackageProvider.Download(const APackage: IDNPackage;
  const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean;
var
  LArchiveFile, LProviderFolder, LVersion, LProviderUrl: string;
  LGithubPackage: TDNGitHubPackage;
const
  CNamePrefix = 'filename=';
begin
  FProgress.SetTasks(['Downloading']);
  LArchiveFile := TPath.Combine(AFolder, 'Package.zip');
  FClient.OnProgress := HandleDownloadProgress;
  LVersion := IfThen(AVersion <> '', AVersion, (APackage as TDNGitHubPackage).DefaultBranch);
  Result := FClient.Download(APackage.DownloadLoaction + LVersion, LArchiveFile) = HTTPErrorOk;
  if Result then
  begin
    AContentFolder := ExtractAndDeleteArchive(LArchiveFile, AFolder);
    if APackage is TDNGitHubPackage then
    begin
      LGithubPackage := APackage as TDNGitHubPackage;
      if LGithubPackage.RepositoryType <> '' then
      begin
        LProviderUrl := GetRepositoryDownloadUrl(LGithubPackage.RepositoryType, LGithubPackage.RepositoryUser, LGithubPackage.Repository, LVersion);
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
          AddDependencies(LVersion, LInfo);
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

function TDNGitHubPackageProvider.GetBitbucketFileText(const AAuthor,
  ARepository, AVersion, AFilePath: string; out AText: string): Boolean;
begin
  FClient.Accept := CMediaTypeRaw;
  try
    Result := FClient.GetText(Format(CBitbucketFileContent, [AAuthor, ARepository, AVersion, AFilePath]), AText) = HTTPErrorOk;
    if not Result then
      CheckRateLimit();
  finally
    FClient.Accept := '';
  end;
end;

function TDNGitHubPackageProvider.GetFileStream(const AAuthor, ARepository,
  AVersion, AFilePath: string; AFile: TStream): Boolean;
begin
  FClient.Accept := CMediaTypeRaw;
  try
    Result := FClient.Get(Format(CGithubFileContent, [AAuthor, ARepository, AFilePath, AVersion]), AFile) = HTTPErrorOk;
    if not Result then
      CheckRateLimit();
  finally
    FClient.Accept := '';
  end;
end;

function TDNGitHubPackageProvider.GetGithubFileText(const AAuthor, ARepository,
  AVersion, AFilePath: string; out AText: string): Boolean;
begin
  FClient.Accept := CMediaTypeRaw;
  try
    Result := FClient.GetText(Format(CGithubFileContent, [AAuthor, ARepository, AFilePath, AVersion]), AText) = HTTPErrorOk;
    if not Result then
      CheckRateLimit();
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
    Result := GetGithubFileText(AAuthor, ARepository, AVersion, CInfoFile, LResponse)
      and AInfo.LoadFromString(LResponse);
    if not Result then
      CheckRateLimit();
  finally
    FClient.Accept := '';
  end;
end;

function TDNGitHubPackageProvider.GetLicense(
  const APackage: TDNGitHubPackage; const ALicense: TDNLicense): string;
var
  LHasExternalLicense: Boolean;
begin
  Result := 'No Licensefile has been provided.' + sLineBreak + 'Contact the Packageauthor to fix this issue by using the report-button.';
  if (ALicense.LicenseFile <> '') then
  begin
    LHasExternalLicense := (SameText(APackage.RepositoryType, CBitbucket) and GetBitbucketFileText(APackage.RepositoryUser, APackage.Repository, APackage.DefaultBranch, ALicense.LicenseFile, Result))
      or (SameText(APackage.RepositoryType, CGithup) and GetGithubFileText(APackage.RepositoryUser, APackage.Repository, APackage.DefaultBranch, ALicense.LicenseFile, Result));
    if LHasExternalLicense or GetGithubFileText(APackage.Author, APackage.RepositoryName, APackage.DefaultBranch, ALicense.LicenseFile, Result) then
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

function TDNGitHubPackageProvider.GetRepositoryDownloadUrl(const AName, AUser,
  ARepo, AVersion: string): string;
begin
  if SameText(CBitbucket, AName) then
    Exit(Format(CBitbucketDownloadUrl, [AUser, ARepo, AVersion]))
  else if SameText(CGithup, AName) then
    Exit(Format(CGithubDownloadUrl, [AUser, ARepo, AVersion]));
  raise EInvalidProviderSetup.Create('Unknown Provider ' + AName);
end;

function TDNGitHubPackageProvider.GetRepositoryIssueUrl(const AName, AUser,
  ARepo: string): string;
begin
  Result := '';
  if SameText(AName, CBitbucket) then
    Result := Format(CBitbucketIssueUrl, [AUser, ARepo])
  else if SameText(AName, CGithup) then
    Result := Format(CGithubIssueUrl, [AUser, ARepo]);
end;

function TDNGitHubPackageProvider.GetProjectUrl(const AName, AUser,
  ARepo: string): string;
begin
  if SameText(AName, CBitbucket) then
    Result := Format(CBitbucketProjectUrl, [AUser, ARepo])
  else if SameText(AName, CGithup) then
    Result := Format(CGithup, [AUser, ARepo])
  else
    Result := '';
end;

function TDNGitHubPackageProvider.GetPushDateFile: string;
begin
  Result := TPath.Combine(GetDelphinusTempFolder(), CPushDates);
end;

function TDNGitHubPackageProvider.GetReleaseText(const AAuthor,
  ARepository: string; out AReleases: string): Boolean;
begin
  Result := FClient.GetText(Format(CGithubRepoReleases, [AAuthor, ARepository]), AReleases) = HTTPErrorOk;
  if not Result then
    CheckRateLimit();
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

function TDNGitHubPackageProvider.Reload: Boolean;
var
  LRepo: TJSONObject;
  LRepos: TJSONArray;
  i: Integer;
begin
  Result := False;
  try
    (FState as TDNGithubPackageProviderState).Reset();
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
      (FState as TDNGithubPackageProviderState).SetError(E.Message)
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
