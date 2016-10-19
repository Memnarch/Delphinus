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
  Generics.Collections,
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs,
  Delphinus.Forms, StdCtrls,
  DN.Settings.Intf, DN.PackageSource.Settings.Intf,
  Vcl.ComCtrls, Vcl.Grids, Vcl.ValEdit;

type
  TDelphinusOptionsDialog = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    lvSources: TListView;
    vleSettings: TValueListEditor;
    procedure btnTestClick(Sender: TObject);
    procedure lvSourcesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    { Private declarations }
    FSettings: TList<IDNPackageSourceSettings>;
    procedure RebuildSettingsList;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
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
  DN.HttpClient.WinHttp,
  DN.PackageSource.Settings.Field.Intf;

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
//  LClient.Authentication := Format(CGithubOAuthAuthentication, [Trim(edToken.Text)]);
  LResult := LClient.GetText('https://api.github.com/user', LResponse);
  if LResult = HTTPErrorOk then
  begin
    LJSon := TJSonObject.ParseJSONValue(LResponse) as TJSonObject;
    try
//      lbResponse.Caption := 'Authenticated as ' + LJSon.GetValue('login').Value;
    finally
      LJSon.Free;
    end;
  end
  else
  begin
//    lbResponse.Caption := 'Failed with ResponseCode ' + IntToStr(LResult);
  end;
end;

constructor TDelphinusOptionsDialog.Create(AOwner: TComponent);
begin
  inherited;
  FSettings := TList<IDNPackageSourceSettings>.Create();
end;

destructor TDelphinusOptionsDialog.Destroy;
begin
  FSettings.Free;
  inherited;
end;

procedure TDelphinusOptionsDialog.LoadSettings(const ASettings: IDNSettings);
begin
  FSettings.Clear();
  FSettings.AddRange(ASettings.SourceSettings);
  RebuildSettingsList();
//  edToken.Text := ASettings.OAuthToken;
end;

procedure TDelphinusOptionsDialog.lvSourcesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  LField: IDNPackageSourceSettingsField;
begin
  vleSettings.Strings.Clear;
  if Selected then
  begin
    for LField in FSettings[Item.Index].Fields do
    begin
      vleSettings.InsertRow(LField.Name, LField.Value.AsString, True);
    end;
  end;
end;

procedure TDelphinusOptionsDialog.RebuildSettingsList;
var
  LSetting: IDNPackageSourceSettings;
begin
  lvSources.Clear;
  for LSetting in FSettings do
    lvSources.AddItem(LSetting.Name, nil);
end;

procedure TDelphinusOptionsDialog.StoreSettings(const ASettings: IDNSettings);
begin
  ASettings.SourceSettings := FSettings.ToArray;
//  ASettings.OAuthToken := Trim(edToken.Text);
end;

end.
