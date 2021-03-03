unit DN.PackageSource.Settings.Field.Intf;

interface

uses
  RTTI;

type
  TFieldValueType = (ftString, ftInteger);

  IDNPackageSourceSettingsField = interface
    ['{DC0FBD64-173E-4569-B1B3-C76D824AD7B8}']
    function GetValue: TValue;
    procedure SetValue(const Value: TValue);
    function GetValueType: TFieldValueType;
    function GetName: string;
    property Name: string read GetName;
    property Value: TValue read GetValue write SetValue;
    property ValueType: TFieldValueType read GetValueType;
  end;

implementation

end.
