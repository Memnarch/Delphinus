unit DN.PackageOverview;

interface

uses
  Classes,
  Types,
  Messages,
  Controls,
  Forms,
  Generics.Collections,
  DN.Package.Intf,
  DN.Preview;

type
  TCheckIsPackageInstalled = reference to function(const APackage: IDNPackage): string;
  TPackageEvent = reference to procedure(const APackage: IDNPackage);

  TPackageOverView = class(TScrollBox)
  private
    FPreviews: TObjectList<TPreview>;
    FUnusedPreviews: TObjectList<TPreview>;
    FPackages: TList<IDNPackage>;
    FSelectedPackage: IDNPackage;
    FOnSelectedPackageChanged: TNotifyEvent;
    FOnCheckIsPackageInstalled: TCheckIsPackageInstalled;
    FOnCheckHasPackageUpdate: TCheckIsPackageInstalled;
    FOnInstallPackage: TPackageEvent;
    FOnUninstallPackage: TPackageEvent;
    FOnUpdatePackage: TPackageEvent;
    FOnInfoPackage: TPackageEvent;
    procedure HandlePackagesChanged(Sender: TObject; const Item: IDNPackage; Action: TCollectionNotification);
    procedure AddPreview(const APackage: IDNPackage);
    procedure RemovePreview(const APackage: IDNPackage);
    procedure HandlePreviewClicked(Sender: TObject);
    procedure ChangeSelectedPackage(const APackage: IDNPackage);
    function GetPreviewForPackage(const APackage: IDNPackage): TPreview;
    function GetInstalledVersion(const APackage: IDNPackage): string;
    function GetUpdateVersion(const APackage: IDNPackage): string;
    procedure InstallPackage(const APackage: IDNPackage);
    procedure UninstallPackage(const APackage: IDNPackage);
    procedure UpdatePackage(const APackage: IDNPackage);
    procedure InfoPackage(const APackage: IDNPackage);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure Clear();
    procedure Refresh();
    property Packages: TList<IDNPackage> read FPackages;
    property SelectedPackage: IDNPackage read FSelectedPackage;
    property OnSelectedPackageChanged: TNotifyEvent read FOnSelectedPackageChanged write FOnSelectedPackageChanged;
    property OnCheckIsPackageInstalled: TCheckIsPackageInstalled read FOnCheckIsPackageInstalled write FOnCheckIsPackageInstalled;
    property OnCheckHasPackageUpdate: TCheckIsPackageInstalled read FOnCheckHasPackageUpdate write FOnCheckHasPackageUpdate;
    property OnInstallPackage: TPackageEvent read FOnInstallPackage write FOnInstallPackage;
    property OnUninstallPackage: TPackageEvent read FOnUninstallPackage write FOnUninstallPackage;
    property OnUpdatePackage: TPackageEvent read FOnUpdatePackage write FOnUpdatePackage;
    property OnInfoPackage: TPackageEvent read FOnInfoPackage write FOnInfoPackage;
  end;

implementation

{ TPackageOverView }

const
  CColumns = 4;
  CSpace = 10;

procedure TPackageOverView.AddPreview(const APackage: IDNPackage);
var
  LPreview: TPreview;
begin
  if FUnusedPreviews.Count > 0 then
    LPreview := FUnusedPreviews.Extract(FUnusedPreviews[0])
  else
    LPreview := TPreview.Create(nil);
  LPreview.Package := APackage;
  LPreview.Parent := Self;
  LPreview.Top := (FPreviews.Count div CColumns) * (LPreview.Height + CSpace);
  LPreview.Left := (FPreviews.Count mod CColumns) * (LPreview.Width + CSpace);
  LPreview.InstalledVersion := GetInstalledVersion(APackage);
  LPreview.UpdateVersion := GetUpdateVersion(APackage);
  LPreview.OnClick := HandlePreviewClicked;
  LPreview.OnInstall := procedure(Sender: TObject) begin InstallPackage(TPreview(Sender).Package) end;
  LPreview.OnUninstall := procedure(Sender: TObject) begin UninstallPackage(TPreview(Sender).Package) end;
  LPreview.OnUpdate := procedure(Sender: TObject) begin UpdatePackage(TPreview(Sender).Package) end;
  LPreview.OnInfo := procedure(Sender: TObject) begin InfoPackage(TPreview(Sender).Package) end;
  FPreviews.Add(LPreview)
end;

procedure TPackageOverView.Clear;
begin
  FPackages.Clear();
end;

constructor TPackageOverView.Create(AOwner: TComponent);
begin
  inherited;
  FPreviews := TObjectList<TPreview>.Create(True);
  FUnusedPreviews := TObjectList<TPreview>.Create(True);
  FPackages := TList<IDNPackage>.Create();
  FPackages.OnNotify := HandlePackagesChanged;
  BorderStyle := bsNone;
  VertScrollBar.Smooth := True;
  VertScrollBar.Tracking := True;
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

function TPackageOverView.GetUpdateVersion(const APackage: IDNPackage): string;
begin
  if Assigned(FOnCheckHasPackageUpdate) then
  begin
    Result := FOnCheckHasPackageUpdate(APackage);
  end
  else
  begin
    Result := '';
  end;
end;

procedure TPackageOverView.InfoPackage(const APackage: IDNPackage);
begin
  if Assigned(FOnInfoPackage) then
    FOnInfoPackage(APackage);
end;

procedure TPackageOverView.InstallPackage(const APackage: IDNPackage);
begin
  if Assigned(FOnInstallPackage) then
    FOnInstallPackage(APackage);
end;

function TPackageOverView.GetInstalledVersion(
  const APackage: IDNPackage): string;
begin
  if Assigned(FOnCheckIsPackageInstalled) then
  begin
    Result := FOnCheckIsPackageInstalled(APackage);
  end
  else
  begin
    Result := '';
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
      FPreviews[i].Package := nil;
      FUnusedPreviews.Add(FPreviews.Extract(FPreviews[i]));
      Break;
    end;
  end;
  if FSelectedPackage = APackage then
  begin
    ChangeSelectedPackage(nil);
  end;
end;

procedure TPackageOverView.UninstallPackage(const APackage: IDNPackage);
begin
  if Assigned(FOnUninstallPackage) then
    FOnUninstallPackage(APackage);
end;

procedure TPackageOverView.UpdatePackage(const APackage: IDNPackage);
begin
  if Assigned(FOnUpdatePackage) then
    FOnUpdatePackage(APackage);
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
