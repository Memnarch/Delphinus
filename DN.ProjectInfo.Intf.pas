unit DN.ProjectInfo.Intf;

interface

type
  IDNProjectInfo = interface
    ['{F598002A-B768-44BA-868A-A8CB8C23D4A7}']
    function GetBinaryName: string;
    function GetDCPName: string;
    function GetIsPackage: Boolean;
    function LoadFromFile(const AProjectFile: string): Boolean;
    property IsPackage: Boolean read GetIsPackage;
    property BinaryName: string read GetBinaryName;
    property DCPName: string read GetDCPName;
  end;

implementation

end.
