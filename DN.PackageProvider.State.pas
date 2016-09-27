unit DN.PackageProvider.State;

interface

uses
  DN.PackageProvider.State.Intf;

type
  TDNPackageProviderState = class(TInterfacedObject, IDNPackageProviderState)
  private
    FLastError: string;
    FState: TProviderState;
  protected
    function GetLastError: string; virtual;
    function GetState: TProviderState; virtual;
    function GetStatisticCount: Integer; virtual;
    function GetStatisticName(const AIndex: Integer): string; virtual;
    function GetStatisticValue(const AIndex: Integer): string; virtual;
  public
    procedure Reset; virtual;
    procedure SetError(const AError: string);
    property StatisticCount: Integer read GetStatisticCount;
    property StatisticName[const AIndex: Integer]: string read GetStatisticName;
    property StatisticValue[const AIndex: Integer]: string read GetStatisticValue;
    property LastError: string read GetLastError;
    property State: TProviderState read GetState;
  end;

implementation

{ TPackageProviderState }

function TDNPackageProviderState.GetLastError: string;
begin
  Result := FLastError;
end;

function TDNPackageProviderState.GetState: TProviderState;
begin
  Result := FState;
end;

function TDNPackageProviderState.GetStatisticCount: Integer;
begin
  Result := 0;
end;

function TDNPackageProviderState.GetStatisticName(const AIndex: Integer): string;
begin
  Result := '';
end;

function TDNPackageProviderState.GetStatisticValue(const AIndex: Integer): string;
begin
  Result := '';
end;

procedure TDNPackageProviderState.Reset;
begin
  FState := psOk;
  FLastError := '';
end;

procedure TDNPackageProviderState.SetError(const AError: string);
begin
  FLastError := AError;
  FState := psError;
end;

end.
