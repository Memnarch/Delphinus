unit DN.Command.Help;

interface

uses
  DN.Command,
  DN.Command.Switch;

type
  TDNCommandHelp = class(TDNCommand)
  protected
    procedure ListAllCommand;
    procedure ShowCommandHelp(const ACommand: string);
    procedure ShowCommandSwitchHelp(const ACommand, ASwitch: string);
    procedure PrintCommandHelp(ACommand: TDNCommandClass);
    procedure PrintCommandSwitchHelp(ACommand: TDNCommandClass; ASwitch: TDNCommandSwitchClass);
    function GetCommand(const AName: string): TDNCommandClass;
  public
    class var KnownCommands: TArray<TDNCommandClass>;
    procedure Execute; override;
    class function Name: string; override;
    class function ParameterCount: Integer; override;
    class function Parameter(AIndex: Integer): string; override;
    class function OptionalParameterCount: Integer; override;
    class function Description: string; override;
  end;

implementation

uses
  SysUtils;

const
  CCommand = 'Command';
  CSwitch = 'Switch';
  CIdent = '  ';

{ TDNCommandHelp }

class function TDNCommandHelp.Description: string;
begin
  Result := 'Displays help for a command or its switch';
end;

procedure TDNCommandHelp.Execute;
begin
  case ParameterValueCount of
    0: ListAllCommand;
    1: ShowCommandHelp(ReadParameter(CCommand));
    2: ShowCommandSwitchHelp(ReadParameter(CCommand), ReadParameter(CSwitch));
  end;
end;

function TDNCommandHelp.GetCommand(const AName: string): TDNCommandClass;
var
  LCommand: TDNCommandClass;
begin
  for LCommand in KnownCommands do
    if SameText(AName, LCommand.Name) then
      Exit(LCommand);

  raise ENotSupportedException.Create('Unknown command ' + AName);
end;

procedure TDNCommandHelp.ListAllCommand;
var
  LCommand: TDNCommandClass;
begin
  for LCommand in KnownCommands do
    PrintCommandHelp(LCommand);;
end;

class function TDNCommandHelp.Name: string;
begin
  Result := 'Help';
end;

class function TDNCommandHelp.OptionalParameterCount: Integer;
begin
  Result := 2;
end;

class function TDNCommandHelp.Parameter(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := CCommand;
    1: Result := CSwitch;
  else
    inherited;
  end;
end;

class function TDNCommandHelp.ParameterCount: Integer;
begin
  Result := 2;
end;

procedure TDNCommandHelp.PrintCommandHelp(ACommand: TDNCommandClass);
begin
  Writeln(ACommand.Name);
  Writeln(CIdent + ACommand.Description);
end;

procedure TDNCommandHelp.PrintCommandSwitchHelp(ACommand: TDNCommandClass; ASwitch: TDNCommandSwitchClass);
begin
  Writeln(ACommand.Name + ':' + ASwitch.Name);
  Writeln(CIdent, ASwitch.Description);
end;

procedure TDNCommandHelp.ShowCommandHelp(const ACommand: string);
begin
  PrintCommandHelp(GetCommand(ACommand));
end;

procedure TDNCommandHelp.ShowCommandSwitchHelp(const ACommand, ASwitch: string);
var
  LCommand: TDNCommandClass;
  LSwitch: TDNCommandSwitchClass;
begin
  LCommand := GetCommand(ACommand);
  LSwitch := LCommand.SwitchClassByName(ASwitch);
  PrintCommandSwitchHelp(LCommand, LSwitch);
end;

end.
