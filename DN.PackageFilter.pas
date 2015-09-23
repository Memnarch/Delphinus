unit DN.PackageFilter;

interface

uses
  DN.Package.Intf;

type
  TPackageFilter = procedure(const APackage: IDNPackage; var AAccepted: Boolean) of object;

implementation

end.
