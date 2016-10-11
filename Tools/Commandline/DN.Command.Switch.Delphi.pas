unit DN.Command.Switch.Delphi;

interface

uses
  DN.Command.Argument.Intf,
  DN.Command.Switch;

type
  TDNCommandSwitchDelphi = class(TDNCommandSwitch)
  private
    FShortName: string;
  public
    class function Description: string; override;
    class function Name: string; override;
    class function Parameter(AIndex: Integer): string; override;
    class function ParameterCount: Integer; override;
    class function ParameterDescription(AIndex: Integer): string; override;
    procedure Initialize(const AArgument: IDNCommandSwitchArgument); override;
    property ShortName: string read FShortName;
  end;

implementation

uses
  SysUtils;

{ TDNCommandSwitchDelphi }

class function TDNCommandSwitchDelphi.Description: string;
begin
  Result := 'Specifies the Delphi-Environment to use';
end;

procedure TDNCommandSwitchDelphi.Initialize(
  const AArgument: IDNCommandSwitchArgument);
begin
  inherited;
  FShortName := Trim(AArgument.Parameters[0]);
  if FShortName = '' then
    raise EArgumentNilException.Create('ShortName can not be empty');
end;

class function TDNCommandSwitchDelphi.Name: string;
begin
  Result := 'Delphi';
end;

class function TDNCommandSwitchDelphi.Parameter(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := 'ShortName';
  end;
end;

class function TDNCommandSwitchDelphi.ParameterCount: Integer;
begin
  Result := 1;
end;

class function TDNCommandSwitchDelphi.ParameterDescription(
  AIndex: Integer): string;
begin
  case AIndex of
    0: Result := 'ShortName of Delphi to use (i.e. XE, XE2)'
  end;
end;

end.
