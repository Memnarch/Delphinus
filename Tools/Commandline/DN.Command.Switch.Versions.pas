unit DN.Command.Switch.Versions;

interface

uses
  DN.Command.Switch;

type
  TDNCommandSwitchVersions = class(TDNCommandSwitch)

  public
    class function Name: string; override;
    class function Description: string; override;
  end;

implementation

{ TDNCommandSwitchVersions }

class function TDNCommandSwitchVersions.Description: string;
begin
  Result := 'list all released versions of the requested package';
end;

class function TDNCommandSwitchVersions.Name: string;
begin
  Result := 'Versions';
end;

end.
