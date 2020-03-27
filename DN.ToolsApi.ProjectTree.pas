unit DN.ToolsApi.ProjectTree;

interface

uses
  Delphinus.ToolsApi.VSTManager,
  DN.ToolsApi.Containers;

type
  TProjectTree = class
  private
    FManager: TVSTManager;
    FDelphinusIcon: Integer;
    FPackageIcon: Integer;
    function GetProjects: TArray<TProjectContainer>;
    function TryGetNodeOfContainer(AContainer: TContainer; out ANode: PNode): Boolean;
    function GetBuildConfiguration(
      AProject: TProjectContainer): TBuildConfigurationContainer;
    function GetTargetPlatform(
      AProject: TProjectContainer): TTargetPlatformContainer;
    function GetDelphinusPackages(
      AProject: TProjectContainer): TDelphinusPackagesContainer;
  public
    constructor Create;
    procedure AddChild(AParent, AChild: TContainer);
    procedure AddSibling(ASibling, ANewSibling: TContainer);
    procedure SetupProject(AProject: TProjectContainer);
    property Projects: TArray<TProjectContainer> read GetProjects;
    property BuildConfiguration[AProject: TProjectContainer]: TBuildConfigurationContainer read GetBuildConfiguration;
    property TargetPlatform[AProject: TProjectContainer]: TTargetPlatformContainer read GetTargetPlatform;
    property DelphinusPackages[AProject: TProjectContainer]: TDelphinusPackagesContainer read GetDelphinusPackages;
  end;

implementation

uses
  RTTI,
  Classes,
  SysUtils,
  Graphics,
  Generics.Collections,
  Controls,
  Delphinus.ToolsApi.IDE,
  Delphinus.Resources.Names;

const
  CNodeDelphinusPackages = 'Delphinus Packages';

{ TProjectTree }

procedure TProjectTree.AddChild(AParent, AChild: TContainer);
var
  LParent, LChild: PNode;
  LData: PNodeData;
begin
  if TryGetNodeOfContainer(AParent, LParent) then
  begin
    LChild := FManager.AddChild(LParent);
    LData := FManager.GetNodeData(LChild);
    LData.ProjectManager := AChild.NodeDataInterfaceA;
    LData.ProjectManagerB := AChild.NodeDataInterfaceB;
  end;
end;

procedure TProjectTree.AddSibling(ASibling, ANewSibling: TContainer);
var
  LParent, LChild: PNode;
  LData: PNodeData;
begin
  if TryGetNodeOfContainer(ASibling, LParent) then
  begin
    LChild := FManager.InsertNode(LParent, amInsertAfter);
    LData := FManager.GetNodeData(LChild);
    LData.ProjectManager := ANewSibling.NodeDataInterfaceA;
    LData.ProjectManagerB := ANewSibling.NodeDataInterfaceB;
  end;
end;

constructor TProjectTree.Create;
var
  LInstance: TControl;
  LIcon: TIcon;
begin
  inherited;
  TryFindControl('TVirtualStringTree', 'ProjectTree2', LInstance);
  FManager := TVSTManager.Create(LInstance);
  LIcon := TIcon.Create();
  try
    LIcon.LoadFromResourceName(HInstance, Ico_Delphinus);
    FDelphinusIcon := FManager.Images.AddIcon(LIcon);
    LIcon.LoadFromResourceName(HInstance, Ico_Package);
    FPackageIcon := FManager.Images.AddIcon(LIcon);
  finally
    LIcon.Free;
  end;
end;

function TProjectTree.GetBuildConfiguration(
  AProject: TProjectContainer): TBuildConfigurationContainer;
var
  LChild: TContainer;
  i: Integer;
  LChildren: IInterfaceList;
begin
  LChildren := AProject.Children;
  for i := 0 to Pred(LChildren.Count) do
  begin
    LChild := TContainer(LChildren[i] as TObject);
    if AnsiSameText(LChild.ClassName, 'TBaseConfigurationContainer') then
    begin
      Result := TBuildConfigurationContainer(LChild);
      Exit;
    end;
  end;
  Result := nil;
end;

function TProjectTree.GetDelphinusPackages(
  AProject: TProjectContainer): TDelphinusPackagesContainer;
var
  LChild: TContainer;
  i: Integer;
  LChildren: IInterfaceList;
begin
  LChildren := AProject.Children;
  for i := 0 to Pred(LChildren.Count) do
  begin
    LChild := TContainer(LChildren[i] as TObject);
    if AnsiSameText(LChild.DisplayName, CNodeDelphinusPackages) then
    begin
      Result := TDelphinusPackagesContainer(LChild);
      Exit;
    end;
  end;
  Result := nil;
end;

function TProjectTree.GetProjects: TArray<TProjectContainer>;
var
  LList: TList<TProjectContainer>;
  LTreeRoot, LProject: Pointer;
  LData: PNodeData;
  LContainer: TProjectContainer;
begin
  LList := TList<TProjectContainer>.Create();
  LTreeRoot := FManager.GetFirstVisible;
  if Assigned(LTreeRoot) then
  begin
    LProject := FManager.GetFirstChild(LTreeRoot);
    while Assigned(LProject) do
    begin
      LData := FManager.GetNodeData(LProject);
      LContainer := TProjectContainer(LData.ProjectManager as TObject);
      if Assigned(LContainer) then
        LList.Add(LContainer);
      LProject := FManager.GetNextSibling(LProject);
    end;
  end;
  Result := LList.ToArray;
end;

function TProjectTree.GetTargetPlatform(
  AProject: TProjectContainer): TTargetPlatformContainer;
var
  LChild: TContainer;
  i: Integer;
  LChildren: IInterfaceList;
begin
  LChildren := AProject.Children;
  for i := 0 to Pred(LChildren.Count) do
  begin
    LChild := TContainer(LChildren[i] as TObject);
    if AnsiSameText(LChild.ClassName, 'TBasePlatformContainer') then
    begin
      Result := TTargetPlatformContainer(LChild);
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TProjectTree.SetupProject(AProject: TProjectContainer);
var
  LPackages, LFirstSibling: TContainer;
  LIndex: Integer;
begin
  LPackages := DelphinusPackages[AProject];
  if not Assigned(LPackages) then
  begin

    LPackages := TContainer.CreateCategory(AProject, CNodeDelphinusPackages);
    LPackages.ImageIndex := FDelphinusIcon;
    //manually add to tree to get instant update
    LIndex := 2;
    LFirstSibling := TargetPlatform[AProject];
    //Delphi XE for example has no TargetPlatForm node, so we fallback to BuildConfiguration
    if not Assigned(LFirstSibling) then
    begin
      LFirstSibling := BuildConfiguration[AProject];
      LIndex := 1;
    end;
    AddSibling(LFirstSibling, LPackages);
    //now add to model so it rebuilds whenever the tree changes
    AProject.Children.Insert(LIndex, LPackages);
  end;
end;

function TProjectTree.TryGetNodeOfContainer(AContainer: TContainer;
  out ANode: PNode): Boolean;
var
  LNode: PNode;
  LData: PNodeData;
begin
  LNode := FManager.GetFirst();
  while Assigned(LNode) do
  begin
    LData := FManager.GetNodeData(LNode);
    if((LData.ProjectManager as TObject) = AContainer) then
    begin
      ANode := LNode;
      Exit(True);
    end;
    LNode := FManager.GetNext(LNode);
  end;
  Result := False;
end;

end.
