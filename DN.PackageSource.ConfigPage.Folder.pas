unit DN.PackageSource.ConfigPage.Folder;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  DN.PackageSource.ConfigPage,
  DN.PackageSource.Settings.Intf,
  StdCtrls;

type
  TDNFolderConfigPage = class(TFrame)
    Label1: TLabel;
    edPath: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Load(const ASettings: IDNPackageSourceSettings); override;
    procedure Save(const ASettings: IDNPackageSourceSettings); override;
  end;

implementation

uses
  DN.PackageSource.Settings.Folder;

{$R *.dfm}

{ TDNFolderConfigPage }

procedure TDNFolderConfigPage.Load(const ASettings: IDNPackageSourceSettings);
begin
  inherited;
  edPath.Text := ASettings[TDNFolderSourceSettings.Path].Value.ToString;
end;

procedure TDNFolderConfigPage.Save(const ASettings: IDNPackageSourceSettings);
begin
  inherited;
  ASettings[TDNFolderSourceSettings.Path].Value := edPath.Text;
end;

end.
