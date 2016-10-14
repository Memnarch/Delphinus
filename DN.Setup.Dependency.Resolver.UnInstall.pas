unit DN.Setup.Dependency.Resolver.UnInstall;

interface

uses
  SysUtils,
  DN.Setup.Dependency.Intf,
  DN.Setup.Dependency.Resolver.Intf,
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Package.Dependency.Intf;

type
  TDNSetupUninstallDependencyResolver = class(TInterfacedObject, IDNSetupDependencyResolver)
  private
    FGetInstalledPackages: TFunc<TArray<IDNPackage>>;
    function PackageRequires(const APackage: IDNPackage; const ARequiredID: TGUID): Boolean;
  public
    constructor Create(const AGetInstalledPackages: TFunc<TArray<IDNPackage>>);
    function Resolver(const APackage: IDNPackage; const AVersion: IDNPackageVersion): TArray<IDNSetupDependency>;
  end;

implementation

uses
  Generics.Collections,
  DN.Setup.Dependency;

{ TDNSetupUninstallDependencyResolver }

constructor TDNSetupUninstallDependencyResolver.Create(
  const AGetInstalledPackages: TFunc<TArray<IDNPackage>>);
begin
  inherited Create();
  FGetInstalledPackages := AGetInstalledPackages;
end;

function TDNSetupUninstallDependencyResolver.PackageRequires(
  const APackage: IDNPackage; const ARequiredID: TGUID): Boolean;
var
  LDependency: IDNPackageDependency;
begin
  for LDependency in APackage.Versions.First.Dependencies do
    if LDependency.ID = ARequiredID then
      Exit(True);
  Result := False;
end;

function TDNSetupUninstallDependencyResolver.Resolver(
  const APackage: IDNPackage;
  const AVersion: IDNPackageVersion): TArray<IDNSetupDependency>;
var
  LSetupDependency: IDNSetupDependency;
  LPackage: IDNPackage;
  LItems: TList<IDNSetupDependency>;
begin
  LItems := TList<IDNSetupDependency>.Create();
  try
    for LPackage in FGetInstalledPackages do
    begin
      if PackageRequires(LPackage, APackage.ID) then
      begin
        LSetupDependency := TDNSetupDependency.Create();
        LSetupDependency.ID := LPackage.ID;
        LSetupDependency.Package := LPackage;
        LSetupDependency.Action := daUninstall;
        LItems.Add(LSetupDependency);
      end;
    end;
    Result := LItems.ToArray;
  finally
    LItems.Free;
  end;
end;

end.
