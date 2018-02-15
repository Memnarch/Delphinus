unit DN.Command.DelphiBlock;

interface

uses
  DN.Command,
  DN.Command.Switch;

type
  TDNCommandDelphiBlock = class(TDNCommand)
  protected
    FOldDelphi: string;
    procedure BeginBlock;
    procedure EndBlock;
  public
    class function SwitchClass(AIndex: Integer): TDNCommandSwitchClass; override;
    class function SwitchClassCount: Integer; override;
  end;

implementation

uses
  DN.Command.Environment.Intf,
  DN.Command.Switch.Delphi;

{ TDNCommandDelphiBlock }

procedure TDNCommandDelphiBlock.BeginBlock;
var
  LEnvironment: IDNCommandEnvironment;
  LSwitch: TDNCommandSwitchDelphi;
begin
  LEnvironment := Environment as IDNCommandEnvironment;
  LSwitch := GetSwitch<TDNCommandSwitchDelphi>();
  if LSwitch.IsUsed then
  begin
    FOldDelphi := LEnvironment.DelphiName;
    LEnvironment.DelphiName := LSwitch.ShortName;
  end;
end;

procedure TDNCommandDelphiBlock.EndBlock;
var
  LEnvironment: IDNCommandEnvironment;
begin
  if FOldDelphi <> '' then
  begin
    LEnvironment := Environment as IDNCommandEnvironment;
    LEnvironment.DelphiName := FOldDelphi;
  end;
end;

class function TDNCommandDelphiBlock.SwitchClass(
  AIndex: Integer): TDNCommandSwitchClass;
begin
  if AIndex = inherited SwitchClassCount then
    Result := TDNCommandSwitchDelphi
  else
    Result := inherited;
end;

class function TDNCommandDelphiBlock.SwitchClassCount: Integer;
begin
  Result := inherited + 1;
end;

end.
