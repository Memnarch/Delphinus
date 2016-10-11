unit DN.Command.Switch.License;

interface

uses
  DN.Command.Switch;

type
  TDNCommandSwitchLicense = class(TDNCommandSwitch)
  public
    class function Name: string; override;
    class function Description: string; override;
  end;

implementation

{ TDNCommandSwitchLicense }

class function TDNCommandSwitchLicense.Description: string;
begin
  Result := 'Displays the licensetext';
end;

class function TDNCommandSwitchLicense.Name: string;
begin
  Result := 'License';
end;

end.
