unit DN.Package.Dependency.Intf;

interface

uses
  DN.Version;

type
  IDNPackageDependency = interface
    ['{159091E6-CB77-4F15-99BD-E7DA83088932}']
    function GetID: TGUID;
    function GetVersion: TDNVersion;
    property ID: TGUID read GetID;
    property Version: TDNVersion read GetVersion;
  end;

implementation

end.
