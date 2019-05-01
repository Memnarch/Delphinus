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
    FIgnoredEditions: TArray<string>;
    function GetInstallations: TList<IDNDelphiInstallation>;
    procedure LoadInstallations;
    procedure RemoveIgnoredInstallations;
  public
    constructor Create(const AIgnoredEditions: array of string);
    destructor Destroy; override;
    property Installations: TList<IDNDelphiInstallation> read GetInstallations;
  end;

implementation

uses
  Classes,
  Registry,
  IOUtils,
  StrUtils,
  DN.DelphiInstallation;

{ TDNDelphiInstallationInfo }

constructor TDNDelphiInstallationProvider.Create(
  const AIgnoredEditions: array of string);
var
  i: Integer;
begin
  inherited Create();
  SetLength(FIgnoredEditions, Length(AIgnoredEditions));
  for i := 0 to Length(FIgnoredEditions) - 1 do
    FIgnoredEditions[i] := AIgnoredEditions[i];
end;

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
        if LInstallation.Application <> '' then
        begin
          FInstallations.Add(LInstallation);
        end;
      end;
      RemoveIgnoredInstallations();
    end;
  finally
    LKeyNames.Free;
    LRegistry.Free;
  end;
end;

procedure TDNDelphiInstallationProvider.RemoveIgnoredInstallations;
var
  i: Integer;
begin
  for i := FInstallations.Count - 1 downto 0 do
  begin
    if AnsiIndexText(FInstallations[i].Edition, FIgnoredEditions) > -1 then
      FInstallations.Delete(i);
  end;
end;

end.
