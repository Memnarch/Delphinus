unit DN.Command.Argument;

interface

uses
  DN.Command.Argument.Intf;

type
  TDNCommandSwitchArgument = class(TInterfacedObject, IDNCommandSwitchArgument)
  private
    FName: string;
    FParameters: TArray<string>;
    function GetName: string;
    function GetParameters: TArray<string>;
  public
    property Name: string read GetName write FName;
    property Parameters: TArray<string> read GetParameters write FParameters;
  end;

  TDNCommandArgument = class(TDNCommandSwitchArgument, IDNCommandArgument)
  private
    FSwitches: TArray<IDNCommandSwitchArgument>;
    function GetSwitches: TArray<IDNCommandSwitchArgument>;
  public
    property Switches: TArray<IDNCommandSwitchArgument> read GetSwitches write FSwitches;
  end;

implementation

{ TDNCommand }

function TDNCommandSwitchArgument.GetName: string;
begin
  Result := FName;
end;

function TDNCommandSwitchArgument.GetParameters: TArray<string>;
begin
  Result := FParameters;
end;

{ TDNCommand }

function TDNCommandArgument.GetSwitches: TArray<IDNCommandSwitchArgument>;
begin
  Result := FSwitches;
end;

end.
