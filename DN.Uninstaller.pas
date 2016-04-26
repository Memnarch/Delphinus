{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Uninstaller;

interface

uses
  Classes,
  Types,
  SysUtils,
  DN.Types,
  DN.Uninstaller.Intf,
  DN.JSonFile.Uninstallation,
  DN.Progress.Intf,
  DN.ToolsAPi.ExpertService.Intf,
  DN.FileService.Intf;

type
  TDNUninstaller = class(TInterfacedObject, IDNUninstaller, IDNProgress)
  private
    FExpertService: IDNExpertService;
    FFileService: IDNFileService;
    FOnMessage: TMessageEvent;
    FProgress: IDNProgress;
    FHasPendingChanges: Boolean;
    function ProcessPackages(const APackages: TArray<TPackage>): Boolean;
    function ProcessExperts(const AExperts: TArray<TInstalledExpert>): Boolean;
    function RemovePathes(const ASearchPathes: string; APathType: TPathType): Boolean;
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
    function GenerateNewName(const ADirName: string): string;
  protected
    function LoadUninstall(const ADirectory: string; AUninstall: TUninstallationFile): Boolean; virtual;
    function DeleteFiles(const ADirectory: string): Boolean; virtual;
    function DeleteRawFiles(const ARawFiles: TArray<string>): Boolean; virtual;
    function DeleteComponentFile(const AFile: string; const AWarningWhenMissing: Boolean = True): Boolean; virtual;
    function UninstallPackage(const ABPLFile: string): Boolean; virtual;
    function UninstallExpert(const AExpert: string; AHotReload: Boolean): Boolean; virtual;
    function RemoveSearchPath(const ASearchPath: string): Boolean; virtual;
    function RemoveBrowsingPath(const ABrowsingPath: string): Boolean; virtual;
    function GetHasPendingChanges: Boolean; virtual;
    procedure DoMessage(AType: TMessageType; const AMessage: string);
    //properties for interfaceredirection
    property Progress: IDNProgress read FProgress implements IDNProgress;
  public
    constructor Create(const AExpertService: IDNExpertService = nil;
      const AFileService: IDNFileService = nil);
    destructor Destroy; override;
    function Uninstall(const ADirectory: string): Boolean; virtual;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
    property HasPendingChanges: Boolean read GetHasPendingChanges;
  end;

implementation

uses
  IOUtils,
  DN.IOUtils,
  StrUtils,
  DN.Progress;

{ TDNUninstaller }

constructor TDNUninstaller.Create(const AExpertService: IDNExpertService;
  const AFileService: IDNFileService);
begin
  inherited Create();
  FExpertService := AExpertService;
  FFileService := AFileService;
  FProgress := TDNProgress.Create();
end;

function TDNUninstaller.DeleteComponentFile(const AFile: string; const AWarningWhenMissing: Boolean): Boolean;
var
  LNewName: string;
begin
  Result := True;
  if TFile.Exists(AFile) then
  begin
    if not HasPendingChanges or not Assigned(FFileService) then
    begin
      DoMessage(mtNotification, 'deleting ' + ExtractFileName(AFile));
      Result := DeleteFile(AFile);
      if TFile.Exists(AFile) then
        DoMessage(mtError, 'failed to delete');
    end
    else
    begin
      DoMessage(mtNotification, 'mark for deletion: ' + AFile);
      LNewName := GenerateNewName(AFile);
      Result := RenameFile(AFile, LNewName);
      if Result then
        FFileService.RegisterFileForDeletion(LNewName)
      else
        DoMessage(mtError, 'Failed to rename file to: ' + LNewName);
    end;
  end
  else
  begin
    if AWarningWhenMissing then
      DoMessage(mtWarning, 'file did not exist ' + AFile);
  end;
end;

function TDNUninstaller.DeleteFiles(const ADirectory: string): Boolean;
var
  LNewName: string;
begin
  DoMessage(mtNotification, 'Deleting Directory ' + ADirectory);
  if not HasPendingChanges or not Assigned(FFileService) then
  begin
    TDirectory.Delete(ADirectory, True);
    Result := not TDirectory.Exists(ADirectory);
    if not Result then
      DoMessage(mtError, 'failed to delete directory');
  end
  else
  begin
    DoMessage(mtNotification, 'detected pending changes, queue for delete on reboot');
    LNewName := GenerateNewName(ADirectory);
    Result := RenameFile(ExcludeTrailingPathDelimiter(ADirectory), LNewName);
    if Result then
      FFileService.RegisterDirectoryForDeletion(LNewName)
    else
      DoMessage(mtError, 'Failed to rename directory to: ' + LNewName);
  end;
end;

function TDNUninstaller.DeleteRawFiles(
  const ARawFiles: TArray<string>): Boolean;
var
  LFile, LNewFile: string;
begin
  Result := True;
  if Length(ARawFiles) > 0 then
    if not HasPendingChanges or not Assigned(FFileService) then
      DoMessage(mtNotification, 'Deleting Rawfiles')
    else
      DoMessage(mtNotification, 'marking Rawfiles for deletion on reboot');

  for LFile in ARawFiles do
    if TFile.Exists(LFile) then
    begin
      if not FHasPendingChanges or not Assigned(FFileService) then
      begin
        TFile.Delete(LFile)
      end
      else
      begin
        LNewFile := GenerateNewName(LFile);
        RenameFile(LFile, LNewFile);
        FFileService.RegisterFileForDeletion(LNewFile);
      end;
    end
    else
    begin
      DoMessage(mtWarning, 'File not found: ' + LFile);
    end;
end;

destructor TDNUninstaller.Destroy;
begin
  FProgress := nil;
  inherited;
end;

procedure TDNUninstaller.DoMessage(AType: TMessageType; const AMessage: string);
begin
  if Assigned(FOnMessage) then
    FOnMessage(AType, AMessage);
end;

function TDNUninstaller.GenerateNewName(const ADirName: string): string;
begin
  Result := ExcludeTrailingPathDelimiter(ADirName);
  while TDirectory.Exists(Result) or TFile.Exists(Result) do
    Result := ExcludeTrailingPathDelimiter(Result) + '~';
end;

function TDNUninstaller.GetHasPendingChanges: Boolean;
begin
  Result := FHasPendingChanges;
end;

function TDNUninstaller.GetOnMessage: TMessageEvent;
begin
  Result := FOnMessage;
end;

function TDNUninstaller.LoadUninstall(const ADirectory: string;
  AUninstall: TUninstallationFile): Boolean;
var
  LUninstallFile: string;
begin
  LUninstallFile := TPath.Combine(ADirectory, CUninstallFile);
  if TFile.Exists(LUninstallFile) then
  begin
    Result := AUninstall.LoadFromFile(LUninstallFile);
    if not Result then
      DoMessage(mtError, 'uninstallation file is invalid json');
  end
  else
  begin
    Result := False;
    DoMessage(mtError, 'No uninstallation file');
  end;
end;

function TDNUninstaller.ProcessExperts(
  const AExperts: TArray<TInstalledExpert>): Boolean;
var
  LExpert: TInstalledExpert;
begin
  Result := True;
  if Length(AExperts) > 0 then
    DoMessage(mtNotification, 'Removing Experts');
  for LExpert in AExperts do
  begin
    DoMessage(mtNotification, LExpert.Expert);
    FHasPendingChanges := FHasPendingChanges or not LExpert.HotReload;
    if not UninstallExpert(LExpert.Expert, LExpert.HotReload) then
    begin
      DoMessage(mtWarning, 'Failed to remove expert:' + LExpert.Expert);
    end;
  end;
end;

function TDNUninstaller.ProcessPackages(const APackages: TArray<TPackage>): Boolean;
var
  LPackage: TPackage;
  LBPI, LLib: string;
  i: Integer;
begin
  Result := Length(APackages) = 0;
  for i := High(APackages) downto Low(APackages) do
  begin
    LPackage := APackages[i];
    if SameText(ExtractFileExt(LPackage.BPLFile), CMacPackageExtension) then
    begin
      LBPI := TPath.Combine(ExtractFilePath(LPackage.BPLFile), ChangeFileExt(ExtractFileName(LPackage.DCPFile), '.info.plist'));
      LLib := TPath.Combine(ExtractFilePath(LPackage.BPLFile), ChangeFileExt(ExtractFileName(LPackage.DCPFile), '.entitlements'));
    end
    else
    begin
      LBPI := ChangeFileExt(LPackage.DCPFile, '.bpi');
      LLib := ChangeFileExt(LPackage.DCPFile, '.lib');
    end;
    if LPackage.Installed then
    begin
      DoMessage(mtNotification, 'uninstalling package ' + LPackage.BPLFile);
      if not UninstallPackage(LPackage.BPLFile) then
        break;
    end;

    Result := DeleteComponentFile(LPackage.BPLFile);
    Result := DeleteComponentFile(LPackage.DCPFile) and Result;
    Result := DeleteComponentFile(LBPI, False) and Result;
    Result := DeleteComponentFile(LLib, False) and Result;
  end;
end;

function TDNUninstaller.RemoveBrowsingPath(
  const ABrowsingPath: string): Boolean;
begin
  Result := True;
end;

function TDNUninstaller.RemoveSearchPath(const ASearchPath: string): Boolean;
begin
  Result := True;
end;

function TDNUninstaller.RemovePathes(const ASearchPathes: string;APathType: TPathType): Boolean;
var
  LPathArray: TStringDynArray;
  LPath: string;
begin
  Result := True;
  LPathArray := SplitString(ASearchPathes, ';');
  if Length(LPathArray) > 0 then
  begin
    case APathType of
      tpSearchPath:  DoMessage(mtNotification, 'Removing Searchpathes:');
      tpBrowsingPath:  DoMessage(mtNotification, 'Removing Browsingpathes:');
    else
      DoMessage(mtError, 'Unknown pathtype');
      Exit(False);
    end;
    for LPath in LPathArray do
    begin
      DoMessage(mtNotification, LPath);
      case APathType of
        tpSearchPath: Result := RemoveSearchPath(LPath);
        tpBrowsingPath: Result := RemoveBrowsingPath(LPath);
      else
        Result := False;
      end;
      if not Result then
      begin
        DoMessage(mtError, 'Failed');
        Break;
      end;
    end;
  end;
end;

procedure TDNUninstaller.SetOnMessage(const Value: TMessageEvent);
begin
  FOnMessage := Value;
end;

function TDNUninstaller.Uninstall(const ADirectory: string): Boolean;
var
  LUninstall: TUninstallationFile;
begin
  Result := False;
  LUninstall := TUninstallationFile.Create();
  try
    if LoadUninstall(ADirectory, LUninstall) then
    begin
      //remove searchpathes first, because it's less criticall
      //in case something goes wrong with uninstalling packages or deleting files, it's simpler to remove
      //them manually from disk, than removing individual searchpathes manually from IDE
      FProgress.SetTasks(['Removing Pathes', 'Removing Experts', 'Remove Packages', 'Delete Files']);
      FProgress.SetTaskProgress('SearchPath', 0, 1);
      Result :=  RemovePathes(LUninstall.SearchPathes, tpSearchPath);
      FProgress.SetTaskProgress('Browsing Path', 1, 1);
      Result := Result and RemovePathes(LUninstall.BrowsingPathes, tpBrowsingPath);
      FProgress.NextTask();
      Result := Result and ProcessExperts(LUninstall.Experts);
      FProgress.NextTask();
      Result := Result and ProcessPackages(LUninstall.Packages);
      FProgress.NextTask();
      Result := Result and DeleteRawFiles(LUninstall.RawFiles);
      Result := Result and DeleteFiles(ADirectory);
      FProgress.Completed();
    end;
  finally
    LUninstall.Free;
  end;
end;

function TDNUninstaller.UninstallExpert(const AExpert: string;
  AHotReload: Boolean): Boolean;
var
  LResult: Boolean;
begin
  Result := True;
  if Assigned(FExpertService) then
  begin
    TThread.Synchronize(nil,
      procedure
      begin
        LResult := FExpertService.UnregisterExpert(AExpert, AHotReload);
      end);
    Result := LResult;
    FHasPendingChanges := FHasPendingChanges or not AHotReload;
  end;
end;

function TDNUninstaller.UninstallPackage(const ABPLFile: string): Boolean;
begin
  Result := True;
end;

end.
