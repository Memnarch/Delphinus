unit DN.Setup.Dependency.Intf;

interface

uses
  DN.Package.Intf,
  DN.Package.Version.Intf;

type
  TDependencyAction = (daNone, daInstall, daUpdate, daUninstall);

  IDNSetupDependency = interface
    ['{F81A8627-D0AE-45CF-BADC-CB933EA5665D}']
    function GetAction: TDependencyAction;
    function GetInstalledVersion: IDNPackageVersion;
    function GetPackage: IDNPackage;
    function GetVersion: IDNPackageVersion;
    procedure SetInstalledVersion(const Value: IDNPackageVersion);
    procedure SetPackage(const Value: IDNPackage);
    procedure SetVersion(const Value: IDNPackageVersion);
    procedure SetAction(const Value: TDependencyAction);
    function GetID: TGUID;
    procedure SetID(const Value: TGUID);
    property ID: TGUID read GetID write SetID;
    property Package: IDNPackage read GetPackage write SetPackage;
    property Action: TDependencyAction read GetAction write SetAction;
    property Version: IDNPackageVersion read GetVersion write SetVersion;
    property InstalledVersion: IDNPackageVersion read GetInstalledVersion write SetInstalledVersion;
  end;

implementation

end.
