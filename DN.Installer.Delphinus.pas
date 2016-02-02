unit DN.Installer.Delphinus;

interface

uses
  DN.Installer,
  DN.Compiler.Intf,
  DN.ProjectInfo.Intf;

type
  TDNDelphinusInstaller = class(TDNInstaller)
  private
    FRegistryKey: string;
  protected
    function InstallProject(const AProject: IDNProjectInfo;
      const ABPLDirectory: string): Boolean; override;
    function GetSupportedPlatforms: TDNCompilerPlatforms; override;
    procedure ConfigureCompiler(const ACompiler: IDNCompiler); override;
  public
    constructor Create(const ACompiler: IDNCompiler; const ARegistryKey: string); reintroduce;
  end;

implementation

uses
  Registry,
  IOUtils,
  SysUtils;

{ TDNDelphinusInstaller }

procedure TDNDelphinusInstaller.ConfigureCompiler(const ACompiler: IDNCompiler);
var
  LSubFolder: string;
begin
  inherited;
  LSubFolder := ExtractFileName(ExcludeTrailingPathDelimiter(FRegistryKey));
  ACompiler.BPLOutput := TPath.Combine(GetTargetDirectory(), LSubFolder);
  ACompiler.DCPOutput := TPath.Combine(ACompiler.BPLOutput, 'Dcp');
end;

constructor TDNDelphinusInstaller.Create(const ACompiler: IDNCompiler;
  const ARegistryKey: string);
begin
  inherited Create(ACompiler);
  FRegistryKey := ARegistryKey;
end;

function TDNDelphinusInstaller.GetSupportedPlatforms: TDNCompilerPlatforms;
begin
  Result := [cpWin32];
end;

function TDNDelphinusInstaller.InstallProject(const AProject: IDNProjectInfo;
  const ABPLDirectory: string): Boolean;
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create();
  try
    Result := LRegistry.OpenKey(TPath.Combine(FRegistryKey, 'Known Packages'), False);
    if Result then
    begin
      LRegistry.WriteString(TPath.Combine(ABPLDirectory, AProject.BinaryName), AProject.BinaryName);
    end;
  finally
    LRegistry.Free;
  end;
end;

end.
