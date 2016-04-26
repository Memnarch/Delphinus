unit DN.VariableResolver.Intf;

interface

type
  IVariableResolver = interface
    ['{DBCEB68B-09AA-4581-9253-DBA974E4BE82}']
    function Resolve(const AText: string): string;
  end;

implementation

end.
