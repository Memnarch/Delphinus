unit DN.ToolsApi.Extension;

interface

uses
  Classes,
  Windows,
  Registry,
  Generics.Collections,
  DN.Compiler.Intf,
  DN.ToolsApi.Extension.Intf;

type
  TDNEnvironmentOptions = class(TInterfacedObject, IDNEnvironmentOptions)
  private
    FPlatform: TDNCompilerPlatform;
    FRegstryKey: string;
    FRegistry: TRegistry;
    FUpdateLevel: Integer;
    FOnChanged: TNotifyEvent;
    function GetPlatform: TDNCompilerPlatform;
    function Open(): Boolean;
    procedure Close();
    function ReadString(const AName: string): string;
    procedure WriteString(const AName, AValue: string);
    function GetBPLOutput: string;
    function GetBrowsingPath: string;
    function GetDCPOutput: string;
    function GetSearchPath: string;
    procedure SetBPLOutput(const Value: string);
    procedure SetBrowsingPath(const Value: string);
    procedure SetDCPOutput(const Value: string);
    procedure SetSearchPath(const Value: string);
    procedure Changed();
  public
    constructor Create(APlatform: TDNCompilerPlatform; const ARegistryKey: string);
    destructor Detsroy();
    procedure BeginUpdate();
    procedure EndUpdate();
    property Platform: TDNCompilerPlatform read GetPlatform;
    property BrowingPath: string read GetBrowsingPath write SetBrowsingPath;
    property SearchPath: string read GetSearchPath write SetSearchPath;
    property BPLOutput: string read GetBPLOutput write SetBPLOutput;
    property DCPOutput: string read GetDCPOutput write SetDCPOutput;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

  TDNEnvironmentOptionsService = class(TInterfacedObject, IDNEnvironmentOptionsService)
  private
    FSupportedPlatforms: TDNCompilerPlatforms;
    FOptions: TList<IDNEnvironmentOptions>;
    FUpdateLevel: Integer;
    FChanges: Integer;
    function GetOptions(
      const APlatform: TDNCompilerPlatform): IDNEnvironmentOptions;
    function GetSupportedPlatforms: TDNCompilerPlatforms;
    procedure LoadPlatforms();
    procedure HandleChanged(Sender: TObject);
  public
    constructor Create();
    destructor Destroy(); override;
    procedure BeginUpdate();
    procedure EndUpdate();
    property Options[const APlatform: TDNCompilerPlatform]: IDNEnvironmentOptions read GetOptions;
    property SupportedPlatforms: TDNCompilerPlatforms read GetSupportedPlatforms;
  end;

implementation

uses
  IOUtils,
  ToolsApi,
  DN.ToolsApi;

const
  CLibraryKey = 'Library';
  CPlatformKeys: array[cpWin32..cpOSX32] of string = ('Win32', 'Win64', 'OSX32');

{ TDNEnvironmentOptionsService }

procedure TDNEnvironmentOptionsService.BeginUpdate;
begin
  Inc(FUpdateLevel);
end;

constructor TDNEnvironmentOptionsService.Create;
begin
  inherited;
  FOptions := TList<IDNEnvironmentOptions>.Create();
  LoadPlatforms();
end;

destructor TDNEnvironmentOptionsService.Destroy;
begin
  FOptions.Free;
  inherited;
end;

procedure TDNEnvironmentOptionsService.EndUpdate;
begin
  if FUpdateLevel > 0 then
  begin
    Dec(FUpdateLevel);
    if (FUpdateLevel = 0) and (FChanges > 0) then
    begin
      FChanges := 0;
      ReloadEnvironmentOptions();
    end;
  end;
end;

function TDNEnvironmentOptionsService.GetOptions(
  const APlatform: TDNCompilerPlatform): IDNEnvironmentOptions;
var
  LOption: IDNEnvironmentOptions;
begin
  Result := nil;
  for LOption in FOptions do
  begin
    if LOption.Platform = APlatform then
      Exit(LOption);
  end;
end;

function TDNEnvironmentOptionsService.GetSupportedPlatforms: TDNCompilerPlatforms;
begin
  Result := FSupportedPlatforms;
end;

procedure TDNEnvironmentOptionsService.HandleChanged(Sender: TObject);
begin
  if FUpdateLevel  = 0 then
    ReloadEnvironmentOptions()
  else
    Inc(FChanges);
end;

procedure TDNEnvironmentOptionsService.LoadPlatforms;
var
  LService: IOTAServices;
  LReg: TRegistry;
  LBase, LLibraryKey, LPlatformKey: string;
  LNames: TStringList;
  LOptions: TDNEnvironmentOptions;
  LPlatform: TDNCompilerPlatform;
begin
  LService := BorlandIDEservices as IOTAServices;
  LBase := LService.GetBaseRegistryKey();
  LReg := TRegistry.Create();
  LNames := TStringList.Create();
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    LLibraryKey := TPath.Combine(LBase ,CLibraryKey);
    if LReg.OpenKey(LLibraryKey, False) then
    begin
      LReg.GetValueNames(LNames);
      //we are on a Win32-Only Delphi
      if LNames.Count > 0 then
      begin
        LOptions := TDNEnvironmentOptions.Create(cpWin32, LLibraryKey);
        LOptions.OnChanged := HandleChanged;
        FOptions.Add(LOptions);
        FSupportedPlatforms := [cpWin32];
      end
      else
      begin
        //we are on a multiplatform Delphi
        FSupportedPlatforms := [];
        for LPlatform := Low(CPlatformKeys) to High(CPlatformKeys) do
        begin
          if LReg.KeyExists(CPlatformKeys[LPlatform]) then
          begin
            LPlatformKey := TPath.Combine(LLibraryKey, CPlatformKeys[LPlatform]);
            LOptions := TDNEnvironmentOptions.Create(LPlatform, LPlatformKey);
            LOptions.OnChanged := HandleChanged;
            FOptions.Add(LOptions);
            FSupportedPlatforms := FSupportedPlatforms + [LPlatform];
          end;
        end;
      end;
    end;
  finally
    LReg.Free;
    LNames.Free;
  end;
end;

{ TDNEnvironmentOptions }

procedure TDNEnvironmentOptions.BeginUpdate;
begin
  Inc(FUpdateLevel);
end;

procedure TDNEnvironmentOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TDNEnvironmentOptions.Close;
begin
  FRegistry.CloseKey();
end;

constructor TDNEnvironmentOptions.Create(APlatform: TDNCompilerPlatform;
  const ARegistryKey: string);
begin
  inherited Create();
  FPlatform := APlatform;
  FRegstryKey := ARegistryKey;
  FRegistry := TRegistry.Create();
  FRegistry.RootKey := HKEY_CURRENT_USER;
end;

destructor TDNEnvironmentOptions.Detsroy;
begin
  FRegistry.Free;
  inherited;
end;

procedure TDNEnvironmentOptions.EndUpdate;
begin
  if FUpdateLevel > 0 then
  begin
    Dec(FUpdateLevel);
    if FUpdateLevel = 0 then
      Changed();
  end;
end;

function TDNEnvironmentOptions.GetBPLOutput: string;
begin
  Result := ReadString('Package DPL Output');
end;

function TDNEnvironmentOptions.GetBrowsingPath: string;
begin
  Result := ReadString('Browsing Path');
end;

function TDNEnvironmentOptions.GetDCPOutput: string;
begin
  Result := ReadString('Package DCP Output');
end;

function TDNEnvironmentOptions.GetPlatform: TDNCompilerPlatform;
begin
  Result := FPlatform;
end;

function TDNEnvironmentOptions.GetSearchPath: string;
begin
  Result := ReadString('Search Path');
end;

function TDNEnvironmentOptions.Open: Boolean;
begin
  Result := FRegistry.OpenKey(FRegstryKey, False);
end;

function TDNEnvironmentOptions.ReadString(const AName: string): string;
begin
  if Open then
  begin
    try
      Result := FRegistry.ReadString(AName);
    finally
      Close();
    end;
  end
  else
    Result := '';
end;

procedure TDNEnvironmentOptions.SetBPLOutput(const Value: string);
begin
  WriteString('Package DPL Output', Value);
end;

procedure TDNEnvironmentOptions.SetBrowsingPath(const Value: string);
begin
  WriteString('Browsing Path', Value);
end;

procedure TDNEnvironmentOptions.SetDCPOutput(const Value: string);
begin
  WriteString('Package DCP Output', Value);
end;

procedure TDNEnvironmentOptions.SetSearchPath(const Value: string);
begin
  WriteString('Search Path', Value);
end;

procedure TDNEnvironmentOptions.WriteString(const AName, AValue: string);
begin
  if Open() then
  begin
    try
      FRegistry.WriteString(AName, AValue);
    finally
      Close();
    end;
    if FUpdateLevel = 0 then
      Changed();
  end;
end;

initialization
  GDelphinusIDEServices := TDNEnvironmentOptionsService.Create();

finalization
  GDelphinusIDEServices := nil;

end.
