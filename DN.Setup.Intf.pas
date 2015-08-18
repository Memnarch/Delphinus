unit DN.Setup.Intf;

interface

uses
  DN.Types;

type
  TDNSetupMessageEvent = procedure(AType: TMessageType; const AMessage: string);

  IDNSetup = interface
    ['{F853423C-9D61-49DA-824B-F6AEE55D3F7B}']
  end;

implementation

end.
