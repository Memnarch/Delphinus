{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit Delphinus.SetupDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Installer.Intf,
  DN.Uninstaller.Intf,
  StdCtrls,
  DN.Types,
  DN.Setup.Intf,
  Delphinus.Form, ComCtrls, ExtCtrls;

const
  CStart = WM_USER + 1;

type
  TSetupDialogMode = (sdmInstall, sdmInstallDirectory, sdmUninstall, sdmUninstallDirectory, sdmUpdate);

  TSetupDialog = class(TDelphinusForm)
    mLog: TMemo;
    pcSteps: TPageControl;
    tsMainPage: TTabSheet;
    tsLog: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    Image1: TImage;
    lbActionInstallUpdate: TLabel;
    lbNameInstallUpdate: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    lbDescriptionInstallUpdate: TLabel;
    cbVersion: TComboBox;
    Label1: TLabel;
    lbLicenseAnotation: TLabel;
    Label3: TLabel;
    lbLicenseType: TLabel;
    btnLicense: TButton;
    procedure HandleOK(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLicenseClick(Sender: TObject);
  private
    { Private declarations }
    FMode: TSetupDialogMode;
    FPackage: IDNPackage;
    FInstalledComponentDirectory: string;
    FDirectoryToInstall: string;
    FSetup: IDNSetup;
    procedure Log(const AMessage: string);
    procedure HandleLogMessage(AType: TMessageType; const AMessage: string);
    procedure InitMainPage();
    procedure InitVersionSelection();
    procedure Execute();
    function GetSelectedVersion: IDNPackageVersion;
  public
    { Public declarations }
    constructor Create(const ASetup: IDNSetup); reintroduce;
    procedure ExecuteInstallation(const APackage: IDNPackage);
    procedure ExecuteInstallationFromDirectory(const ADirectory: string);
    procedure ExecuteUninstallation(const APackage: IDNPackage);
    procedure ExecuteUninstallationFromDirectory(const ADirectory: string);
    procedure ExecuteUpdate(const APackage: IDNPackage);
  end;

var
  SetupDialog: TSetupDialog;

implementation

uses
  IOUtils,
  DN.JSonFile.InstalledInfo,
  Delphinus.LicenseDialog;

{$R *.dfm}

{ TSetupDialog }

procedure TSetupDialog.btnLicenseClick(Sender: TObject);
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

constructor TSetupDialog.Create(const ASetup: IDNSetup);
begin
  inherited Create(nil);
  FSetup := ASetup;
  FSetup.OnMessage := HandleLogMessage;
end;

procedure TSetupDialog.Execute;
begin
  mLog.Clear;
  pcSteps.ActivePage := tsLog;
  case FMode of
    sdmInstall: FSetup.Install(FPackage, GetSelectedVersion());
    sdmInstallDirectory: FSetup.InstallDirectory(FDirectoryToInstall);
    sdmUninstall: FSetup.Uninstall(FPackage);
    sdmUninstallDirectory: FSetup.UninstallDirectory(FInstalledComponentDirectory);
    sdmUpdate: FSetup.Update(FPackage, GetSelectedVersion());
  end;
end;

procedure TSetupDialog.ExecuteInstallation(const APackage: IDNPackage);
begin
  FPackage := APackage;
  FMode := sdmInstall;
  ShowModal();
end;

procedure TSetupDialog.ExecuteInstallationFromDirectory(
  const ADirectory: string);
begin
  FDirectoryToInstall := ADirectory;
  FMode := sdmInstallDirectory;
  ShowModal();
end;

procedure TSetupDialog.ExecuteUninstallation(const APackage: IDNPackage);
begin
  FPackage := APackage;
  FMode := sdmUninstall;
  ShowModal();
end;

procedure TSetupDialog.ExecuteUninstallationFromDirectory(
  const ADirectory: string);
begin
  FInstalledComponentDirectory := ADirectory;
  FMode := sdmUninstallDirectory;
  ShowModal();
end;

procedure TSetupDialog.ExecuteUpdate(const APackage: IDNPackage);
begin
  FPackage := APackage;
  FMode := sdmUpdate;
  ShowModal();
end;

procedure TSetupDialog.FormShow(Sender: TObject);
begin
  InitMainPage();
end;

function TSetupDialog.GetSelectedVersion: IDNPackageVersion;
begin
  if Assigned(FPackage) and (cbVersion.ItemIndex > -1) then
    Result := FPackage.Versions[cbVersion.ItemIndex]
  else
    Result := nil;
end;

procedure TSetupDialog.HandleLogMessage(AType: TMessageType;
  const AMessage: string);
begin
  case AType of
    mtNotification: Log(AMessage);
    mtWarning: Log('Warning: ' + AMessage);
    mtError: Log('Error: ' + AMessage);
  end;
end;

procedure TSetupDialog.HandleOK(Sender: TObject);
begin
  Execute();
end;

procedure TSetupDialog.InitMainPage;
begin
  pcSteps.ActivePage := tsMainPage;
  case FMode of
    sdmInstall:
    begin
      lbActionInstallUpdate.Caption := 'Install';
      lbNameInstallUpdate.Caption := FPackage.Name;
      lbDescriptionInstallUpdate.Caption := FPackage.Description;
      lbLicenseType.Caption := FPackage.LicenseType;
      btnLicense.Visible := lbLicenseType.Caption <> '';
      if Assigned(FPackage.Picture) then
        Image1.Picture.Assign(FPackage.Picture);
      InitVersionSelection();
    end;
//    sdmInstallDirectory: ;
    sdmUninstall:
    begin
      lbActionInstallUpdate.Caption := 'Uninstall';
      lbNameInstallUpdate.Caption := FPackage.Name;
      lbDescriptionInstallUpdate.Caption := FPackage.Description;
      if Assigned(FPackage.Picture) then
        Image1.Picture.Assign(FPackage.Picture);
      Label1.Visible := False;
      cbVersion.Visible := False;
      lbLicenseAnotation.Visible := False;
      btnLicense.Visible := False;
    end;
//    sdmUninstallDirectory: ;
    sdmUpdate:
    begin
      lbActionInstallUpdate.Caption := 'Update';
      lbNameInstallUpdate.Caption := FPackage.Name;
      lbDescriptionInstallUpdate.Caption := FPackage.Description;
      if Assigned(FPackage.Picture) then
        Image1.Picture.Assign(FPackage.Picture);
      InitVersionSelection();
    end;
  end;
end;

procedure TSetupDialog.InitVersionSelection;
var
  i: Integer;
begin
  cbVersion.Enabled := FPackage.Versions.Count > 0;
  for i := 0 to FPackage.Versions.Count - 1 do
  begin
    cbVersion.Items.Add(FPackage.Versions[i].Name);
  end;
  cbVersion.ItemIndex := 0;
end;

procedure TSetupDialog.Log(const AMessage: string);
begin
  mLog.Lines.Add(AMessage);
end;

end.
