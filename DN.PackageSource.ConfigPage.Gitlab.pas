{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.PackageSource.ConfigPage.Gitlab;

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
  StdCtrls, Vcl.ExtCtrls;

type
  TDNGitlabSourceConfigPage = class(TFrame)
    edtOAuthToken: TEdit;
    lblInfoToken: TLabel;
    lbResponse: TLabel;
    edtBaseURL: TEdit;
    lblInfoBaseURL: TLabel;
    btnTestURL: TButton;
    btnSetURLGitLabCom: TButton;
    imgAvatar: TImage;
    procedure btnSetURLGitLabComClick(Sender: TObject);
    procedure btnTestTokenClick(Sender: TObject);
    procedure edtBaseURLChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Load(const ASettings: IDNPackageSourceSettings); override;
    procedure Save(const ASettings: IDNPackageSourceSettings); override;
  end;

implementation

uses
  DN.PackageProvider.GitLab,
  DN.JSon,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp,
  DN.PackageSource.Settings.GitLab
  {$IF RTLVersion < 32.0}
  , PngImage, Jpeg
  {$ENDIF}
  ;

{$R *.dfm}

{ TGitlabSourceConfigPage }

procedure TDNGitlabSourceConfigPage.btnSetURLGitLabComClick(Sender: TObject);
begin
  edtBaseURL.Text := 'https://gitlab.com';
end;

procedure TDNGitlabSourceConfigPage.btnTestTokenClick(Sender: TObject);
var
  LClient: IDNHttpClient;
  LResult: Integer;
  LResponse: string;
  LJSon: TJSONObject;
  zs : string;
  avatarstream : TMemoryStream;
  {$IF RTLVersion < 32.0}
  cgfx : TGraphic;
  {$ENDIF}
begin
  lbResponse.Caption := Format('Checking (%0:s)...', [DateTimeToStr(Now)]);
  Application.ProcessMessages;
  LClient := TDNWinHttpClient.Create();
  LClient.Authentication := Format(CGitlabOAuthAuthentication, [Trim(edtOAuthToken.Text)]);
  zs := Format('%0:s/api/v4/user?private_token=%1:s', [edtBaseURL.Text, Trim(edtOAuthToken.Text)]);
  try
    LResult := LClient.GetText(zs, LResponse);
  except
    on e : exception do
    begin
      lbResponse.Caption := Format('No connection "%0:s"', [e.Message]);
      exit;
    end;
  end;
  if LResult = HTTPErrorOk then
  begin
    LJSon := TJSonObject.ParseJSONValue(LResponse) as TJSonObject;
    try
      if LJSon <> nil then
      begin
        lbResponse.Caption := Format('You are: %0:s (%1:s)', [LJSon.GetValue('username').Value, LJSon.GetValue('name').Value]);
        try
          avatarstream := TMemoryStream.Create;
          try
            LResult := LClient.Get(LJSon.GetValue('avatar_url').Value, avatarstream);
            if LResult = HTTPErrorOk then
            begin
              avatarstream.Position := 0;
              {$IF RTLVersion >= 32.0}
              imgAvatar.Picture.LoadFromStream(avatarstream);
              {$ELSE}
              cgfx := nil;
              // try PNG...
              if cgfx = nil then
              begin
                cgfx := TPngImage.Create;
                try
                  cgfx.LoadFromStream(avatarstream);
                  imgAvatar.Picture.Graphic := cgfx;
                except
                  FreeAndNil(cgfx);
                end;
              end;
              // try JPG...
              if cgfx = nil then
              begin
                cgfx := TJpegImage.Create;
                try
                  cgfx.LoadFromStream(avatarstream);
                  imgAvatar.Picture.Graphic := cgfx;
                except
                  FreeAndNil(cgfx);
                end;
              end;
              // try BMP...
              if cgfx = nil then
              begin
                cgfx := TBitmap.Create;
                try
                  cgfx.LoadFromStream(avatarstream);
                  imgAvatar.Picture.Graphic := cgfx;
                except
                  FreeAndNil(cgfx);
                end;
              end;
              {$ENDIF}
            end;
          finally
            FreeAndNil(avatarstream);
          end;
        except
          on e : exception do
          begin
            // only a missing picture
          end;
        end;
      end else
      begin
        lbResponse.Caption := 'Unexpected result, there is no API answer';
      end;
    finally
      LJSon.Free;
    end;
  end else
  begin
    lbResponse.Caption := 'Authentication failed with ResponseCode ' + IntToStr(LResult);
  end;
end;

procedure TDNGitlabSourceConfigPage.edtBaseURLChange(Sender: TObject);
begin
  edtBaseURL.Hint := edtBaseURL.Text;
end;

procedure TDNGitlabSourceConfigPage.Load(
  const ASettings: IDNPackageSourceSettings);
begin
  inherited;
  edtOAuthToken.Text := ASettings.Field[TDNGitlabPackageSourceSettings.OAuthToken].Value.AsString;
  edtBaseURL.Text := ASettings.Field[TDNGitlabPackageSourceSettings.BaseURL].Value.AsString;
end;

procedure TDNGitlabSourceConfigPage.Save(
  const ASettings: IDNPackageSourceSettings);
begin
  inherited;
  ASettings.Field[TDNGitlabPackageSourceSettings.OAuthToken].Value := edtOAuthToken.Text;
  ASettings.Field[TDNGitlabPackageSourceSettings.BaseURL].Value := edtBaseURL.Text;
end;

end.
