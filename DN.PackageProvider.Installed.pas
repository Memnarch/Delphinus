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
  DN.Package,
  DN.Uninstaller.Intf,
  DN.JSonFile.InstalledInfo,
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
  LInfo: TInstalledInfoFile;
  LVersions: TStringDynArray;
begin
  if TFile.Exists(AInfoFile) then
  begin
    LInfo := TInstalledInfoFile.Create();
    try
      if LInfo.LoadFromFile(AInfoFile) then
      begin
        APackage.Author := LInfo.Author;
        APackage.Description := LInfo.Description;
        APackage.ID := LInfo.ID;
        APackage.CompilerMin := LInfo.CompilerMin;
        Apackage.CompilerMax := LInfo.CompilerMax;
        SetLength(LVersions, 1);
        if LInfo.Version <> '' then
          LVersions[0] := LInfo.Version
        else
          LVersions[0] := 'unknown';
        APackage.Versions := LVersions;
        if LInfo.Picture <> '' then
        begin
          LImageFile := TPath.Combine(ExtractFilePath(AInfoFile), LInfo.Picture);
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
      end;
    finally
      LInfo.Free;
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
