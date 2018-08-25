unit DN.Command.Switch.License;

interface

uses
  DN.Command.Switch,
  DN.Command.Argument.Intf;

type
  TDNCommandSwitchLicense = class(TDNCommandSwitch)
  private
    FLicenseType: string;
  public
    class function Name: string; override;
    class function Description: string; override;
    class function ParameterCount: Integer; override;
    class function OptionalParameterCount: Integer; override;
    class function Parameter(AIndex: Integer): string; override;
    class function ParameterDescription(AIndex: Integer): string; override;
    procedure Initialize(const AArgument: IDNCommandSwitchArgument); override;
    property LicenseType: string read FLicenseType;
  end;

implementation

{ TDNCommandSwitchLicense }

class function TDNCommandSwitchLicense.Description: string;
begin
  Result := 'Displays the licensetext';
end;

procedure TDNCommandSwitchLicense.Initialize(
  const AArgument: IDNCommandSwitchArgument);
begin
  inherited;
  if Length(AArgument.Parameters) > 0 then
    FLicenseType := AArgument.Parameters[0];
end;

class function TDNCommandSwitchLicense.Name: string;
begin
  Result := 'License';
end;

class function TDNCommandSwitchLicense.OptionalParameterCount: Integer;
begin
  Result := inherited + 1;
end;

class function TDNCommandSwitchLicense.Parameter(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := 'LicenseType';
  end;
end;

class function TDNCommandSwitchLicense.ParameterCount: Integer;
begin
  Result := inherited + 1;
end;

class function TDNCommandSwitchLicense.ParameterDescription(
  AIndex: Integer): string;
begin
  case AIndex of
    0: Result := 'Specify a specific licensetype to display instead of all licenses in a package';
  end;
end;

end.
