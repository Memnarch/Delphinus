{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.EnvironmentOptions.IDE;

interface

uses
  Classes,
  Windows,
  Registry,
  IniFiles,
  Generics.Collections,
  ToolsApi,
  DN.Compiler.Intf,
  DN.EnvironmentOptions.Intf;

type
  TDNEnvironmentOptions = class(TInterfacedObject, IDNEnvironmentOptions)
  private
    FPlatform: TDNCompilerPlatform;
    FUpdateLevel: Integer;
    FOnChanged: TNotifyEvent;
    function GetPlatform: TDNCompilerPlatform;
    function GetBPLOutput: string;
    function GetBrowsingPath: string;
    function GetDCPOutput: string;
    function GetSearchPath: string;
    procedure SetBPLOutput(const Value: string);
    procedure SetBrowsingPath(const Value: string);
    procedure SetDCPOutput(const Value: string);
    procedure SetSearchPath(const Value: string);
  protected
    FBrowsingPathName: string;
    FSearchPathName: string;
    FBPLOutputName: string;
    FDCPOutputName: string;
    function ReadString(const AName: string): string; virtual; abstract;
    procedure WriteString(const AName, AValue: string); virtual; abstract;
    procedure Changed(); virtual;
  public
    constructor Create(APlatform: TDNCompilerPlatform);
    procedure BeginUpdate();
    procedure EndUpdate();
    property Platform: TDNCompilerPlatform read GetPlatform;
    property BrowingPath: string read GetBrowsingPath write SetBrowsingPath;
    property SearchPath: string read GetSearchPath write SetSearchPath;
    property BPLOutput: string read GetBPLOutput write SetBPLOutput;
    property DCPOutput: string read GetDCPOutput write SetDCPOutput;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

  TDNRegistryEnvironmentOptions = class(TDNEnvironmentOptions)
  private
    FRegstryKey: string;
    FRegistryOptions: TObject;
    FRegistry: TMemIniFile;
  protected
    function ReadString(const AName: string): string; override;
    procedure WriteString(const AName, AValue: string); override;
    procedure Changed; override;
  public
    constructor Create(APlatform: TDNCompilerPlatform; const ARegistryKey: string; const ARegistryOptions : TObject);
  end;

  TDNOTAEnvironmentOptions = class(TDNEnvironmentOptions)
  private
    FOptions: IOTAOptions;
  protected
    function ReadString(const AName: string): string; override;
    procedure WriteString(const AName: string; const AValue: string); override;
  public
    constructor Create(APlatform: TDNCompilerPlatform);
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
  DN.ToolsApi,
  RTTI;

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
  Inc(FChanges);
end;

procedure TDNEnvironmentOptionsService.LoadPlatforms;
var
  LService: IOTAServices;
  LReg: TRegistry;
  LBase, LLibraryKey, LPlatformKey: string;
  LOptions: TDNEnvironmentOptions;
  LPlatform: TDNCompilerPlatform;
  LRegistryOptions: TObject;
begin
  LService := BorlandIDEservices as IOTAServices;
  LBase := LService.GetBaseRegistryKey();
  LReg := TRegistry.Create();
  try
    LReg.RootKey := HKEY_CURRENT_USER;
    LLibraryKey := TPath.Combine(LBase ,CLibraryKey);
    if LReg.OpenKey(LLibraryKey, False) then
    begin
      //we are on a Win32-Only Delphi
      if CompilerVersion <= 22 then
      begin
        LOptions := TDNOTAEnvironmentOptions.Create(cpWin32);
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

            LRegistryOptions := GetRegistryOptionsObject(GetEnvironmentOptionObject(), LPlatformKey);

            if Assigned(LRegistryOptions) then
            begin
              LOptions := TDNRegistryEnvironmentOptions.Create(LPlatform, LPlatformKey, LRegistryOptions);
              LOptions.OnChanged := HandleChanged;
              FOptions.Add(LOptions);
              FSupportedPlatforms := FSupportedPlatforms + [LPlatform];
            end;
          end;
        end;
      end;
    end;
  finally
    LReg.Free;
  end;
end;

{ TDNEnvironmentOptions }

procedure TDNEnvironmentOptions.BeginUpdate;
begin
  Inc(FUpdateLevel);
end;

procedure TDNRegistryEnvironmentOptions.Changed;
var
  LContext: TRttiContext;
  LType: TRttiType;
begin
  LType := LContext.GetType(FRegistryOptions.ClassType);
  LType.GetMethod('SavePropValues').Invoke(FRegistryOptions, []);
  inherited;
end;

constructor TDNRegistryEnvironmentOptions.Create(APlatform: TDNCompilerPlatform; const ARegistryKey: string; const ARegistryOptions : TObject);
begin
  inherited Create(APlatform);
  FSearchPathName := 'Search Path';
  FBPLOutputName := 'Package DPL Output';
  FBrowsingPathName := 'Browsing Path';
  FDCPOutputName := 'Package DCP Output';
  FRegstryKey := ARegistryKey;
  FRegistryOptions := ARegistryOptions;
  FRegistry := GetRegistryOptionsMemIni(FRegistryOptions);
end;

procedure TDNEnvironmentOptions.Changed;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

constructor TDNEnvironmentOptions.Create(APlatform: TDNCompilerPlatform);
begin
  inherited Create();
  FPlatform := APlatform;
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
  Result := ReadString(FBPLOutputName);
end;

function TDNEnvironmentOptions.GetBrowsingPath: string;
begin
  Result := ReadString(FBrowsingPathName);
end;

function TDNEnvironmentOptions.GetDCPOutput: string;
begin
  Result := ReadString(FDCPOutputName);
end;

function TDNEnvironmentOptions.GetPlatform: TDNCompilerPlatform;
begin
  Result := FPlatform;
end;

function TDNEnvironmentOptions.GetSearchPath: string;
begin
  Result := ReadString(FSearchPathName);
end;

function TDNRegistryEnvironmentOptions.ReadString(const AName: string): string;
begin
  Result := FRegistry.ReadString(FRegstryKey, AName, '');
end;

procedure TDNEnvironmentOptions.SetBPLOutput(const Value: string);
begin
  WriteString(FBPLOutputName, Value);
end;

procedure TDNEnvironmentOptions.SetBrowsingPath(const Value: string);
begin
  WriteString(FBrowsingPathName, Value);
end;

procedure TDNEnvironmentOptions.SetDCPOutput(const Value: string);
begin
  WriteString(FDCPOutputName, Value);
end;

procedure TDNEnvironmentOptions.SetSearchPath(const Value: string);
begin
  WriteString(FSearchPathName, Value);
end;

procedure TDNRegistryEnvironmentOptions.WriteString(const AName, AValue: string);
begin
  FRegistry.WriteString(FRegstryKey, AName, AValue);
  if FUpdateLevel = 0 then
    Changed();
end;

{ TDNOTAEnvironmentOptions }

constructor TDNOTAEnvironmentOptions.Create(APlatform: TDNCompilerPlatform);
begin
  inherited;
  FSearchPathName := 'LibraryPath';
  FBPLOutputName := 'PackageDPLOutput';
  FBrowsingPathName := 'BrowsingPath';
  FDCPOutputName := 'PackageDCPOutput';
  FOptions := (BorlandIDEServices as IOTAServices).GetEnvironmentOptions;
end;

function TDNOTAEnvironmentOptions.ReadString(const AName: string): string;
begin
  Result := FOptions.Values[AName];
end;

procedure TDNOTAEnvironmentOptions.WriteString(const AName, AValue: string);
begin
  FOptions.Values[AName] := AValue;
end;

end.
