unit DN.PackageSource.Settings.Field;

interface

uses
  DN.PackageSource.Settings.Field.Intf,
  RTTI;

type
  TDNPackageSourceSettingsField = class(TInterfacedObject, IDNPackageSourceSettingsField)
  private
    FName: string;
    FValue: TValue;
    FValueType: TFieldValueType;
    function GetValue: TValue;
    procedure SetValue(const Value: TValue);
    function GetValueType: TFieldValueType;
    function GetName: string;
  public
    constructor Create(const AName: string; AType: TFieldValueType);
    property Name: string read GetName;
    property Value: TValue read GetValue write SetValue;
    property ValueType: TFieldValueType read GetValueType;
  end;

implementation

{ TDNPackageSourceSettingsField }

constructor TDNPackageSourceSettingsField.Create(const AName: string; AType: TFieldValueType);
begin
  inherited Create();
  FName := AName;
  FValueType := AType;
end;

function TDNPackageSourceSettingsField.GetName: string;
begin
  Result := FName;
end;

function TDNPackageSourceSettingsField.GetValue: TValue;
begin
  Result := FValue;
end;

function TDNPackageSourceSettingsField.GetValueType: TFieldValueType;
begin
  Result := FValueType;
end;

procedure TDNPackageSourceSettingsField.SetValue(const Value: TValue);
begin
  FValue := Value;
end;

end.
