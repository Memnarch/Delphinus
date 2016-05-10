unit DN.Command.Exit;

interface

uses
  DN.Command;

type
  TDNCommandExit = class(TDNCommand)

  public
    class function Name: string; override;
    class function Description: string; override;
    procedure Execute; override;
  end;

implementation

uses
  DN.Command.Environment.Intf;

{ TDNCommandExit }

class function TDNCommandExit.Description: string;
begin
  Result := 'Quits interactive session';
end;

procedure TDNCommandExit.Execute;
begin
  (Environment as IDNCommandEnvironment).Interactive := False;
end;

class function TDNCommandExit.Name: string;
begin
  Result := 'Exit';
end;

end.
