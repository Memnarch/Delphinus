unit DN.Setup.Dependency.Resolver.Intf;

interface

uses
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Setup.Dependency.Intf;

type
  IDNSetupDependencyResolver = interface
    ['{EFCBFDA4-6A78-43EE-B481-05D56DC4590B}']
    function Resolver(const APackage: IDNPackage; const AVersion: IDNPackageVersion): TArray<IDNSetupDependency>;
  end;

implementation

end.
