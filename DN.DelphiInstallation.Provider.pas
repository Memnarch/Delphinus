unit DN.DelphiInstallation.Provider;

interface

uses
  DN.DelphiInstallation.Provider.Intf,
  DN.DelphiInstallation.Intf,
  Generics.Collections;

type
  TDNDelphiInstallationProvider = class(TInterfacedObject, IDNDelphiInstallationProvider)
  private
    FInstallations: TList<IDNDelphiInstallation>;
    function GetInstallations: TList<IDNDelphiInstallation>;
    procedure LoadInstallations;
  public
    destructor Destroy; override;
    property Installations: TList<IDNDelphiInstallation> read GetInstallations;
  end;

implementation

uses
  Classes,
  Registry,
  IOUtils,
  DN.DelphiInstallation;

{ TDNDelphiInstallationInfo }

destructor TDNDelphiInstallationProvider.Destroy;
begin
  FInstallations.Free;
  inherited;
end;

function TDNDelphiInstallationProvider.GetInstallations: TList<IDNDelphiInstallation>;
begin
  if not Assigned(FInstallations) then
  begin
    FInstallations := TList<IDNDelphiInstallation>.Create();
    LoadInstallations();
  end;
  Result := FInstallations;
end;

procedure TDNDelphiInstallationProvider.LoadInstallations;
var
  LRegistry: TRegistry;
  LInstallation: IDNDelphiInstallation;
  LKeyNames: TStringList;
  LKey: string;
const
  CRootKey = 'Software\Embarcadero\BDS';
begin
  LRegistry := TRegistry.Create();
  LKeyNames := TStringList.Create();
  try
    if LRegistry.OpenKeyReadOnly(CRootKey) then
    begin
      LRegistry.GetKeyNames(LKeyNames);
      for LKey in LKeyNames do
      begin
        LInstallation := TDNDelphInstallation.Create(TPath.Combine(CRootKey, LKey));
        FInstallations.Add(LInstallation);
      end;
    end;
  finally
    LKeyNames.Free;
    LRegistry.Free;
  end;
end;

end.
