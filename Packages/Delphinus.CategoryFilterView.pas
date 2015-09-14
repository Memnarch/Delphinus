unit Delphinus.CategoryFilterView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls,
  Delphinus.PackageFilter, Generics.Collections;

type
  TPackageCategory = (pcOnline, pcInstalled, pcUpdates);
  TCategoryChanged = procedure(Sender: TObject; ACategory: TPackageCategory) of object;
  TFilterChanged = procedure(Sender: TObject; ANewFilter: TPackageFilter) of object;

  TCategoryFilterView = class(TFrame)
    tvCategories: TTreeView;
    tvFilters: TTreeView;
    procedure tvCategoriesAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure FrameResize(Sender: TObject);
    procedure tvCategoriesChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure tvCategoriesCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure tvCategoriesChange(Sender: TObject; Node: TTreeNode);
    procedure tvFiltersChange(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
    FPackageNodeIndex: Integer;
    FOnlineNodeIndex: Integer;
    FInstalledNodeIndex: Integer;
    FUpdatesNodeIndex: Integer;
    FFilterNodeIndex: Integer;
    FOnCategoryChanged: TCategoryChanged;
    FOnFilterChanged: TFilterChanged;
    FFilters: TDictionary<string, TPackageFilter>;
    FOnlineCount: Integer;
    FInstalledCount: Integer;
    FUpdatesCount: Integer;
    procedure CategoryChanged(ANewCategory: TPackageCategory);
    procedure FilterChanged(AFilter: TPackageFilter);
    function GetNumberedCaption(const AText: string; AValue: Integer): string;
    procedure SetInstalledCount(const Value: Integer);
    procedure SetOnlineCount(const Value: Integer);
    procedure SetUpdatesCount(const Value: Integer);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure RegisterFilter(const AName: string; AFilter: TPackageFilter);
    procedure UnregisterFilter(const AName: string);
    property OnCategoryChanged: TCategoryChanged read FOnCategoryChanged write FOnCategoryChanged;
    property OnFilterChanged: TFilterChanged read FOnFilterChanged write FOnFilterChanged;
    property OnlineCount: Integer read FOnlineCount write SetOnlineCount;
    property InstalledCount: Integer read FInstalledCount write SetInstalledCount;
    property UpdatesCount: Integer read FUpdatesCount write SetUpdatesCount;
  end;

implementation

uses
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
  LPackageNode, LOnlineNode, LFilterNode: TTreeNode;
  LRect: TRect;
begin
  inherited;
  //in case you wonder why i save the nodes index and not the TTreeNode Instance:
  //on first show all nodes are recreated which invalidates the instances we receive here.
  //See(in german): http://www.delphipraxis.net/89993-treenode-treeview-automatisches-destroy.html
  FFilters := TDictionary<string, TPackageFilter>.Create();
  LPackageNode := tvCategories.Items.AddChild(nil, 'Packages');
  FPackageNodeIndex := LPackageNode.AbsoluteIndex;
  LOnlineNode := tvCategories.Items.AddChild(LPackageNode, GetNumberedCaption(COnline, FOnlineCount));
  LOnlineNode.Selected := True;
  FOnlineNodeIndex := LOnlineNode.AbsoluteIndex;
  FInstalledNodeIndex := tvCategories.Items.AddChild(LPackageNode, GetNumberedCaption(CInstalled, FInstalledCount)).AbsoluteIndex;
  FUpdatesNodeIndex := tvCategories.Items.AddChild(LPackageNode, GetNumberedCaption(CUpdates, FUpdatesCount)).AbsoluteIndex;
  LRect := LPackageNode.DisplayRect(False);
  tvCategories.ClientHeight := (LRect.Bottom - LRect.Top)*4;

  LFilterNode := tvFilters.Items.AddChild(nil, 'Filters');
  FFilterNodeIndex := LFilterNode.AbsoluteIndex;
  RegisterFilter('All', nil);

  LPackageNode.Expand(False);
  LFilterNode.Expand(False);
end;

destructor TCategoryFilterView.Destroy;
begin
  FFilters.Free();
  inherited;
end;

procedure TCategoryFilterView.FilterChanged(AFilter: TPackageFilter);
begin
  if Assigned(FOnFilterChanged) then
    FOnFilterChanged(Self, AFilter);
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

procedure TCategoryFilterView.RegisterFilter(const AName: string;
  AFilter: TPackageFilter);
begin
  tvFilters.Selected := tvFilters.Items.AddChild(tvFilters.Items.Item[FFilterNodeIndex], AName);
  FFilters.Add(AName, AFilter);
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
  LRect := Node.DisplayRect(False);
  LText := Node.Text;

    if cdsSelected in State then
      LBackground := clSkyBlue
    else
      LBackground := clLtGray;

    if (not Assigned(Node.Parent)) or (cdsSelected in State) then
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
  AllowChange := Assigned(Node.Parent);
end;

procedure TCategoryFilterView.tvCategoriesCollapsing(Sender: TObject;
  Node: TTreeNode; var AllowCollapse: Boolean);
begin
  AllowCollapse := False;
end;

procedure TCategoryFilterView.tvFiltersChange(Sender: TObject; Node: TTreeNode);
var
  LFilter: TPackageFilter;
begin
  if FFilters.TryGetValue(Node.Text, LFilter) then
    FilterChanged(LFilter);
end;

procedure TCategoryFilterView.UnregisterFilter(const AName: string);
var
  LNode: TTreeNode;
begin
  FFilters.Remove(AName);
  LNode := tvFilters.Items.Item[FFilterNodeIndex].GetLastChild;
  while Assigned(LNode) do
  begin
    if LNode.Text = AName then
    begin
      tvFilters.Items.Delete(LNode);
      Break;
    end;
    LNode := LNode.getPrevSibling;
  end;
end;

end.
