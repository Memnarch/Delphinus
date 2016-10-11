unit DN.Package.Finder.Intf;

interface

uses
  DN.Package.Intf;

type
  IDNPackageFinder = interface
    ['{9DDA3852-0F63-441A-8DB8-A3F92C96E317}']
    function TryFind(const ANameOrID: string; out APackage: IDNPackage): Boolean;
    function Find(const ANameOrID: string): IDNPackage;
  end;

implementation

end.
