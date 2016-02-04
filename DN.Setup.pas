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
  DN.PackageProvider.Intf,
  DN.Progress.Intf;

type
  TDNSetup = class(TInterfacedObject, IDNSetup)
  private
    FComponentDirectory: string;
    FOnMessage: TMessageEvent;
    FOnProgress: TDNProgressEvent;
    FProgress: IDNProgress;
    FProvider: IDNPackageProvider;
    FInstaller: IDNInstaller;
    FUninstaller: IDNUninstaller;
    function GetComponentDirectory: string;
    procedure SetComponentDirectory(const Value: string);
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
    function GetOnProgress: TDNProgressEvent;
    procedure SetOnProgress(const Value: TDNProgressEvent);
  protected
    procedure DoMessage(AType: TMessageType; const AMessage: string);
    procedure DoProgress(const ATask, AItem: string; AProgress, AMax: Int64);
    procedure ReportInfo(const AInfo: string);
    procedure ReportWarning(const AWarning: string);
    procedure ReportError(const AError: string);
    function DownloadPackage(const APackage: IDNPackage; const AVersion: IDNPackageVersion; out AContentDirectory: string): Boolean;
    function GetInstallDirectoryForPackage(const APackage: IDNPackage): string; virtual;
    function GetInstallDirectoryForDirectory(const ADirectory: string): string; virtual;
    function ExtendInfoFile(const APackage: IDNPackage; const AVersion: IDNPackageVersion; const AInstallDirectory: string): Boolean;
    function GetSetupTempDir: string;
    procedure CleanupTemp();
    function ConvertNameToValidDirectoryName(const AName: string): string;
    procedure HandleProgress(const ATask, AItem: string; AProgress, AMax: Int64);
    procedure AttachProgressEvents;
    procedure DetachProgressEvents;
  public
    constructor Create(const AInstaller: IDNInstaller; const AUninstaller: IDNUninstaller; const APackageProvider: IDNPackageProvider);
    function Install(const APackage: IDNPackage; const AVersion: IDNPackageVersion): Boolean;
    function Update(const APackage: IDNPackage; const AVersion: IDNPackageVersion): Boolean;
    function Uninstall(const APackage: IDNPackage): Boolean;
    function InstallDirectory(const ADirectory: string): Boolean;
    function UninstallDirectory(const ADirectory: string): Boolean;
    property ComponentDirectory: string read GetComponentDirectory write SetComponentDirectory;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
    property OnProgress: TDNProgressEvent read GetOnProgress write SetOnProgress;
  end;

implementation

uses
  SysUtils,
  IOUtils,
  StrUtils,
  DN.JSonFile.InstalledInfo,
  DN.Progress,
  DN.Environment;

{ TDNSetup }

procedure TDNSetup.AttachProgressEvents;
var
  LProgress: IDNProgress;
begin
  if Assigned(FInstaller) and Supports(FInstaller, IDNProgress, LProgress) then
    LProgress.OnProgress := HandleProgress;

  if Assigned(FUninstaller) and Supports(FUninstaller, IDNProgress, LProgress) then
    LProgress.OnProgress := HandleProgress;

  if Assigned(FProvider) and Supports(FProvider, IDNProgress, LProgress) then
    LProgress.OnProgress := HandleProgress;
end;

procedure TDNSetup.CleanupTemp;
begin
  ReportInfo('deleting tempfiles');
  if TDirectory.Exists(GetSetupTempDir()) then
  begin
    TDirectory.Delete(GetSetupTempDir(), True);
  end;
end;

function TDNSetup.ConvertNameToValidDirectoryName(const AName: string): string;
var
  i: Integer;
{$i DN.LowHighString.inc}
begin
  SetLength(Result, Length(AName));
  for i := Low(Result) to High(Result) do
  begin
    if TPath.IsValidFileNameChar(AName[i]) then
      Result[i] := AName[i]
    else
      Result[i] := ' ';
  end;
  Result := Trim(Result);
end;

constructor TDNSetup.Create(const AInstaller: IDNInstaller;
  const AUninstaller: IDNUninstaller;
  const APackageProvider: IDNPackageProvider);
begin
  inherited Create();
  FInstaller := AInstaller;
  if Assigned(FInstaller) then
    FInstaller.OnMessage := DoMessage;
  FUninstaller := AUninstaller;
  if Assigned(FUninstaller) then
    FUninstaller.OnMessage := DoMessage;
  FProvider := APackageProvider;
  FProgress := TDNProgress.Create();
  FProgress.OnProgress := DoProgress;
end;

procedure TDNSetup.DetachProgressEvents;
var
  LProgress: IDNProgress;
begin
  if Assigned(FInstaller) and Supports(FInstaller, IDNProgress, LProgress) then
    LProgress.OnProgress := nil;

  if Assigned(FUninstaller) and Supports(FUninstaller, IDNProgress, LProgress) then
    LProgress.OnProgress := nil;

  if Assigned(FProvider) and Supports(FProvider, IDNProgress, LProgress) then
    LProgress.OnProgress := nil;
end;

procedure TDNSetup.DoMessage(AType: TMessageType; const AMessage: string);
begin
  if Assigned(FOnMessage) then
    FOnMessage(AType, AMessage);
end;

procedure TDNSetup.DoProgress(const ATask, AItem: string; AProgress, AMax: Int64);
begin
  if Assigned(FOnProgress) then
    FOnProgress(ATask, AItem, AProgress, AMax);
end;

function TDNSetup.DownloadPackage(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion; out AContentDirectory: string): Boolean;
var
  LTempDir: string;
  LVersion: string;
begin
  ReportInfo('Downloading ' + APackage.Name);
  LTempDir := GetSetupTempDir();
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
  LInfoFile := TPath.Combine(AInstallDirectory, CInfoFile);
  if TFile.Exists(LInfoFile) then
  begin
    LInstalledInfo := TInstalledInfoFile.Create();
    try
      LInstalledInfo.LoadFromFile(LInfoFile);
      LInstalledInfo.Author := APackage.Author;
      LInstalledInfo.Description := APackage.Description;
      if Assigned(AVersion) then
        LInstalledInfo.Version := AVersion.Name;

      LInstalledInfo.ProjectUrl := APackage.ProjectUrl;
      LInstalledInfo.HomepageUrl := APackage.HomepageUrl;
      LInstalledInfo.ReportUrl := APackage.ReportUrl;
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
  Result := TPath.Combine(FComponentDirectory, ConvertNameToValidDirectoryName(APackage.Name));
end;

function TDNSetup.GetOnMessage: TMessageEvent;
begin
  Result := FOnMessage;
end;

function TDNSetup.GetOnProgress: TDNProgressEvent;
begin
  Result := FOnProgress;
end;

function TDNSetup.GetSetupTempDir: string;
begin
  Result := TPath.Combine(GetDelphinusTempFolder(), 'Setup');
end;

procedure TDNSetup.HandleProgress(const ATask, AItem: string; AProgress,
  AMax: Int64);
begin
  FProgress.SetTaskProgress(IfThen(AItem <> '', ATask + ': ' + AItem, ATask), AProgress, AMax);
end;

function TDNSetup.Install(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion): Boolean;
var
  LContentDirectory: string;
  LInstallDirectory: string;
begin
  AttachProgressEvents();
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
    DetachProgressEvents();
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
  AttachProgressEvents();
  try
    FProgress.SetTasks(['Installing']);
    LInstallDirectory := GetInstallDirectoryForDirectory(ADirectory);
    Result := FInstaller.Install(ADirectory, LInstallDirectory);
    FProgress.Completed();
    if Result then
      ReportInfo('Installation finished')
    else
      ReportError('Installation failed');
  finally
    DetachProgressEvents();
  end;
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

procedure TDNSetup.SetOnProgress(const Value: TDNProgressEvent);
begin
  FOnProgress := Value;
end;

function TDNSetup.Uninstall(const APackage: IDNPackage): Boolean;
begin
  Result := UninstallDirectory(GetInstallDirectoryForPackage(APackage));
end;

function TDNSetup.UninstallDirectory(const ADirectory: string): Boolean;
begin
  AttachProgressEvents();
  try
    ReportInfo('Uninstalling...');
    FProgress.SetTasks(['Uninstalling']);
    Result := FUninstaller.Uninstall(ADirectory);
    FProgress.Completed();
    if Result then
      ReportInfo('success')
    else
      ReportError('failed');
  finally
    DetachProgressEvents();
  end;
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
