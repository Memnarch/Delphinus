unit Delphinus.WebSetup;

interface

uses
  DN.Installer.Intf,
  DN.Uninstaller.Intf,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  DN.Setup;

type
  TDNDelphinusWebSetup = class(TDNSetup)
  private
    FRootKey: string;
    FSubDir: string;
  protected
    function GetInstallDirectoryForPackage(const APackage: IDNPackage): string;
      override;
    function GetInstallDirectoryForDirectory(const ADirectory: string): string;
      override;
  public
    constructor Create(const AInstaller: IDNInstaller; const AUninstaller: IDNUninstaller;
      const APackageProvider: IDNPackageProvider; const ARootKey: string); reintroduce;
  end;

implementation

uses
  SysUtils,
  IOUtils;

{ TDNDelphinusWebSetup }

constructor TDNDelphinusWebSetup.Create(const AInstaller: IDNInstaller;
  const AUninstaller: IDNUninstaller;
  const APackageProvider: IDNPackageProvider; const ARootKey: string);
begin
  inherited Create(AInstaller, AUninstaller, APackageProvider);
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

end.
