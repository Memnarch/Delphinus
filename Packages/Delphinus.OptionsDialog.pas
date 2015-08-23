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
  Delphinus.Form, StdCtrls,
  Delphinus.Settings;

type
  TDelphinusOptionsDialog = class(TDelphinusForm)
    edToken: TEdit;
    Label1: TLabel;
    btnTest: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    lbResponse: TLabel;
    procedure btnTestClick(Sender: TObject);
  private
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
  IdHttp,
  IdSSLOpenSSl,
  DN.PackageProvider.GitHub.Authentication,
  DN.JSon;

{$R *.dfm}

{ TDelphinusOptionsDialog }

procedure TDelphinusOptionsDialog.btnTestClick(Sender: TObject);
var
  LRequest: TIdHTTP;
  LResponse: TStringStream;
  LJSon: TJSONObject;
begin
  LRequest := TIdHTTP.Create(nil);
  LResponse := TStringStream.Create('', TEncoding.UTF8);
  try
    LRequest.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(LRequest);
    LRequest.HandleRedirects := True;
    LRequest.Request.Authentication := TGithubAuthentication.Create();
    LRequest.Request.Authentication.Password := Settings.OAuthToken;
    try
      LRequest.Get('https://api.github.com/user', LResponse);
    except

    end;
    if LRequest.ResponseCode = 200 then
    begin
      LJSon := TJSonObject.ParseJSONValue(LResponse.DataString) as TJSonObject;
      lbResponse.Caption := 'Authenticated as ' + LJSon.GetValue('login').Value;
    end
    else
    begin
      lbResponse.Caption := 'Failed with ResponseCode ' + IntToStr(LRequest.ResponseCode);
    end;
  finally
    LResponse.Free;
    LRequest.Free;
  end;
end;

function TDelphinusOptionsDialog.GetSettings: TDelphinusSettings;
begin
  Result.OAuthToken := Trim(edToken.Text);
end;

procedure TDelphinusOptionsDialog.SetSettings(const Value: TDelphinusSettings);
begin
  edToken.Text := Value.OAuthToken;
end;

end.
