unit DN.PackageProvider.State.Intf;

interface

type
  TProviderState = (psOk, psCritical, psError);

  IDNPackageProviderState = interface
    ['{B9FFA71B-7CDD-42F7-9BC3-4C0EFDC78F7A}']
    function GetLastError: string;
    function GetState: TProviderState;
    function GetStatisticCount: Integer;
    function GetStatisticName(const AIndex: Integer): string;
    function GetStatisticValue(const AIndex: Integer): string;
    property StatisticCount: Integer read GetStatisticCount;
    property StatisticName[const AIndex: Integer]: string read GetStatisticName;
    property StatisticValue[const AIndex: Integer]: string read GetStatisticValue;
    property LastError: string read GetLastError;
    property State: TProviderState read GetState;
  end;

implementation

end.
