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
  Controls, Forms,
  Dialogs,
  Delphinus.Forms,
  DN.PackageSource.Registry.Intf,
  DN.Settings.Intf,
  DN.PackageSource.Settings.Intf,
  DN.PackageSource.ConfigPage.Intf,
  StdCtrls,
  ComCtrls,
  ExtCtrls;

type
  TDelphinusOptionsDialog = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    lvSources: TListView;
    pnlSettings: TPanel;
    procedure lvSourcesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    { Private declarations }
    FRegistry: IDNPackageSourceRegistry;
    FSettings: TList<IDNPackageSourceSettings>;
    FPages: TDictionary<IDNPackageSourceSettings, IDNPackageSourceConfigPage>;
    procedure RebuildSettingsList;
  public
    { Public declarations }
    constructor Create(const ARegistry: IDNPackageSourceRegistry); reintroduce;
    destructor Destroy; override;
    procedure LoadSettings(const ASettings: IDNSettings);
    procedure StoreSettings(const ASettings: IDNSettings);
  end;

var
  DelphinusOptionsDialog: TDelphinusOptionsDialog;

implementation

uses
  DN.PackageSource.Intf;

{$R *.dfm}

{ TDelphinusOptionsDialog }

constructor TDelphinusOptionsDialog.Create(const ARegistry: IDNPackageSourceRegistry);
begin
  inherited Create(nil);
  FSettings := TList<IDNPackageSourceSettings>.Create();
  FPages := TDictionary<IDNPackageSourceSettings, IDNPackageSourceConfigPage>.Create();
  FRegistry := ARegistry;
end;

destructor TDelphinusOptionsDialog.Destroy;
begin
  FPages.Free;
  FSettings.Free;
  inherited;
end;

procedure TDelphinusOptionsDialog.LoadSettings(const ASettings: IDNSettings);
begin
  FSettings.Clear();
  FSettings.AddRange(ASettings.SourceSettings);
  RebuildSettingsList();
end;

procedure TDelphinusOptionsDialog.lvSourcesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  LSource: IDNPackageSource;
  LSettings: IDNPackageSourceSettings;
  LPage: IDNPackageSourceConfigPage;
begin
  if Selected then
  begin
    LSettings := FSettings[Item.Index];
    if not FPages.TryGetValue(LSettings, LPage) then
    begin
      if not FRegistry.TryGetSource(LSettings.SourceName, LSource) then
        Exit;
      LPage := LSource.NewConfigPage;
      FPages.Add(LSettings, LPage);
    end;
    LPage.Parent := pnlSettings;
    LPage.Load(LSettings);
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
var
  LPair: TPair<IDNPackageSourceSettings, IDNPackageSourceConfigPage>;
begin
  for LPair in FPages do
    LPair.Value.Save(LPair.Key);
  ASettings.SourceSettings := FSettings.ToArray;
end;

end.
