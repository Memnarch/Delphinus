unit Delphinus.DependencyDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ComCtrls,
  DN.Setup.Dependency.Intf,
  Delphinus.Forms, ImgList, StdCtrls
{$IFDEF CONDITIONALEXPRESSIONS}
{$IF CompilerVersion >= 29.0}
   , System.ImageList
{$IFEND}
{$ENDIF};

type
  TDependencyDialog = class(TForm)
    lvDependencies: TListView;
    ilIcons: TImageList;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure lvDependenciesDblClick(Sender: TObject);
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
  Delphinus.Resources.Names,
  Delphinus.LicenseDialog;

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
      LItem.SubItems.Add(LDependency.Package.LicenseTypes);
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

procedure TDependencyDialog.lvDependenciesDblClick(Sender: TObject);
var
  LDialog: TLicenseDialog;
begin
  if lvDependencies.ItemIndex > -1 then
  begin
    LDialog := TLicenseDialog.Create(nil);
    try
      LDialog.Package := FDependencies[lvDependencies.ItemIndex].Package;
      LDialog.ShowModal();
    finally
      LDialog.Free();
    end;
  end;
end;

end.
