unit Delphinus.PackageDetailView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  DN.Package.Intf, Vcl.ImgList;

type
  TPackageDetailView = class(TFrame)
    mDescription: TMemo;
    lbName: TLabel;
    lbAuthor: TLabel;
    btnInstall: TButton;
    btnUninstall: TButton;
    imgButtons: TImageList;
  private
    FPackage: IDNPackage;
    procedure SetPackage(const Value: IDNPackage);
    { Private declarations }
  public
    { Public declarations }
    property Package: IDNPackage read FPackage write SetPackage;
  end;

implementation

{$R *.dfm}

{ TPackageDetailView }

procedure TPackageDetailView.SetPackage(const Value: IDNPackage);
begin
  FPackage := Value;
  if Assigned(FPackage) then
  begin
    lbName.Caption := FPackage.Name;
    lbAuthor.Caption := FPackage.Author;
    mDescription.Text := FPackage.Description;
  end
  else
  begin
    lbName.Caption := '';
    lbAuthor.Caption := '';
    mDescription.Text := '';
  end;
end;

end.
