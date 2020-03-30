unit DN.Project.Dependency.Intf;

interface

uses
  DN.Package.Dependency.Intf;

type
  IDNProjectPackageDependency = interface(IDNPackageDependency)
    ['{0B8204CE-13F9-4C9C-9673-20E3C1E6F4E3}']
    function GetName: string;
    property Name: string read GetName;
  end;

implementation

end.
