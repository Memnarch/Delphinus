unit DN.EnvironmentOptions;

interface

uses
  Classes,
  Generics.Collections,
  DN.Types,
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
    function IsUpdating: Boolean;
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

  TDNEnvironmentOptionsService = class(TInterfacedObject, IDNEnvironmentOptionsService)
  private
    FSupportedPlatforms: TDNCompilerPlatforms;
    FOptions: TDictionary<TDNCompilerPlatform, IDNEnvironmentOptions>;
    FUpdateLevel: Integer;
    FChanges: Integer;
    function GetOptions(
      const APlatform: TDNCompilerPlatform): IDNEnvironmentOptions;
    function GetSupportedPlatforms: TDNCompilerPlatforms;
  protected
    procedure AddOption(const AOption: IDNEnvironmentOptions);
  public
    constructor Create;
    destructor Destroy(); override;
    procedure BeginUpdate(); virtual;
    procedure EndUpdate(); virtual;
    property Options[const APlatform: TDNCompilerPlatform]: IDNEnvironmentOptions read GetOptions;
    property SupportedPlatforms: TDNCompilerPlatforms read GetSupportedPlatforms;
  end;

implementation

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

function TDNEnvironmentOptions.IsUpdating: Boolean;
begin
  Result := FUpdateLevel > 0;
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

{ TDNEnvironmentOptionsService }

procedure TDNEnvironmentOptionsService.AddOption(const AOption: IDNEnvironmentOptions);
begin
  FOptions.Add(AOption.Platform, AOption);
  Include(FSupportedPlatforms, AOption.Platform);
end;

procedure TDNEnvironmentOptionsService.BeginUpdate;
begin
  Inc(FUpdateLevel);
end;

constructor TDNEnvironmentOptionsService.Create;
begin
  inherited;
  FOptions := TDictionary<TDNCompilerPlatform, IDNEnvironmentOptions>.Create();
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
begin
  Result := FOptions[APlatform];
end;

function TDNEnvironmentOptionsService.GetSupportedPlatforms: TDNCompilerPlatforms;
begin
  Result := FSupportedPlatforms;
end;

end.
