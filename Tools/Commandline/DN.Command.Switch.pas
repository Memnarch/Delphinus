unit DN.Command.Switch;

interface

uses
  SysUtils,
  Generics.Collections,
  DN.Command.Argument.Intf;

type
  TDNCommandSwitch = class
  private
    FParameters: TDictionary<string, string>;
  protected
    function ReadParameter(const AName: string): string;
    function ParameterValueCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Initialize(const AArgument: IDNCommandSwitchArgument); virtual;
    class procedure Validate(const AArgument: IDNCommandSwitchArgument); virtual;
    class function Name: string; virtual; abstract;
    class function Description: string; virtual;
    class function OptionalParameterCount: Integer; virtual;
    class function ParameterCount: Integer; virtual;
    class function Parameter(AIndex: Integer): string; virtual;
    class function ParameterDescription(AIndex: Integer): string; virtual;
  end;

  TDNCommandSwitchClass = class of TDNCommandSwitch;

  ECommandSwitchValidation = class(Exception);

implementation

{ TDNCommandSwitch }

constructor TDNCommandSwitch.Create;
begin
  inherited;
  FParameters := TDictionary<string, string>.Create();
end;

class function TDNCommandSwitch.Description: string;
begin
  Result := '';
end;

destructor TDNCommandSwitch.Destroy;
begin
  FParameters.Free;
  inherited;
end;

class function TDNCommandSwitch.OptionalParameterCount: Integer;
begin
  Result := 0;
end;

class function TDNCommandSwitch.ParameterDescription(
  AIndex: Integer): string;
begin
  Result := '';
end;

function TDNCommandSwitch.ParameterValueCount: Integer;
begin
  Result := FParameters.Count;
end;

function TDNCommandSwitch.ReadParameter(const AName: string): string;
begin
  Result := FParameters[AName];
end;

class function TDNCommandSwitch.Parameter(AIndex: Integer): string;
begin
  Result := '';
end;

class function TDNCommandSwitch.ParameterCount: Integer;
begin
  Result := 0;
end;

procedure TDNCommandSwitch.Initialize(
  const AArgument: IDNCommandSwitchArgument);
var
  i: Integer;
begin
  for i := 0 to Length(AArgument.Parameters) - 1 do
    FParameters.Add(Parameter(i), AArgument.Parameters[i]);
end;

class procedure TDNCommandSwitch.Validate(const AArgument: IDNCommandSwitchArgument);
var
  LParameters, LRequired: Integer;
begin
  LParameters := Length(AArgument.Parameters);
  LRequired := ParameterCount - OptionalParameterCount;
  if (LParameters < LRequired) then
    raise ECommandSwitchValidation.Create('Expected at least ' + IntToStr(LRequired) + ' arguments but got only ' + IntToStr(LParameters))
  else if LParameters > ParameterCount then
    raise ECommandSwitchValidation.Create('Expected a maximum of ' + IntToStr(ParameterCount) + ' but got ' + IntToStr(LParameters));
end;

end.
