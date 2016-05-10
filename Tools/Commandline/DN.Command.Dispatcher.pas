unit DN.Command.Dispatcher;

interface

uses
  DN.Command,
  DN.Command.Argument.Intf,
  DN.Command.Dispatcher.Intf,
  DN.Command.Environment.Intf;

type
  TDNCommandDispatcher = class(TInterfacedObject, IDNCommandDispatcher)
  private
    FEnvironment: IDNCommandEnvironment;
    function TryGetCommandClass(const AName: string; out ACommandClass: TDNCommandClass): Boolean;
  public
    constructor Create(const AEnvironment: IDNCommandEnvironment);
    procedure Execute(const ACommand: IDNCommandArgument);
  end;

implementation

uses
  SysUtils;

{ TDNCommandDispatcher }

constructor TDNCommandDispatcher.Create(
  const AEnvironment: IDNCommandEnvironment);
begin
  inherited Create();
  FEnvironment := AEnvironment;
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
      LCommand.Environment := FEnvironment;
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
  for LClass in FEnvironment.KnownCommands do
    if SameText(AName, LClass.Name) then
    begin
      ACommandClass := LClass;
      Exit(True);
    end;
end;

end.
