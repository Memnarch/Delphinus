unit DN.Command.Switch.PanicOnError;

interface

uses
  DN.Command.Switch;

type
  TDNCommandSwitchPanicOnError = class(TDNCommandSwitch)
  public
    class function Description: string; override;
    class function Name: string; override;
  end;

implementation

{ TDNCommandSwitchPanicOnError }

class function TDNCommandSwitchPanicOnError.Description: string;
begin
  Result := 'Interactive session is terminated on first failing command'
end;

class function TDNCommandSwitchPanicOnError.Name: string;
begin
  Result := 'PanicOnError';
end;

end.
