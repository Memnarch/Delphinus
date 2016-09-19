unit DN.Command.Delphis;

interface

uses
  DN.Command;

type
  TDNCommandDelphis = class(TDNCommand)
  public
    class function Name: string; override;
    class function Description: string; override;
    procedure Execute; override;
  end;

implementation

uses
  DN.TextTable,
  DN.TextTable.Intf,
  DN.DelphiInstallation.Intf,
  DN.Command.Environment.Intf;

{ TDNCommandDelphis }

class function TDNCommandDelphis.Description: string;
begin
  Result := 'Lists all detected Delphis and their shortnames (used for -Delphi switch)';
end;

procedure TDNCommandDelphis.Execute;
var
  LInstallation: IDNDelphiInstallation;
  LTable: IDNTextTable;
  LEnvironment: IDNCommandEnvironment;
begin
  inherited;
  LTable := TDNTextTable.Create();
  LTable.AddColumn('Name', 20);
  LTable.AddColumn('Shortname', 10);
  LTable.AddColumn('BDS', 5);
  LTable.AddColumn('Edition');
  LEnvironment := Environment as IDNCommandEnvironment;
  for LInstallation in LEnvironment.DelphiInstallations do
    LTable.AddRecord([LInstallation.Name, LInstallation.ShortName, LInstallation.BDSVersion, LInstallation.Edition]);

  Writeln('');
  Writeln(LTable.Text);
end;

class function TDNCommandDelphis.Name: string;
begin
  Result := 'Delphis';
end;

end.
