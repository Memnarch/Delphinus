unit DN.Command.Uninstall;

interface

uses
  DN.Command.Switch,
  DN.Command.DelphiBlock;

type
  TDNCommandUninstall = class(TDNCommandDelphiBlock)
  public
    class function Description: string; override;
    class function Name: string; override;
    class function Parameter(AIndex: Integer): string; override;
    class function ParameterCount: Integer; override;
    class function ParameterDescription(AIndex: Integer): string; override;
    class function SwitchClass(AIndex: Integer): TDNCommandSwitchClass; override;
    class function SwitchClassCount: Integer; override;

    procedure Execute; override;
  end;

implementation

uses
  SysUtils,
  DN.Command.Environment.Intf,
  DN.Command.Types,
  DN.Setup.Intf,
  DN.Package.Intf,
  DN.Package.Finder.Intf,
  DN.Command.Switch.IgnoreDependencies,
  DN.Setup.Dependency.Resolver.Intf,
  DN.Setup.Dependency.Processor.Intf;

const
  CID = 'ID';

{ TDNCommandUninstall }

class function TDNCommandUninstall.Description: string;
begin
  Result := 'Uninstalls a given package'
end;

procedure TDNCommandUninstall.Execute;
var
  LEnvironment: IDNCommandEnvironment;
  LSetup: IDNSetup;
  LPackage: IDNPackage;
  LFinder: IDNPackageFinder;
  LResolver: IDNSetupDependencyResolver;
  LProcessor: IDNSetupDependencyProcessor;
begin
  inherited;
  BeginBlock();
  try
    LEnvironment := Environment as IDNCommandEnvironment;
    LFinder := LEnvironment.CreatePackageFinder(LEnvironment.InstalledPackages);
    LPackage := LFinder.Find(ReadParameter(CID));
    LResolver := LEnvironment.UninstallDependencyResolver;
    LProcessor := LEnvironment.DependencyProcessor;
    if HasSwitch<TDNCommandSwitchIgnoreDependencies> or LProcessor.Execute(LResolver.Resolve(LPackage, LPackage.Versions.First)) then
    begin
      LSetup := LEnvironment.CreateSetup();
      if not LSetup.Uninstall(LPackage) then
        raise ECommandFailed.Create('Could not uninstall ' + LPackage.Name);
    end
    else
    begin
      raise ECommandFailed.Create('Failed to process dependencies');
    end;
  finally
    EndBlock();
  end;
end;

class function TDNCommandUninstall.Name: string;
begin
  Result := 'Uninstall';
end;

class function TDNCommandUninstall.Parameter(AIndex: Integer): string;
begin
  if AIndex = 0 then
    Result := CID
  else
    Result := inherited;
end;

class function TDNCommandUninstall.ParameterCount: Integer;
begin
  Result := 1;
end;

class function TDNCommandUninstall.ParameterDescription(
  AIndex: Integer): string;
begin
  if AIndex = 0 then
    Result := 'GUID or Name of the package to uninstall'
  else
    Result := inherited;
end;

class function TDNCommandUninstall.SwitchClass(
  AIndex: Integer): TDNCommandSwitchClass;
begin
  if AIndex = inherited SwitchClassCount  then
    Result := TDNCommandSwitchIgnoreDependencies
  else
    Result := inherited;
end;

class function TDNCommandUninstall.SwitchClassCount: Integer;
begin
  Result := inherited + 1;
end;

end.
