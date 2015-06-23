unit DN.PackageProvider.Installed;

interface

uses
  Classes,
  Types,
  SysUtils,
  DN.PackageProvider,
  DN.Package.Intf;

type
  TDNInstalledPackageProvider = class(TDNPackageProvider)
  private
    FComponentDirectory: string;
    procedure LoadDetails(const APackage: IDNPackage; const AInfoFile: string);
  public
    constructor Create(const AComponentDirectory: string);
    function Reload: Boolean; override;
  end;

implementation

uses
  IOUtils,
  DBXJSon,
  JSon,
  DN.Package,
  DN.Uninstaller.Intf,
  JPeg;

{ TDNInstalledPackageProvider }

constructor TDNInstalledPackageProvider.Create(
  const AComponentDirectory: string);
begin
  inherited Create();
  FComponentDirectory := AComponentDirectory;
end;

procedure TDNInstalledPackageProvider.LoadDetails(const APackage: IDNPackage;
  const AInfoFile: string);
var
  LJPG: TJPEGImage;
  LImageFile: string;
  LInfo: TJSONObject;
  LValue: TJSONValue;
  LData: TStringStream;
begin
  if TFile.Exists(AInfoFile) then
  begin
    LData := TStringStream.Create();
    try
      LData.LoadFromFile(AInfoFile);
      LInfo := TJSONObject.ParseJSONValue(LData.DataString) as TJSONObject;
      if Assigned(LInfo) then
      begin
        try
          LValue := LInfo.GetValue('author');
          if Assigned(LValue) then
            APackage.Author := LValue.Value;

          LValue := LInfo.GetValue('picture');
          if Assigned(LValue) then
          begin
            LImageFile := TPath.Combine(ExtractFilePath(AInfoFile), LValue.Value);
            if TFile.Exists(LImageFile) then
            begin
              LJPG := TJPEGImage.Create();
              try
                LJPG.LoadFromFile(LImageFile);
                APackage.Picture.Graphic := LJPG;
              finally
                LJPG.Free;
              end;
            end;
          end;
        finally
          LInfo.Free;
        end;
      end;
    finally
      LData.Free();
    end;
  end;
end;

function TDNInstalledPackageProvider.Reload: Boolean;
var
  LDirectories: TStringDynArray;
  LDirectory: string;
  LPackage: IDNPackage;
begin
  Result := False;
  if TDirectory.Exists(FComponentDirectory) then
  begin
    Packages.Clear();
    LDirectories := TDirectory.GetDirectories(FComponentDirectory);
    for LDirectory in LDirectories do
    begin
      if TFile.Exists(TPath.Combine(LDirectory, CUninstallFile)) then
      begin
        LPackage := TDNPackage.Create();
        LPackage.Name := ExtractFileName(LDirectory);
        LoadDetails(LPackage, TPath.Combine(LDirectory, 'info.json'));
        Packages.Add(LPackage);
      end;
    end;
    Result := True;
  end;
end;

end.
