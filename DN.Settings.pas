unit DN.Settings;

interface

uses
  Generics.Collections,
  DN.Settings.Intf,
  DN.PackageSource.Settings.Intf;

type
  TDNPackageSourceSettingsFactory = reference to function(const ASourceName: string; out ASettings: IDNPackageSourceSettings): Boolean;

  TDNSettings = class(TInterfacedObject, IDNSettings, IDNElevatedSettings)
  private
    FSourceSettings: TList<IDNPackageSourceSettings>;
    FSettingsFactory: TDNPackageSourceSettingsFactory;
    function ReadString(const AValueName: string): string;
    procedure WriteString(const AValueName, AContent: string);
    function GetInstallationDirectory: string;
    function GetOAuthToken: string;
    procedure SetInstallationDirectory(const Value: string);
    procedure SetOAuthToken(const Value: string);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function GetInstallDate: TDateTime;
    procedure SetInstallDate(const Value: TDateTime);
    function GetSourceSettings: TArray<IDNPackageSourceSettings>;
    procedure CreateDefaultSource;
    procedure LoadSources;
    procedure SaveSources;
    procedure SetSourceSettings(const Value: TArray<IDNPackageSourceSettings>);
  public
    constructor Create(const ASettingsFactory: TDNPackageSourceSettingsFactory);
    destructor Destroy; override;
    procedure Clear();
    property InstallationDirectory: string read GetInstallationDirectory write SetInstallationDirectory;
    property OAuthToken: string read GetOAuthToken write SetOAuthToken;
    property Version: string read GetVersion write SetVersion;
    property InstallDate: TDateTime read GetInstallDate write SetInstallDate;
    property SourceSettings: TArray<IDNPackageSourceSettings> read GetSourceSettings write SetSourceSettings;
  end;

implementation

uses
  Classes,
  Windows,
  Registry,
  SysUtils,
  DateUtils,
  StrUtils,
  IOUtils,
  DN.PackageSource.Settings.Field.Intf;

const
  CInstallationDirectory = 'InstallationDirectory';
  COAuthToken = 'OAuthToken';
  CVersion = 'Version';
  CInstallDate = 'InstallDate';
  CDelphinusKey = 'Software\Delphinus';
  CDelphinusSourcesKey = CDelphinusKey + '\Sources';
  CRootKey = HKEY_CURRENT_USER;
  CDateFormat = 'yyyy-mm-dd';
  CDateSeperator = '-';
  CTimeFormat = 'hh:nn:ss:zzz';
  CTimeSeperator = ':';
  CDateTimeFormat = CDateFormat + ' ' + CTimeFormat;
  CSourceType = 'SourceType';

{ TDNSettings }

procedure TDNSettings.Clear;
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create();
  try
    LRegistry.RootKey := CRootKey;
    LRegistry.DeleteKey(CDelphinusKey)
  finally
    LRegistry.Free;
  end;
end;

constructor TDNSettings.Create(const ASettingsFactory: TDNPackageSourceSettingsFactory);
begin
  inherited Create();
  FSourceSettings := TList<IDNPackageSourceSettings>.Create();
  FSettingsFactory := ASettingsFactory;
end;

procedure TDNSettings.CreateDefaultSource;
var
  LSetting: IDNPackageSourceSettings;
begin
  if FSettingsFactory('GitHub', LSetting) then
  begin
    LSetting.Name := 'GitHub';
    LSetting.Field['OAuthToken'].Value := OAuthToken;
    FSourceSettings.Add(LSetting);
  end;
end;

destructor TDNSettings.Destroy;
begin
  FSourceSettings.Free();
  inherited;
end;

function TDNSettings.GetInstallationDirectory: string;
begin
  Result := ReadString(CInstallationDirectory)
end;

function TDNSettings.GetInstallDate: TDateTime;
var
  LDate: string;
  LSettings: TFormatSettings;
begin
  LDate := ReadString(CInstallDate);
  if LDate <> '' then
  begin
    LSettings := TFormatSettings.Create();
    LSettings.ShortDateFormat := CDateFormat;
    LSettings.DateSeparator := CDateSeperator;
    LSettings.LongTimeFormat := CTimeFormat;
    LSettings.TimeSeparator := CTimeSeperator;
    Result := StrToDateTimeDef(LDate, 0, LSettings);
  end
  else
    Result := 0;
end;

function TDNSettings.GetOAuthToken: string;
begin
  Result := ReadString(COAuthToken);
end;

function TDNSettings.GetSourceSettings: TArray<IDNPackageSourceSettings>;
begin
  if FSourceSettings.Count = 0 then
    LoadSources();
  if FSourceSettings.Count = 0 then
    CreateDefaultSource();
  Result := FSourceSettings.ToArray;
end;

function TDNSettings.GetVersion: string;
begin
  Result := ReadString(CVersion);
end;

procedure TDNSettings.LoadSources;
var
  LRegistry: TRegistry;
  LKeys: TStringList;
  LKey, LSourceType, LPath: string;
  LSettings: IDNPackageSourceSettings;
  LField: IDNPackageSourceSettingsField;
begin
  FSourceSettings.Clear();
  LRegistry := TRegistry.Create();
  try
    LRegistry.RootKey := CRootKey;
    if LRegistry.OpenKeyReadOnly(CDelphinusSourcesKey) then
    begin
      LKeys := TStringList.Create();
      try
        LRegistry.GetKeyNames(LKeys);
        for LKey in LKeys do
        begin
          if LRegistry.OpenKeyReadOnly(LKey) and LRegistry.ValueExists(CSourceType) then
          begin
            LSourceType := LRegistry.ReadString(CSourceType);
            if FSettingsFactory(LSourceType, LSettings) then
            begin
              LSettings.Name := LKey;
              for LField in LSettings.Fields do
              begin
                if LRegistry.ValueExists(LField.Name) then
                begin
                  case LField.ValueType of
                    ftString: LField.Value := LRegistry.ReadString(LField.Name);
                    ftInteger: LField.Value := LRegistry.ReadInteger(LField.Name);
                  end;
                end;
              end;
              FSourceSettings.Add(LSettings);
            end;
          end;
        end;
      finally
        LKeys.Free();
      end;
    end;
  finally
    LRegistry.Free;
  end;
end;

function TDNSettings.ReadString(const AValueName: string): string;
var
  LRegistry: TRegistry;
begin
  Result := '';
  LRegistry := TRegistry.Create();
  try
    LRegistry.RootKey := CRootKey;
    if LRegistry.OpenKeyReadOnly(CDelphinusKey) then
    begin
      if LRegistry.ValueExists(AValueName) then
        Result := LRegistry.ReadString(AValueName);
    end;
  finally
    LRegistry.Free;
  end;
end;

procedure TDNSettings.SaveSources;
var
  LRegistry: TRegistry;
  LSetting: IDNPackageSourceSettings;
  LField: IDNPackageSourceSettingsField;
  LPath: string;
begin
  LRegistry := TRegistry.Create();
  try
    LRegistry.RootKey := CRootKey;
    if (not LRegistry.KeyExists(CDelphinusSourcesKey) or LRegistry.DeleteKey(CDelphinusSourcesKey)) then
    begin
      for LSetting in FSourceSettings do
      begin
        LPath := TPath.Combine(CDelphinusSourcesKey, LSetting.Name);
        if LRegistry.OpenKey(LPath, True) then
        begin
          try
            LRegistry.WriteString(CSourceType, LSetting.SourceName);
            for LField in LSetting.Fields do
            begin
              if not LField.Value.IsEmpty then
              begin
                case LField.ValueType of
                  ftString: LRegistry.WriteString(LField.Name, LField.Value.AsString);
                  ftInteger: LRegistry.WriteInteger(LField.Name, LField.Value.AsInteger);
                end;
              end;
            end;
          finally
            LRegistry.CloseKey();
          end;
        end;
      end;
    end;
  finally
    LRegistry.Free;
  end;
end;

procedure TDNSettings.SetInstallationDirectory(const Value: string);
begin
  WriteString(CInstallationDirectory, Value);
end;

procedure TDNSettings.SetInstallDate(const Value: TDateTime);
begin
  WriteString(CInstallDate, FormatDateTime(CDateTimeFormat, Value));
end;

procedure TDNSettings.SetOAuthToken(const Value: string);
begin
  WriteString(COAuthToken, Value);
end;

procedure TDNSettings.SetSourceSettings(
  const Value: TArray<IDNPackageSourceSettings>);
begin
  FSourceSettings.Clear();
  FSourceSettings.AddRange(Value);
  SaveSources();
end;

procedure TDNSettings.SetVersion(const Value: string);
begin
  WriteString(CVersion, Value);
end;

procedure TDNSettings.WriteString(const AValueName, AContent: string);
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create();
  try
    LRegistry.RootKey := CRootKey;
    if LRegistry.OpenKey(CDelphinusKey, True) then
      LRegistry.WriteString(AValueName, AContent);
  finally
    LRegistry.Free;
  end;
end;

end.
