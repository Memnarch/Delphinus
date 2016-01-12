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
  Delphinus.Forms,
  ImgList;

type
  TGetExtendedPackageInformation = function(const APackage: IDNPackage): string of object;

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
    ImageList1: TImageList;
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
    FOnGetInstalledVersion: TGetExtendedPackageInformation;
    FOnGetOnlineVersion: TGetExtendedPackageInformation;
    procedure SetPackage(const Value: IDNPackage);
    function GetInstalledVersion(const APackage: IDNPackage): string;
    function GetOnlineVersion(const APackage: IDNPackage): string;
    { Private declarations }
  protected
    procedure OpenUrl(const AUrl: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    property Package: IDNPackage read FPackage write SetPackage;
    property OnGetInstalledVersion: TGetExtendedPackageInformation read FOnGetInstalledVersion write FOnGetInstalledVersion;
    property OnGetOnlineVersion: TGetExtendedPackageInformation read FOnGetOnlineVersion write FOnGetOnlineVersion;
  end;

implementation

uses
  Delphinus.LicenseDialog,
  ShellAPi,
  DN.Compiler.Intf;

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

  function GeneratePlatformString(APlatforms: TDNCompilerPlatforms): string;
  var
    LPlatform: TDNCompilerPlatform;
    LRequiresSeperator: Boolean;
  begin
    Result := '';
    LRequiresSeperator := False;
    for LPlatform in APlatforms do
    begin
      if LRequiresSeperator then
        Result := Result + ', ';

      Result := Result + TDNCompilerPlatformName[LPlatform];
      LRequiresSeperator := True;
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
  Package := nil;
end;

destructor TPackageDetailView.Destroy;
begin
  FreeAndNil(FCanvas);
  inherited;
end;

function TPackageDetailView.GetInstalledVersion(
  const APackage: IDNPackage): string;
begin
  if Assigned(FOnGetInstalledVersion) then
    Result := FOnGetInstalledVersion(APackage)
  else
    Result := '';
end;

function TPackageDetailView.GetOnlineVersion(
  const APackage: IDNPackage): string;
begin
  if Assigned(FOnGetOnlineVersion) then
    Result := FOnGetOnlineVersion(APackage)
  else
    Result := '';

  if Result = '' then
    Result := GetInstalledVersion(APackage);
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
    lbDescription.Caption := FPackage.Description;
    lbSupports.Caption := GenerateSupportsString(FPackage.CompilerMin, FPackage.CompilerMax);
    imgRepo.Picture := FPackage.Picture;
    lbLicense.Caption := FPackage.LicenseType;
    lbVersion.Caption := GetOnlineVersion(FPackage);
    lbInstalled.Caption := GetInstalledVersion(FPackage);
    lbPlatforms.Caption := GeneratePlatformString(FPackage.Platforms);
    btnHome.Enabled := FPackage.HomepageUrl <> '';
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
