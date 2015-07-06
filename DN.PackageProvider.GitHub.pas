unit DN.PackageProvider.GitHub;

interface

uses
  Classes,
  Types,
  SysUtils,
  IdHttp,
  Generics.Collections,
  DN.Package.Intf,
  DN.PackageProvider;

type
  TDNGitHubPackageProvider = class(TDNPackageProvider)
  private
    FRequest: TIdHTTP;
    FLastContentDisposition: string;
    function ExecuteRequest(const ATarget: TStream; const ARequest: string): Boolean;
    procedure LoadPackageInfo(const APackage: IDNPackage; const ABranch: string; AData: TStringStream);
  public
    constructor Create();
    destructor Destroy(); override;
    function Reload(): Boolean; override;
    function Download(const APackage: IDNPackage; const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean; override;
    function LoadVersions(const APackage: IDNPackage): TStringDynArray;
  end;

implementation

uses
  IOUtils,
  StrUtils,
  DN.Package,
  DN.Package.Github,
  IdIOHandlerStack,
  IdSSLOpenSSl,
  DBXJSon,
  JSon,
  JPeg,
  DN.Zip,
  DN.JSOnFile.Info;

const
  CGithubRaw = 'https://raw.githubusercontent.com/';
  CGitRepoSearch = 'https://api.github.com/search/repositories?q="Delphinus-Support"+in:readme&per_page=100';
  CGithubRepoReleases = 'https://api.github.com/repos/%s/%s/releases';// user/repo/releases
//  CGitRepoSearch = 'https://api.github.com/search/repositories?q=tetris&per_page=30';

{ TDCPMPackageProvider }

constructor TDNGitHubPackageProvider.Create;
begin
  inherited;
  FRequest := TIdHTTP.Create(nil);
  FRequest.HTTPOptions := FRequest.HTTPOptions + [hoNoProtocolErrorException];
  FRequest.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FRequest);
end;

destructor TDNGitHubPackageProvider.Destroy;
begin
  FRequest.Free;
  inherited;
end;

function TDNGitHubPackageProvider.Download(const APackage: IDNPackage; const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean;
var
  LArchive: TFileStream;
  LArchiveFile, LFileName: string;
  LDirs: TStringDynArray;
const
  CNamePrefix = 'filename=';
begin
  LArchiveFile := TPath.Combine(AFolder, 'Package.zip');
  LArchive := TFileStream.Create(LArchiveFile, fmCreate or fmOpenReadWrite);
  try
    Result := ExecuteRequest(LArchive, APackage.DownloadLoaction + IfThen(AVersion <> '', AVersion, (APackage as TDNGitHubPackage).DefaultBranch));
  finally
    LArchive.Free;
  end;
  LFileName := Copy(FLastContentDisposition, Pos(CNamePrefix, FLastContentDisposition) + Length(CNamePrefix), Length(FLastContentDisposition));
//  AContentFolder := TPath.Combine(AFolder, ChangeFileExt(StringReplace(LFileName, AVersion, '', []), ''));
  if Result then
    Result := ShellUnzip(LArchiveFile, AFolder);

  if Result then
  begin
    LDirs := TDirectory.GetDirectories(AFolder);
    Result := Length(LDirs) = 1;
    if Result then
      AContentFolder := LDirs[0];
  end;
  TFile.Delete(LArchiveFile);
end;

function TDNGitHubPackageProvider.ExecuteRequest(const ATarget: TStream; const ARequest: string): Boolean;
begin
  FRequest.Get(ARequest, ATarget);
  while FRequest.ResponseCode = 302 do//redirect
  begin
    FRequest.Get(FRequest.Response.Location, ATarget);
  end;
  Result := FRequest.ResponseCode = 200;//ok
  FLastContentDisposition := FRequest.Response.ContentDisposition;
end;

procedure TDNGitHubPackageProvider.LoadPackageInfo(const APackage: IDNPackage;
  const ABranch: string; AData: TStringStream);
var
  LInfo: TInfoFile;
  LPicture: TMemoryStream;
  LJPG: TJPEGImage;
begin
  LInfo := TInfoFile.Create();
  LPicture := TMemoryStream.Create();
  try
    LInfo.LoadFromString(AData.DataString);
    APackage.ID := LInfo.ID;
    APackage.CompilerMin := LInfo.CompilerMin;
    APackage.CompilerMax := LInfo.CompilerMax;
    if (LInfo.Picture <> '') and ExecuteRequest(LPicture, CGithubRaw + APackage.Author + '/' + APackage.Name + '/' + ABranch + '/' + LInfo.Picture) then
    begin
      LJPG := TJPEGImage.Create();
      try
        LPicture.Position := 0;
        LJPG.LoadFromStream(LPicture);
        APackage.Picture.Graphic := LJPG;
      finally
        LJPG.Free;
      end;
    end;
  finally
    LInfo.Free;
    LPicture.Free;
  end;
end;

function TDNGitHubPackageProvider.LoadVersions(
  const APackage: IDNPackage): TStringDynArray;
var
  LData: TStringStream;
  LRoot: TJSONArray;
  i: Integer;
begin
  LData := TStringStream.Create();
  try
    if ExecuteRequest(LData, Format(CGithubRepoReleases, [APackage.Author, APackage.Name])) then
    begin
      LRoot := TJSONObject.ParseJSONValue(LData.DataString) as TJSONArray;
      SetLength(Result, LRoot.Count);
      for i := 0 to LRoot.Count - 1 do
      begin
        Result[i] := TJSONObject(LRoot.Items[i]).GetValue('tag_name').Value;
      end;
    end;
  finally
    LData.Free;
  end;
end;

function TDNGitHubPackageProvider.Reload: Boolean;
var
  LData, LInfoData: TStringStream;
  LText: string;
  LRoot: TJSONObject;
  LItems: TJSONArray;
  i: Integer;
  LItem: TJSonObject;
  LPackage: TDNGitHubPackage;
  LInfoLocation: string;
const
  CArchivePlaceholder = '{archive_format}{/ref}';
begin
  Result := False;
  LData := TStringStream.Create();
  try
    if ExecuteRequest(LData, CGitRepoSearch) then
    begin
      Packages.Clear();
      LText := LData.DataString;
      LRoot := TJSONObject.ParseJSONValue(LText)as TJSONObject;
      try
        LItems := LRoot.GetValue('items') as TJSONArray;
        for i := 0 to LItems.Count - 1 do
        begin
          LItem := LItems.Items[i] as TJSonObject;
          LPackage := TDNGitHubPackage.Create(Self);
          LInfoData := TStringStream.Create();
          try
            LPackage.Name := LItem.GetValue('name').Value;
            LPackage.Description := LItem.GetValue('description').Value;
            LPackage.Author := TJSonObject(LItem.GetValue('owner')).GetValue('login').Value;
            LPackage.LastUpdated := LItem.GetValue('pushed_at').Value;
            LPackage.DownloadLoaction := LItem.GetValue('archive_url').Value;
            LPackage.DownloadLoaction := StringReplace(LPackage.DownloadLoaction, CArchivePlaceholder, 'zipball/', []);
            LPackage.DefaultBranch := LItem.GetValue('default_branch').Value;
            LInfoLocation := CGithubRaw + LItem.GetValue('full_name').Value + '/' + LItem.GetValue('default_branch').Value + '/info.json';
            if ExecuteRequest(LInfoData, LInfoLocation) then
            begin
              LoadPackageInfo(LPackage, LItem.GetValue('default_branch').Value, LInfoData);
            end;
          finally
            if LPackage.ID <> TGUID.Empty then
              Packages.Add(LPackage);
            LInfoData.Free;
          end;
        end;
      finally
        LRoot.Free;
      end;
      Result := True;
    end;
  finally
    LData.Free;
  end;
end;

end.
