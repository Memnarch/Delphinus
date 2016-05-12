unit DN.Command.Environment.Intf;

interface

uses
  DN.Command,
  DN.Package.Intf;

type
  IDNCommandEnvironment = interface
  ['{BCAF0F46-F95D-44FD-9FDF-3841BFBEE851}']
    function GetKnownCommands: TArray<TDNCommandClass>;
    function GetOnlinePackages: TArray<IDNPackage>;
    function GetInstalledPackages: TArray<IDNPackage>;
    function GetUpdatePackages: TArray<IDNPackage>;
    function GetInteractive: Boolean;
    procedure SetInteractive(const Value: Boolean);
    property KnownCommands: TArray<TDNCommandClass> read GetKnownCommands;
    property OnlinePackages: TArray<IDNPackage> read GetOnlinePackages;
    property InstalledPackages: TArray<IDNPackage> read GetInstalledPackages;
    property UpdatePackages: TArray<IDNPackage> read GetUpdatePackages;
    property Interactive: Boolean read GetInteractive write SetInteractive;
  end;

implementation

end.
