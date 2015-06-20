unit DN.Uninstaller.Intf;

interface

type
  IDNUninstaller = interface
    ['{0FAA025F-21E8-48B4-9CCA-8C62D1065F69}']
    function Uninstall(const ADirectory: string): Boolean;
  end;

const
  CUninstallFile = 'uninstall.json';

implementation

end.
