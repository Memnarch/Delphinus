unit Delphinus.DependencyDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  DN.Setup.Dependency.Intf,
  Delphinus.Forms, Vcl.ImgList;

type
  TDependencyDialog = class(TForm)
    lvDependencies: TListView;
    ilIcons: TImageList;
    procedure FormShow(Sender: TObject);
  private
    FDependencies: TArray<IDNSetupDependency>;
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property Dependencies: TArray<IDNSetupDependency> read FDependencies write FDependencies;
  end;

var
  DependencyDialog: TDependencyDialog;

implementation

uses
  Delphinus.Resources,
  Delphinus.Resources.Names;

{$R *.dfm}

constructor TDependencyDialog.Create(AOwner: TComponent);
begin
  inherited;
  AddIconToImageList(ilIcons, Ico_Dependency);
end;

procedure TDependencyDialog.FormShow(Sender: TObject);
var
  LDependency: IDNSetupDependency;
  LItem: TListItem;
begin
  for LDependency in FDependencies do
  begin
    LItem := lvDependencies.Items.Add();
    LItem.ImageIndex := 0;
    if Assigned(LDependency.Package) then
    begin
      LItem.Caption := LDependency.Package.Name;
      if Assigned(LDependency.Version) then
        LItem.SubItems.Add(LDependency.Version.Value.ToString)
      else
        LItem.SubItems.Add('');

      if Assigned(LDependency.InstalledVersion) then
        LItem.SubItems.Add(LDependency.InstalledVersion.Value.ToString)
      else
        LItem.SubItems.Add('');

      case LDependency.Action of
        daNone: LItem.SubItems.Add('');
        daInstall: LItem.SubItems.Add('Install');
        daUpdate: LItem.SubItems.Add('Update');
        daUninstall: LItem.SubItems.Add('Uninstall');
      end;
    end
    else
      LItem.Caption := LDependency.ID.ToString;
  end;
end;

end.
