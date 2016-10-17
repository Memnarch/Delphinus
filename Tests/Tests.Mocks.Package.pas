unit Tests.Mocks.Package;

interface

uses
  DN.Types,
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Version;

function NewPackage(AID: TGUID): IDNPackage; overload;
function NewPackage(AID: TGUID; AVersion: string): IDNPackage; overload;
procedure AddDependency(const AVersion: IDNPackageVersion; AID: TGUID; ADepVersion: string);

implementation

uses
  DN.Package,
  DN.Package.Version,
  DN.Package.Dependency.Intf,
  DN.Package.Dependency;

function NewPackage(AID: TGUID): IDNPackage;
begin
  Result := TDNPackage.Create();
  Result.ID := AID;
  Result.Versions.Add(TDNPackageVersion.Create() as IDNPackageVersion);
end;

function NewPackage(AID: TGUID; AVersion: string): IDNPackage; overload;
begin
  Result := NewPackage(AID);
  Result.Versions.First.Value := TDNVersion.Parse(AVersion);
end;

procedure AddDependency(const AVersion: IDNPackageVersion; AID: TGUID; ADepVersion: string);
var
  LDependency: TDNPackageDependency;
begin
  LDependency := TDNPackageDependency.Create(AID, TDNVersion.Parse(ADepVersion));
  AVersion.Dependencies.Add(LDependency);
end;

end.
