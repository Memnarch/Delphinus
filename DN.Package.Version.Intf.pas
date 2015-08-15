unit DN.Package.Version.Intf;

interface

type
  IDNPackageVersion = interface
    ['{93EA70C0-D7BD-4B9B-9886-210D62FAB05F}']
    function GetCompilerMax: Integer;
    function GetCompilerMin: Integer;
    function GetName: string;
    procedure SetCompilerMax(const Value: Integer);
    procedure SetCompilerMin(const Value: Integer);
    procedure SetName(const Value: string);
    property Name: string read GetName write SetName;
    property CompilerMin: Integer read GetCompilerMin write SetCompilerMin;
    property CompilerMax: Integer read GetCompilerMax write SetCompilerMax;
  end;

implementation

end.
