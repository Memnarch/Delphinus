unit DN.DelphiInstallation.Intf;

interface

uses
  Graphics;

type
  IDNDelphiInstallation = interface
    ['{B460C736-86F8-49DE-AD72-53BB6D8D71D6}']
    function GetIcon: TIcon;
    function GetName: string;
    function GetRoot: string;
    function GetDirectory: string;
    function GetApplication: string;
    function GetEdition: string;

    property Name: string read GetName;
    property Edition: string read GetEdition;
    property Icon: TIcon read GetIcon;
    property Root: string read GetRoot;
    property Directory: string read GetDirectory;
    property Application: string read GetApplication;
  end;

implementation

end.
