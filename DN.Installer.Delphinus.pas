unit DN.Installer.Delphinus;

interface

uses
  DN.Types,
  DN.Installer,
  DN.Compiler.Intf,
  DN.ProjectInfo.Intf,
  DN.VariableResolver.Compiler.Factory;

type
  TDNDelphinusInstaller = class(TDNInstaller)
  private
    FRegistryKey: string;
  protected
    function InstallBPL(const ABPL: string): Boolean; override;
    function GetSupportedPlatforms: TDNCompilerPlatforms; override;
    function GetBPLDir(APlatform: TDNCompilerPlatform): string; override;
    function GetDCPDir(APlatform: TDNCompilerPlatform): string; override;
  public
    constructor Create(const ACompiler: IDNCompiler;
      const AVariableResolverFactory: TDNCompilerVariableResolverFacory;
      const ARegistryKey: string); reintroduce;
  end;

implementation

uses
  Registry,
  IOUtils,
  SysUtils;

{ TDNDelphinusInstaller }

constructor TDNDelphinusInstaller.Create(const ACompiler: IDNCompiler;
  const AVariableResolverFactory: TDNCompilerVariableResolverFacory;
  const ARegistryKey: string);
begin
  inherited Create(ACompiler, AVariableResolverFactory);
  FRegistryKey := ARegistryKey;
end;

function TDNDelphinusInstaller.GetBPLDir(
  APlatform: TDNCompilerPlatform): string;
begin
  Result := TPath.Combine(GetTargetDirectory(), 'Bpl');
end;

function TDNDelphinusInstaller.GetDCPDir(
  APlatform: TDNCompilerPlatform): string;
begin
  Result := TPath.Combine(GetTargetDirectory(), 'Dcp');
end;

function TDNDelphinusInstaller.GetSupportedPlatforms: TDNCompilerPlatforms;
begin
  Result := [cpWin32];
end;

function TDNDelphinusInstaller.InstallBPL(const ABPL: string): Boolean;
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create();
  try
    Result := LRegistry.OpenKey(TPath.Combine(FRegistryKey, 'Known Packages'), False);
    if Result then
    begin
      LRegistry.WriteString(ABPL, ExtractFileName(ABPL));
    end;
  finally
    LRegistry.Free;
  end;
end;

end.
