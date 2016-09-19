unit DN.Command.Environment.Intf;

interface

uses
  DN.Command,
  DN.Package.Intf,
  DN.Setup.Intf,
  DN.Package.Finder.Intf,
  DN.Package.Version.Finder.Intf,
  DN.DelphiInstallation.Intf;

type
  IDNCommandEnvironment = interface
  ['{BCAF0F46-F95D-44FD-9FDF-3841BFBEE851}']
    function GetKnownCommands: TArray<TDNCommandClass>;
    function GetOnlinePackages: TArray<IDNPackage>;
    function GetInstalledPackages: TArray<IDNPackage>;
    function GetUpdatePackages: TArray<IDNPackage>;
    function GetInteractive: Boolean;
    function GetDelphiName: string;
    function GetDelphiInstallations: TArray<IDNDelphiInstallation>;
    procedure SetDelphiName(const Value: string);
    procedure SetInteractive(const Value: Boolean);
    function CreateSetup: IDNSetup;
    function CreatePackageFinder(const APackages: TArray<IDNPackage>): IDNPackageFinder;
    function VersionFinder: IDNVersionFinder;
    property KnownCommands: TArray<TDNCommandClass> read GetKnownCommands;
    property OnlinePackages: TArray<IDNPackage> read GetOnlinePackages;
    property InstalledPackages: TArray<IDNPackage> read GetInstalledPackages;
    property UpdatePackages: TArray<IDNPackage> read GetUpdatePackages;
    property Interactive: Boolean read GetInteractive write SetInteractive;
    property DelphiName: string read GetDelphiName write SetDelphiName;
    property DelphiInstallations: TArray<IDNDelphiInstallation> read GetDelphiInstallations;
  end;

implementation

end.
