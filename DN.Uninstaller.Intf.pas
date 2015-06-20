unit DN.Uninstaller.Intf;

interface

uses
  DN.Types;

type
  IDNUninstaller = interface
    ['{0FAA025F-21E8-48B4-9CCA-8C62D1065F69}']
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
    function Uninstall(const ADirectory: string): Boolean;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
  end;

const
  CUninstallFile = 'uninstall.json';

implementation

end.
