unit DN.DelphiInstallation.Provider.Intf;

interface

uses
  DN.DelphiInstallation.Intf,
  Generics.Collections;

type
  IDNDelphiInstallationProvider = interface
    ['{4D3C0C3B-A3D0-4550-A21D-C8C6E7587D05}']
    function GetInstallations: TList<IDNDelphiInstallation>;
    property Installations: TList<IDNDelphiInstallation> read GetInstallations;
  end;

implementation

end.
