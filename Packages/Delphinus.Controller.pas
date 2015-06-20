unit Delphinus.Controller;

interface

uses
  Classes,
  Types,
  Menus,
  Dialogs,
  Delphinus.Dialog;

type
  TDelphinusController = class(TInterfacedObject)
  private
    FMenuItem: TMenuItem;
    FDialog: TDelphinusDialog;
    procedure HandleClickDelphinus(Sender: TObject);
    procedure InstallMenu();
    procedure UninstallMenu();
  public
    constructor Create();
    destructor Destroy(); override;
  end;

implementation

uses
  ToolsApi;

const
  CToolsMenu = 'ToolsMenu';

{ TDelphinusController }

constructor TDelphinusController.Create;
begin
  inherited;
  InstallMenu();
  FDialog := TDelphinusDialog.Create(nil);
end;

destructor TDelphinusController.Destroy;
begin
  UninstallMenu();
  FDialog.Free;
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
