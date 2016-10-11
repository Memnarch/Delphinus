unit DN.Command.Default;

interface

uses
  DN.Command,
  DN.Command.Switch;

type
  TDNCommandDefault = class(TDNCommand)
  public
    class function Description: string; override;
    class function Name: string; override;
    class function SwitchClass(AIndex: Integer): TDNCommandSwitchClass;
      override;
    class function SwitchClassCount: Integer; override;
    procedure Execute; override;
  end;

implementation

uses
  DN.Command.Environment.Intf,
  DN.Command.Switch.Delphi,
  DN.Command.Switch.PanicOnError,
  DN.Command.Types;

{ TDNCommandDefault }

class function TDNCommandDefault.Description: string;
begin
  Result := 'Start interactive session for executing multiple tasks before quiting';
end;

procedure TDNCommandDefault.Execute;
var
  LEnvironment: IDNCommandEnvironment;
  LDelphi: TDNCommandSwitchDelphi;
  LFirstRun: Boolean;
begin
  LEnvironment := (Environment as IDNCommandEnvironment);
  LFirstRun := not LEnvironment.Interactive;
  LEnvironment.Interactive := True;
  LDelphi := GetSwitch<TDNCommandSwitchDelphi>();
  if LDelphi.ShortName <> '' then
    LEnvironment.DelphiName := LDelphi.ShortName;

  if HasSwitch<TDNCommandSwitchPanicOnError>() then
    LEnvironment.PanicOnError := True;

  if LFirstRun or (LDelphi.ShortName <> '') then
    Writeln('Selected Delphi ' + LEnvironment.DelphiName);
end;

class function TDNCommandDefault.Name: string;
begin
  Result := '';
end;

class function TDNCommandDefault.SwitchClass(
  AIndex: Integer): TDNCommandSwitchClass;
begin
  case AIndex of
    0: Result := TDNCommandSwitchDelphi;
    1: Result := TDNCommandSwitchPanicOnError;
  else
    raise EInvalidSwitchIndex.Create(AIndex);
  end;
end;

class function TDNCommandDefault.SwitchClassCount: Integer;
begin
  Result := 2;
end;

end.
