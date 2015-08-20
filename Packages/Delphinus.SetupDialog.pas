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
  Delphinus.Form;

const
  CStart = WM_USER + 1;

type
  TSetupDialogMode = (sdmInstall, sdmInstallDirectory, sdmUninstall, sdmUninstallDirectory, sdmUpdate);

  TSetupDialog = class(TDelphinusForm)
    mLog: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FMode: TSetupDialogMode;
    FPackage: IDNPackage;
    FVersion: IDNPackageVersion;
    FInstalledComponentDirectory: string;
    FDirectoryToInstall: string;
    FSetup: IDNSetup;
    procedure HandleCustomMessage(var AMSG: TMessage); message CStart;
    procedure Log(const AMessage: string);
    procedure HandleLogMessage(AType: TMessageType; const AMessage: string);
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
  DN.JSonFile.InstalledInfo;

{$R *.dfm}

{ TSetupDialog }

constructor TSetupDialog.Create(const ASetup: IDNSetup);
begin
  inherited Create(nil);
  FSetup := ASetup;
  FSetup.OnMessage := HandleLogMessage;
end;

procedure TSetupDialog.ExecuteInstallation(const APackage: IDNPackage);
begin
  FPackage := APackage;
  if FPackage.Versions.Count > 0 then
    FVersion := FPackage.Versions[0]
  else
    FVersion := nil;
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
  if FPackage.Versions.Count > 0 then
    FVersion := FPackage.Versions[0]
  else
    FVersion := nil;
  FMode := sdmUpdate;
  ShowModal();
end;

procedure TSetupDialog.FormShow(Sender: TObject);
begin
  PostMessage(Handle, CStart, 0, 0);
end;

procedure TSetupDialog.HandleCustomMessage(var AMSG: TMessage);
begin
  mLog.Clear;
  case FMode of
    sdmInstall: FSetup.Install(FPackage, FVersion);
    sdmInstallDirectory: FSetup.InstallDirectory(FDirectoryToInstall);
    sdmUninstall: FSetup.Uninstall(FPackage);
    sdmUninstallDirectory: FSetup.UninstallDirectory(FInstalledComponentDirectory);
    sdmUpdate: FSetup.Update(FPackage, FVersion);
  end;
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

procedure TSetupDialog.Log(const AMessage: string);
begin
  mLog.Lines.Add(AMessage);
end;

end.
