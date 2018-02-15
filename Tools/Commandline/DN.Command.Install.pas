unit DN.Command.Install;

interface

uses
  DN.Command.Switch,
  DN.Command.DelphiBlock,
  DN.Package.Intf,
  DN.Package.Version.Intf;

type
  TDNCommandInstall = class(TDNCommandDelphiBlock)
  public
    class function Description: string; override;
    class function Name: string; override;
    class function OptionalParameterCount: Integer; override;
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
  DN.Setup.Intf,
  DN.Version,
  DN.Package.Finder.Intf,
  DN.Command.Types,
  DN.Command.Switch.IgnoreDependencies,
  DN.Setup.Dependency.Resolver.Intf,
  DN.Setup.Dependency.Processor.Intf;

const
  CID = 'ID';
  CVersion = 'Version';

{ TDNCommandInstall }

class function TDNCommandInstall.Description: string;
begin
  Result := 'Installs or updates a package';
end;

procedure TDNCommandInstall.Execute;
var
  LEnvironment: IDNCommandEnvironment;
  LSetup: IDNSetup;
  LPackage, LInstalledPackage: IDNPackage;
  LVersion: IDNPackageVersion;
  LFinder: IDNPackageFinder;
  LResolver: IDNSetupDependencyResolver;
  LProcessor: IDNSetupDependencyProcessor;
begin
  inherited;
  BeginBlock();
  try
    LEnvironment := Environment as IDNCommandEnvironment;
    LFinder := LEnvironment.CreatePackageFinder(LEnvironment.OnlinePackages);
    LPackage := LFinder.Find(ReadParameter(CID));
    if ParameterValueCount > 1 then
      LVersion := LEnvironment.VersionFinder.Find(LPackage, ReadParameter(CVersion))
    else if LPackage.Versions.Count > 0 then
      LVersion := LPackage.Versions[0];

    LProcessor := LEnvironment.DependencyProcessor;
    LResolver := LEnvironment.InstallDependencyResolver;
    if HasSwitch<TDNCommandSwitchIgnoreDependencies>() or LProcessor.Execute(LResolver.Resolve(LPackage, LVersion)) then
    begin
      LSetup := LEnvironment.CreateSetup();
      if LEnvironment.CreatePackageFinder(LEnvironment.InstalledPackages).TryFind(LPackage.ID.ToString, LInstalledPackage) then
      begin
        if not LSetup.Update(LPackage, LVersion) then
          raise ECommandFailed.Create('Update failed');
      end
      else
      begin
        if not LSetup.Install(LPackage, LVersion)then
          raise ECommandFailed.Create('Installation failed');
      end;
    end
    else
    begin
      raise ECommandFailed.Create('Failed to process dependencies');
    end;
  finally
    EndBlock();
  end;
end;

class function TDNCommandInstall.Name: string;
begin
  Result := 'Install';
end;

class function TDNCommandInstall.OptionalParameterCount: Integer;
begin
  Result := 1;
end;

class function TDNCommandInstall.Parameter(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := CID;
    1: Result := CVersion;
  end;
end;

class function TDNCommandInstall.ParameterCount: Integer;
begin
  Result := 2;
end;

class function TDNCommandInstall.ParameterDescription(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := 'GUID or Name of a package';
    1: Result := 'Version to install. Most recent is used when not specified'
  end;
end;


class function TDNCommandInstall.SwitchClass(
  AIndex: Integer): TDNCommandSwitchClass;
begin
  if AIndex = inherited SwitchClassCount then
    Result := TDNCommandSwitchIgnoreDependencies
  else
    Result := inherited;
end;

class function TDNCommandInstall.SwitchClassCount: Integer;
begin
  Result := inherited + 1;
end;

end.
