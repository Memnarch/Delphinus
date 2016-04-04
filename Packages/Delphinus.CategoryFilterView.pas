unit Delphinus.CategoryFilterView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls,
  DN.PackageFilter, Generics.Collections,
  DN.Package.Intf,
  Delphinus.Forms,
  ExtCtrls,
  ImgList,
  Menus;

type
  TPackageCategory = (pcOnline, pcInstalled, pcUpdates);
  TCategoryChanged = procedure(Sender: TObject; ACategory: TPackageCategory) of object;
  TFilterChanged = procedure(Sender: TObject; ANewFilter: TPackageFilter) of object;

  TCategoryFilterView = class(TFrame)
    tvCategories: TTreeView;
    procedure tvCategoriesAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure FrameResize(Sender: TObject);
    procedure tvCategoriesCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure tvCategoriesChange(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
    FOnlineNodeIndex: Integer;
    FInstalledNodeIndex: Integer;
    FUpdatesNodeIndex: Integer;
    FOnCategoryChanged: TCategoryChanged;
    FOnlineCount: Integer;
    FInstalledCount: Integer;
    FUpdatesCount: Integer;
    procedure CategoryChanged(ANewCategory: TPackageCategory);
    function GetNumberedCaption(const AText: string; AValue: Integer): string;
    procedure SetInstalledCount(const Value: Integer);
    procedure SetOnlineCount(const Value: Integer);
    procedure SetUpdatesCount(const Value: Integer);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property OnCategoryChanged: TCategoryChanged read FOnCategoryChanged write FOnCategoryChanged;
    property OnlineCount: Integer read FOnlineCount write SetOnlineCount;
    property InstalledCount: Integer read FInstalledCount write SetInstalledCount;
    property UpdatesCount: Integer read FUpdatesCount write SetUpdatesCount;
  end;

implementation

uses
  Character,
  DN.Graphics;

{$R *.dfm}

const
  COnline = 'Online';
  CInstalled = 'Installed';
  CUpdates = 'Updates';

{ TCategoryFilterView }

procedure TCategoryFilterView.CategoryChanged(ANewCategory: TPackageCategory);
begin
  if Assigned(FOnCategoryChanged) then
    FOnCategoryChanged(Self, ANewCategory);
end;

constructor TCategoryFilterView.Create(AOwner: TComponent);
var
  LOnlineNode: TTreeNode;
  LRect: TRect;
begin
  inherited;
  //in case you wonder why i save the nodes index and not the TTreeNode Instance:
  //on first show all nodes are recreated which invalidates the instances we receive here.
  //See(in german): http://www.delphipraxis.net/89993-treenode-treeview-automatisches-destroy.html
  LOnlineNode := tvCategories.Items.AddChild(nil, GetNumberedCaption(COnline, FOnlineCount));
  LOnlineNode.Selected := True;
  FOnlineNodeIndex := LOnlineNode.AbsoluteIndex;
  FInstalledNodeIndex := tvCategories.Items.AddChild(nil, GetNumberedCaption(CInstalled, FInstalledCount)).AbsoluteIndex;
  FUpdatesNodeIndex := tvCategories.Items.AddChild(nil, GetNumberedCaption(CUpdates, FUpdatesCount)).AbsoluteIndex;
  LRect := LOnlineNode.DisplayRect(False);
  tvCategories.ClientHeight := (LRect.Bottom - LRect.Top)*3;
end;

procedure TCategoryFilterView.FrameResize(Sender: TObject);
begin
  tvCategories.Invalidate;
  tvCategories.Repaint;
end;

function TCategoryFilterView.GetNumberedCaption(const AText: string;
  AValue: Integer): string;
begin
  if AValue > 0 then
    Result := AText + ' (' + IntToStr(AValue) + ')'
  else
    Result := AText;
end;

procedure TCategoryFilterView.SetInstalledCount(const Value: Integer);
begin
  FInstalledCount := Value;
  tvCategories.Items.Item[FInstalledNodeIndex].Text := GetNumberedCaption(CInstalled, FInstalledCount);
end;

procedure TCategoryFilterView.SetOnlineCount(const Value: Integer);
begin
  FOnlineCount := Value;
  tvCategories.Items.Item[FOnlineNodeIndex].Text := GetNumberedCaption(COnline, FOnlineCount);
end;

procedure TCategoryFilterView.SetUpdatesCount(const Value: Integer);
begin
  FUpdatesCount := Value;
  tvCategories.Items.Item[FUpdatesNodeIndex].Text := GetNumberedCaption(CUpdates, FUpdatesCount);
end;

procedure TCategoryFilterView.tvCategoriesAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  LRect: TRect;
  LText: string;
  LBackground: TColor;
const
  CDiff = 2;
begin
  if Stage = cdPostPaint then
  begin
    LRect := Node.DisplayRect(False);
    LText := Node.Text;

    if cdsSelected in State then
      LBackground := clSkyBlue
    else if cdsHot in State then
      LBackground := clLtGray
    else
      LBackground := Color;

    Sender.Canvas.Brush.Color := LBackground;
    Sender.Canvas.FillRect(LRect);
    SetBkMode(Sender.Canvas.Handle, TRANSPARENT);
    LRect.Left := 3;
    Sender.Canvas.TextRect(LRect, LText);
    DefaultDraw := True;
  end;
end;

procedure TCategoryFilterView.tvCategoriesChange(Sender: TObject;
  Node: TTreeNode);
begin
  case Node.Index of
    0: CategoryChanged(pcOnline);
    1: CategoryChanged(pcInstalled);
    2: CategoryChanged(pcUpdates);
  end;
end;

procedure TCategoryFilterView.tvCategoriesCollapsing(Sender: TObject;
  Node: TTreeNode; var AllowCollapse: Boolean);
begin
  AllowCollapse := False;
end;

end.
