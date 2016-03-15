unit DN.Settings;

interface

uses
  DN.Settings.Intf;

type
  TDNSettings = class(TInterfacedObject, IDNSettings, IDNElevatedSettings)
  private
    function ReadString(const AValueName: string): string;
    procedure WriteString(const AValueName, AContent: string);
    function GetInstallationDirectory: string;
    function GetOAuthToken: string;
    procedure SetInstallationDirectory(const Value: string);
    procedure SetOAuthToken(const Value: string);
  public
    procedure Clear();
    property InstallationDirectory: string read GetInstallationDirectory write SetInstallationDirectory;
    property OAuthToken: string read GetOAuthToken write SetOAuthToken;
  end;

implementation

uses
  Windows,
  Registry;

const
  CInstallationDirectory = 'InstallationDirectory';
  COAuthToken = 'OAuthToken';
  CDelphinusKey = 'Software\Delphinus';
  CRootKey = HKEY_CURRENT_USER;

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

function TDNSettings.GetInstallationDirectory: string;
begin
  Result := ReadString(CInstallationDirectory)
end;

function TDNSettings.GetOAuthToken: string;
begin
  Result := ReadString(COAuthToken);
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

procedure TDNSettings.SetInstallationDirectory(const Value: string);
begin
  WriteString(CInstallationDirectory, Value);
end;

procedure TDNSettings.SetOAuthToken(const Value: string);
begin
  WriteString(COAuthToken, Value);
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
