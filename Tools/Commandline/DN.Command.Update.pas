unit DN.Command.Update;

interface

uses
  DN.Command,
  DN.Package.Intf;

type
  TDNCommandUpdate = class(TDNCommand)
  private
    procedure PrintUpdateTable(const APackages: TArray<IDNPackage>);
  public
    class function Name: string; override;
    class function Description: string; override;
    procedure Execute; override;
  end;

implementation

uses
  DN.Command.Environment.Intf,
  DN.Setup.Intf;

const
  CTableHeader = 'Name              UpdateTo';
  CColumn1Length = 18;
{ TDNCommandUpdate }

class function TDNCommandUpdate.Description: string;
begin
  Result := 'Updates all installed packages to their most recent version, if they provide versions';
end;

procedure TDNCommandUpdate.Execute;
var
  LEnvironment: IDNCommandEnvironment;
  LSetup: IDNSetup;
  LPackage: IDNPackage;
  LUpdates: TArray<IDNPackage>;
begin
  inherited;
  LEnvironment := Environment as IDNCommandEnvironment;
  LUpdates := LEnvironment.UpdatePackages;
  if Length(LUpdates) > 0 then
  begin
    PrintUpdateTable(LUpdates);
    LSetup := LEnvironment.CreateSetup();
    for LPackage in LUpdates do
      LSetup.Update(LPackage, LPackage.Versions.First);
  end
  else
  begin
    Writeln('No updates available');
  end;
end;

class function TDNCommandUpdate.Name: string;
begin
  Result := 'Update';
end;

procedure TDNCommandUpdate.PrintUpdateTable(
  const APackages: TArray<IDNPackage>);
var
  LPackage: IDNPackage;
  LLine: string;
begin
  Writeln(CTableHeader);
  for LPackage in APackages do
  begin
    LLine := LPackage.Name + StringOfChar(' ', CColumn1Length - Length(LPackage.Name)) + LPackage.Versions.First.Value.ToString;
    Writeln(LLine);
  end;
end;

end.
