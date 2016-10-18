unit DN.PackageSource.Settings;

interface

uses
  Generics.Collections,
  DN.PackageSource.Settings.Field.Intf,
  DN.PackageSource.Settings.Intf;

type
  TDNPackageSourceSettings = class(TInterfacedObject, IDNPackageSourceSettings)
  private
    FName: string;
    FSourceName: string;
    FFields: TDictionary<string, IDNPackageSourceSettingsField>;
    function GetField(const AName: string): IDNPackageSourceSettingsField;
    function GetFields: TArray<IDNPackageSourceSettingsField>;
    function GetName: string;
    function GetSourceName: string;
    procedure SetName(const Value: string);
  protected
    function DeclareField(const AName: string; AType: TFieldValueType): IDNPackageSourceSettingsField;
    procedure InitFields; virtual;
  public
    constructor Create(const ASourceName: string);
    destructor Destroy; override;
    property Name: string read GetName write SetName;
    property SourceName: string read GetSourceName;
    property Field[const AName: string]: IDNPackageSourceSettingsField read GetField;
    property Fields: TArray<IDNPackageSourceSettingsField> read GetFields;
  end;

implementation

uses
  DN.Character,
  DN.PackageSource.Settings.Field;

{ TDNPackageSourceSettings }

constructor TDNPackageSourceSettings.Create(const ASourceName: string);
begin
  inherited Create();
  FFields := TDictionary<string, IDNPackageSourceSettingsField>.Create();
  FSourceName := ASourceName;
  InitFields();
end;

function TDNPackageSourceSettings.DeclareField(
  const AName: string; AType: TFieldValueType): IDNPackageSourceSettingsField;
begin
  Result := TDNPackageSourceSettingsField.Create(AName, AType);
  FFields.Add(TCharacter.ToLower(AName), Result);
end;

destructor TDNPackageSourceSettings.Destroy;
begin
  FFields.Free;
  inherited;
end;

function TDNPackageSourceSettings.GetField(
  const AName: string): IDNPackageSourceSettingsField;
begin
  Result := FFields[TCharacter.ToLower(AName)];
end;

function TDNPackageSourceSettings.GetFields: TArray<IDNPackageSourceSettingsField>;
begin
  Result := FFields.Values.ToArray;
end;

function TDNPackageSourceSettings.GetName: string;
begin
  Result := FName;
end;

function TDNPackageSourceSettings.GetSourceName: string;
begin
  Result := FSourceName;
end;

procedure TDNPackageSourceSettings.InitFields;
begin

end;

procedure TDNPackageSourceSettings.SetName(const Value: string);
begin
  FName := Value;
end;

end.
