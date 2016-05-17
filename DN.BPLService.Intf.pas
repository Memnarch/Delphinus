unit DN.BPLService.Intf;

interface

type
  IDNBPLService = interface
    ['{C84411DA-474F-4172-BF76-E037C4686E36}']
    function Install(const ABPLFile: string): Boolean;
    function Uninstall(const ABPLFile: string): Boolean;
  end;

implementation

end.
