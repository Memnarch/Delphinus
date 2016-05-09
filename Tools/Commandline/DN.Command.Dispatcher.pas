unit DN.Command.Dispatcher;

interface

uses
  DN.Command,
  DN.Command.Argument.Intf,
  DN.Command.Dispatcher.Intf;

type
  TDNCommandDispatcher = class(TInterfacedObject, IDNCommandDispatcher)
  private
    FCommands: TArray<TDNCommandClass>;
    function TryGetCommandClass(const AName: string; out ACommandClass: TDNCommandClass): Boolean;
  public
    constructor Create(const ACommands: TArray<TDNCommandClass>);
    procedure Execute(const ACommand: IDNCommandArgument);
  end;

implementation

uses
  SysUtils;

{ TDNCommandDispatcher }

constructor TDNCommandDispatcher.Create(
  const ACommands: TArray<TDNCommandClass>);
begin
  inherited Create();
  FCommands := ACommands;
end;

procedure TDNCommandDispatcher.Execute(const ACommand: IDNCommandArgument);
var
  LClass: TDNCommandClass;
  LCommand: TDNCommand;
begin
  if TryGetCommandClass(ACommand.Name, LClass) then
  begin
    LClass.Validate(ACommand);
    LCommand := LClass.Create();
    try
      LCommand.Initialize(ACommand);
      LCommand.Execute();
    finally
      LCommand.Free;
    end;
  end
  else
  begin
    raise ENotSupportedException.Create('Unknown command ' + ACommand.Name);
  end;
end;

function TDNCommandDispatcher.TryGetCommandClass(const AName: string;
  out ACommandClass: TDNCommandClass): Boolean;
var
  LClass: TDNCommandClass;
begin
  Result := False;
  for LClass in FCommands do
    if SameText(AName, LClass.Name) then
    begin
      ACommandClass := LClass;
      Exit(True);
    end;
end;

end.
