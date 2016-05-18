unit DN.BPLService.Registry;

interface

uses
  Registry,
  DN.BPLService.Intf;

type
  TDNRegistryBPLService = class(TInterfacedObject, IDNBPLService)
  private
    FRegistry: TRegistry;
    FKey: string;
  public
    constructor Create(const ARootKey: string);
    function Install(const ABPLFile: string): Boolean;
    function Uninstall(const ABPLFile: string): Boolean;
  end;

implementation

uses
  Windows,
  IOUtils;

{ TDNRegistryBPLService }

constructor TDNRegistryBPLService.Create(const ARootKey: string);
begin
  inherited Create();
  FKey := TPath.Combine(ARootKey, 'Known Packages');
  FRegistry := TRegistry.Create();
  FRegistry.RootKey := HKEY_CURRENT_USER;
  FRegistry.Access := FRegistry.Access or KEY_WOW64_64KEY;
end;

function TDNRegistryBPLService.Install(const ABPLFile: string): Boolean;
begin
  Result := FRegistry.OpenKey(FKey, True);
  if Result then
  begin
    try
      FRegistry.WriteString(ABPLFile, '');
    finally
      FRegistry.CloseKey();
    end;
  end;
end;

function TDNRegistryBPLService.Uninstall(const ABPLFile: string): Boolean;
begin
  Result := FRegistry.OpenKey(ABPLFile, False);
  if Result then
  try
    Result := FRegistry.DeleteValue(ABPLFile);
  finally
    FRegistry.CloseKey();
  end;
end;

end.
