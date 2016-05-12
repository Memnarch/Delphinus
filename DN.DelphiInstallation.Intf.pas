unit DN.DelphiInstallation.Intf;

interface

uses
  Graphics,
  DN.Compiler.Intf;

type
  IDNDelphiInstallation = interface
    ['{B460C736-86F8-49DE-AD72-53BB6D8D71D6}']
    function GetIcon: TIcon;
    function GetName: string;
    function GetShortName: string;
    function GetRoot: string;
    function GetDirectory: string;
    function GetApplication: string;
    function GetEdition: string;
    function GetBDSVersion: string;
    function GetBDSCommonDir: string;
    function GetSupportedPlatforms: TDNCompilerPlatforms;

    function IsRunning: Boolean;
    property Name: string read GetName;
    property ShortName: string read GetShortName;
    property Edition: string read GetEdition;
    property BDSVersion: string read GetBDSVersion;
    property Icon: TIcon read GetIcon;
    property Root: string read GetRoot;
    property Directory: string read GetDirectory;
    property Application: string read GetApplication;
    property BDSCommonDir: string read GetBDSCommonDir;
    property SupportedPlatforms: TDNCompilerPlatforms read GetSupportedPlatforms;
  end;

implementation

end.
