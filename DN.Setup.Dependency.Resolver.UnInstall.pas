unit DN.Setup.Dependency.Resolver.UnInstall;

interface

uses
  SysUtils,
  Generics.Collections,
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
    procedure InternalResolve(const APackage: IDNPackage; ATarget: TList<IDNSetupDependency>; AProcessed: TDictionary<string, IDNSetupDependency>);
  public
    constructor Create(const AGetInstalledPackages: TFunc<TArray<IDNPackage>>);
    function Resolve(const APackage: IDNPackage; const AVersion: IDNPackageVersion): TArray<IDNSetupDependency>;
  end;

implementation

uses
  DN.Setup.Dependency;

{ TDNSetupUninstallDependencyResolver }

constructor TDNSetupUninstallDependencyResolver.Create(
  const AGetInstalledPackages: TFunc<TArray<IDNPackage>>);
begin
  inherited Create();
  FGetInstalledPackages := AGetInstalledPackages;
end;

procedure TDNSetupUninstallDependencyResolver.InternalResolve(
  const APackage: IDNPackage; ATarget: TList<IDNSetupDependency>;
  AProcessed: TDictionary<string, IDNSetupDependency>);
var
  LSetupDependency: IDNSetupDependency;
  LPackage: IDNPackage;
begin
  for LPackage in FGetInstalledPackages do
  begin
    if not AProcessed.ContainsKey(LPackage.ID.ToString) and PackageRequires(LPackage, APackage.ID) then
    begin
      LSetupDependency := TDNSetupDependency.Create();
      LSetupDependency.ID := LPackage.ID;
      LSetupDependency.Package := LPackage;
      LSetupDependency.InstalledVersion := LPackage.Versions.First;
      LSetupDependency.Action := daUninstall;
      AProcessed.Add(LPackage.ID.ToString, LSetupDependency);
      InternalResolve(LPackage, ATarget, AProcessed);
      ATarget.Add(LSetupDependency);
    end;
  end;
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

function TDNSetupUninstallDependencyResolver.Resolve(
  const APackage: IDNPackage;
  const AVersion: IDNPackageVersion): TArray<IDNSetupDependency>;
var
  LItems: TList<IDNSetupDependency>;
  LProcessed: TDictionary<string, IDNSetupDependency>;
begin
  LItems := TList<IDNSetupDependency>.Create();
  LProcessed := TDictionary<string, IDNSetupDependency>.Create();
  try
    InternalResolve(APackage, LItems, LProcessed);
    Result := LItems.ToArray;
  finally
    LItems.Free;
    LProcessed.Free;
  end;
end;

end.
