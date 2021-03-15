unit DN.PackageSource.Intf;

interface

uses
  DN.PackageProvider.Intf,
  DN.PackageSource.Settings.Intf,
  DN.PackageSource.ConfigPage.Intf;

type
  IDNPackageSource = interface
    ['{DBC78301-EE5B-4CD3-98F8-A00413905077}']
    function GetName: string;
    function NewSettings: IDNPackageSourceSettings;
    function NewProvider(const ASettings: IDNPackageSourceSettings): IDNPackageProvider;
    function NewConfigPage: IDNPackageSourceConfigPage;
    property Name: string read GetName;
  end;

implementation

end.
