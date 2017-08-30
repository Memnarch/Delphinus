{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.PackageOverview;

interface

uses
  Classes,
  Types,
  Messages,
  Windows,
  Graphics,
  Controls,
  Forms,
  Generics.Collections,
  ImgList,
  DN.Package.Intf,
  DN.Preview,
  DN.PackageFilter,
  DN.Version;

type
  TCheckIsPackageInstalled = reference to function(const APackage: IDNPackage): TDNVersion;
  TPackageEvent = reference to procedure(const APackage: IDNPackage);

  TPackageOverView = class(TScrollBox)
  private
    FPreviews: TList<TPreview>;
    FUnusedPreviews: TObjectList<TPreview>;
    FPackages: TList<IDNPackage>;
    FSelectedPackage: IDNPackage;
    FOnSelectedPackageChanged: TNotifyEvent;
    FOnCheckIsPackageInstalled: TCheckIsPackageInstalled;
    FOnCheckHasPackageUpdate: TCheckIsPackageInstalled;
    FOnInstallPackage: TPackageEvent;
    FOnUninstallPackage: TPackageEvent;
    FOnUpdatePackage: TPackageEvent;
    FColumns: Integer;
    FOnFilter: TPackageFilter;
    FOSIcons: TImageList;
    FButtonIcons: TImageList;
    FRemovedSelectedPackage: TGUID;
    FDummyPic: TGraphic;
    procedure HandlePackagesChanged(Sender: TObject; const Item: IDNPackage; Action: TCollectionNotification);
    procedure AddPreview(const APackage: IDNPackage);
    procedure RemovePreview(const APackage: IDNPackage);
    procedure HandlePreviewClicked(Sender: TObject);
    procedure ChangeSelectedPackage(const APackage: IDNPackage);
    function GetPreviewForPackage(const APackage: IDNPackage): TPreview;
    function GetInstalledVersion(const APackage: IDNPackage): TDNVersion;
    function GetUpdateVersion(const APackage: IDNPackage): TDNVersion;
    procedure InstallPackage(const APackage: IDNPackage);
    procedure UninstallPackage(const APackage: IDNPackage);
    procedure UpdatePackage(const APackage: IDNPackage);
    procedure LoadIcons;
  protected
    procedure Resize; override;
    procedure UpdateElements(AColumns: Integer);
    procedure SetPreviewPosition(APreview: TPreview; AIndex: Integer; AColumns: Integer);
    procedure ClearPreviews;
    function IsAccepted(const APackage: IDNPackage): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure Clear();
    procedure Refresh();
    procedure ApplyFilter;
    property Packages: TList<IDNPackage> read FPackages;
    property DummyPic: TGraphic read FDummyPic write FDummyPic;
    property SelectedPackage: IDNPackage read FSelectedPackage;
    property OnSelectedPackageChanged: TNotifyEvent read FOnSelectedPackageChanged write FOnSelectedPackageChanged;
    property OnCheckIsPackageInstalled: TCheckIsPackageInstalled read FOnCheckIsPackageInstalled write FOnCheckIsPackageInstalled;
    property OnCheckHasPackageUpdate: TCheckIsPackageInstalled read FOnCheckHasPackageUpdate write FOnCheckHasPackageUpdate;
    property OnInstallPackage: TPackageEvent read FOnInstallPackage write FOnInstallPackage;
    property OnUninstallPackage: TPackageEvent read FOnUninstallPackage write FOnUninstallPackage;
    property OnUpdatePackage: TPackageEvent read FOnUpdatePackage write FOnUpdatePackage;
    property OnFilter: TPackageFilter read FOnFilter write FOnFilter;
  end;

implementation

{ TPackageOverView }

uses
  Delphinus.Resources.Names,
  Delphinus.Resources;

const
  CColumns = 1;
  CSpace = 0;

procedure TPackageOverView.AddPreview(const APackage: IDNPackage);
var
  LPreview: TPreview;
begin
  if IsAccepted(APackage) then
  begin
    if FUnusedPreviews.Count > 0 then
      LPreview := FUnusedPreviews.Extract(FUnusedPreviews[0])
    else
      LPreview := TPreview.Create(nil, FOSIcons, FButtonIcons);
    LPreview.DummyPic := FDummyPic;
    LPreview.Package := APackage;
    LPreview.Parent := Self;
    SetPreviewPosition(LPreview, FPreviews.Count, FColumns);
    LPreview.InstalledVersion := GetInstalledVersion(APackage);
    LPreview.UpdateVersion := GetUpdateVersion(APackage);
    LPreview.OnClick := HandlePreviewClicked;
    LPreview.OnInstall := procedure(Sender: TObject) begin InstallPackage(TPreview(Sender).Package) end;
    LPreview.OnUninstall := procedure(Sender: TObject) begin UninstallPackage(TPreview(Sender).Package) end;
    LPreview.OnUpdate := procedure(Sender: TObject) begin UpdatePackage(TPreview(Sender).Package) end;
    FPreviews.Add(LPreview);
    if (not Assigned(SelectedPackage)) and (FRemovedSelectedPackage = APackage.ID) then
      ChangeSelectedPackage(APackage);
  end;
end;

procedure TPackageOverView.Clear;
begin
  FPackages.Clear();
end;

procedure TPackageOverView.ClearPreviews;
var
  LPreview: TPreview;
begin
  for LPreview in FPreviews do
  begin
    LPreview.Parent := nil;
    LPreview.Package := nil;
  end;
  FUnusedPreviews.AddRange(FPreviews);
  FPreviews.Clear;
end;

constructor TPackageOverView.Create(AOwner: TComponent);
begin
  inherited;
  FPreviews := TList<TPreview>.Create();
  FUnusedPreviews := TObjectList<TPreview>.Create(True);
  FPackages := TList<IDNPackage>.Create();
  FPackages.OnNotify := HandlePackagesChanged;
  BorderStyle := bsNone;
  VertScrollBar.Smooth := True;
  VertScrollBar.Tracking := True;
  VertScrollBar.Visible := True;
  FColumns := CColumns;
  Self.ControlStyle := Self.ControlStyle + [csOpaque];
  HorzScrollBar.Visible := False;
  FOSIcons := TImageList.Create(Self);
  FOSIcons.Width := 32;
  FOSIcons.Height := 32;
  FOSIcons.ColorDepth := cd32Bit;
  FButtonIcons := TImageList.Create(Self);
  FButtonIcons.Width := 32;
  FButtonIcons.Height := 32;
  FButtonIcons.ColorDepth := cd32Bit;
  LoadIcons();
  ParentColor := False;
  Color := clWindow;
end;

destructor TPackageOverView.Destroy;
begin
  FPreviews.Free();
  FUnusedPreviews.Free;
  FPackages.Free();
  inherited;
end;

function TPackageOverView.GetPreviewForPackage(
  const APackage: IDNPackage): TPreview;
var
  LPreview: TPreview;
begin
  Result := nil;
  for LPreview in FPreviews do
  begin
    if LPreview.Package = APackage then
    begin
      Result := LPreview;
      Break;
    end;
  end;
end;

procedure TPackageOverView.HandlePackagesChanged(Sender: TObject;
  const Item: IDNPackage; Action: TCollectionNotification);
begin
  case Action of
    cnAdded: AddPreview(Item);
    cnRemoved, cnExtracted: RemovePreview(Item);
  end;
end;

procedure TPackageOverView.HandlePreviewClicked(Sender: TObject);
begin
  ChangeSelectedPackage((Sender as TPreview).Package);
end;

function TPackageOverView.GetUpdateVersion(const APackage: IDNPackage): TDNVersion;
begin
  if Assigned(FOnCheckHasPackageUpdate) then
  begin
    Result := FOnCheckHasPackageUpdate(APackage);
  end
  else
  begin
    Result := TDNVersion.Create();
  end;
end;

procedure TPackageOverView.InstallPackage(const APackage: IDNPackage);
begin
  if Assigned(FOnInstallPackage) then
    FOnInstallPackage(APackage);
end;

function TPackageOverView.IsAccepted(const APackage: IDNPackage): Boolean;
begin
  Result := True;
  if Assigned(FOnFilter) then
    FOnFilter(APackage, Result);
end;

procedure TPackageOverView.LoadIcons;
begin
  AddIconToImageList(FOSIcons, Ico_Windows);
  AddIconToImageList(FOSIcons, Ico_Mac);
  AddIconToImageList(FOSIcons, Ico_Android);
  AddIconToImageList(FOSIcons, Ico_IOS);
  AddIconToImageList(FOSIcons, Ico_Linux);
  AddIconToImageList(FButtonIcons, Ico_Install);
  AddIconToImageList(FButtonIcons, Ico_Delete);
  AddIconToImageList(FButtonIcons, Ico_Update);
end;

function TPackageOverView.GetInstalledVersion(
  const APackage: IDNPackage): TDNVersion;
begin
  if Assigned(FOnCheckIsPackageInstalled) then
  begin
    Result := FOnCheckIsPackageInstalled(APackage);
  end
  else
  begin
    Result := TDNVersion.Create();
  end;
end;

procedure TPackageOverView.Refresh;
var
  LPreview: TPreview;
begin
  for LPreview in FPreviews do
  begin
    LPreview.InstalledVersion := GetInstalledVersion(LPreview.Package);
    LPreview.UpdateVersion := GetUpdateVersion(LPreview.Package);
  end;
end;

procedure TPackageOverView.RemovePreview(const APackage: IDNPackage);
var
  i: Integer;
begin
  for i := FPreviews.Count - 1 downto 0 do
  begin
    if FPreviews[i].Package = APackage then
    begin
      FPreviews[i].Parent := nil;
      FPreviews[i].Package := nil;
      if FPreviews[i].Selected then
      begin
        FRemovedSelectedPackage := APackage.ID;
        FPreviews[i].Selected := False;
      end;
      FUnusedPreviews.Add(FPreviews.Extract(FPreviews[i]));
      Break;
    end;
  end;
  if FSelectedPackage = APackage then
    ChangeSelectedPackage(nil);
end;

procedure TPackageOverView.Resize;
begin
  inherited;
  UpdateElements(FColumns);
end;

procedure TPackageOverView.SetPreviewPosition(APreview: TPreview;
  AIndex: Integer; AColumns: Integer);
begin
  APreview.Top := (AIndex div AColumns) * (APreview.Height + CSpace) - VertScrollBar.Position;
  APreview.Left := (AIndex mod AColumns) * (APreview.Width + CSpace);
  APreview.Width := ClientWidth;
end;

procedure TPackageOverView.UninstallPackage(const APackage: IDNPackage);
begin
  if Assigned(FOnUninstallPackage) then
    FOnUninstallPackage(APackage);
end;

procedure TPackageOverView.UpdateElements(AColumns: Integer);
var
  i: Integer;
begin
  for i := 0 to FPreviews.Count - 1 do
    SetPreviewPosition(FPreviews[i], i, AColumns);
end;

procedure TPackageOverView.UpdatePackage(const APackage: IDNPackage);
begin
  if Assigned(FOnUpdatePackage) then
    FOnUpdatePackage(APackage);
end;

procedure TPackageOverView.ApplyFilter;
var
  LPackage: IDNPackage;
begin
  ClearPreviews();
  for LPackage in FPackages do
  begin
    AddPreview(LPackage);
  end;
end;

procedure TPackageOverView.ChangeSelectedPackage;
var
  LPreview: TPreview;
begin
  if Assigned(FSelectedPackage) then
  begin
    LPreview := GetPreviewForPackage(FSelectedPackage);
    if Assigned(LPreview) then
      LPreview.Selected := False;
  end;

  FSelectedPackage := APackage;
  if Assigned(FSelectedPackage) then
  begin
    LPreview := GetPreviewForPackage(FSelectedPackage);
    if Assigned(LPreview) then
      LPreview.Selected := True;
  end;

  if Assigned(FOnSelectedPackageChanged) then
    FOnSelectedPackageChanged(Self);
end;

end.
