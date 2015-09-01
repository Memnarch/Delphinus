unit Delphinus.CategoryFilterView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls;

type
  TPackageCategory = (pcOnline, pcInstalled, pcUpdates);
  TCategoryChanged = procedure(Sender: TObject; ACategory: TPackageCategory) of object;

  TCategoryFilterView = class(TFrame)
    tvCategories: TTreeView;
    procedure tvCategoriesAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure FrameResize(Sender: TObject);
    procedure tvCategoriesChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure tvCategoriesCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure tvCategoriesChange(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
    LPackageNode: TTreeNode;
    FOnCategoryChanged: TCategoryChanged;
    procedure CategoryChanged(ANewCategory: TPackageCategory);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property OnCategoryChanged: TCategoryChanged read FOnCategoryChanged write FOnCategoryChanged;
  end;

implementation

uses
  DN.Graphics;

{$R *.dfm}

{ TCategoryFilterView }

procedure TCategoryFilterView.CategoryChanged(ANewCategory: TPackageCategory);
begin
  if Assigned(FOnCategoryChanged) then
    FOnCategoryChanged(Self, ANewCategory);
end;

constructor TCategoryFilterView.Create(AOwner: TComponent);
begin
  inherited;
  LPackageNode := tvCategories.Items.AddChild(nil, 'Packages');
  tvCategories.Items.AddChild(LPackageNode, 'Online').Selected := True;
  tvCategories.Items.AddChild(LPackageNode, 'Installed');
  tvCategories.Items.AddChild(LPackageNode, 'Updates');
  LPackageNode.Expand(False);
end;

procedure TCategoryFilterView.FrameResize(Sender: TObject);
begin
  tvCategories.Invalidate;
  tvCategories.Repaint;
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
  LRect := Node.DisplayRect(False);
  LText := Node.Text;

    if cdsSelected in State then
      LBackground := clSkyBlue
    else
      LBackground := clLtGray;

    if (Node.Count > 0) or (cdsSelected in State) then
      GradientFillRectVertical(Sender.Canvas, AlterColor(LBackground, CDiff), AlterColor(LBackground, -CDiff), LRect);
    SetBkMode(Sender.Canvas.Handle, TRANSPARENT);
    Sender.Canvas.TextRect(LRect, LText, [tfCenter]);

  DefaultDraw := False;
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

procedure TCategoryFilterView.tvCategoriesChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
begin
  AllowChange := Node.Count = 0;
end;

procedure TCategoryFilterView.tvCategoriesCollapsing(Sender: TObject;
  Node: TTreeNode; var AllowCollapse: Boolean);
begin
  AllowCollapse := False;
end;

end.
