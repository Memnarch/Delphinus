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
    procedure PrintDetailedCommandHelp(ACommand: TDNCommandClass);
    procedure PrintCommandSwitchHelp(ACommand: TDNCommandClass; ASwitch: TDNCommandSwitchClass);
    procedure PrintDetailedCommandSwitchHelp(ACommand: TDNCommandClass; ASwitch: TDNCommandSwitchClass);
    function GetCommand(const AName: string): TDNCommandClass;
    function GetParameterString(ASwitch: TDNCommandSwitchClass): string;
    function GetSwitchString(ACommand: TDNCommandClass; AIncludeParameters: Boolean): string;
  public
    procedure Execute; override;
    class function Name: string; override;
    class function ParameterCount: Integer; override;
    class function Parameter(AIndex: Integer): string; override;
    class function OptionalParameterCount: Integer; override;
    class function Description: string; override;
  end;

implementation

uses
  SysUtils,
  DN.Command.Environment.Intf;

const
  CCommand = 'Command';
  CSwitch = 'Switch';
  CIdent = '  ';
  CIdent2 = CIdent + CIdent;
  CIdent3 = CIdent2 + CIdent;

{ TDNCommandHelp }

class function TDNCommandHelp.Description: string;
begin
  Result := 'Displays detailed help for a command or its switch and an overview if nothing is specified';
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
  LEnvironment: IDNCommandEnvironment;
begin
  LEnvironment := Environment as IDNCommandEnvironment;
  for LCommand in LEnvironment.KnownCommands do
    if SameText(AName, LCommand.Name) then
      Exit(LCommand);

  raise ENotSupportedException.Create('Unknown command ' + AName);
end;

function TDNCommandHelp.GetParameterString(ASwitch: TDNCommandSwitchClass): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to ASwitch.ParameterCount - 1 do
  begin
    if (ASwitch.OptionalParameterCount > 0) and (i = ASwitch.ParameterCount - ASwitch.OptionalParameterCount) then
      Result := Result + ' [';
    if i > 0 then
      Result := Result + ', ' + ASwitch.Parameter(i)
    else
      Result := Result + ASwitch.Parameter(i);
  end;
  if ASwitch.OptionalParameterCount > 0 then
    Result := Result + ']';
end;

function TDNCommandHelp.GetSwitchString(ACommand: TDNCommandClass;
  AIncludeParameters: Boolean): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to ACommand.SwitchClassCount - 1 do
  begin
    if i > 0 then
      Result := Result + ' ';
    Result := Result + '-' + ACommand.SwitchClass(i).Name;
    if AIncludeParameters then
      Result := Result + ' ' + GetParameterString(ACommand.SwitchClass(0));
  end;
  if Result <> '' then
    Result := '[' + Result + ']';
end;

procedure TDNCommandHelp.ListAllCommand;
var
  LCommand: TDNCommandClass;
begin
  for LCommand in (Environment as IDNCommandEnvironment).KnownCommands do
  begin
    PrintCommandHelp(LCommand);
    Writeln('');
  end;
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
  if ACommand.Name <> '' then
    Writeln(ACommand.Name + ' ' + GetParameterString(ACommand) + ' ' + GetSwitchString(ACommand, False))
  else
    Writeln('<no command> ' + GetParameterString(ACommand) + ' ' + GetSwitchString(ACommand, False));
  Writeln(CIdent + ACommand.Description);
end;

procedure TDNCommandHelp.PrintCommandSwitchHelp(ACommand: TDNCommandClass; ASwitch: TDNCommandSwitchClass);
begin
  if ACommand.Name <> '' then
    Writeln(ACommand.Name + ':' + ASwitch.Name + ' ' + GetParameterString(ASwitch))
  else
    Writeln('<no command>:' + ASwitch.Name + ' ' + GetParameterString(ASwitch));
  Writeln(CIdent, ASwitch.Description);
end;

procedure TDNCommandHelp.PrintDetailedCommandHelp(ACommand: TDNCommandClass);
var
  i: Integer;
begin
  PrintCommandHelp(ACommand);
  if ACommand.ParameterCount > 0 then
  begin
    Writeln(' ');
    Writeln('Parameters:');
    for i := 0 to ACommand.ParameterCount - 1 do
    begin
      Writeln(CIdent2 + ACommand.Parameter(i));
      Writeln(CIdent3 + ACommand.ParameterDescription(i));
    end;
  end;

  if ACommand.SwitchClassCount > 0 then
  begin
    Writeln(' ');
    Writeln('Switches:');
    for i := 0 to ACommand.SwitchClassCount - 1 do
    begin
      Writeln(CIdent2 + '-' + ACommand.SwitchClass(i).Name);
      Writeln(CIdent3 + ACommand.SwitchClass(i).Description);
    end;
  end;
end;

procedure TDNCommandHelp.PrintDetailedCommandSwitchHelp(
  ACommand: TDNCommandClass; ASwitch: TDNCommandSwitchClass);
var
  i: Integer;
begin
  PrintCommandSwitchHelp(ACommand, ASwitch);
  if ASwitch.ParameterCount > 0 then
  begin
    Writeln('');
    Writeln('Parameters:');
    for i := 0 to ASwitch.ParameterCount - 1 do
    begin
      Writeln(CIdent2 + ASwitch.Parameter(i));
      Writeln(CIdent3 + ASwitch.ParameterDescription(i));
    end;
  end;
end;

procedure TDNCommandHelp.ShowCommandHelp(const ACommand: string);
begin
  PrintDetailedCommandHelp(GetCommand(ACommand));
end;

procedure TDNCommandHelp.ShowCommandSwitchHelp(const ACommand, ASwitch: string);
var
  LCommand: TDNCommandClass;
  LSwitch: TDNCommandSwitchClass;
begin
  LCommand := GetCommand(ACommand);
  LSwitch := LCommand.SwitchClassByName(ASwitch);
  PrintDetailedCommandSwitchHelp(LCommand, LSwitch);
end;

end.
