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
  DN.Setup.Intf,
  DN.Installer.Intf,
  DN.Uninstaller.Intf,
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.PackageProvider.Intf;

type
  TDNSetup = class(TInterfacedObject, IDNSetup)
  private
    FComponentDirectory: string;
    FOnMessage: TMessageEvent;
    FProvider: IDNPackageProvider;
    FInstaller: IDNInstaller;
    FUninstaller: IDNUninstaller;
    function GetComponentDirectory: string;
    procedure SetComponentDirectory(const Value: string);
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
  protected
    procedure DoMessage(AType: TMessageType; const AMessage: string);
    procedure ReportInfo(const AInfo: string);
    procedure ReportWarning(const AWarning: string);
    procedure ReportError(const AError: string);
    function DownloadPackage(const APackage: IDNPackage; const AVersion: IDNPackageVersion; out AContentDirectory: string): Boolean;
    function GetInstallDirectoryForPackage(const APackage: IDNPackage): string;
    function GetInstallDirectoryForDirectory(const ADirectory: string): string;
    function ExtendInfoFile(const APackage: IDNPackage; const AVersion: IDNPackageVersion; const AInstallDirectory: string): Boolean;
  public
    constructor Create(const AInstaller: IDNInstaller; const AUninstaller: IDNUninstaller; const APackageProvider: IDNPackageProvider);
    function Install(const APackage: IDNPackage; const AVersion: IDNPackageVersion): Boolean;
    function Update(const APackage: IDNPackage; const AVersion: IDNPackageVersion): Boolean;
    function Uninstall(const APackage: IDNPackage): Boolean;
    function InstallDirectory(const ADirectory: string): Boolean;
    function UninstallDirectory(const ADirectory: string): Boolean;
    property ComponentDirectory: string read GetComponentDirectory write SetComponentDirectory;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
  end;

implementation

uses
  SysUtils,
  IOUtils,
  DN.JSonFile.InstalledInfo;

{ TDNSetup }

constructor TDNSetup.Create(const AInstaller: IDNInstaller;
  const AUninstaller: IDNUninstaller;
  const APackageProvider: IDNPackageProvider);
begin
  inherited Create();
  FInstaller := AInstaller;
  FInstaller.OnMessage := DoMessage;
  FUninstaller := AUninstaller;
  FUninstaller.OnMessage := DoMessage;
  FProvider := APackageProvider;
end;

procedure TDNSetup.DoMessage(AType: TMessageType; const AMessage: string);
begin
  if Assigned(FOnMessage) then
    FOnMessage(AType, AMessage);
end;

function TDNSetup.DownloadPackage(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion; out AContentDirectory: string): Boolean;
var
  LTempDir: string;
  LVersion: string;
begin
  ReportInfo('Downloading ' + APackage.Name);
  LTempDir := TPath.Combine(GetEnvironmentVariable('Temp'), 'Delphinus');
  ForceDirectories(LTempDir);
  if Assigned(AVersion) then
    LVersion := AVersion.Name
  else
    LVersion := '';

  ReportInfo('Version: ' + LVersion);
  Result := FProvider.Download(APackage, LVersion, LTempDir, AContentDirectory);
  if not Result then
  begin
    ReportError('failed to download');
  end;
end;

function TDNSetup.ExtendInfoFile(const APackage: IDNPackage; const AVersion: IDNPackageVersion;
  const AInstallDirectory: string): Boolean;
var
  LInfoFile: string;
  LInstalledInfo: TInstalledInfoFile;
begin
  Result := False;
  LInfoFile := TPath.Combine(AInstallDirectory, 'Info.json');
  if TFile.Exists(LInfoFile) then
  begin
    LInstalledInfo := TInstalledInfoFile.Create();
    try
      LInstalledInfo.LoadFromFile(LInfoFile);
      LInstalledInfo.Author := APackage.Author;
      LInstalledInfo.Description := APackage.Description;
      if Assigned(AVersion) then
        LInstalledInfo.Version := AVersion.Name;
      LInstalledInfo.SaveToFile(LInfoFile);
      Result := True;
    finally
      LInstalledInfo.Free;
    end;
  end;
end;

function TDNSetup.GetComponentDirectory: string;
begin
  Result := FComponentDirectory;
end;

function TDNSetup.GetInstallDirectoryForDirectory(
  const ADirectory: string): string;
begin
  Result := TPath.Combine(FComponentDirectory, ExtractFileName(ExcludeTrailingPathDelimiter(ADirectory)));
end;

function TDNSetup.GetInstallDirectoryForPackage(const APackage: IDNPackage): string;
begin
  Result := TPath.Combine(FComponentDirectory, APackage.Name);
end;

function TDNSetup.GetOnMessage: TMessageEvent;
begin
  Result := FOnMessage;
end;

function TDNSetup.Install(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion): Boolean;
var
  LContentDirectory: string;
  LInstallDirectory: string;
begin
  Result := DownloadPackage(APackage, AVersion, LContentDirectory);
  if Result then
  begin
    LInstallDirectory := GetInstallDirectoryForPackage(APackage);
    Result := FInstaller.Install(LContentDirectory, LInstallDirectory);
    if Result then
      Result := ExtendInfoFile(APackage, AVersion, LInstallDirectory)
  end;

  ReportInfo('deleting tempfiles');
  if TDirectory.Exists(LContentDirectory) then
  begin
    TDirectory.Delete(LContentDirectory, True);
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
  LInstallDirectory := GetInstallDirectoryForDirectory(ADirectory);
  Result := FInstaller.Install(ADirectory, LInstallDirectory);

  if Result then
    ReportInfo('Installation finished')
  else
    ReportError('Installation failed');
end;

procedure TDNSetup.ReportError(const AError: string);
begin
  DoMessage(mtError, AError);
end;

procedure TDNSetup.ReportInfo(const AInfo: string);
begin
  DoMessage(mtNotification, AInfo);
end;

procedure TDNSetup.ReportWarning(const AWarning: string);
begin
  DoMessage(mtWarning, AWarning);
end;

procedure TDNSetup.SetComponentDirectory(const Value: string);
begin
  FComponentDirectory := Value;
end;

procedure TDNSetup.SetOnMessage(const Value: TMessageEvent);
begin
  FOnMessage := Value;
end;

function TDNSetup.Uninstall(const APackage: IDNPackage): Boolean;
begin
  Result := UninstallDirectory(GetInstallDirectoryForPackage(APackage));
end;

function TDNSetup.UninstallDirectory(const ADirectory: string): Boolean;
begin
  ReportInfo('Uninstalling...');
  Result := FUninstaller.Uninstall(ADirectory);
  if Result then
    ReportInfo('success')
  else
    ReportError('failed');
end;

function TDNSetup.Update(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion): Boolean;
begin
  ReportInfo('Updating ' + APackage.Name);
  Result := Uninstall(APackage);
  if Result then
    Result := Install(APackage, AVersion);
end;

end.
