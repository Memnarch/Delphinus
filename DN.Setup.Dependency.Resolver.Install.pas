unit DN.Setup.Dependency.Resolver.Install;

interface

uses
  SysUtils,
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Setup.Dependency.Intf,
  DN.Setup.Dependency.Resolver.Intf,
  DN.Package.Finder.Intf,
  DN.Version,
  Generics.Collections;

type
  TDNSetupInstallDependencyResolver = class(TInterfacedObject, IDNSetupDependencyResolver)
  private
    FInstalledFinderFactory: TFunc<IDNPackageFinder>;
    FOnlineFinderFactory: TFunc<IDNPackageFinder>;
    FInstalledFinder: IDNPackageFinder;
    FOnlineFinder: IDNPackageFinder;
    function InstalledFinder: IDNPackageFinder;
    function OnlineFinder: IDNPackageFinder;
    function TryFindAvailable(const AID: string; ARequiredVersion: TDNVersion; out APackage: IDNPackage): Boolean;
    function TryFindInstalled(const AID: string; out APackage: IDNPackage): Boolean;
    function TryFindVersion(const APackage: IDNPackage; const ARequiredVersion: TDNVersion; out AVersion: IDNPackageVersion): Boolean;
    procedure EvaluateAction(const ADependency: IDNSetupDependency);
    procedure InternalResolve(const APackage: IDNPackage; const AVersion: IDNPackageVersion; ATarget: TList<IDNSetupDependency>; AProcessed: TDictionary<string, IDNSetupDependency>);
  public
    constructor Create(const AInstalledFinderFactory, AOnlineFinderFactory: TFunc<IDNPackageFinder>);
    function Resolve(const APackage: IDNPackage; const AVersion: IDNPackageVersion): TArray<IDNSetupDependency>;
  end;

implementation

uses
  DN.Setup.Dependency,
  DN.Package.Dependency.Intf;

{ TDNSetupDependencyResolver }

constructor TDNSetupInstallDependencyResolver.Create(const AInstalledFinderFactory,
  AOnlineFinderFactory: TFunc<IDNPackageFinder>);
begin
  inherited Create();
  FInstalledFinderFactory := AInstalledFinderFactory;
  FOnlineFinderFactory := AOnlineFinderFactory;
end;

procedure TDNSetupInstallDependencyResolver.EvaluateAction(
  const ADependency: IDNSetupDependency);
begin
  if Assigned(ADependency) and Assigned(ADependency.Version) then
  begin
    if Assigned(ADependency.InstalledVersion) then
    begin
      if ADependency.InstalledVersion.Value < ADependency.Version.Value then
        ADependency.Action := daUpdate;
    end
    else
      ADependency.Action := daInstall;
  end;
end;

function TDNSetupInstallDependencyResolver.InstalledFinder: IDNPackageFinder;
begin
  if not Assigned(FInstalledFinder) then
    FInstalledFinder := FInstalledFinderFactory();
  Result := FInstalledFinder;
end;

procedure TDNSetupInstallDependencyResolver.InternalResolve(
  const APackage: IDNPackage; const AVersion: IDNPackageVersion;
  ATarget: TList<IDNSetupDependency>;
  AProcessed: TDictionary<string, IDNSetupDependency>);
var
  LDependency: IDNSetupDependency;
  LPackageDependency: IDNPackageDependency;
  LPackage: IDNPackage;
  LVersion: IDNPackageVersion;
begin
  for LPackageDependency in AVersion.Dependencies do
  begin
    if AProcessed.ContainsKey(LPackageDependency.ID.ToString) then
      Continue;

    LDependency := TDNSetupDependency.Create();
    LDependency.ID := LPackageDependency.ID;
    if TryFindAvailable(LPackageDependency.ID.ToString, LPackageDependency.Version, LPackage) then
    begin
      LDependency.Package := LPackage;
      if TryFindVersion(LPackage, LPackageDependency.Version, LVersion) then
        LDependency.Version := LVersion;
    end;
    if TryFindInstalled(LPackageDependency.ID.ToString, LPackage) then
    begin
      if not Assigned(LDependency.Package) then
        LDependency.Package := LPackage;
      LDependency.InstalledVersion := LPackage.Versions.First;
    end;
    EvaluateAction(LDependency);
    AProcessed.Add(LDependency.ID.ToString, LDependency);
    if Assigned(LDependency.Package) and Assigned(LDependency.Version) then
      InternalResolve(LDependency.Package, LDependency.Version, ATarget, AProcessed);
    ATarget.Add(LDependency);
  end;
end;

function TDNSetupInstallDependencyResolver.OnlineFinder: IDNPackageFinder;
begin
  if not Assigned(FOnlineFinder) then
    FOnlineFinder := FOnlineFinderFactory();
  Result := FOnlineFinder;
end;

function TDNSetupInstallDependencyResolver.Resolve(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion): TArray<IDNSetupDependency>;
var
  LResult: TList<IDNSetupDependency>;
  LProcessed: TDictionary<string, IDNSetupDependency>;
begin
  LResult := TList<IDNSetupDependency>.Create();
  LProcessed := TDictionary<string, IDNSetupDependency>.Create();
  try
    InternalResolve(APackage, AVersion, LResult, LProcessed);
    Result := LResult.ToArray();
  finally
    LProcessed.Free;
    LResult.Free;
  end;
end;

function TDNSetupInstallDependencyResolver.TryFindAvailable(const AID: string;
  ARequiredVersion: TDNVersion;
  out APackage: IDNPackage): Boolean;
var
  LVersion: IDNPackageVersion;
begin
  Result := InstalledFinder.TryFind(AID, APackage);
  if not (Result and TryFindVersion(APackage, ARequiredVersion, LVersion)) then
    Result := OnlineFinder.TryFind(AID, APackage);
end;

function TDNSetupInstallDependencyResolver.TryFindInstalled(const AID: string;
  out APackage: IDNPackage): Boolean;
begin
  Result := InstalledFinder.TryFind(AID, APackage);
end;

function TDNSetupInstallDependencyResolver.TryFindVersion(const APackage: IDNPackage;
  const ARequiredVersion: TDNVersion; out AVersion: IDNPackageVersion): Boolean;
var
  LVersion: IDNPackageVersion;
begin
  for LVersion in APackage.Versions do
  begin
    if LVersion.Value = ARequiredVersion then
    begin
      AVersion := LVersion;
      Exit(True);
    end;
  end;
  Result := False;
end;

end.
