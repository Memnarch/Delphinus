unit DN.Package.DirectoryLoader.Intf;

interface

uses
  DN.Package.Intf;

type
  IDNPackageDirectoryLoader = interface
    ['{10340735-57D8-43BA-A4EF-7CDD766AFB75}']
    function Load(const ADirectory: string; const APackage: IDNPackage): Boolean;
  end;

implementation

end.
