unit DN.PackageProvider.Installed;

interface

uses
  Classes,
  Types,
  SysUtils,
  DN.PackageProvider;

type
  TDNInstalledPackageProvider = class(TDNPackageProvider)
  private
    FComponentDirectory: string;
  public
    constructor Create(const AComponentDirectory: string);
    function Reload: Boolean; override;
  end;

implementation

uses
  IOUtils,
  DN.Package,
  DN.Package.Intf,
  DN.Uninstaller.Intf;

{ TDNInstalledPackageProvider }

constructor TDNInstalledPackageProvider.Create(
  const AComponentDirectory: string);
begin
  inherited Create();
  FComponentDirectory := AComponentDirectory;
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
        Packages.Add(LPackage);
      end;
    end;
    Result := True;
  end;
end;

end.
