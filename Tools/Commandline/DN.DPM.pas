unit DN.DPM;

interface

uses
  Generics.Collections,
  DN.Command,
  DN.Command.Dispatcher.Intf;

type
  TDPM = class
  private
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
  DN.Command.Help;

{ TDPM }

constructor TDPM.Create;
begin
  inherited;
  FDispatcher := TDNCommandDispatcher.Create(GetKnownCommands());
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
  LCommands.Add(TDNCommandHelp);
  Result := LCommands.ToArray;
  TDNCommandHelp.KnownCommands := Result;
end;

procedure TDPM.Run;
var
  LParser: IDNCommandArgumentParser;
  LCommand: IDNCommandArgument;
begin
  LParser := TDNCommandArgumentParser.Create();
  LCommand := LParser.FromText(GetCommandLine());
  FDispatcher.Execute(LCommand);
end;

end.
