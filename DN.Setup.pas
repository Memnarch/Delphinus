{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Setup;

interface

uses
  DN.Types,
  DN.Setup.Core,
  DN.Installer.Intf,
  DN.Uninstaller.Intf,
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.PackageProvider.Intf,
  DN.Progress.Intf;

type
  TDNSetup = class(TDNSetupCore)
  private
    FInstaller: IDNInstaller;
    FUninstaller: IDNUninstaller;
  public
    constructor Create(const AInstaller: IDNInstaller; const AUninstaller: IDNUninstaller; const APackageProvider: IDNPackageProvider);
    destructor Destroy; override;
    function Install(const APackage: IDNPackage; const AVersion: IDNPackageVersion): Boolean; override;
    function Uninstall(const APackage: IDNPackage): Boolean; override;
    function InstallDirectory(const ADirectory: string): Boolean; override;
    function UninstallDirectory(const ADirectory: string): Boolean; override;
  end;

implementation

uses
  SysUtils,
  IOUtils,
  StrUtils,
  DN.JSonFile.InstalledInfo;

{ TDNSetup }


constructor TDNSetup.Create(const AInstaller: IDNInstaller;
  const AUninstaller: IDNUninstaller;
  const APackageProvider: IDNPackageProvider);
begin
  inherited Create(APackageProvider);
  FInstaller := AInstaller;
  if Assigned(FInstaller) then
    FInstaller.OnMessage := DoMessage;
  RegisterProgressHandler(FInstaller);
  FUninstaller := AUninstaller;
  if Assigned(FUninstaller) then
    FUninstaller.OnMessage := DoMessage;
  RegisterProgressHandler(FUninstaller);
end;

destructor TDNSetup.Destroy;
begin
  UnregisterProgressHandler(FInstaller);
  UnregisterProgressHandler(FUninstaller);
  inherited;
end;

function TDNSetup.Install(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion): Boolean;
var
  LContentDirectory: string;
  LInstallDirectory: string;
begin
  try
    FProgress.SetTasks(['Downloading', 'Installing']);
    Result := DownloadPackage(APackage, AVersion, LContentDirectory);
    if Result then
    begin
      FProgress.NextTask();
      LInstallDirectory := GetInstallDirectoryForPackage(APackage);
      Result := FInstaller.Install(LContentDirectory, LInstallDirectory);
      if Result then
        Result := ExtendInfoFile(APackage, AVersion, LInstallDirectory);
      FProgress.Completed();
    end;
  finally
    CleanupTemp();
  end;

  if Result then
    ReportInfo('Installation finished')
  else
    ReportError('Installation failed');
end;

function TDNSetup.InstallDirectory(const ADirectory: string): Boolean;
var
  LInstallDirectory: string;
begin
  FProgress.SetTasks(['Installing']);
  LInstallDirectory := GetInstallDirectoryForDirectory(ADirectory);
  Result := FInstaller.Install(ADirectory, LInstallDirectory);
  FProgress.Completed();
  if Result then
    ReportInfo('Installation finished')
  else
    ReportError('Installation failed');
end;

function TDNSetup.Uninstall(const APackage: IDNPackage): Boolean;
begin
  Result := UninstallDirectory(GetInstallDirectoryForPackage(APackage));
end;

function TDNSetup.UninstallDirectory(const ADirectory: string): Boolean;
begin
  ReportInfo('Uninstalling...');
  FProgress.SetTasks(['Uninstalling']);
  Result := FUninstaller.Uninstall(ADirectory);
  FProgress.Completed();
  if Result then
    ReportInfo('success')
  else
    ReportError('failed');
end;

end.
