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
  TCategoryChanged = procedure(Sender: TObject; ACategory: TPackageCategory; ASubNode: Integer) of object;
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
    FOnlineSubNodes: TArray<Integer>;
    FOnlineSubNodeNames: TArray<string>;
    FOnlineSubNodeCounts: TArray<Integer>;
    FInstalledNodeIndex: Integer;
    FUpdatesNodeIndex: Integer;
    FOnCategoryChanged: TCategoryChanged;
    FOnlineCount: Integer;
    FInstalledCount: Integer;
    FUpdatesCount: Integer;
    procedure CategoryChanged(ANewCategory: TPackageCategory; ASubNode: Integer);
    function GetNumberedCaption(const AText: string; AValue: Integer): string;
    procedure SetInstalledCount(const Value: Integer);
    procedure SetOnlineCount(const Value: Integer);
    procedure SetUpdatesCount(const Value: Integer);
    function GetSubOnlineCount(const AIndex: Integer): Integer;
    procedure SetSubOnlineCount(const AIndex, Value: Integer);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure SetOnlineSubnodes(const ANames: TArray<string>);
    property OnCategoryChanged: TCategoryChanged read FOnCategoryChanged write FOnCategoryChanged;
    property OnlineCount: Integer read FOnlineCount write SetOnlineCount;
    property InstalledCount: Integer read FInstalledCount write SetInstalledCount;
    property UpdatesCount: Integer read FUpdatesCount write SetUpdatesCount;
    property SubOnlineCount[const AIndex: Integer]: Integer read GetSubOnlineCount write SetSubOnlineCount;
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

procedure TCategoryFilterView.CategoryChanged(ANewCategory: TPackageCategory; ASubNode: Integer);
begin
  if Assigned(FOnCategoryChanged) then
    FOnCategoryChanged(Self, ANewCategory, ASubNode);
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
  FOnlineNodeIndex := LOnlineNode.Index;
  FInstalledNodeIndex := tvCategories.Items.AddChild(nil, GetNumberedCaption(CInstalled, FInstalledCount)).Index;
  FUpdatesNodeIndex := tvCategories.Items.AddChild(nil, GetNumberedCaption(CUpdates, FUpdatesCount)).Index;
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

function TCategoryFilterView.GetSubOnlineCount(const AIndex: Integer): Integer;
begin
  Result := FOnlineSubNodeCounts[AIndex];
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

procedure TCategoryFilterView.SetOnlineSubnodes(const ANames: TArray<string>);
var
  LOnlineNode, LSubNode: TTreeNode;
  i: Integer;
begin
  FOnlineSubNodeNames := ANames;
  SetLength(FOnlineSubNodes, Length(ANames));
  SetLength(FOnlineSubNodeCounts, Length(ANames));
  LOnlineNode := tvCategories.Items.Item[FOnlineNodeIndex];
  FInstalledNodeIndex := FOnlineNodeIndex + 1;
  FUpdatesNodeIndex := FOnlineNodeIndex + 2;
  for i := Pred(LOnlineNode.Count) downto 0 do
    tvCategories.Items.Delete(LOnlineNode.Item[i]);

  for i := 0 to High(FOnlineSubNodeNames) do
  begin
    LSubNode := tvCategories.Items.AddChild(LOnlineNode, FOnlineSubNodeNames[i]);
    FOnlineSubNodes[i] := LSubNode.Index;
    Inc(FInstalledNodeIndex);
    Inc(FUpdatesNodeIndex);
  end;
end;

procedure TCategoryFilterView.SetSubOnlineCount(const AIndex, Value: Integer);
begin
  FOnlineSubNodeCounts[AIndex] := Value;
  tvCategories.Items[FOnlineNodeIndex].Item[FOnlineSubNodes[AIndex]].Text := GetNumberedCaption(FOnlineSubNodeNames[AIndex], Value);
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
    LRect.Left := 16;
    if Assigned(Node.Parent) then
      LRect.Left := LRect.Left + 10;
    Sender.Canvas.TextRect(LRect, LText);
    if Node.Count > 0 then
    begin
      LRect.Left := 2;
      if Node.Expanded then
        LText := '-'
      else
        LText := '+';
      Sender.Canvas.TextRect(LRect, LText);
    end;
    DefaultDraw := True;
  end;
end;

procedure TCategoryFilterView.tvCategoriesChange(Sender: TObject;
  Node: TTreeNode);
begin
  if not Assigned(Node.Parent) then
  begin
    if Node.AbsoluteIndex = FOnlineNodeIndex then
      CategoryChanged(pcOnline, -1)
    else if Node.AbsoluteIndex = FInstalledNodeIndex then
      CategoryChanged(pcInstalled, -1)
    else if Node.AbsoluteIndex = FUpdatesNodeIndex then
      CategoryChanged(pcUpdates, -1);
  end
  else
    CategoryChanged(pcOnline, Node.Index);
end;

procedure TCategoryFilterView.tvCategoriesCollapsing(Sender: TObject;
  Node: TTreeNode; var AllowCollapse: Boolean);
begin
  AllowCollapse := True;
end;

end.
