unit Delphinus.CategoryFilterView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls,
  DN.PackageFilter, Generics.Collections,
  Delphinus.FilterProperties,
  DN.Package.Intf,
  Delphinus.Settings;

type
  TPackageCategory = (pcOnline, pcInstalled, pcUpdates);
  TCategoryChanged = procedure(Sender: TObject; ACategory: TPackageCategory) of object;
  TFilterChanged = procedure(Sender: TObject; ANewFilter: TPackageFilter) of object;

  TCategoryFilterView = class(TFrame)
    tvCategories: TTreeView;
    tvFilters: TTreeView;
    btnRemove: TButton;
    btnAdd: TButton;
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
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
  private
    { Private declarations }
    FPackageNodeIndex: Integer;
    FOnlineNodeIndex: Integer;
    FInstalledNodeIndex: Integer;
    FUpdatesNodeIndex: Integer;
    FFilterNodeIndex: Integer;
    FOnCategoryChanged: TCategoryChanged;
    FOnFilterChanged: TFilterChanged;
    FFilterCallbacks: TDictionary<string, TPackageFilter>;
    FFilterProperties: TDictionary<string, TFilterProperties>;
    FOnlineCount: Integer;
    FInstalledCount: Integer;
    FUpdatesCount: Integer;
    FCurrentFilterProperties: TFilterProperties;
    FSettings: TDelphinusSettings;
    procedure CategoryChanged(ANewCategory: TPackageCategory);
    procedure FilterChanged(AFilter: TPackageFilter);
    function GetNumberedCaption(const AText: string; AValue: Integer): string;
    procedure SetInstalledCount(const Value: Integer);
    procedure SetOnlineCount(const Value: Integer);
    procedure SetUpdatesCount(const Value: Integer);
    procedure FilterByFilterProperties(const APackage: IDNPackage; var AAccepted: Boolean);
    function IsNameValid(const AName: string): Boolean;
    procedure SetSettings(const Value: TDelphinusSettings);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure RegisterFilter(const AName: string; AFilter: TPackageFilter);
    procedure RegisterFilterProperties(AProperties: TFilterProperties);
    procedure UnregisterFilter(const AName: string);
    property OnCategoryChanged: TCategoryChanged read FOnCategoryChanged write FOnCategoryChanged;
    property OnFilterChanged: TFilterChanged read FOnFilterChanged write FOnFilterChanged;
    property OnlineCount: Integer read FOnlineCount write SetOnlineCount;
    property InstalledCount: Integer read FInstalledCount write SetInstalledCount;
    property UpdatesCount: Integer read FUpdatesCount write SetUpdatesCount;
    property Settings: TDelphinusSettings read FSettings write SetSettings;
  end;

implementation

uses
  Character,
  DN.Graphics,
  Delphinus.FilterProperties.Dialog;

{$R *.dfm}

const
  COnline = 'Online';
  CInstalled = 'Installed';
  CUpdates = 'Updates';

{ TCategoryFilterView }

procedure TCategoryFilterView.btnAddClick(Sender: TObject);
var
  LProperties: TFilterProperties;
  LDialog: TFilterPropertiesDialog;
begin
  LDialog := TFilterPropertiesDialog.Create(nil);
  try
    LProperties := TFilterProperties.Create();
    LDialog.OnIsNameValid := IsNameValid;
    LDialog.FilterProperties := LProperties;
    if LDialog.ShowModal() = mrOk then
    begin
      RegisterFilterProperties(LProperties);
      FSettings.Filters.Add(LProperties);
    end
    else
      LProperties.Free;
  finally
    LDialog.Free;
  end;
end;

procedure TCategoryFilterView.btnRemoveClick(Sender: TObject);
begin
  if Assigned(tvFilters.Selected) then
    UnregisterFilter(tvFilters.Selected.Text);
end;

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
  FFilterCallbacks := TDictionary<string, TPackageFilter>.Create();
  FFilterProperties := TDictionary<string, TFilterProperties>.Create();
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
  FFilterCallbacks.Free();
  FFilterProperties.Free();
  inherited;
end;

procedure TCategoryFilterView.FilterByFilterProperties(
  const APackage: IDNPackage; var AAccepted: Boolean);
begin
  AAccepted := not Assigned(FCurrentFilterProperties)
    or (FCurrentFilterProperties.Platforms * APackage.Platforms <> []);
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

function TCategoryFilterView.IsNameValid(const AName: string): Boolean;
begin
  Result := not FFilterCallbacks.ContainsKey(TCharacter.ToLower(AName));
end;

procedure TCategoryFilterView.RegisterFilter(const AName: string;
  AFilter: TPackageFilter);
begin
  tvFilters.Selected := tvFilters.Items.AddChild(tvFilters.Items.Item[FFilterNodeIndex], AName);
  FFilterCallbacks.Add(TCharacter.ToLower(AName), AFilter);
end;

procedure TCategoryFilterView.RegisterFilterProperties(
  AProperties: TFilterProperties);
begin
  FFilterProperties.Add(AProperties.Caption, AProperties);
  RegisterFilter(AProperties.Caption, FilterByFilterProperties);
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

procedure TCategoryFilterView.SetSettings(const Value: TDelphinusSettings);
var
  LProperties: TFilterProperties;
begin
  if FSettings <> Value then
  begin
    FSettings := Value;
    if Assigned(FSettings) then
    begin
      for LProperties in FSettings.Filters do
        RegisterFilterProperties(LProperties);
    end;
  end;
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
  FCurrentFilterProperties := nil;
  if FFilterCallbacks.TryGetValue(TCharacter.ToLower(Node.Text), LFilter) then
  begin
    if FFilterProperties.ContainsKey(Node.Text) then
      FCurrentFilterProperties := FFilterProperties.Items[Node.Text];

    FilterChanged(LFilter);
  end;
end;

procedure TCategoryFilterView.UnregisterFilter(const AName: string);
var
  LNode: TTreeNode;
  i: Integer;
begin
  FFilterCallbacks.Remove(TCharacter.ToLower(AName));
  FFilterProperties.Remove(AName);
  for i := FSettings.Filters.Count - 1 downto 0 do
    if SameText(FSettings.Filters[i].Caption, AName) then
      FSettings.Filters.Delete(i);

  LNode := tvFilters.Items.Item[FFilterNodeIndex].GetLastChild;
  while Assigned(LNode) do
  begin
    if (LNode.Text = AName) and (LNode.Index > 0) then
    begin
      tvFilters.Items.Delete(LNode);
      Break;
    end;
    LNode := LNode.getPrevSibling;
  end;
end;

end.
