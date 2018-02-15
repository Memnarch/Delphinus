unit DN.Command.Update;

interface

uses
  DN.Command.DelphiBlock,
  DN.Package.Intf,
  DN.Command.Switch;

type
  TDNCommandUpdate = class(TDNCommandDelphiBlock)
  private
    procedure PrintUpdateTable(const APackages: TArray<IDNPackage>);
  public
    class function Name: string; override;
    class function Description: string; override;
    class function SwitchClass(AIndex: Integer): TDNCommandSwitchClass; override;
    class function SwitchClassCount: Integer; override;

    procedure Execute; override;
  end;

implementation

uses
  DN.Command.Types,
  DN.Command.Environment.Intf,
  DN.Setup.Intf,
  DN.TextTable.Intf,
  DN.TextTable,
  DN.Command.Switch.IgnoreDependencies,
  DN.Setup.Dependency.Resolver.Intf,
  DN.Setup.Dependency.Processor.Intf;

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
  LResolver: IDNSetupDependencyResolver;
  LProcessor: IDNSetupDependencyProcessor;
begin
  inherited;
  BeginBlock();
  try
    LEnvironment := Environment as IDNCommandEnvironment;
    LUpdates := LEnvironment.UpdatePackages;
    if Length(LUpdates) > 0 then
    begin
      PrintUpdateTable(LUpdates);
      LSetup := LEnvironment.CreateSetup();
      for LPackage in LUpdates do
      begin
        LResolver := LEnvironment.InstallDependencyResolver;
        LProcessor := LEnvironment.DependencyProcessor;
        if HasSwitch<TDNCommandSwitchIgnoreDependencies> or LProcessor.Execute(LResolver.Resolve(LPackage, LPackage.Versions.First)) then
        begin
          if not LSetup.Update(LPackage, LPackage.Versions.First) then
            raise ECommandFailed.Create('Failed to update ' + LPackage.Name);
        end
        else
        begin
          raise ECommandFailed.Create('failed to process dependencies of ' + LPackage.Name);
        end;
      end;
    end
    else
    begin
      Writeln('No updates available');
    end;
  finally
    EndBlock();
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
  LTable: IDNTextTable;
begin
  LTable := TDNTextTable.Create();
  LTable.AddColumn('Name', 20);
  LTable.AddColumn('UpdateTo');
  for LPackage in APackages do
    LTable.AddRecord([LPackage.Name, LPackage.Versions.First.Value.ToString]);

  Writeln('');
  Writeln(LTable.Text);
end;

class function TDNCommandUpdate.SwitchClass(
  AIndex: Integer): TDNCommandSwitchClass;
begin
  if AIndex = inherited SwitchClassCount then
    Result := TDNCommandSwitchIgnoreDependencies
  else
    Result := inherited;
end;

class function TDNCommandUpdate.SwitchClassCount: Integer;
begin
  Result := inherited + 1;
end;

end.
