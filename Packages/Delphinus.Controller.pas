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
  Classes,
  Types,
  Menus,
  Graphics,
  ImgList,
  Dialogs,
  Delphinus.Dialog;

type
  TDelphinusController = class(TInterfacedObject)
  private
    FMenuItem: TMenuItem;
    FDialog: TDelphinusDialog;
    FIcon: TIcon;
    procedure HandleClickDelphinus(Sender: TObject);
    procedure InstallMenu();
    procedure UninstallMenu();
  public
    constructor Create();
    destructor Destroy(); override;
  end;

implementation

uses
  ToolsApi,
  Delphinus.ResourceNames;

const
  CToolsMenu = 'ToolsMenu';

{ TDelphinusController }

constructor TDelphinusController.Create;
begin
  inherited;
  FIcon := TIcon.Create();
  FIcon.LoadFromResourceName(HInstance, CIconDelphinus);
  InstallMenu();
  FDialog := TDelphinusDialog.Create(nil);
end;

destructor TDelphinusController.Destroy;
begin
  UninstallMenu();
  FDialog.Free;
  FIcon.Free;
  inherited;
end;

procedure TDelphinusController.HandleClickDelphinus(Sender: TObject);
begin
  FDialog.Show();
end;

procedure TDelphinusController.InstallMenu;
var
  LItem: TMenuItem;
  LService: INTAServices;
  i: Integer;
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
      LItem.Insert(LItem.Count - 1, FMenuItem);
      LImageList := LItem.GetImageList;
      if Assigned(LImageList) then
      begin
        FMenuItem.ImageIndex := LImageList.AddIcon(FIcon);
      end;
      Break;
    end;
  end;
end;

procedure TDelphinusController.UninstallMenu;
begin
  if Assigned(FMenuItem) then
  begin
    FMenuItem.Free;
  end;
end;

end.
