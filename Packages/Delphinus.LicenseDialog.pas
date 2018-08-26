unit Delphinus.LicenseDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls,
  DN.Package.Intf,
  Delphinus.Forms, Vcl.ComCtrls;

type
  TLicenseDialog = class(TForm)
    btnOk: TButton;
    pcLicenses: TPageControl;
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

uses
  DN.Types;

{$R *.dfm}

{ TLicenseDialog }

procedure TLicenseDialog.SetPackage(const Value: IDNPackage);
var
  LLicense: TDNLicense;
  LMemo: TMemo;
  LTab: TTabSheet;
begin
  FPackage := Value;
  if Assigned(FPackage) then
  begin
    for LLicense in FPackage.Licenses do
    begin
      LTab := TTabSheet.Create(pcLicenses);
      LTab.Caption := LLicense.LicenseType;
      LMemo := TMemo.Create(LTab);
      LMemo.WordWrap := False;
      LMemo.ScrollBars := ssBoth;
      LMemo.Align := alClient;
      LMemo.Parent := LTab;
      LMemo.Text := FPackage.LicenseText[LLicense];
      LTab.PageControl := pcLicenses;
    end;
    Caption := FPackage.Name + ' ' + FPackage.LicenseTypes;
  end;
end;

end.
