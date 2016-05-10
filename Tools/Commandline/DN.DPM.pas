unit DN.DPM;

interface

uses
  Generics.Collections,
  DN.Command,
  DN.Command.Dispatcher.Intf,
  DN.Command.Environment.Intf;

type
  TDPM = class
  private
    FEnvironment: IDNCommandEnvironment;
    FDispatcher: IDNCommandDispatcher;
    function GetCommandLine: string;
    function GetKnownCommands: TArray<TDNCommandClass>;
  public
    constructor Create;
    procedure Run;
  end;

implementation

uses
  SysUtils,
  DN.Command.Argument.Parser,
  DN.Command.Argument.Parser.Intf,
  DN.Command.Argument,
  DN.Command.Argument.Intf,
  DN.Command.Dispatcher,
  DN.Command.Environment,
  DN.Command.Help,
  DN.Command.Install,
  DN.Command.Default,
  DN.Command.Exit;

{ TDPM }

constructor TDPM.Create;
begin
  inherited;
  FEnvironment := TDNCommandEnvironment.Create(GetKnownCommands(), nil, nil);
  FDispatcher := TDNCommandDispatcher.Create(FEnvironment);
end;

function TDPM.GetCommandLine: string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to ParamCount do
    Result := Result + ' "' + ParamStr(i) + '"';
end;

function TDPM.GetKnownCommands: TArray<TDNCommandClass>;
var
  LCommands: TList<TDNCommandClass>;
begin
  LCommands := TList<TDNCommandClass>.Create();
  LCommands.Add(TDNCommandDefault);
  LCommands.Add(TDNCommandHelp);
  LCommands.Add(TDNCommandInstall);
  LCommands.Add(TDNCommandExit);
  Result := LCommands.ToArray;
end;

procedure TDPM.Run;
var
  LParser: IDNCommandArgumentParser;
  LCommand: IDNCommandArgument;
  LLine: string;
begin
  LParser := TDNCommandArgumentParser.Create();
  LCommand := LParser.FromText(GetCommandLine());
  FDispatcher.Execute(LCommand);
  while FEnvironment.Interactive do
  begin
    try
      Write('DPM>');
      ReadLn(LLine);
      FDispatcher.Execute(LParser.FromText(LLine));
    except
      on E:Exception do
      begin
        Writeln(E.Message);
      end;
    end;
  end;
end;

end.
