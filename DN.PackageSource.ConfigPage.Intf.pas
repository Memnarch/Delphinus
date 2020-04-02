unit DN.PackageSource.ConfigPage.Intf;

interface

uses
  Controls,
  DN.PackageSource.Settings.Intf;

type
  IDNPackageSourceConfigPage = interface
    ['{56F8FA24-FEA1-4FF5-91FF-06EF005161A5}']
    function GetParent: TWinControl;
    procedure SetParent(const AValue: TWinControl);
    procedure Load(const ASettings: IDNPackageSourceSettings);
    procedure Save(const ASettings: IDNPackageSourceSettings);
    property Parent: TWinControl read GetParent write SetParent;
  end;

implementation

end.
