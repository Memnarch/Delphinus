unit DN.Command.Default;

interface

uses
  DN.Command;

type
  TDNCommandDefault = class(TDNCommand)
  public
    class function Description: string; override;
    class function Name: string; override;
    procedure Execute; override;
  end;

implementation

uses
  DN.Command.Environment.Intf;

{ TDNCommandDefault }

class function TDNCommandDefault.Description: string;
begin
  Result := 'Start interactive session for executing multiple tasks before quiting';
end;

procedure TDNCommandDefault.Execute;
begin
  (Environment as IDNCommandEnvironment).Interactive := True;
end;

class function TDNCommandDefault.Name: string;
begin
  Result := '';
end;

end.
