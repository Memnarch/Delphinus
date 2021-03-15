unit DN.PackageSource.ConfigPage.Github;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  DN.PackageSource.ConfigPage,
  DN.PackageSource.Settings.Intf,
  StdCtrls;

type
  TDNGithubSourceConfigPage = class(TFrame)
    edOAuthToken: TEdit;
    Label1: TLabel;
    btnTest: TButton;
    lbResponse: TLabel;
    procedure btnTestClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Load(const ASettings: IDNPackageSourceSettings); override;
    procedure Save(const ASettings: IDNPackageSourceSettings); override;
  end;

implementation

uses
  DN.PackageProvider.GitHub,
  DN.JSon,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp,
  DN.PackageSource.Settings.GitHub;

{$R *.dfm}

{ TGithubSourceConfigPage }

procedure TDNGithubSourceConfigPage.btnTestClick(Sender: TObject);
var
  LClient: IDNHttpClient;
  LResult: Integer;
  LResponse: string;
  LJSon: TJSONObject;
begin
  LClient := TDNWinHttpClient.Create();
  LClient.Authentication := Format(CGithubOAuthAuthentication, [Trim(edOAuthToken.Text)]);
  LResult := LClient.GetText('https://api.github.com/user', LResponse);
  if LResult = HTTPErrorOk then
  begin
    LJSon := TJSonObject.ParseJSONValue(LResponse) as TJSonObject;
    try
      lbResponse.Caption := 'Authenticated as ' + LJSon.GetValue('login').Value;
    finally
      LJSon.Free;
    end;
  end
  else
  begin
    lbResponse.Caption := 'Failed with ResponseCode ' + IntToStr(LResult);
  end;
end;

procedure TDNGithubSourceConfigPage.Load(
  const ASettings: IDNPackageSourceSettings);
begin
  inherited;
  edOAuthToken.Text := ASettings.Field[TDNGithubPackageSourceSettings.OAuthToken].Value.AsString;
end;

procedure TDNGithubSourceConfigPage.Save(
  const ASettings: IDNPackageSourceSettings);
begin
  inherited;
  ASettings.Field[TDNGithubPackageSourceSettings.OAuthToken].Value := edOAuthToken.Text;
end;

end.
