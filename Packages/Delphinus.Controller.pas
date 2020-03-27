{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit Delphinus.Controller;

interface

uses
  XMLIntf,
  ToolsApi,
  Classes,
  Types,
  Menus,
  Windows,
  Graphics,
  ImgList,
  Dialogs,
  Delphinus.Dialog,
  Delphinus.EventWindow,
  DN.ToolsApi.ProjectTree;

type
  IDelphinusController = interface
    ['{559073E9-136F-42DE-A615-13023C078680}']
    procedure Dispose;
  end;

  TProjectsNotifier = class(TModuleNotifierObject, IOTAProjectFileStorageNotifier)
  private
    FEventWindow: TEventWindow;
  public
    constructor Create(AEventWindow: TEventWindow);
    function GetName: string;
    procedure ProjectLoaded(const ProjectOrGroup: IOTAModule; const Node: IXMLNode);
    procedure CreatingProject(const ProjectOrGroup: IOTAModule);
    procedure ProjectSaving(const ProjectOrGroup: IOTAModule; const Node: IXMLNode);
    procedure ProjectClosing(const ProjectOrGroup: IOTAModule);
  end;

  TProjectEvent = procedure(const AProject: IOTAProject) of object;

  TDelphinusPackagesMenuEvents = class(TInterfacedObject, INTAProjectMenuCreatorNotifier)
  private
    FOnManagePackages: TProjectEvent;
    procedure HandleManagePackages(Sender: TObject);
  public
    function AddMenu(const Ident: string): TMenuItem;
    function CanHandle(const Ident: string): Boolean;
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    property OnManagePackages: TProjectEvent read FOnManagePackages write FOnManagePackages;
  end;

  TDelphinusController = class(TInterfacedObject, IDelphinusController)
  private
    FMenuItem: TMenuItem;
    FDialog: TDelphinusDialog;
    FProjectTree: TProjectTree;
    FIcon: TIcon;
    FStorageNotifierIndex: Integer;
    FProjectMenuNotifierIndex: Integer;
    FEventWindow: TEventWindow;
    procedure NeedProjectTree;
    procedure HandleClickDelphinus(Sender: TObject);
    procedure InstallMenu();
    procedure UninstallMenu();
    function GetIndexOfConfigureTools(AToolsMenu: TMenuItem): Integer;
    procedure HandleEvent(AEvent: TEventType);
    procedure HandleManageProjectPackages(const AProject: IOTAProject);
  public
    constructor Create();
    destructor Destroy(); override;
    //IDelphinusController
    procedure Dispose;
  end;

implementation

uses
  SysUtils,
  StrUtils,
  DN.ToolsApi,
  DN.ToolsApi.Containers,
  Delphinus.Version,
  Delphinus.Resources.Names;

const
  CToolsMenu = 'ToolsMenu';
  CConfigureTools = 'ToolsToolsItem';//heard you like tools....

{ TDelphinusController }

constructor TDelphinusController.Create;
var
  LBitmap: TBitmap;
  LMenuNotifier: TDelphinusPackagesMenuEvents;
begin
  inherited;
  FIcon := TIcon.Create();
  FIcon.SetSize(16, 16);
  FIcon.Handle := LoadImage(HInstance, Ico_Delphinus, IMAGE_ICON, 0, 0, 0);
  LBitmap := TBitmap.Create();
  try
    LBitmap.SetSize(24, 24);
    LBitmap.Canvas.Draw((24 - FIcon.Width) div 2, (24 - FIcon.Height) div 2, FIcon);
    SplashScreenServices.AddPluginBitmap(CVersionedDelphinus, LBitmap.Handle);
  finally
    LBitmap.Free;
  end;
  InstallMenu();
  FEventWindow := TEventWindow.Create(nil);
  FEventWindow.OnEvent := HandleEvent;
  FDialog := TDelphinusDialog.Create(nil);
  FStorageNotifierIndex := (BorlandIDEServices as IOTAProjectFileStorage).AddNotifier(TProjectsNotifier.Create(FEventWindow));
  LMenuNotifier := TDelphinusPackagesMenuEvents.Create();
  LMenuNotifier.OnManagePackages := HandleManageProjectPackages;
  FProjectMenuNotifierIndex := (BorlandIDEServices as IOTAProjectManager).AddMenuCreatorNotifier(LMenuNotifier);
end;

destructor TDelphinusController.Destroy;
begin
  FEventWindow.Free;
  UninstallMenu();
  FDialog.Free;
  FIcon.Free;
  FProjectTree.Free;
  inherited;
end;

procedure TDelphinusController.Dispose;
begin
  (BorlandIDEServices as IOTAProjectFileStorage).RemoveNotifier(FStorageNotifierIndex);
  (BorlandIDEServices as IOTAProjectManager).RemoveMenuCreatorNotifier(FProjectMenuNotifierIndex);
end;

function TDelphinusController.GetIndexOfConfigureTools(
  AToolsMenu: TMenuItem): Integer;
var
  i: Integer;
begin
  Result := AToolsMenu.Count;
  for i := 0 to AToolsMenu.Count - 1 do
  begin
    if AToolsMenu.Items[i].Name = CConfigureTools then
      Exit(i);
  end;
end;

procedure TDelphinusController.HandleClickDelphinus(Sender: TObject);
begin
  FDialog.Show();
end;

procedure TDelphinusController.HandleEvent(AEvent: TEventType);
var
  LProjectContainer: TProjectContainer;
begin
  if AEvent = etSetupDelphinusPackages then
  begin
    NeedProjectTree;
    for LProjectContainer in FProjectTree.Projects do
      FProjectTree.SetupProject(LProjectContainer);
  end;
end;

procedure TDelphinusController.HandleManageProjectPackages(
  const AProject: IOTAProject);
begin

end;

procedure TDelphinusController.InstallMenu;
var
  LItem: TMenuItem;
  LService: INTAServices;
  i, LIndex: Integer;
  LImageList: TCustomImageList;
begin
  LService := BorlandIDEServices as INTAServices;
  for i := LService.MainMenu.Items.Count - 1 downto 0 do
  begin
    LItem := LService.MainMenu.Items[i];
    if LItem.Name = CToolsMenu then
    begin
      FMenuItem := TMenuItem.Create(LService.MainMenu);
      FMenuItem.Caption := 'Delphinus';
      FMenuItem.Name := 'DelphinusMenu';
      FMenuItem.OnClick := HandleClickDelphinus;
      LIndex := GetIndexOfConfigureTools(LItem);
      LItem.Insert(LIndex, FMenuItem);
      LImageList := LItem.GetImageList;
      if Assigned(LImageList) then
      begin
        FMenuItem.ImageIndex := LImageList.AddIcon(FIcon);
      end;
      Break;
    end;
  end;
end;

procedure TDelphinusController.NeedProjectTree;
begin
  if not Assigned(FProjectTree) then
    FProjectTree := TProjectTree.Create();
end;

procedure TDelphinusController.UninstallMenu;
begin
  if Assigned(FMenuItem) then
  begin
    FMenuItem.Free;
  end;
end;

{ TProjectsNotifier }

constructor TProjectsNotifier.Create(AEventWindow: TEventWindow);
begin
  inherited Create();
  FEventWindow := AEventWindow;
end;

procedure TProjectsNotifier.CreatingProject(const ProjectOrGroup: IOTAModule);
begin
  FEventWindow.PostEvent(etSetupDelphinusPackages);
end;

function TProjectsNotifier.GetName: string;
begin
  Result := 'Platforms';
end;

procedure TProjectsNotifier.ProjectClosing(const ProjectOrGroup: IOTAModule);
begin

end;

procedure TProjectsNotifier.ProjectLoaded(const ProjectOrGroup: IOTAModule;
  const Node: IXMLNode);
begin
  FEventWindow.PostEvent(etSetupDelphinusPackages);
end;

procedure TProjectsNotifier.ProjectSaving(const ProjectOrGroup: IOTAModule;
  const Node: IXMLNode);
begin

end;

{ TDelphinusPackagesMenuEvents }

function TDelphinusPackagesMenuEvents.AddMenu(const Ident: string): TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  Result.Caption := 'Manage Packages';
  Result.OnClick := HandleManagePackages;
end;

procedure TDelphinusPackagesMenuEvents.AfterSave;
begin

end;

procedure TDelphinusPackagesMenuEvents.BeforeSave;
begin

end;

function TDelphinusPackagesMenuEvents.CanHandle(const Ident: string): Boolean;
begin
  Result := Ident = CDelphinusPackagesIdent;
end;

procedure TDelphinusPackagesMenuEvents.Destroyed;
begin

end;

procedure TDelphinusPackagesMenuEvents.HandleManagePackages(Sender: TObject);
var
  LIdent: string;
  LProject: IOTAProject;
begin
  LProject := (BorlandIDEServices as IOTAProjectManager).GetCurrentSelection(LIdent);
  if Assigned(FOnManagePackages) then
    FOnManagePackages(LProject);
end;

procedure TDelphinusPackagesMenuEvents.Modified;
begin

end;

end.
