unit DN.Package;

interface

uses
  Types,
  Graphics,
  Generics.Collections,
  DN.Package.Intf,
  DN.Package.Version.Intf;

type
  TDNPackage = class(TInterfacedObject, IDNPackage)
  private
    FID: TGUID;
    FCompilerMin: Integer;
    FCompilerMax: Integer;
    FName: string;
    FAuthor: string;
    FDescription: string;
    FPicture: TPicture;
    FDownloadLocation: string;
    FLastUpdated: string;
    FVersions: TList<IDNPackageVersion>;
  protected
    function GetID: TGUID; virtual;
    procedure SetID(const Value: TGUID); virtual;
    function GetCompilerMax: Integer; virtual;
    function GetCompilerMin: Integer; virtual;
    procedure SetCompilerMax(const Value: Integer); virtual;
    procedure SetCompilerMin(const Value: Integer); virtual;
    function GetDownloadLocation: string; virtual;
    procedure SetDownloadLocation(const Value: string); virtual;
    function GetAuthor: string; virtual;
    function GetDescription: string; virtual;
    function GetName: string; virtual;
    function GetPicture: TPicture; virtual;
    procedure SetAuthor(const Value: string); virtual;
    procedure SetDescription(const Value: string); virtual;
    procedure SetName(const Value: string); virtual;
    function GetLastUpdated: string; virtual;
    procedure SetLastUpdated(const Value: string); virtual;
    function GetVersions: TList<IDNPackageVersion>; virtual;
  public
    constructor Create();
    destructor Destroy(); override;
    property ID: TGUID read GetID write SetID;
    property CompilerMin: Integer read GetCompilerMin write SetCompilerMin;
    property CompilerMax: Integer read GetCompilerMax write SetCompilerMax;
    property Author: string read GetAuthor write SetAuthor;
    property Name: string read GetName write SetName;
    property Description: string read GetDescription write SetDescription;
    property Picture: TPicture read GetPicture;
    property DownloadLoaction: string read GetDownloadLocation write SetDownloadLocation;
    property LastUpdated: string read GetLastUpdated write SetLastUpdated;
    property Versions: TList<IDNPackageVersion> read GetVersions;
  end;

implementation

{ TDCPMPackage }

constructor TDNPackage.Create;
begin
  inherited;
  FPicture := TPicture.Create();
  FVersions := TList<IDNPackageVersion>.Create();
end;

destructor TDNPackage.Destroy;
begin
  FVersions.Free;
  FPicture.Free;
  inherited;
end;

function TDNPackage.GetAuthor: string;
begin
  Result := FAuthor;
end;

function TDNPackage.GetCompilerMax: Integer;
begin
  Result := FCompilerMax;
end;

function TDNPackage.GetCompilerMin: Integer;
begin
  Result := FCompilerMin;
end;

function TDNPackage.GetDescription: string;
begin
  Result := FDescription;
end;

function TDNPackage.GetDownloadLocation: string;
begin
  Result := FDownloadLocation;
end;

function TDNPackage.GetID: TGUID;
begin
  Result := FID;
end;

function TDNPackage.GetLastUpdated: string;
begin
  Result := FLastUpdated;
end;

function TDNPackage.GetName: string;
begin
  Result := FName;
end;

function TDNPackage.GetPicture: TPicture;
begin
  Result := FPicture;
end;

function TDNPackage.GetVersions: TList<IDNPackageVersion>;
begin
  Result := FVersions;
end;

procedure TDNPackage.SetAuthor(const Value: string);
begin
  FAuthor := Value;
end;

procedure TDNPackage.SetCompilerMax(const Value: Integer);
begin
  FCompilerMax := Value;
end;

procedure TDNPackage.SetCompilerMin(const Value: Integer);
begin
  FCompilerMin := Value;
end;

procedure TDNPackage.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

procedure TDNPackage.SetDownloadLocation(const Value: string);
begin
  FDownloadLocation := Value;
end;

procedure TDNPackage.SetID(const Value: TGUID);
begin
  FID := Value;
end;

procedure TDNPackage.SetLastUpdated(const Value: string);
begin
  FLastUpdated := Value;
end;

procedure TDNPackage.SetName(const Value: string);
begin
  FName := Value;
end;

end.
