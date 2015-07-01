unit Delphinus.SetupDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  DN.Installer.Intf,
  DN.Uninstaller.Intf,
  Vcl.StdCtrls,
  DN.Types;

const
  CStart = WM_USER + 1;

type
  TSetupDialogMode = (sdmInstall, sdmInstallDirectory, sdmUninstall);

  TSetupDialog = class(TForm)
    mLog: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FMode: TSetupDialogMode;
    FPackage: IDNPackage;
    FProvider: IDNPackageProvider;
    FInstaller: IDNInstaller;
    FUninstaller: IDNUninstaller;
    FComponentDirectory: string;
    FInstalledComponentDirectory: string;
    FDirectoryToInstall: string;
    procedure HandleCustomMessage(var AMSG: TMessage); message CStart;
    procedure Install;
    procedure Uninstall;
    procedure Log(const AMessage: string);
    procedure HandleLogMessage(AType: TMessageType; const AMessage: string);
  public
    { Public declarations }
    procedure ExecuteInstallation(const APackage: IDNPackage; AProvider: IDNPackageProvider; AInstaller: IDNInstaller; const AComponentDirectory: string);
    procedure ExecuteInstallationFromDirectory(const ADirectory: string; AInstaller: IDNInstaller; const AComponentDirectory: string);
    procedure ExecuteUninstallation(const ATargetDirectory: string; const AUninstaller: IDNUninstaller);
  end;

var
  SetupDialog: TSetupDialog;

implementation

uses
  IOUtils,
  DN.JSonFile.InstalledInfo;

{$R *.dfm}

{ TSetupDialog }

procedure TSetupDialog.ExecuteInstallation(const APackage: IDNPackage;
  AProvider: IDNPackageProvider; AInstaller: IDNInstaller; const AComponentDirectory: string);
begin
  FPackage := APackage;
  FProvider := AProvider;
  FInstaller := AInstaller;
  FComponentDirectory := AComponentDirectory;
  FMode := sdmInstall;
  ShowModal();
end;

procedure TSetupDialog.ExecuteInstallationFromDirectory(
  const ADirectory: string; AInstaller: IDNInstaller;
  const AComponentDirectory: string);
begin
  FDirectoryToInstall := ADirectory;
  FInstaller := AInstaller;
  FComponentDirectory := AComponentDirectory;
  FMode := sdmInstallDirectory;
  ShowModal();
end;

procedure TSetupDialog.ExecuteUninstallation(const ATargetDirectory: string;
  const AUninstaller: IDNUninstaller);
begin
  FUninstaller := AUninstaller;
  FInstalledComponentDirectory := ATargetDirectory;
  FMode := sdmUninstall;
  ShowModal();
end;

procedure TSetupDialog.FormShow(Sender: TObject);
begin
  PostMessage(Handle, CStart, 0, 0);
end;

procedure TSetupDialog.HandleCustomMessage(var AMSG: TMessage);
begin
  case FMode of
    sdmInstall, sdmInstallDirectory: Install;
    sdmUninstall: Uninstall;
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

procedure TSetupDialog.Install;
var
  LTempDir, LContentDir, LPackageName, LComponentDir, LInfoFile: string;
  LError: Boolean;
  LInstalledInfo: TInstalledInfoFile;
begin
  mLog.Clear;
  LError := False;
  if FMode = sdmInstall then
  begin
    Log('Downloading ' + FPackage.Name);
    LTempDir := TPath.Combine(GetEnvironmentVariable('Temp'), 'Delphinus');
    ForceDirectories(LTempDir);
    if not FProvider.Download(FPackage, LTempDir, LContentDir) then
    begin
      Log('failed to download');
      LError := True;
    end;
  end
  else
  begin
    //else we are installing from directory
    LContentDir := FDirectoryToInstall;
  end;

  if not LError then
  begin
    Log('installing...');
    FInstaller.OnMessage := HandleLogMessage;
    if FMode = sdmInstall then
      LPackageName := FPackage.Name
    else
      LPackageName := ExtractFileName(ExcludeTrailingPathDelimiter(LContentDir));

    LComponentDir := TPath.Combine(FComponentDirectory, LPackageName);
    if  FInstaller.Install(LContentDir, LComponentDir) then
    begin
      if FMode = sdmInstall then
      begin
        LInfoFile := TPath.Combine(LComponentDir, 'Info.json');
        if TFile.Exists(LInfoFile) then
        begin
          LInstalledInfo := TInstalledInfoFile.Create();
          try
            LInstalledInfo.LoadFromFile(LInfoFile);
            LInstalledInfo.Author := FPackage.Author;
            LInstalledInfo.Description := FPackage.Description;
            LInstalledInfo.SaveToFile(LInfoFile);
          finally
            LInstalledInfo.Free;
          end;
        end;
      end;
    end
    else
    begin
      Log('installation failed');
      LError := True;
    end;
  end;

  if FMode = sdmInstall then
  begin
    Log('cleaning tempfiles');
    TDirectory.Delete(LTempDir, True);
  end;

  if LError then
    Log('Installation aborted')
  else
    Log('Installation finished');
//  if not LError then
//  begin
//    ModalResult := mrOk;
//  end;
end;

procedure TSetupDialog.Log(const AMessage: string);
begin
  mLog.Lines.Add(AMessage);
end;

procedure TSetupDialog.Uninstall;
begin
  mLog.Clear;
  FUninstaller.OnMessage := HandleLogMessage;
  Log('uninstalling...');
  if FUninstaller.Uninstall(FInstalledComponentDirectory) then
    Log('success')
  else
    Log('failed');
end;

end.
