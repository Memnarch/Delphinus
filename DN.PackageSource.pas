unit DN.PackageSource;

interface

uses
  DN.PackageSource.Settings.Intf,
  DN.PackageProvider.Intf,
  DN.PackageSource.Intf;

type
  TDNPackageSource = class(TInterfacedObject, IDNPackageSource)
  public
    function GetName: string; virtual; abstract;
    function NewProvider(const ASettings: IDNPackageSourceSettings): IDNPackageProvider; virtual; abstract;
    function NewSettings: IDNPackageSourceSettings; virtual; abstract;
  end;

implementation

end.
