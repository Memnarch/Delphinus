unit DN.Uninstaller;

interface

uses
  Classes,
  Types,
  SysUtils,
  DN.Types,
  DN.Uninstaller.Intf,
  DN.JSonFile.Uninstallation;

type
  TDNUninstaller = class(TInterfacedObject, IDNUninstaller)
  private
    FOnMessage: TMessageEvent;
    function ProcessPackages(const APackages: TArray<TPackage>): Boolean;
    function DeleteFiles(const ADirectory: string): Boolean;
    function RemoveSearchPathes(const ASearchPathes: string): Boolean;
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
  protected
    function UninstallPackage(const ABPLFile: string): Boolean; virtual;
    function RemoveSearchPath(const ASearchPath: string): Boolean; virtual;
    procedure DoMessage(AType: TMessageType; const AMessage: string);
  public
    function Uninstall(const ADirectory: string): Boolean; virtual;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
  end;

implementation

uses
  IOUtils,
  StrUtils;

{ TDNUninstaller }

function TDNUninstaller.DeleteFiles(const ADirectory: string): Boolean;
begin
  DoMessage(mtNotification, 'Deleting Directory ' + ADirectory);
  TDirectory.Delete(ADirectory, True);
  Result := not TDirectory.Exists(ADirectory);
  if not Result then
    DoMessage(mtError, 'failed to delete directory');
end;

procedure TDNUninstaller.DoMessage(AType: TMessageType; const AMessage: string);
begin
  if Assigned(FOnMessage) then
    FOnMessage(AType, AMessage);
end;

function TDNUninstaller.GetOnMessage: TMessageEvent;
begin
  Result := FOnMessage;
end;

function TDNUninstaller.ProcessPackages(const APackages: TArray<TPackage>): Boolean;
var
  LPackage: TPackage;
  LBPI, LLib: string;
begin
  Result := Length(APackages) = 0;
  for LPackage in APackages do
  begin
    LBPI := ChangeFileExt(LPackage.DCPFile, '.bpi');
    LLib := ChangeFileExt(LPackage.DCPFile, '.lib');
    if LPackage.Installed then
    begin
      DoMessage(mtNotification, 'uninstalling package ' + LPackage.BPLFile);
      if not UninstallPackage(LPackage.BPLFile) then
        break;
    end;

    Result := True;
    if TFile.Exists(LPackage.BPLFile) then
    begin
      DoMessage(mtNotification, 'deleting ' + ExtractFileName(LPackage.BPLFile));
      Result := DeleteFile(LPackage.BPLFile);
      if TFile.Exists(LPackage.BPLFile) then
        DoMessage(mtError, 'failed to delete');
    end
    else
    begin
      DoMessage(mtWarning, 'file did not exist ' + LPackage.BPLFile);
    end;

    if TFile.Exists(LPackage.DCPFile) then
    begin
      DoMessage(mtNotification, 'deleting ' + ExtractFileName(LPackage.DCPFile));
      Result := DeleteFile(LPackage.DCPFile) and Result;
      if TFile.Exists(LPackage.DCPFile) then
        DoMessage(mtError, 'failed to delete');
    end
    else
    begin
      DoMessage(mtWarning, 'file did not exist ' + LPackage.DCPFile);
    end;

    if TFile.Exists(LBPI) then
    begin
      DoMessage(mtNotification, 'deleting ' + ExtractFileName(LBPI));
      Result := DeleteFile(LBPI) and Result;
      if TFile.Exists(LBPI) then
        DoMessage(mtError, 'failed to delete');
    end;

    if TFile.Exists(LLib) then
    begin
      DoMessage(mtNotification, 'deleting ' + ExtractFileName(LLib));
      Result := DeleteFile(LLib) and Result;
      if TFile.Exists(LLib) then
        DoMessage(mtError, 'failed to delete');
    end;
  end;
end;

function TDNUninstaller.RemoveSearchPath(const ASearchPath: string): Boolean;
begin
  Result := True;
end;

function TDNUninstaller.RemoveSearchPathes(const ASearchPathes: string): Boolean;
var
  LPathArray: TStringDynArray;
  LPath: string;
begin
  Result := True;
  LPathArray := SplitString(ASearchPathes, ';');
  if Length(LPathArray) > 0 then
  begin
    DoMessage(mtNotification, 'Removing Searchpathes:');
    for LPath in LPathArray do
    begin
      DoMessage(mtNotification, LPath);
      Result := RemoveSearchPath(LPath);
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
  LUninstallFile: string;
  LUninstall: TUninstallationFile;
begin
  Result := False;
  LUninstallFile := TPath.Combine(ADirectory, CUninstallFile);
  if TFile.Exists(LUninstallFile) then
  begin
    LUninstall := TUninstallationFile.Create();
    try
      if LUninstall.LoadFromFile(LUninstallFile) then
      begin
        //remove searchpathes first, because it's less criticall
        //in case something goes wrong with uninstalling packages or deleting files, it's simpler to remove
        //them manually from disk, than removing individual searchpathes manually from IDE
        Result :=  RemoveSearchPathes(LUninstall.SearchPathes)
          and ProcessPackages(LUninstall.Packages)
          and DeleteFiles(ADirectory);
      end
      else
      begin
        DoMessage(mtError, 'uninstallation file is corrupt');
      end;
    finally
      LUninstall.Free;
    end;
  end
  else
  begin
    DoMessage(mtError, 'No uninstallation file');
  end;
end;

function TDNUninstaller.UninstallPackage(const ABPLFile: string): Boolean;
begin
  Result := True;
end;

end.
