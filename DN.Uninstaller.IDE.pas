unit DN.Uninstaller.IDE;

interface

uses
  Classes,
  Types,
  DN.Uninstaller;

type
  TDNIDEUninstaller = class(TDNUninstaller)
  protected
    function RemoveSearchPath(const ASearchPath: string): Boolean; override;
    function UninstallPackage(const ABPLFile: string): Boolean; override;
  public
    function Uninstall(const ADirectory: string): Boolean; override;
  end;

implementation

uses
  Registry,
  SysUtils,
  StrUtils,
  Windows,
  ToolsApi,
  DN.Types,
  DN.ToolsApi;

{ TDNIDEUninstaller }

function TDNIDEUninstaller.RemoveSearchPath(const ASearchPath: string): Boolean;
var
  LService: IOTAServices;
  LRegistryKey: string;
  LPathes: TStringDynArray;
  LPath: string;
  LPathStr: string;
  LReg: TRegistry;
const
  CKey = '\Library\Win32';
  CSearchPath = 'Search Path';
begin
  inherited;
  Result := False;
  LService := BorlandIDEservices as IOTAServices;
  LRegistryKey := LService.GetBaseRegistryKey();
  LReg := TRegistry.Create();
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    LReg.Access := LReg.Access or KEY_WOW64_64KEY;
    if LReg.OpenKey(LRegistryKey + CKey, False) then
    begin
      LPathes := SplitString (LReg.ReadString(CSearchPath), ';');
      LPathStr := '';
      for LPath in LPathes do
      begin
        if LPath <> ASearchPath then
          LPathStr := LPathStr + ';' + LPath;
      end;
      LReg.WriteString(CSearchPath, LPathStr);
      Result := True;
    end;
  finally
    LReg.Free;
  end;
end;

function TDNIDEUninstaller.Uninstall(const ADirectory: string): Boolean;
begin
  Result := inherited;
  if not ReloadEnvironmentOptions() then
    DoMessage(mtWarning, 'Could not refresh Environmentoptions. An IDE restart might be required for all changes to take effect');
end;

function TDNIDEUninstaller.UninstallPackage(const ABPLFile: string): Boolean;
var
  LService: IOTAPackageServices;
  i: Integer;
  LPackage: string;
begin
  LService := BorlandIDEServices as IOTAPackageServices;
  Result := LService.UninstallPackage(ABPLFile);
  if not Result then
  begin
    Result := True;
    LPackage := ExtractFileName(ABPLFile);
    for i := 0 to LService.PackageCount - 1 do
    begin
      if SameText(LService.Package[i].Name, LPackage) then
      begin
        Exit(False);
      end;
    end;
    if Result then
      DoMessage(mtWarning, 'Package was not installed previously');
  end;
end;

end.
