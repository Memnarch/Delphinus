unit DN.EnvironmentOptions.Project;

interface

uses
  ToolsApi,
  DN.Types,
  DN.EnvironmentOptions,
  DN.EnvironmentOptions.Intf;

type
  TDNProjectEnvironmentOptions = class(TDNEnvironmentOptions)
  private
    FConfig: IOTABuildConfiguration;
  protected
    function ReadString(const AName: string): string; override;
    procedure WriteString(const AName: string; const AValue: string); override;
  public
    constructor Create(const AConfig: IOTABuildConfiguration; APlatform: TDNCompilerPlatform);
  end;

  TDNProjectEnvironmentOptionsService = class(TDNEnvironmentOptionsService)
  private
    FProject: IOTAProject;
  public
    constructor Create(const AProject: IOTAProject);
  end;

implementation

uses
  DCCStrs,
  SysUtils,
  DN.Utils;

{ TDNProjectEnvironmentOptionsService }

constructor TDNProjectEnvironmentOptionsService.Create(
  const AProject: IOTAProject);
var
  LConfigs: IOTAProjectOptionsConfigurations140;
  LConfig: IOTABuildConfiguration;
  LPlatformName: string;
  LPlatform: TDNCompilerPlatform;
  LEnvironment: IDNEnvironmentOptions;
begin
  inherited Create();
  FProject := AProject;
  if Supports(FProject.ProjectOptions, IOTAProjectOptionsConfigurations140, LConfigs) then
  begin
    {$IF Declared(IOTABuildConfiguration140)}
    for LPlatformName in LConfigs.BaseConfiguration.Platforms do
    begin
      if TryPlatformNameToCompilerPlatform(LPlatformName, LPlatform) then
      begin
        LConfig := LConfigs.BaseConfiguration.PlatformConfiguration[LPlatformName];
        LEnvironment := TDNProjectEnvironmentOptions.Create(LConfig, LPlatform);
        AddOption(LEnvironment);
      end;
    end;
    {$else}
      AddOption(TDNProjectEnvironmentOptions.Create(LConfigs.BaseConfiguration, cpWin32));
    {$IfEnd}
  end;
end;

{ TDNProjectEnvironmentOptions }

constructor TDNProjectEnvironmentOptions.Create(
  const AConfig: IOTABuildConfiguration; APlatform: TDNCompilerPlatform);
begin
  inherited Create(APlatform);
  FConfig := AConfig;
  FSearchPathName := sUnitSearchPath;
  FBPLOutputName := sBplOutput;
  FDCPOutputName := sDcpOutput;
end;

function TDNProjectEnvironmentOptions.ReadString(const AName: string): string;
begin
  Result := FConfig.Value[AName];
end;

procedure TDNProjectEnvironmentOptions.WriteString(const AName, AValue: string);
begin
  FConfig.Value[AName] := AValue;
end;

end.
