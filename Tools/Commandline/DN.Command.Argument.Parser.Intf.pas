unit DN.Command.Argument.Parser.Intf;

interface

uses
  DN.Command.Argument.Intf;

type
  IDNCommandArgumentParser = interface
  ['{30514CEC-E981-43E2-B60B-6565313EE818}']
    function FromText(const AText: string): IDNCommandArgument;
  end;

implementation

end.
