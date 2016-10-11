{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Package.Version;

interface

uses
  Generics.Collections,
  DN.Types,
  DN.Version,
  DN.Package.Version.Intf,
  DN.Package.Dependency.Intf;

type
  TDNPackageVersion = class(TInterfacedObject, IDNPackageVersion)
  private
    FName: string;
    FValue: TDNVersion;
    FCompilerMin: TCompilerVersion;
    FCompilerMax: TCompilerVersion;
    FDependencies: TList<IDNPackageDependency>;
    function GetCompilerMax: TCompilerVersion;
    function GetCompilerMin: TCompilerVersion;
    function GetName: string;
    procedure SetCompilerMax(const Value: TCompilerVersion);
    procedure SetCompilerMin(const Value: TCompilerVersion);
    procedure SetName(const Value: string);
    function GetValue: TDNVersion;
    procedure SetValue(const Value: TDNVersion);
    function GetDependencies: TList<IDNPackageDependency>;
  public
    constructor Create;
    destructor Destroy; override;
    property Name: string read GetName write SetName;
    property Value: TDNVersion read GetValue write SetValue;
    property CompilerMin: TCompilerVersion read GetCompilerMin write SetCompilerMin;
    property CompilerMax: TCompilerVersion read GetCompilerMax write SetCompilerMax;
    property Dependencies: TList<IDNPackageDependency> read GetDependencies;
  end;

implementation

{ TDNPackageVersion }

constructor TDNPackageVersion.Create;
begin
  inherited;
  FDependencies := TList<IDNPackageDependency>.Create();
end;

destructor TDNPackageVersion.Destroy;
begin
  FDependencies.Free;
  inherited;
end;

function TDNPackageVersion.GetCompilerMax: TCompilerVersion;
begin
  Result := FCompilerMax;
end;

function TDNPackageVersion.GetCompilerMin: TCompilerVersion;
begin
  Result := FCompilerMin;
end;

function TDNPackageVersion.GetDependencies: TList<IDNPackageDependency>;
begin
  Result := FDependencies;
end;

function TDNPackageVersion.GetName: string;
begin
  Result := FName;
end;

function TDNPackageVersion.GetValue: TDNVersion;
begin
  Result := FValue;
end;

procedure TDNPackageVersion.SetCompilerMax(const Value: TCompilerVersion);
begin
  FCompilerMax := Value;
end;

procedure TDNPackageVersion.SetCompilerMin(const Value: TCompilerVersion);
begin
  FCompilerMin := Value;
end;

procedure TDNPackageVersion.SetName(const Value: string);
begin
  FName := Value;
  TDNVersion.TryParse(FName, FValue);
end;

procedure TDNPackageVersion.SetValue(const Value: TDNVersion);
begin
  FValue := Value;
end;

end.
