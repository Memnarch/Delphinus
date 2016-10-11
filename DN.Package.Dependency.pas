unit DN.Package.Dependency;

interface

uses
  DN.Version,
  DN.Package.Dependency.Intf;

type
  TDNPackageDependency = class(TInterfacedObject, IDNPackageDependency)
  private
    FID: TGUID;
    FVersion: TDNVersion;
    function GetID: TGUID;
    function GetVersion: TDNVersion;
  public
    constructor Create(const AID: TGUID; const AVersion: TDNVersion);
  end;

implementation

{ TDNPackageDependency }

constructor TDNPackageDependency.Create(const AID: TGUID;
  const AVersion: TDNVersion);
begin
  inherited Create();
  FID := AID;
  FVersion := AVersion;
end;

function TDNPackageDependency.GetID: TGUID;
begin
  Result := FID;
end;

function TDNPackageDependency.GetVersion: TDNVersion;
begin
  Result := FVersion;
end;

end.
