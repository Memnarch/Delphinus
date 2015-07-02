unit DN.Installer.IDE;

interface

uses
  Classes,
  Types,
  DN.Installer,
  DN.ProjectInfo.Intf,
  DN.Compiler.Intf;

type
  TDNIDEInstaller = class(TDNInstaller)
  protected
    procedure AddSearchPath(const ASearchPath: string; const APlatforms: TDNCompilerPlatforms); override;
    function InstallProject(const AProject: IDNProjectInfo): Boolean; override;
  public
    function Install(const ASourceDirectory: string;
      const ATargetDirectory: string): Boolean; override;
  end;

implementation

uses
  Windows,
  SysUtils,
  Registry,
  DN.Types,
  ToolsApi,
  DN.ToolsApi.Extension.Intf;

{ TDNIDEInstaller }

procedure TDNIDEInstaller.AddSearchPath(const ASearchPath: string; const APlatforms: TDNCompilerPlatforms);
var
  LService: IDNEnvironmentOptionsService;
  LPlatform: TDNCompilerPlatform;
  LPathes: string;
begin
  inherited;
  LService := GDelphinusIDEServices as IDNEnvironmentOptionsService;
  for LPlatform in APlatforms do
  begin
    if LPlatform in LService.SupportedPlatforms then
    begin
      LPathes := LService.Options[LPlatform].SearchPath;
      if LPathes <> '' then
        LPathes := LPathes + ';' + ASearchPath
      else
        LPathes := ASearchPath;

      LService.Options[LPlatform].SearchPath := LPathes;
    end;
  end;
end;

function TDNIDEInstaller.Install(const ASourceDirectory,
  ATargetDirectory: string): Boolean;
var
  LService: IDNEnvironmentOptionsService;
begin
  LService := GDelphinusIDEServices as IDNEnvironmentOptionsService;
  LService.BeginUpdate();
  try
    Result := inherited;
  finally
    LService.EndUpdate();
  end;
end;

function TDNIDEInstaller.InstallProject(const AProject: IDNProjectInfo): Boolean;
var
  LService: IOTAPackageServices;
begin
  LService := BorlandIDEServices as IOTAPackageServices;
  Result := LService.InstallPackage(AProject.BinaryName);
end;

end.
