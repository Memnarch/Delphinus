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
  DN.Version,
  Delphinus.Forms,
  ImgList
{$IFDEF CONDITIONALEXPRESSIONS}
{$IF CompilerVersion >= 29.0}
  ,System.ImageList
{$IFEND}
{$ENDIF};

type
  TGetPackageVersion = function(const APackage: IDNPackage): TDNVersion of object;

  TPackageDetailView = class(TFrame)
    imgRepo: TImage;
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
    ilButtons: TImageList;
    btnProject: TButton;
    btnReport: TButton;
    Label5: TLabel;
    lbPlatforms: TLabel;
    Label4: TLabel;
    lbVersion: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure btnLicenseClick(Sender: TObject);
    procedure btnHomeClick(Sender: TObject);
    procedure btnProjectClick(Sender: TObject);
    procedure btnReportClick(Sender: TObject);
  private
    FCanvas: TControlCanvas;
    FPackage: IDNPackage;
    FOnGetInstalledVersion: TGetPackageVersion;
    FOnGetOnlineVersion: TGetPackageVersion;
    FDummyPic: TGraphic;
    procedure LoadIcons;
    procedure SetPackage(const Value: IDNPackage);
    function GetInstalledVersion(const APackage: IDNPackage): TDNVersion;
    function GetOnlineVersion(const APackage: IDNPackage): TDNVersion;
    { Private declarations }
  protected
    procedure OpenUrl(const AUrl: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property DummyPic: TGraphic read FDummyPic write FDummyPic;
    property Package: IDNPackage read FPackage write SetPackage;
    property OnGetInstalledVersion: TGetPackageVersion read FOnGetInstalledVersion write FOnGetInstalledVersion;
    property OnGetOnlineVersion: TGetPackageVersion read FOnGetOnlineVersion write FOnGetOnlineVersion;
  end;

implementation

uses
  Delphinus.LicenseDialog,
  Delphinus.Resources.Names,
  Delphinus.Resources,
  ShellAPi,
  DN.Compiler.Intf,
  DN.Utils;

{$R *.dfm}

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
  Package := nil;
  LoadIcons();
end;

destructor TPackageDetailView.Destroy;
begin
  FreeAndNil(FCanvas);
  inherited;
end;

function TPackageDetailView.GetInstalledVersion(
  const APackage: IDNPackage): TDNVersion;
begin
  if Assigned(FOnGetInstalledVersion) then
    Result := FOnGetInstalledVersion(APackage)
  else
    Result := TDNVersion.Create();
end;

function TPackageDetailView.GetOnlineVersion(
  const APackage: IDNPackage): TDNVersion;
begin
  if Assigned(FOnGetOnlineVersion) then
    Result := FOnGetOnlineVersion(APackage)
  else
    Result := TDNVersion.Create();

  if Result.IsEmpty then
    Result := GetInstalledVersion(APackage);
end;

procedure TPackageDetailView.LoadIcons;
begin
  btnLicense.ImageIndex := AddIconToImageList(ilButtons, Ico_Agreement);
  btnLicense.DisabledImageIndex := AddIconToImageList(ilButtons, Ico_Agreement_Disabled);
  btnHome.ImageIndex := AddIconToImageList(ilButtons, Ico_Home);
  btnHome.DisabledImageIndex := AddIconToImageList(ilButtons, Ico_Home_Disabled);
  btnProject.ImageIndex := AddIconToImageList(ilButtons, Ico_Repo);
  btnProject.DisabledImageIndex := AddIconToImageList(ilButtons, Ico_Repo_Disabled);
  btnReport.ImageIndex := AddIconToImageList(ilButtons, Ico_Bug);
  btnReport.DisabledImageIndex := AddIconToImageList(ilButtons, Ico_Bug_Disabled);
end;

procedure TPackageDetailView.OpenUrl(const AUrl: string);
begin
  ShellExecute(0, 'OPEN', PChar(AUrl), '', '', SW_SHOWNORMAL);
end;

procedure TPackageDetailView.SetPackage(const Value: IDNPackage);
begin
  FPackage := Value;
  if Assigned(FPackage) then
  begin
    lbAuthor.Caption := FPackage.Author;
    if Trim(FPackage.Description) = '' then
      lbDescription.Caption := FPackage.Name
    else
      lbDescription.Caption := FPackage.Description;
    lbSupports.Caption := GenerateSupportsString(FPackage.CompilerMin, FPackage.CompilerMax);
    if Assigned(FPackage.Picture.Graphic) then
      imgRepo.Picture := FPackage.Picture
    else
      imgRepo.Picture.Graphic := FDummyPic;

    lbLicense.Caption := FPackage.LicenseTypes;
    lbVersion.Caption := GetOnlineVersion(FPackage).ToString;
    lbInstalled.Caption := GetInstalledVersion(FPackage).ToString;
    lbPlatforms.Caption := GeneratePlatformString(FPackage.Platforms);
    btnHome.Enabled := FPackage.HomepageUrl <> '';
    btnHome.Hint := FPackage.HomepageUrl;
    btnProject.Enabled := FPackage.ProjectUrl <> '';
    btnReport.Enabled := FPackage.ReportUrl <> '';
  end
  else
  begin
    lbAuthor.Caption := '';
    lbDescription.Caption := '';
    lbSupports.Caption := '';
    lbVersion.Caption := '';
    lbInstalled.Caption := '';
    lbLicense.Caption := '';
    lbPlatforms.Caption := '';
    imgRepo.Picture := nil;
    btnHome.Enabled := False;
    btnProject.Enabled := False;
    btnReport.Enabled := False;
  end;

  btnLicense.Enabled := lbLicense.Caption <> '';
end;

end.
