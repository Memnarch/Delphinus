unit DN.Command.Switch.Dependencies;

interface

uses
  DN.Command.Switch;

type
  TDNCommandSwitchDependencies = class(TDNCommandSwitch)
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

implementation

{ TDNCommandSwitchDependencies }

class function TDNCommandSwitchDependencies.Description: string;
begin
  Result := 'Displays direct and indirect dependencies of this Package';
end;

class function TDNCommandSwitchDependencies.Name: string;
begin
  Result := 'Dependencies';
end;

end.
