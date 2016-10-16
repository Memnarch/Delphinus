unit DN.Command.Switch.IgnoreDependencies;

interface

uses
  DN.Command.Switch;

type
  TDNCommandSwitchIgnoreDependencies = class(TDNCommandSwitch)
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

implementation

{ TDNCommandSwitchIgnoreDependencies }

class function TDNCommandSwitchIgnoreDependencies.Description: string;
begin
  Result := 'Ignore dependencies';
end;

class function TDNCommandSwitchIgnoreDependencies.Name: string;
begin
  Result := 'IgnoreDependencies';
end;

end.
