unit DN.Installer.Intf;

interface

uses
  DN.Types;

type
  IDNInstaller = interface
    ['{BE1681DA-4DC1-4393-9E7A-050CD63468D2}']
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
    function Install(const ASourceDirectory, ATargetDirectory: string): Boolean;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
  end;

implementation

end.
