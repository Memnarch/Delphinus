unit DN.PackageSource.Registry;

interface

uses
  Generics.Collections,
  DN.PackageSource.Intf,
  DN.PackageSource.Registry.Intf;

type
  TDNPackageSourceRegistry = class(TInterfacedObject, IDNPackageSourceRegistry)
  private
    FSources: TDictionary<string, IDNPackageSource>;
    function GetSources: TArray<IDNPackageSource>;
    procedure RegisterSource(const ASource: IDNPackageSource);
    function TryGetSource(const AName: string;
      out ASource: IDNPackageSource): Boolean;
    procedure UnregisterSource(const ASource: IDNPackageSource);
  public
    constructor Create;
    destructor Destroy; override;
  end;


implementation

uses
  DN.Character;

{ TDNPackageSourceRegistry }

constructor TDNPackageSourceRegistry.Create;
begin
  inherited;
  FSources := TDictionary<string, IDNPackageSource>.Create();
end;

destructor TDNPackageSourceRegistry.Destroy;
begin
  FSources.Free;
  inherited;
end;

function TDNPackageSourceRegistry.GetSources: TArray<IDNPackageSource>;
begin
  Result := FSources.Values.ToArray;
end;

procedure TDNPackageSourceRegistry.RegisterSource(
  const ASource: IDNPackageSource);
begin
  FSources.Add(TCharacter.ToLower(ASource.Name), ASource);
end;

function TDNPackageSourceRegistry.TryGetSource(const AName: string;
  out ASource: IDNPackageSource): Boolean;
begin
  Result := FSources.TryGetValue(TCharacter.ToLower(AName), ASource);
end;

procedure TDNPackageSourceRegistry.UnregisterSource(
  const ASource: IDNPackageSource);
begin
  FSources.Remove(TCharacter.ToLower(ASource.Name));
end;

end.
