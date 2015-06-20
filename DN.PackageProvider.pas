unit DN.PackageProvider;

interface

uses
  Classes,
  Types,
  SysUtils,
  IdHttp,
  Generics.Collections,
  DN.Package.Intf;

type
  TDNPackageProvider = class
  private
    FPackages: TList<IDNPackage>;
    FRequest: TIdHTTP;
    FLastContentDisposition: string;
    function ExecuteRequest(const ATarget: TStream; const ARequest: string): Boolean;
    procedure LoadPackageInfo(const APackage: IDNPackage; AData: TStringStream);
    function GetPackages: TList<IDNPackage>;
  public
    constructor Create();
    destructor Destroy(); override;
    function Reload(): Boolean;
    function Download(const APackage: IDNPackage; const AFolder: string; out AContentFolder: string): Boolean;
    property Packages: TList<IDNPackage> read GetPackages;
  end;

implementation

uses
  IOUtils,
  DN.Package,
  IdIOHandlerStack,
  IdSSLOpenSSl,
  DBXJSon,
  JSon,
  JPeg,
  DN.Zip;

const
  CGithubRaw = 'https://raw.githubusercontent.com/';
  CGitRepoSearch = 'https://api.github.com/search/repositories?q="Delphinus-Support"+in:readme&per_page=100';
//  CGitRepoSearch = 'https://api.github.com/search/repositories?q=tetris&per_page=30';

{ TDCPMPackageProvider }

constructor TDNPackageProvider.Create;
begin
  inherited;
  FPackages := TList<IDNPackage>.Create();
  FRequest := TIdHTTP.Create(nil);
  FRequest.HTTPOptions := FRequest.HTTPOptions + [hoNoProtocolErrorException];
  FRequest.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FRequest);
end;

destructor TDNPackageProvider.Destroy;
begin
  FPackages.Free;
  FRequest.Free;
  inherited;
end;

function TDNPackageProvider.Download(const APackage: IDNPackage; const AFolder: string; out AContentFolder: string): Boolean;
var
  LArchive: TFileStream;
  LArchiveFile, LFileName: string;
const
  CNamePrefix = 'filename=';
begin
  LArchiveFile := TPath.Combine(AFolder, 'Package.zip');
  LArchive := TFileStream.Create(LArchiveFile, fmCreate or fmOpenReadWrite);
  try
    Result := ExecuteRequest(LArchive, APackage.DownloadLoaction);
  finally
    LArchive.Free;
  end;
  LFileName := Copy(FLastContentDisposition, Pos(CNamePrefix, FLastContentDisposition) + Length(CNamePrefix), Length(FLastContentDisposition));
  AContentFolder := TPath.Combine(AFolder, ChangeFileExt(LFileName, ''));
  if Result then
    Result := ShellUnzip(LArchiveFile, AFolder);

  TFile.Delete(LArchiveFile);
end;

function TDNPackageProvider.ExecuteRequest(const ATarget: TStream; const ARequest: string): Boolean;
begin
  FRequest.Get(ARequest, ATarget);
  while FRequest.ResponseCode = 302 do//redirect
  begin
    FRequest.Get(FRequest.Response.Location, ATarget);
  end;
  Result := FRequest.ResponseCode = 200;//ok
  FLastContentDisposition := FRequest.Response.ContentDisposition;
end;

function TDNPackageProvider.GetPackages: TList<IDNPackage>;
begin
  Result := FPackages;
end;

procedure TDNPackageProvider.LoadPackageInfo(const APackage: IDNPackage;
  AData: TStringStream);
var
  LRoot: TJSONObject;
  LPictureValue: TJSONValue;
  LPicture: TMemoryStream;
  LJPG: TJPEGImage;
begin
  LRoot := TJSONObject.ParseJSONValue(AData.DataString) as TJSONObject;
  LPicture := TMemoryStream.Create();
  try
    LPictureValue := LRoot.GetValue('picture');
    if Assigned(LPictureValue) and ExecuteRequest(LPicture, LPictureValue.Value) then
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
    LRoot.Free;
    LPicture.Free;
  end;
end;

function TDNPackageProvider.Reload: Boolean;
var
  LData, LInfoData: TStringStream;
  LText: string;
  LRoot: TJSONObject;
  LItems: TJSONArray;
  i: Integer;
  LItem: TJSonObject;
  LPackage: TDNPackage;
  LInfoLocation: string;
const
  CArchivePlaceholder = '{archive_format}{/ref}';
begin
  Result := False;
  LData := TStringStream.Create();
  try
    if ExecuteRequest(LData, CGitRepoSearch) then
    begin
      FPackages.Clear();
      LText := LData.DataString;
      LRoot := TJSONObject.ParseJSONValue(LText)as TJSONObject;
      try
        LItems := LRoot.GetValue('items') as TJSONArray;
        for i := 0 to LItems.Count - 1 do
        begin
          LItem := LItems.Items[i] as TJSonObject;
          LPackage := TDNPackage.Create();
          LInfoData := TStringStream.Create();
          try
            LPackage.Name := LItem.GetValue('name').Value;
            LPackage.Description := LItem.GetValue('description').Value;
            LPackage.Author := TJSonObject(LItem.GetValue('owner')).GetValue('login').Value;
            LPackage.LastUpdated := LItem.GetValue('pushed_at').Value;
            LPackage.DownloadLoaction := LItem.GetValue('archive_url').Value;
            LPackage.DownloadLoaction := StringReplace(LPackage.DownloadLoaction, CArchivePlaceholder, 'zipball/' + LItem.GetValue('default_branch').Value, []);
            LInfoLocation := CGithubRaw + LItem.GetValue('full_name').Value + '/' + LItem.GetValue('default_branch').Value + '/info.json';
            if ExecuteRequest(LInfoData, LInfoLocation) then
            begin
              LoadPackageInfo(LPackage, LInfoData);
            end;
          finally
            FPackages.Add(LPackage);
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
