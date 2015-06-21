unit DN.Uninstaller;

interface

uses
  Classes,
  Types,
  SysUtils,
  DN.Types,
  DN.Uninstaller.Intf,
  DBXJSon,
  JSon;

type
  TDNUninstaller = class(TInterfacedObject, IDNUninstaller)
  private
    FOnMessage: TMessageEvent;
    function ProcessPackages(AObject: TJSONObject): Boolean;
    function DeleteFiles(const ADirectory: string): Boolean;
    function RemoveSearchPathes(AObject: TJSONObject): Boolean;
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

function TDNUninstaller.ProcessPackages(AObject: TJSONObject): Boolean;
var
  LPackages: TJSONArray;
  LPackage: TJSONObject;
  LInstalled: TJSONValue;
  LBPLFile, LDCPFile, LBPI, LLib: string;
  i: Integer;
begin
  LPackages := TJSONArray(AObject.GetValue('packages'));
  if Assigned(LPackages) then
  begin
    Result := False;
    for i := LPackages.Count - 1 downto 0 do
    begin
      LPackage := LPackages.Items[i] as TJSONObject;
      LBPLFile := LPackage.GetValue('bpl_file').Value;
      LDCPFile := LPackage.GetValue('dcp_file').Value;
      LBPI := ChangeFileExt(LDCPFile, '.bpi');
      LLib := ChangeFileExt(LDCPFile, '.lib');
      LInstalled := LPackage.GetValue('installed');
      if Assigned(LInstalled) and (SameText(LInstalled.Value, 'true')) then
      begin
        DoMessage(mtNotification, 'uninstalling package ' + LBPLFile);
        if not UninstallPackage(LBPLFile) then
          break;
      end;

      Result := True;
      if TFile.Exists(LBPLFile) then
      begin
        DoMessage(mtNotification, 'deleting ' + ExtractFileName(LBPLFile));
        Result := DeleteFile(LBPLFile);
        if TFile.Exists(LBPLFile) then
          DoMessage(mtError, 'failed to delete');
      end
      else
      begin
        DoMessage(mtWarning, 'file did not exist ' + LBPLFile);
      end;

      if TFile.Exists(LDCPFile) then
      begin
        DoMessage(mtNotification, 'deleting ' + ExtractFileName(LDCPFile));
        Result := DeleteFile(LDCPFile) and Result;
        if TFile.Exists(LDCPFile) then
          DoMessage(mtError, 'failed to delete');
      end
      else
      begin
        DoMessage(mtWarning, 'file did not exist ' + LDCPFile);
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
  end
  else
  begin
    Result := True;
  end;
end;

function TDNUninstaller.RemoveSearchPath(const ASearchPath: string): Boolean;
begin
  Result := True;
end;

function TDNUninstaller.RemoveSearchPathes(AObject: TJSONObject): Boolean;
var
  LPathes: TJSONValue;
  LPathArray: TStringDynArray;
  LPath: string;
begin
  Result := True;
  LPathes := AObject.GetValue('search_pathes');
  if Assigned(LPathes) then
  begin
    Result := False;
    DoMessage(mtNotification, 'Removing Searchpathes:');
    LPathArray := SplitString(LPathes.Value, ';');
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
  LUninstall: string;
  LData: TStringStream;
  LJSon: TJSONObject;
begin
  Result := False;
  LUninstall := TPath.Combine(ADirectory, CUninstallFile);
  if TFile.Exists(LUninstall) then
  begin
    LData := TStringStream.Create();
    try
      LData.LoadFromFile(LUninstall);
      LJSon := TJSOnObject(TJSONObject.ParseJSONValue(LData.DataString));
      if Assigned(LJSon) then
      begin
        try
          //remove searchpathes first, because it's less criticall
          //in case something goes wrong with uninstalling packages or deleting files, it's simpler to remove
          //them manually from disk, than removing individual searchpathes manually from IDE
          Result :=  RemoveSearchPathes(LJSon)
            and ProcessPackages(LJSon)
            and DeleteFiles(ADirectory);
        finally
          LJSon.Free;
        end;
      end;
    finally
      LData.Free;
    end;
  end;
end;

function TDNUninstaller.UninstallPackage(const ABPLFile: string): Boolean;
begin
  Result := True;
end;

end.
