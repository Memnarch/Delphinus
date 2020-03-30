unit DN.Project.Dependency.Access.Intf;

interface

uses
  DN.Project.Dependency.Intf;

type
  IDNProjectDependencyAccess = interface
    ['{1D6C392E-728E-443A-9F56-E9F959594A11}']
    function GetDependencies: TArray<IDNProjectPackageDependency>;
    procedure SetDependencies(const AValue: TArray<IDNProjectPackageDependency>);
    property Dependencies: TArray<IDNProjectPackageDependency> read GetDependencies write SetDependencies;
  end;

implementation

end.
