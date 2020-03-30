unit DN.Installer.Project;

interface

uses
  DN.Types,
  DN.JSonFile.Installation,
  DN.EnvironmentOptions.Intf,
  DN.VariableResolver.Compiler.Factory,
  DN.Installer.IDE;

type
  TDNIDEProjectInstaller = class(TDNIDEInstaller)
  protected
    function ProcessProjects(const AProjects: TArray<TProject>; const ATargetDirectory: string): Boolean; override;
    function ProcessExperts(const AExperts: TArray<TExpert>): Boolean; override;
  public
  constructor Create(
      const AEnvironmentOptionsService: IDNEnvironmentOptionsService;
      const AVariableResolverFactory: TDNCompilerVariableResolverFacory); reintroduce;
  end;

implementation

{ TDNIDEProjectInstaller }


constructor TDNIDEProjectInstaller.Create(
  const AEnvironmentOptionsService: IDNEnvironmentOptionsService;
  const AVariableResolverFactory: TDNCompilerVariableResolverFacory);
begin
  inherited Create(nil, AEnvironmentOptionsService, nil, AVariableResolverFactory);
end;

function TDNIDEProjectInstaller.ProcessExperts(
  const AExperts: TArray<TExpert>): Boolean;
begin
  Result := True;
end;

function TDNIDEProjectInstaller.ProcessProjects(
  const AProjects: TArray<TProject>; const ATargetDirectory: string): Boolean;
begin
  Result := True;
end;

end.
