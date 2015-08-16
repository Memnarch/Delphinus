unit Delphinus.SetupDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  DN.Installer.Intf,
  DN.Uninstaller.Intf,
  StdCtrls,
  DN.Types;

const
  CStart = WM_USER + 1;

type
  TSetupDialogMode = (sdmInstall, sdmInstallDirectory, sdmUninstall, sdmUpdate);

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
    function Install: Boolean;
    function Uninstall: Boolean;
    procedure Log(const AMessage: string);
    procedure HandleLogMessage(AType: TMessageType; const AMessage: string);
  public
    { Public declarations }
    procedure ExecuteInstallation(const APackage: IDNPackage; AProvider: IDNPackageProvider; AInstaller: IDNInstaller; const AComponentDirectory: string);
    procedure ExecuteInstallationFromDirectory(const ADirectory: string; AInstaller: IDNInstaller; const AComponentDirectory: string);
    procedure ExecuteUninstallation(const ATargetDirectory: string; const AUninstaller: IDNUninstaller);
    procedure ExecuteUpdate(const APackage: IDNPackage; AProvider: IDNPackageProvider; const AInstaller: IDNInstaller;
      const AUninstaller: IDNUninstaller; const AComponentDirectory, AInstalledComponentDirectory: string);
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

procedure TSetupDialog.ExecuteUpdate(const APackage: IDNPackage;
  AProvider: IDNPackageProvider; const AInstaller: IDNInstaller;
  const AUninstaller: IDNUninstaller; const AComponentDirectory, AInstalledComponentDirectory: string);
begin
  FPackage := APackage;
  FProvider := AProvider;
  FInstaller := AInstaller;
  FUninstaller := AUninstaller;
  FInstalledComponentDirectory := AInstalledComponentDirectory;
  FComponentDirectory := AComponentDirectory;
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
    sdmInstall, sdmInstallDirectory: Install;
    sdmUninstall: Uninstall;
    sdmUpdate:
    begin
      if Uninstall then
        Install();
    end;
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

function TSetupDialog.Install: Boolean;
var
  LTempDir, LContentDir, LPackageName, LComponentDir, LInfoFile: string;
  LError: Boolean;
  LInstalledInfo: TInstalledInfoFile;
  LVersion: string;
begin
  LError := False;
  if FMode in [sdmInstall, sdmUpdate] then
  begin
    Log('Downloading ' + FPackage.Name);
    LTempDir := TPath.Combine(GetEnvironmentVariable('Temp'), 'Delphinus');
    ForceDirectories(LTempDir);
    if FPackage.Versions.Count > 0 then
      LVersion := FPackage.Versions[0].Name
    else
      LVersion := '';

    Log('Version: ' + LVersion);
    if not FProvider.Download(FPackage, LVersion, LTempDir, LContentDir) then
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
    if FMode in [sdmInstall, sdmUpdate] then
      LPackageName := FPackage.Name
    else
      LPackageName := ExtractFileName(ExcludeTrailingPathDelimiter(LContentDir));

    LComponentDir := TPath.Combine(FComponentDirectory, LPackageName);
    if  FInstaller.Install(LContentDir, LComponentDir) then
    begin
      if FMode in [sdmInstall, sdmUpdate] then
      begin
        LInfoFile := TPath.Combine(LComponentDir, 'Info.json');
        if TFile.Exists(LInfoFile) then
        begin
          LInstalledInfo := TInstalledInfoFile.Create();
          try
            LInstalledInfo.LoadFromFile(LInfoFile);
            LInstalledInfo.Author := FPackage.Author;
            LInstalledInfo.Description := FPackage.Description;
            LInstalledInfo.Version := LVersion;
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
  Result := not LError;
end;

procedure TSetupDialog.Log(const AMessage: string);
begin
  mLog.Lines.Add(AMessage);
end;

function TSetupDialog.Uninstall: Boolean;
begin
  Result := False;
  FUninstaller.OnMessage := HandleLogMessage;
  Log('uninstalling...');
  if FUninstaller.Uninstall(FInstalledComponentDirectory) then
  begin
    Log('success');
    Result := True;
  end
  else
    Log('failed');
end;

end.
