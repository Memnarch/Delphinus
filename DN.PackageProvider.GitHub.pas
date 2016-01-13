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
    FClient: IDNHttpClient;
    FProgress: IDNProgress;
    function DownloadVersionMeta(const APackage: IDNPackage; const AAuthor, AName, AFirstVersion: string): Boolean;
    procedure AddPackageFromJSon(AJSon: TJSONObject);
    function CreatePackageWithMetaInfo(AItem: TJSONObject; out APackage: IDNPackage): Boolean;
    procedure LoadPicture(APicture: TPicture; AAuthor, ARepository, AVersion, APictureFile: string);
    function GetInfoFile(const AAuthor, ARepository, AVersion: string; AInfo: TInfoFile): Boolean;
  protected
    function GetLicense(const APackage: TDNGitHubPackage): string;
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
  DN.Progress;

const
  CGithubRaw = 'https://raw.githubusercontent.com/';
  CGithubRawReferencedFile = CGithubRaw + '%s/%s/%s/%s';//User/Repo/Reference/Filename
  CGitRepoSearch = 'https://api.github.com/search/repositories?q="Delphinus-Support"+in:readme&per_page=100';
  CGithubRepoReleases = 'https://api.github.com/repos/%s/%s/releases';// user/repo/releases
//  CGitRepoSearch = 'https://api.github.com/search/repositories?q=tetris&per_page=30';
  CJpg_Package = 'Jpg_Package';

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
begin
  inherited Create();
  FClient := AClient;
  FProgress := TDNProgress.Create();
end;

function TDNGitHubPackageProvider.CreatePackageWithMetaInfo(AItem: TJSONObject;
  out APackage: IDNPackage): Boolean;
var
  LPackage: TDNGitHubPackage;
  LName, LAuthor, LDefaultBranch: string;
  LHeadInfo: TInfoFile;
  LHomePage: TJSONValue;
const
  CArchivePlaceholder = '{archive_format}{/ref}';
begin
  Result := False;
  LName := AItem.GetValue('name').Value;
  LAuthor := TJSonObject(AItem.GetValue('owner')).GetValue('login').Value;
  LDefaultBranch := AItem.GetValue('default_branch').Value;
  LHeadInfo := TInfoFile.Create();
  try
    if GetInfoFile(LAuthor, LName, LDefaultBranch, LHeadInfo) then
    begin
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
      DownloadVersionMeta(APackage, LAuthor, LName, LHeadInfo.FirstVersion);
      Result := True;
    end;
  finally
    LHeadInfo.Free;
  end;
end;

destructor TDNGitHubPackageProvider.Destroy;
begin
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
  Result := FClient.Download(APackage.DownloadLoaction + IfThen(AVersion <> '', AVersion, (APackage as TDNGitHubPackage).DefaultBranch), LArchiveFile) = HTTPErrorOk;

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

function TDNGitHubPackageProvider.DownloadVersionMeta(
  const APackage: IDNPackage; const AAuthor, AName,
  AFirstVersion: string): Boolean;
var
  LArray: TJSONArray;
  LObject: TJSonObject;
  i: Integer;
  LVersionName: string;
  LInfo: TInfoFile;
  LReleaseResponse: string;
  LVersion: IDNPackageVersion;
begin
  Result := False;
  LInfo := TInfoFile.Create();
  try
    if FClient.GetText(Format(CGithubRepoReleases, [AAuthor, AName]), LReleaseResponse) = HTTPErrorOk then
    begin
      LArray := TJSOnObject.ParseJSONValue(LReleaseResponse) as TJSONArray;
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
    end;
  finally
    LInfo.Free;
  end;
end;

function TDNGitHubPackageProvider.GetInfoFile(const AAuthor, ARepository,
  AVersion: string; AInfo: TInfoFile): Boolean;
var
  LResponse: string;
begin
  Result := (FClient.GetText(CGithubRaw + AAuthor + '/' + ARepository + '/' + AVersion + '/' + CInfoFile, LResponse) = HTTPErrorOk)
    and AInfo.LoadFromString(LResponse);
end;

function TDNGitHubPackageProvider.GetLicense(
  const APackage: TDNGitHubPackage): string;
begin
  Result := '';
  if (APackage.LicenseType <> '') then
  begin
    if FClient.GetText(Format(CGithubRawReferencedFile, [APackage.Author, APackage.RepositoryName, APackage.DefaultBranch, APackage.LicenseFile]), Result) = HTTPErrorOk then
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

procedure TDNGitHubPackageProvider.LoadPicture(APicture: TPicture; AAuthor, ARepository, AVersion, APictureFile: string);
var
  LGraphic: TGraphic;
  LResStream: TResourceStream;
  LIsValid: Boolean;
  LPicStream: TMemoryStream;
  LPictureFile: string;
begin
  LIsValid := False;
  LGraphic := nil;

  LPicStream := TMemoryStream.Create();
  try
    LPictureFile := StringReplace(APictureFile, '\', '/', [rfReplaceAll]);
    if FClient.Get(Format(CGithubRawReferencedFile, [AAuthor, ARepository, AVersion, LPictureFile]), LPicStream) = HTTPErrorOk then
    begin
      case AnsiIndexText(ExtractFileExt(APictureFile), ['.png', '.jpg', '.jpeg']) of
        0: LGraphic := TPngImage.Create();
        1, 2: LGraphic := TJPEGImage.Create();
      end;

      if Assigned(LGraphic) then
      begin
        try
          LPicStream.Position := 0;
          LGraphic.LoadFromStream(LPicStream);
          LIsValid := True;
        except
          on E: EInvalidGraphic do
            FreeAndNil(LGraphic);
        end;
      end;
    end;  
  finally
    LPicStream.Free;
  end;

  if not LIsValid then
  begin
    LResStream := TResourceStream.Create(HInstance, CJpg_Package, RT_RCDATA);
    try
      LGraphic := TJPEGImage.Create();
      LGraphic.LoadFromStream(LResStream);
    finally
      LResStream.Free;
    end;
  end;

  APicture.Assign(LGraphic);

  if Assigned(LGraphic) then
    LGraphic.Free;
end;

function TDNGitHubPackageProvider.Reload: Boolean;
var
  LRoot: TJSONObject;
  LItems: TJSONArray;
  i: Integer;
  LSearchResponse: string;
begin
  Result := False;
  if FClient.GetText(CGitRepoSearch, LSearchResponse) = HTTPErrorOk then
  begin
    Packages.Clear();
    LRoot := TJSONObject.ParseJSONValue(LSearchResponse)as TJSONObject;
    try
      LItems := LRoot.GetValue('items') as TJSONArray;
      for i := 0 to LItems.Count - 1 do
      begin
        AddPackageFromJSon(LItems.Items[i] as TJSONObject);
      end;
    finally
      LRoot.Free;
    end;
    Result := True;
  end;
end;

end.
