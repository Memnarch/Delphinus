{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit Delphinus.OptionsDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs,
  Delphinus.Forms, StdCtrls,
  DN.Settings.Intf;

type
  TDelphinusOptionsDialog = class(TForm)
    edToken: TEdit;
    Label1: TLabel;
    btnTest: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    lbResponse: TLabel;
    procedure btnTestClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadSettings(const ASettings: IDNSettings);
    procedure StoreSettings(const ASettings: IDNSettings);
  end;

var
  DelphinusOptionsDialog: TDelphinusOptionsDialog;

implementation

uses
  DN.PackageProvider.GitHub,
  DN.JSon,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp;

{$R *.dfm}

{ TDelphinusOptionsDialog }

procedure TDelphinusOptionsDialog.btnTestClick(Sender: TObject);
var
  LClient: IDNHttpClient;
  LResult: Integer;
  LResponse: string;
  LJSon: TJSONObject;
begin
  LClient := TDNWinHttpClient.Create();
  LClient.Authentication := Format(CGithubOAuthAuthentication, [Trim(edToken.Text)]);
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

procedure TDelphinusOptionsDialog.LoadSettings(const ASettings: IDNSettings);
begin
  edToken.Text := ASettings.OAuthToken;
end;

procedure TDelphinusOptionsDialog.StoreSettings(const ASettings: IDNSettings);
begin
  ASettings.OAuthToken := Trim(edToken.Text);
end;

end.
