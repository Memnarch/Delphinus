unit DN.Project.Dependency;

interface

uses
  DN.Version,
  DN.Package.Dependency,
  DN.Project.Dependency.Intf;

type
  TDNProjectPackageDependency = class(TDNPackageDependency, IDNProjectPackageDependency)
  private
    FName: string;
  public
    constructor Create(const AName: string; const AID: TGUID; const AVersion: TDNVersion); reintroduce;
    function GetName: string;
  end;

implementation

{ TDNProjectPackageDependency }

constructor TDNProjectPackageDependency.Create(const AName: string;
  const AID: TGUID; const AVersion: TDNVersion);
begin
  inherited Create(AID, AVersion);
  FName := AName;
end;

function TDNProjectPackageDependency.GetName: string;
begin
  Result := FName;
end;

end.
