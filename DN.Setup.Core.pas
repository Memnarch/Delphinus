{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Setup.Core;

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
  TDNSetupCore = class(TInterfacedObject, IDNSetup)
  private
    FComponentDirectory: string;
    FOnMessage: TMessageEvent;
    FOnProgress: TDNProgressEvent;
    FProvider: IDNPackageProvider;
    function GetComponentDirectory: string;
    procedure SetComponentDirectory(const Value: string);
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
    function GetOnProgress: TDNProgressEvent;
    procedure SetOnProgress(const Value: TDNProgressEvent);
    procedure HandleProgress(const ATask, AItem: string; AProgress, AMax: Int64);
    procedure HandleProviderProgress(const ATask, AItem: string; AProgress, AMax: Int64);
    procedure DoProgress(const ATask, AItem: string; AProgress, AMax: Int64);
  protected
    FProgress: IDNProgress;
    procedure DoMessage(AType: TMessageType; const AMessage: string);
    procedure ReportInfo(const AInfo: string);
    procedure ReportWarning(const AWarning: string);
    procedure ReportError(const AError: string);
    function DownloadPackage(const APackage: IDNPackage; const AVersion: IDNPackageVersion; out AContentDirectory: string): Boolean;
    function GetInstallDirectoryForPackage(const APackage: IDNPackage): string; virtual;
    function GetInstallDirectoryForDirectory(const ADirectory: string): string; virtual;
    function GetHasPendingChanges: Boolean; virtual;
    function ExtendInfoFile(const APackage: IDNPackage; const AVersion: IDNPackageVersion; const AInstallDirectory: string): Boolean;
    function GetSetupTempDir: string;
    procedure CleanupTemp();
    function ConvertNameToValidDirectoryName(const AName: string): string;
    procedure RegisterProgressHandler(const AInterface: IInterface; AHandler: TDNProgressEvent = nil);
    procedure UnregisterProgressHandler(const AInterface: IInterface);
  public
    constructor Create(const APackageProvider: IDNPackageProvider);
    destructor Destroy; override;
    function Install(const APackage: IDNPackage; const AVersion: IDNPackageVersion): Boolean; virtual; abstract;
    function Update(const APackage: IDNPackage; const AVersion: IDNPackageVersion): Boolean; virtual;
    function Uninstall(const APackage: IDNPackage): Boolean; virtual; abstract;
    function InstallDirectory(const ADirectory: string): Boolean; virtual; abstract;
    function UninstallDirectory(const ADirectory: string): Boolean; virtual; abstract;
    property ComponentDirectory: string read GetComponentDirectory write SetComponentDirectory;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
    property OnProgress: TDNProgressEvent read GetOnProgress write SetOnProgress;
    property HasPendingChanges: Boolean read GetHasPendingChanges;
  end;

implementation

uses
  SysUtils,
  IOUtils,
  StrUtils,
  DN.JSonFile.InstalledInfo,
  DN.Progress,
  DN.Environment;

{ TDNSetupCore }

procedure TDNSetupCore.CleanupTemp;
begin
  ReportInfo('deleting tempfiles');
  if TDirectory.Exists(GetSetupTempDir()) then
  begin
    TDirectory.Delete(GetSetupTempDir(), True);
  end;
end;

function TDNSetupCore.ConvertNameToValidDirectoryName(const AName: string): string;
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

constructor TDNSetupCore.Create(const APackageProvider: IDNPackageProvider);
begin
  inherited Create();
  FProvider := APackageProvider;
  FProgress := TDNProgress.Create();
  FProgress.OnProgress := DoProgress;
end;

destructor TDNSetupCore.Destroy;
begin
  inherited;
end;

procedure TDNSetupCore.DoMessage(AType: TMessageType; const AMessage: string);
begin
  if Assigned(FOnMessage) then
    FOnMessage(AType, AMessage);
end;

procedure TDNSetupCore.DoProgress(const ATask, AItem: string; AProgress, AMax: Int64);
begin
  if Assigned(FOnProgress) then
    FOnProgress(ATask, AItem, AProgress, AMax);
end;

function TDNSetupCore.DownloadPackage(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion; out AContentDirectory: string): Boolean;
var
  LTempDir: string;
  LVersion: string;
begin
  RegisterProgressHandler(FProvider, HandleProviderProgress);
  try
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
  finally
    UnregisterProgressHandler(FProvider);
  end;
end;

function TDNSetupCore.ExtendInfoFile(const APackage: IDNPackage; const AVersion: IDNPackageVersion;
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

function TDNSetupCore.GetComponentDirectory: string;
begin
  Result := FComponentDirectory;
end;

function TDNSetupCore.GetHasPendingChanges: Boolean;
begin
  Result := False;
end;

function TDNSetupCore.GetInstallDirectoryForDirectory(
  const ADirectory: string): string;
begin
  Result := TPath.Combine(FComponentDirectory, ExtractFileName(ExcludeTrailingPathDelimiter(ADirectory)));
end;

function TDNSetupCore.GetInstallDirectoryForPackage(const APackage: IDNPackage): string;
begin
  Result := TPath.Combine(FComponentDirectory, ConvertNameToValidDirectoryName(APackage.Name));
end;

function TDNSetupCore.GetOnMessage: TMessageEvent;
begin
  Result := FOnMessage;
end;

function TDNSetupCore.GetOnProgress: TDNProgressEvent;
begin
  Result := FOnProgress;
end;

function TDNSetupCore.GetSetupTempDir: string;
begin
  Result := TPath.Combine(GetDelphinusTempFolder(), 'Setup');
end;

procedure TDNSetupCore.HandleProviderProgress(const ATask, AItem: string;
  AProgress, AMax: Int64);
begin
  FProgress.SetTaskProgress(IfThen(AItem <> '', AItem, 'Archive'), AProgress, AMax);
end;

procedure TDNSetupCore.HandleProgress(const ATask, AItem: string; AProgress,
  AMax: Int64);
begin
  FProgress.SetTaskProgress(IfThen(AItem <> '', ATask + ': ' + AItem, ATask), AProgress, AMax);
end;

procedure TDNSetupCore.RegisterProgressHandler(const AInterface: IInterface; AHandler: TDNProgressEvent);
var
  LProgress: IDNProgress;
begin
  if Assigned(AInterface) and Supports(AInterface, IDNProgress, LProgress) then
  begin
    if Assigned(AHandler) then
      LProgress.OnProgress := AHandler
    else
      LProgress.OnProgress := HandleProgress;
  end;
end;

procedure TDNSetupCore.ReportError(const AError: string);
begin
  DoMessage(mtError, AError);
end;

procedure TDNSetupCore.ReportInfo(const AInfo: string);
begin
  DoMessage(mtNotification, AInfo);
end;

procedure TDNSetupCore.ReportWarning(const AWarning: string);
begin
  DoMessage(mtWarning, AWarning);
end;

procedure TDNSetupCore.SetComponentDirectory(const Value: string);
begin
  FComponentDirectory := Value;
end;

procedure TDNSetupCore.SetOnMessage(const Value: TMessageEvent);
begin
  FOnMessage := Value;
end;

procedure TDNSetupCore.SetOnProgress(const Value: TDNProgressEvent);
begin
  FOnProgress := Value;
end;

procedure TDNSetupCore.UnregisterProgressHandler(const AInterface: IInterface);
var
  LProgress: IDNProgress;
begin
  if Assigned(AInterface) and Supports(AInterface, IDNProgress, LProgress) then
    LProgress.OnProgress := nil;
end;

function TDNSetupCore.Update(const APackage: IDNPackage;
  const AVersion: IDNPackageVersion): Boolean;
begin
  ReportInfo('Updating ' + APackage.Name);
  Result := Uninstall(APackage);
  if Result then
    Result := Install(APackage, AVersion);
end;

end.
