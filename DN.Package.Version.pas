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
  DN.Package.Version.Intf;

type
  TDNPackageVersion = class(TInterfacedObject, IDNPackageVersion)
  private
    FVersion: string;
    FCompilerMin: Integer;
    FCompilerMax: Integer;
    function GetCompilerMax: Integer;
    function GetCompilerMin: Integer;
    function GetName: string;
    procedure SetCompilerMax(const Value: Integer);
    procedure SetCompilerMin(const Value: Integer);
    procedure SetName(const Value: string);
  public
    property Name: string read GetName write SetName;
    property CompilerMin: Integer read GetCompilerMin write SetCompilerMin;
    property CompilerMax: Integer read GetCompilerMax write SetCompilerMax;
  end;

implementation

{ TDNPackageVersion }

function TDNPackageVersion.GetCompilerMax: Integer;
begin
  Result := FCompilerMax;
end;

function TDNPackageVersion.GetCompilerMin: Integer;
begin
  Result := FCompilerMin;
end;

function TDNPackageVersion.GetName: string;
begin
  Result := FVersion;
end;

procedure TDNPackageVersion.SetCompilerMax(const Value: Integer);
begin
  FCompilerMax := Value;
end;

procedure TDNPackageVersion.SetCompilerMin(const Value: Integer);
begin
  FCompilerMin := Value;
end;

procedure TDNPackageVersion.SetName(const Value: string);
begin
  FVersion := Value;
end;

end.
