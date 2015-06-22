unit DN.Installer.IDE;

interface

uses
  Classes,
  Types,
  DN.Installer,
  DN.ProjectInfo.Intf;

type
  TDNIDEInstaller = class(TDNInstaller)
  protected
    procedure AddSearchPath(const ASearchPath: string); override;
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
  DN.ToolsApi;

{ TDNIDEInstaller }

procedure TDNIDEInstaller.AddSearchPath(const ASearchPath: string);
var
  LService: IOTAServices;
  LPathes, LRegistryKey: string;
  LReg: TRegistry;
const
  CKey = '\Library\Win32';
  CSearchPath = 'Search Path';
begin
  inherited;
  LService := BorlandIDEservices as IOTAServices;
  LRegistryKey := LService.GetBaseRegistryKey();
  LReg := TRegistry.Create();
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    LReg.Access := LReg.Access or KEY_WOW64_64KEY;
    if LReg.OpenKey(LRegistryKey + CKey, False) then
    begin
      LPathes := LReg.ReadString(CSearchPath);
      if LPathes <> '' then
        LPathes := LPathes + ';' + ASearchPath
      else
        LPathes := ASearchPath;

      LReg.WriteString(CSearchPath, LPathes);
    end;
  finally
    LReg.Free;
  end;
end;

function TDNIDEInstaller.Install(const ASourceDirectory,
  ATargetDirectory: string): Boolean;
begin
  Result := inherited;
  if not ReloadEnvironmentOptions() then
      DoMessage(mtWarning, 'Could not refresh Environmentoptions. An IDE restart might be required for all changes to take effect');
end;

function TDNIDEInstaller.InstallProject(const AProject: IDNProjectInfo): Boolean;
var
  LService: IOTAPackageServices;
begin
  LService := BorlandIDEServices as IOTAPackageServices;
  Result := LService.InstallPackage(AProject.BinaryName);
end;

end.
