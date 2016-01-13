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
  Delphinus.Settings;

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
    FSettings: TDelphinusSettings;
    procedure SetSettings(const Value: TDelphinusSettings);
    function GetSettings: TDelphinusSettings;
    { Private declarations }
  public
    { Public declarations }
    property Settings: TDelphinusSettings read GetSettings write SetSettings;
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
  LClient.Authentication := Format(CGithubOAuthAuthentication, [Settings.OAuthToken]);
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

function TDelphinusOptionsDialog.GetSettings: TDelphinusSettings;
begin
  Result := FSettings;
  Result.OAuthToken := Trim(edToken.Text);
end;

procedure TDelphinusOptionsDialog.SetSettings(const Value: TDelphinusSettings);
begin
  if FSettings <> Value then
  begin
    FSettings := Value;
    if Assigned(FSettings) then
    begin
      edToken.Text := FSettings.OAuthToken;
    end;
  end;
end;

end.
