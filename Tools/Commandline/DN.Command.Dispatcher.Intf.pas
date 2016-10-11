unit DN.Command.Dispatcher.Intf;

interface

uses
  DN.Command.Argument.Intf;

type
  IDNCommandDispatcher = interface
    procedure Execute(const ACommand: IDNCommandArgument);
  end;

implementation

end.
