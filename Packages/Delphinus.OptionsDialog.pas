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
  ExtCtrls, ToolWin, ImgList, System.ImageList;

type
  TDelphinusOptionsDialog = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    lvSources: TListView;
    pnlSettings: TPanel;
    ToolBar1: TToolBar;
    tbAdd: TToolButton;
    tbDelete: TToolButton;
    ilToolbar: TImageList;
    Label1: TLabel;
    procedure lvSourcesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure tbDeleteClick(Sender: TObject);
    procedure tbAddClick(Sender: TObject);
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
  DN.PackageSource.Intf,
  Delphinus.Resources,
  Delphinus.Resources.Names,
  Delphinus.OptionsDialog.TypeSelection;

{$R *.dfm}

{ TDelphinusOptionsDialog }

constructor TDelphinusOptionsDialog.Create(const ARegistry: IDNPackageSourceRegistry);
begin
  inherited Create(nil);
  FSettings := TList<IDNPackageSourceSettings>.Create();
  FPages := TDictionary<IDNPackageSourceSettings, IDNPackageSourceConfigPage>.Create();
  FRegistry := ARegistry;
  tbAdd.ImageIndex := AddIconToImageList(ilToolbar, Ico_Add);
  tbDelete.ImageIndex := AddIconToImageList(ilToolbar, Ico_Delete);
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
  LPage, LOldPage: IDNPackageSourceConfigPage;
begin
  LPage := nil;
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

  for LOldPage in FPages.Values do
    if LOldPage <> LPage then
      LOldPage.Parent := nil;
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

procedure TDelphinusOptionsDialog.tbDeleteClick(Sender: TObject);
var
  LSettings: IDNPackageSourceSettings;
  LPage: IDNPackageSourceConfigPage;
begin
  if lvSources.ItemIndex > -1 then
  begin
    LSettings := FSettings[lvSources.ItemIndex];
    if FPages.TryGetValue(LSettings, LPage) then
    begin
      LPage.Parent := nil;
      FPages.Remove(LSettings);
    end;

    FSettings.Delete(lvSources.ItemIndex);
    RebuildSettingsList;
  end;
end;

procedure TDelphinusOptionsDialog.tbAddClick(Sender: TObject);
var
  LDialog: TTypeSelectionDialog;
  LSettings: IDNPackageSourceSettings;
begin
  LDialog := TTypeSelectionDialog.Create(FRegistry.Sources);
  try
    LDialog.OnValidateName :=
      function(const AName: string): Boolean
      var
        LSettings: IDNPackageSourceSettings;
      begin
        Result := True;
        for LSettings in FSettings do
          if AnsiSameText(LSettings.Name, AName) then
            Exit(False);
      end;
    if LDialog.ShowModal() = mrOk then
    begin
      LSettings := LDialog.SelectedSource.NewSettings;
      LSettings.Name := LDialog.SourceName;
      FSettings.Add(LSettings);
      RebuildSettingsList;
    end;
  finally
    LDialog.Free;
  end;
end;

end.
