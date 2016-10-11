unit DN.Package.Version.Finder.Intf;

interface

uses
  DN.Package.Intf,
  DN.Package.Version.Intf;

type
  IDNVersionFinder = interface
    ['{335D4E10-74CD-4A02-A030-070B85F32E92}']
    function TryFind(const APackage: IDNPackage; const AVersion: string; out APackageVersion: IDNPackageVersion): Boolean;
    function Find(const APackage: IDNPackage; const AVersion: string): IDNPackageVersion;
  end;

implementation

end.
