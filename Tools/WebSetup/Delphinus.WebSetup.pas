unit Delphinus.WebSetup;

interface

uses
  DN.Installer.Intf,
  DN.Uninstaller.Intf,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Settings.Intf,
  DN.Setup.Core;

type
  TDNDelphinusWebSetup = class(TDNSetupCore)
  private
    FSubDirs: TArray<string>;
    FSettings: IDNElevatedSettings;
    FInstallers: TArray<IDNInstaller>;
    FUninstallers: TArray<IDNUninstaller>;
  public
    constructor Create(const AInstallers: TArray<IDNInstaller>; const AUninstallers: TArray<IDNUninstaller>;
      const APackageProvider: IDNPackageProvider; const ASettings: IDNElevatedSettings;
      const ASubDirs: TArray<string>); reintroduce;
    destructor Destroy; override;
    function Install(const APackage: IDNPackage;
      const AVersion: IDNPackageVersion): Boolean; override;
    function Uninstall(const APackage: IDNPackage): Boolean; override;
    function UninstallDirectory(const ADirectory: string): Boolean; override;
    function InstallDirectory(const ADirectory: string): Boolean; override;
  end;

implementation

uses
  SysUtils,
  IOUtils,
  DN.Types;

{ TDNDelphinusWebSetup }

constructor TDNDelphinusWebSetup.Create(const AInstallers: TArray<IDNInstaller>;
  const AUninstallers: TArray<IDNUninstaller>;
  const APackageProvider: IDNPackageProvider; const ASettings: IDNElevatedSettings;
  const ASubDirs: TArray<string>);
var
  LInstaller: IDNInstaller;
  LUninstaller: IDNUninstaller;
begin
  inherited Create(APackageProvider);
  FInstallers := AInstallers;
  for LInstaller in FInstallers do
  begin
    LInstaller.OnMessage := DoMessage;
    RegisterProgressHandler(LInstaller);
  end;
  FUninstallers := AUninstallers;
  for LUninstaller in FUninstallers do
  begin
    LUninstaller.OnMessage := DoMessage;
    RegisterProgressHandler(LUninstaller);
  end;
  FSettings := ASettings;
  FSubDirs := ASubDirs;
end;

destructor TDNDelphinusWebSetup.Destroy;
var
  LInstaller: IDNInstaller;
  LUninstaller: IDNUninstaller;
begin
  for LInstaller in FInstallers do
  begin
    LInstaller.OnMessage := nil;
    UnregisterProgressHandler(LInstaller);
  end;
  for LUninstaller in FUninstallers do
  begin
    LUninstaller.OnMessage := nil;
    UnregisterProgressHandler(LUninstaller);
  end;
  inherited;
end;

function TDNDelphinusWebSetup.Install(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion): Boolean;
var
  LContentDir: string;
  LInstallDir: string;
  LSubDir: string;
  i: Integer;
begin
  FProgress.SetTasks(['Downloading']);
  for LSubDir in FSubDirs do
    FProgress.AddTask('Installing BDS ' + LSubDir);

  Result := DownloadPackage(APackage, AVersion, LContentDir);
  if Result then
  begin
    FProgress.NextTask();
    for i := 0 to High(FInstallers) do
    begin
      ReportInfo('BDS ' + FSubDirs[i]);
      LInstallDir := TPath.Combine(ComponentDirectory, FSubDirs[i]);
      if TFile.Exists(TPath.Combine(LInstallDir, CUninstallFile)) then
      begin
        ReportInfo('Uninstalling');
        Result := FUninstallers[i].Uninstall(LInstallDir);
        if not Result then
        begin
          ReportError('Failed');
          Break;
        end;
      end;
      ReportInfo('Installing');
      Result := FInstallers[i].Install(LContentDir, LInstallDir);
      if Result then
      begin
        Result := ExtendInfoFile(APackage, AVersion, LInstallDir);
        if not Result then
        begin
          ReportError('Failed to modify Informationfile');
        end
      end
      else
      begin
        ReportError('Failed');
        Break;
      end;
      FProgress.NextTask();
    end;
  end;
  if Result then
    FSettings.InstallationDirectory := ComponentDirectory;
  FProgress.Completed();
end;

function TDNDelphinusWebSetup.InstallDirectory(
  const ADirectory: string): Boolean;
begin
  raise ENotImplemented.Create('I was lazy');
end;

function TDNDelphinusWebSetup.Uninstall(const APackage: IDNPackage): Boolean;
var
  LInstallDir: string;
  LSubDir: string;
  i: Integer;
begin
  Result := False;
  FProgress.SetTasks([]);
  for LSubDir in FSubDirs do
    FProgress.AddTask('Uninstalling BDS ' + LSubDir);
  for i := 0 to High(FUninstallers) do
  begin
    ReportInfo('Uninstalling BDS ' + FSubDirs[i]);
    LInstallDir := TPath.Combine(ComponentDirectory, FSubDirs[i]);
    Result := FUninstallers[i].Uninstall(LInstallDir);
    if Result then
      ReportInfo('Success')
    else
    begin
      ReportError('Failed');
      Break;
    end;
    FProgress.NextTask();
  end;
  if Result and TDirectory.IsEmpty(FSettings.InstallationDirectory) then
  begin
    ReportInfo('Cleaning up directory and settings');
    TDirectory.Delete(FSettings.InstallationDirectory);
    FSettings.Clear();
  end;
  FProgress.Completed();
end;

function TDNDelphinusWebSetup.UninstallDirectory(
  const ADirectory: string): Boolean;
begin
  raise ENotImplemented.Create('I was lazy...');
end;

end.
