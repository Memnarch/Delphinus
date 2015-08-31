{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.PackageDetailView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  DN.Types,
  DN.Package.Intf,
  DN.Controls,
  DN.Controls.Button,
  ImgList;

type
  TPackageDetailView = class(TFrame)
    imgRepo: TImage;
    lbTitle: TLabel;
    lbDescription: TLabel;
    lbAuthor: TLabel;
    Label1: TLabel;
    pnlHeader: TPanel;
    pnlDetail: TPanel;
    Label2: TLabel;
    lbSupports: TLabel;
    lbInstalledCaption: TLabel;
    lbInstalled: TLabel;
    Label3: TLabel;
    lbLicense: TLabel;
    btnLicense: TButton;
    btnHome: TButton;
    ImageList1: TImageList;
    btnProject: TButton;
    btnReport: TButton;
    procedure Button1Click(Sender: TObject);
    procedure btnLicenseClick(Sender: TObject);
    procedure btnHomeClick(Sender: TObject);
    procedure btnProjectClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
  private
    FCanvas: TControlCanvas;
    FPackage: IDNPackage;
    FGui: TDNControlsController;
    FBackButton: TDNButton;
    procedure SetPackage(const Value: IDNPackage);
    { Private declarations }
  protected
    procedure PaintWindow(DC: HDC); override;
    procedure OpenUrl(const AUrl: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property Package: IDNPackage read FPackage write SetPackage;
  end;

implementation

uses
  Delphinus.LicenseDialog,
  ShellAPi;

{$R *.dfm}

const
  CDelphiNames: array[9..30] of string =
  ('2', '3', '3', '4', '5', '6', '7', '8', '2005', '2006', '2007', '2009', '2010',
   'XE', 'XE2', 'XE3', 'XE4', 'XE5', 'XE6', 'XE7', 'XE8', 'Seattle');

  function GetDelphiName(const ACompilerVersion: TCompilerVersion): string;
  var
    LVersion: Integer;
  begin
    LVersion := Trunc(ACompilerVersion);
    if (LVersion >= Low(CDelphiNames)) and (LVersion <= High(CDelphiNames)) then
    begin
      Result := CDelphiNames[LVersion];
    end
    else
    begin
      Result := 'Compiler ' + IntToStr(LVersion);
    end;
  end;

  function GenerateSupportsString(const AMin, AMax: TCompilerVersion): string;
  begin
    if AMin > 0 then
    begin
      if (AMax - AMin) =  0 then
        Result := 'Delphi ' + GetDelphiName(AMin)
      else if (AMax < AMin) then
        Result := 'Delphi ' + GetDelphiName(AMin) + ' and newer'
      else
        Result := 'Delphi ' + GetDelphiName(AMin) + ' to ' + GetDelphiName(AMax);
    end
    else
    begin
      Result := 'Unspecified';
    end;
  end;

{ TFrame1 }

procedure TPackageDetailView.btnHomeClick(Sender: TObject);
begin
  OpenUrl(FPackage.HomepageUrl);
end;

procedure TPackageDetailView.btnLicenseClick(Sender: TObject);
var
  LDialog: TLicenseDialog;
begin
  LDialog := TLicenseDialog.Create(nil);
  try
    LDialog.Package := FPackage;
    LDialog.ShowModal();
  finally
    LDialog.Free;
  end;
end;

procedure TPackageDetailView.btnProjectClick(Sender: TObject);
begin
  OpenUrl(FPackage.ProjectUrl);
end;

procedure TPackageDetailView.btnReportClick(Sender: TObject);
begin
  OpenUrl(FPackage.ReportUrl);
end;

procedure TPackageDetailView.Button1Click(Sender: TObject);
begin
  Visible := False;
end;

constructor TPackageDetailView.Create(AOwner: TComponent);
begin
  inherited;
  FCanvas := TControlCanvas.Create();
  TControlCanvas(FCanvas).Control := Self;
  FGUI := TDNControlsController.Create();
  FGUI.Parent := Self;
  FBackButton := TDNButton.Create();
  FBackButton.Height := 25;
  FBackButton.Width := 150;
  FBackButton.Caption := 'Back';
  FBackButton.Left := 2;
  FBackButton.OnClick := Button1Click;
  FBackButton.Color := clSilver;
  FBackButton.HoverColor := clSilver;
  FGui.Controls.Add(FBackButton);
end;

destructor TPackageDetailView.Destroy;
begin
  FreeAndNil(FCanvas);
  FreeAndNil(FGUI);
  inherited;
end;

procedure TPackageDetailView.OpenUrl(const AUrl: string);
begin
  ShellExecute(0, 'OPEN', PChar(AUrl), '', '', SW_SHOWNORMAL);
end;

procedure TPackageDetailView.PaintWindow(DC: HDC);
begin
  inherited;
  FCanvas.Lock();
  try
    FCanvas.Handle := DC;
    TControlCanvas(FCanvas).UpdateTextFlags;
    FBackButton.Top := Height - FBackButton.Height - 2;
    FGui.PaintTo(FCanvas);
    FCanvas.Handle := 0;
  finally
    FCanvas.Unlock();
  end;
end;

procedure TPackageDetailView.SetPackage(const Value: IDNPackage);
begin
  FPackage := Value;
  if Assigned(FPackage) then
  begin
    lbTitle.Caption := FPackage.Name;
    lbAuthor.Caption := FPackage.Author;
    lbDescription.Caption := FPackage.Description;
    lbSupports.Caption := GenerateSupportsString(FPackage.CompilerMin, FPackage.CompilerMax);
    imgRepo.Picture := FPackage.Picture;
    lbLicense.Caption := FPackage.LicenseType;
    if FPackage.Versions.Count > 0 then
    begin
      lbInstalled.Caption := FPackage.Versions[0].Name;
    end
    else
    begin
      lbInstalled.Caption := '';
    end;
    btnHome.Enabled := FPackage.HomepageUrl <> '';
    btnProject.Enabled := FPackage.ProjectUrl <> '';
    btnReport.Enabled := FPackage.ReportUrl <> '';
  end
  else
  begin
    lbTitle.Caption := '';
    lbAuthor.Caption := '';
    lbDescription.Caption := '';
    lbSupports.Caption := '';
    lbInstalled.Caption := '';
    lbLicense.Caption := '';
    imgRepo.Picture := nil;
    btnHome.Enabled := False;
    btnProject.Enabled := False;
    btnReport.Enabled := False;
  end;
  lbInstalledCaption.Visible := lbInstalled.Caption <> '';
  lbInstalled.Visible := lbInstalled.Caption <> '';
  btnLicense.Visible := lbLicense.Caption <> '';
end;

end.
