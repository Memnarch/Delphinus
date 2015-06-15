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
  TPackageOverView = class(TScrollBox)
  private
    FPreviews: TObjectList<TPreview>;
    FPackages: TList<IDNPackage>;
    FSelectedPackage: IDNPackage;
    FOnSelectedPackageChanged: TNotifyEvent;
    procedure HandlePackagesChanged(Sender: TObject; const Item: IDNPackage; Action: TCollectionNotification);
    procedure AddPreview(const APackage: IDNPackage);
    procedure RemovePreview(const APackage: IDNPackage);
    procedure HandlePreviewClicked(Sender: TObject);
    procedure ChangeSelectedPackage(const APackage: IDNPackage);
    function GetPreviewForPackage(const APackage: IDNPackage): TPreview;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure Clear();
    property Packages: TList<IDNPackage> read FPackages;
    property SelectedPackage: IDNPackage read FSelectedPackage;
    property OnSelectedPackageChanged: TNotifyEvent read FOnSelectedPackageChanged write FOnSelectedPackageChanged;
  end;

implementation

{ TPackageOverView }

procedure TPackageOverView.AddPreview(const APackage: IDNPackage);
var
  LPreview: TPreview;
begin
  LPreview := TPreview.Create(nil);
  LPreview.Package := APackage;
  LPreview.Parent := Self;
  LPreview.Top := (FPreviews.Count div 3) * (LPreview.Height + 10);
  LPreview.Left := (FPreviews.Count mod 3) * (LPreview.Width + 10);
  LPreview.OnClick := HandlePreviewClicked;
  FPreviews.Add(LPreview)
end;

procedure TPackageOverView.Clear;
begin
  FPreviews.Clear();
  FPackages.Clear();
end;

constructor TPackageOverView.Create(AOwner: TComponent);
begin
  inherited;
  FPreviews := TObjectList<TPreview>.Create(True);
  FPackages := TList<IDNPackage>.Create();
  FPackages.OnNotify := HandlePackagesChanged;
  BorderStyle := bsNone;
  VertScrollBar.Smooth := True;
  VertScrollBar.Tracking := True;
end;

destructor TPackageOverView.Destroy;
begin
  FPreviews.Clear();
  FPackages.Clear;
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

procedure TPackageOverView.RemovePreview(const APackage: IDNPackage);
var
  i: Integer;
begin
  for i := FPreviews.Count - 1 downto 0 do
  begin
    if FPreviews[i].Package = APackage then
    begin
      FPreviews.Delete(i);
      Break;
    end;
  end;
  if FSelectedPackage = APackage then
  begin
    ChangeSelectedPackage(nil);
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
