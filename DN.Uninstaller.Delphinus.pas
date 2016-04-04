unit DN.Uninstaller.Delphinus;

interface

uses
  DN.Uninstaller;

type
  TDNDelphinusUninstaller = class(TDNUninstaller)
  private
    FRegistryKey: string;
  protected
    function UninstallPackage(const ABPLFile: string): Boolean; override;
  public
    constructor Create(const ARegistryKey: string);
  end;

implementation

uses
  IOUtils,
  SysUtils,
  Registry,
  DN.Types;

{ TDNDelphinusUninstaller }

constructor TDNDelphinusUninstaller.Create(const ARegistryKey: string);
begin
  inherited Create();
  FRegistryKey := ARegistryKey;
end;

function TDNDelphinusUninstaller.UninstallPackage(
  const ABPLFile: string): Boolean;
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create();
  try
    Result := LRegistry.OpenKey(TPath.Combine(FRegistryKey, 'Known Packages'), False);
    if Result then
    begin
      if LRegistry.ValueExists(ABPLFile) then
        LRegistry.DeleteValue(ABPLFile)
      else
        DoMessage(mtWarning, 'Package was not registered before: ' + ABPLFile);
    end
    else
    begin
      DoMessage(mtError, 'Failed to open registrykey for removing registered package ' + ABPLFile);
    end;
  finally
    LRegistry.Free;
  end;
end;

end.
