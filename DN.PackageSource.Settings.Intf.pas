unit DN.PackageSource.Settings.Intf;

interface

uses
  DN.PackageSource.Settings.Field.Intf;

type
  IDNPackageSourceSettings = interface
    ['{F26601A3-7C4E-4E2B-981D-057C80F85D94}']
    function GetField(const AName: string): IDNPackageSourceSettingsField;
    function GetFields: TArray<IDNPackageSourceSettingsField>;
    function GetName: string;
    function GetSourceName: string;
    procedure SetName(const Value: string);
    property Name: string read GetName write SetName;
    property SourceName: string read GetSourceName;
    property Field[const AName: string]: IDNPackageSourceSettingsField read GetField;
    property Fields: TArray<IDNPackageSourceSettingsField> read GetFields;
  end;

implementation

end.
