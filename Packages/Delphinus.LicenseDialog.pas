unit Delphinus.LicenseDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls,
  DN.Package.Intf;

type
  TLicenseDialog = class(TForm)
    mLicense: TMemo;
    btnOk: TButton;
  private
    FPackage: IDNPackage;
    procedure SetPackage(const Value: IDNPackage);
    { Private declarations }
  public
    { Public declarations }
    property Package: IDNPackage read FPackage write SetPackage;
  end;

var
  LicenseDialog: TLicenseDialog;

implementation

{$R *.dfm}

{ TLicenseDialog }

procedure TLicenseDialog.SetPackage(const Value: IDNPackage);
begin
  FPackage := Value;
  if Assigned(FPackage) then
  begin
    mLicense.Text := FPackage.LicenseText;
    Caption := FPackage.Name + ' ' + FPackage.LicenseType;
  end;
end;

end.
