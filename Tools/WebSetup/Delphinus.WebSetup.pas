unit Delphinus.WebSetup;

interface

uses
  DN.Installer.Intf,
  DN.Uninstaller.Intf,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Settings.Intf,
  DN.Setup;

type
  TDNDelphinusWebSetup = class(TDNSetup)
  private
    FRootKey: string;
    FSubDir: string;
    FSettings: IDNElevatedSettings;
  protected
    function GetInstallDirectoryForPackage(const APackage: IDNPackage): string;
      override;
    function GetInstallDirectoryForDirectory(const ADirectory: string): string;
      override;
  public
    constructor Create(const AInstaller: IDNInstaller; const AUninstaller: IDNUninstaller;
      const APackageProvider: IDNPackageProvider; const ASettings: IDNElevatedSettings;
      const ARootKey: string); reintroduce;
    function Install(const APackage: IDNPackage;
      const AVersion: IDNPackageVersion): Boolean; override;
    function Uninstall(const APackage: IDNPackage): Boolean; override;
  end;

implementation

uses
  SysUtils,
  IOUtils;

{ TDNDelphinusWebSetup }

constructor TDNDelphinusWebSetup.Create(const AInstaller: IDNInstaller;
  const AUninstaller: IDNUninstaller;
  const APackageProvider: IDNPackageProvider; const ASettings: IDNElevatedSettings;
  const ARootKey: string);
begin
  inherited Create(AInstaller, AUninstaller, APackageProvider);
  FSettings := ASettings;
  FRootKey := ARootKey;
  FSubDir := ExtractFileName(ExcludeTrailingPathDelimiter(FRootKey));
end;

function TDNDelphinusWebSetup.GetInstallDirectoryForDirectory(
  const ADirectory: string): string;
begin
  Result := TPath.Combine(ComponentDirectory, FSubDir);
end;

function TDNDelphinusWebSetup.GetInstallDirectoryForPackage(
  const APackage: IDNPackage): string;
begin
  Result := TPath.Combine(ComponentDirectory, FSubDir);
end;

function TDNDelphinusWebSetup.Install(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion): Boolean;
begin
  Result := inherited;
  if Result then
    FSettings.InstallationDirectory := ComponentDirectory;
end;

function TDNDelphinusWebSetup.Uninstall(const APackage: IDNPackage): Boolean;
begin
  Result := inherited;
  if Result and TDirectory.IsEmpty(FSettings.InstallationDirectory) then
  begin
    TDirectory.Delete(FSettings.InstallationDirectory);
    FSettings.Clear();
  end;
end;

end.
