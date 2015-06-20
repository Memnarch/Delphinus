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
    function UninstallPackage(const ADCPFile: string): Boolean; virtual;
    function RemoveSearchPath(const ASearchPath: string): Boolean; virtual;
    procedure DoMessage(AType: TMessageType; const AMessage: string);
  public
    function Uninstall(const ADirectory: string): Boolean;
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
      if Assigned(LInstalled) and (LInstalled is TJSONTrue) then
        if not UninstallPackage(LDCPFile) then
          break;

      DoMessage(mtNotification, 'deleting ' + ExtractFileName(LBPLFile));
      Result := DeleteFile(LBPLFile);
      if TFile.Exists(LBPLFile) then
        DoMessage(mtError, 'failed to delete');

      DoMessage(mtNotification, 'deleting ' + ExtractFileName(LDCPFile));
      Result := DeleteFile(LDCPFile) and Result;
      if TFile.Exists(LDCPFile) then
        DoMessage(mtError, 'failed to delete');

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
          Result := ProcessPackages(LJSon)
            and DeleteFiles(ADirectory)
            and RemoveSearchPathes(LJSon);
        finally
          LJSon.Free;
        end;
      end;
    finally
      LData.Free;
    end;
  end;
end;

function TDNUninstaller.UninstallPackage(const ADCPFile: string): Boolean;
begin
  Result := True;
end;

end.
