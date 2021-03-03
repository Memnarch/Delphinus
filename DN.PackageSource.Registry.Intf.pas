unit DN.PackageSource.Registry.Intf;

interface

uses
  DN.PackageSource.Intf;

type
  IDNPackageSourceRegistry = interface
    ['{A8F4ACA8-09FE-40E9-8951-512C375C85C3}']
    function GetSources: TArray<IDNPackageSource>;
    procedure RegisterSource(const ASource: IDNPackageSource);
    procedure UnregisterSource(const ASource: IDNPackageSource);
    function TryGetSource(const AName: string; out ASource: IDNPackageSource): Boolean;
    property Sources: TArray<IDNPackageSource> read GetSources;
  end;

implementation

end.
