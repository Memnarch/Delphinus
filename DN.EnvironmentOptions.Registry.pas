unit DN.EnvironmentOptions.Registry;

interface

uses
  Registry,
  Generics.Collections,
  DN.Compiler.Intf,
  DN.EnvironmentOptions;

type
  TDNRegistryEnvironmentOptions = class(TDNEnvironmentOptions)
  private
    FRegistry: TRegistry;
    FKey: string;
  protected
    function ReadString(const AName: string): string; override;
    procedure WriteString(const AName: string; const AValue: string); override;
  public
    constructor Create(const ARegistryKey: string; APlatform: TDNCompilerPlatform); reintroduce;
    destructor Destroy; override;
  end;

  TDNRegistryEnvironmentOptionsService = class(TDNEnvironmentOptionsService)
  public
    constructor Create(const ARegistryRoot: string; ASupportedPlatforms: TDNCompilerPlatforms); reintroduce;
  end;


implementation

uses
  Windows,
  IOUtils,
  DN.EnvironmentOptions.Intf;

{ TDNRegistryEnvironmentOptionsService }

constructor TDNRegistryEnvironmentOptionsService.Create(
  const ARegistryRoot: string; ASupportedPlatforms: TDNCompilerPlatforms);
var
  LPlatform: TDNCompilerPlatform;
  LOption: IDNEnvironmentOptions;
  LLibKey: string;
begin
  inherited Create;
  LLibKey := TPath.Combine(ARegistryRoot, 'Library');
  if ASupportedPlatforms = [cpWin32] then
  begin
    LOption := TDNRegistryEnvironmentOptions.Create(LLibKey, cpWin32);
    AddOption(LOption);
  end
  else
  begin
    for LPlatform in ASupportedPlatforms do
    begin
      LOption := TDNRegistryEnvironmentOptions.Create(TPath.Combine(LLibKey, TDNCompilerPlatformName[LPlatform]), LPlatform);
      AddOption(LOption);
    end;
  end;
end;

{ TDNRegistryEnvironmentOptions }

constructor TDNRegistryEnvironmentOptions.Create(const ARegistryKey: string;
  APlatform: TDNCompilerPlatform);
begin
  inherited Create(APlatform);
  FSearchPathName := 'Search Path';
  FBPLOutputName := 'Package DPL Output';
  FBrowsingPathName := 'Browsing Path';
  FDCPOutputName := 'Package DCP Output';
  FKey := ARegistryKey;
  FRegistry := TRegistry.Create();
  FRegistry.RootKey := HKEY_CURRENT_USER;
  FRegistry.Access := FRegistry.Access or KEY_WOW64_64KEY;
end;

destructor TDNRegistryEnvironmentOptions.Destroy;
begin
  FRegistry.Free();
  inherited;
end;

function TDNRegistryEnvironmentOptions.ReadString(const AName: string): string;
begin
  if FRegistry.OpenKey(FKey, False) then
  begin
    try
      Result := FRegistry.ReadString(AName);
    finally
      FRegistry.CloseKey();
    end
  end
  else
    Result := '';
end;

procedure TDNRegistryEnvironmentOptions.WriteString(const AName,
  AValue: string);
begin
  if FRegistry.OpenKey(FKey, True) then
  begin
    try
      FRegistry.WriteString(AName, AValue);
    finally
      FRegistry.CloseKey();
    end;
  end;
end;

end.
