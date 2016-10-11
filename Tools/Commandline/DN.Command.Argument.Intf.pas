unit DN.Command.Argument.Intf;

interface

type
  IDNCommandSwitchArgument = interface
    ['{3D0038C9-344B-487D-AB11-6B429861EC22}']
    function GetName: string;
    function GetParameters: TArray<string>;
    property Name: string read GetName;
    property Parameters: TArray<string> read GetParameters;
  end;

  IDNCommandArgument = interface(IDNCommandSwitchArgument)
    ['{03433974-5F75-4C13-BDB6-41A0107081CE}']
    function GetSwitches: TArray<IDNCommandSwitchArgument>;
    property Switches: TArray<IDNCommandSwitchArgument> read GetSwitches;
  end;


implementation

end.
