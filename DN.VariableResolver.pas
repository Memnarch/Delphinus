unit DN.VariableResolver;

interface

uses
  DN.VariableResolver.Intf;

type
  TVariableResolver = class(TInterfacedObject, IVariableResolver)
  private
    FVariables: TArray<string>;
    FValues: TArray<string>;
  public
    constructor Create(const AVariables, AValues: array of string);
    function Resolve(const AText: string): string;
  end;

implementation

uses
  Classes,
  Types,
  SysUtils;

{ TVariableResolver }

function OpenToDynamicArray(const AValues: array of string): TArray<string>;
var
  i: Integer;
begin
  SetLength(Result, Length(AValues));
  for i := 0 to High(AValues) do
    Result[i] := AValues[i];
end;

constructor TVariableResolver.Create(const AVariables, AValues: array of string);
begin
  inherited Create();
  FVariables := OpenToDynamicArray(AVariables);
  FValues := OpenToDynamicArray(AValues);
  if Length(FVariables) <> Length(FValues) then
    raise EArgumentException.Create('Number of elements in Variables argument does not match number of elements in Values argument');
end;

function TVariableResolver.Resolve(const AText: string): string;
var
  i: Integer;
const
  CPrefix = '$(';
  CPostFix = ')';
begin
  Result := AText;
  for i := 0 to High(FVariables) do
    Result := StringReplace(Result, CPrefix + FVariables[i] + CPostFix, FValues[i], [rfReplaceAll, rfIgnoreCase]);
end;

end.
