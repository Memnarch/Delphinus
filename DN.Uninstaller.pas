unit DN.Uninstaller;

interface

uses
  Classes,
  Types,
  SysUtils,
  DN.Uninstaller.Intf,
  DBXJSon,
  JSon;

type
  TDNUninstaller = class(TInterfacedObject, IDNUninstaller)
  private
    function ProcessPackages(AObject: TJSONObject): Boolean;
    function DeleteFiles(const ADirectory: string): Boolean;
    function RemoveSearchPathes(AObject: TJSONObject): Boolean;
  protected
    function UninstallPackage(const ADCPFile: string): Boolean; virtual;
    function RemoveSearchPath(const ASearchPath: string): Boolean; virtual;
  public
    function Uninstall(const ADirectory: string): Boolean;
  end;

implementation

uses
  IOUtils,
  StrUtils;

{ TDNUninstaller }

function TDNUninstaller.DeleteFiles(const ADirectory: string): Boolean;
begin
  TDirectory.Delete(ADirectory, True);
  Result := not TDirectory.Exists(ADirectory);
end;

function TDNUninstaller.ProcessPackages(AObject: TJSONObject): Boolean;
var
  LPackages: TJSONArray;
  LPackage: TJSONObject;
  LInstalled: TJSONValue;
  LBPLFile, LDCPFile: string;
  i: Integer;
begin
  LPackages := TJSONArray(AObject.GetValue('packages'));
  if Assigned(LPackages) then
  begin
    Result := False;
    for i := 0 to LPackages.Count - 1 do
    begin
      LPackage := LPackages.Items[i] as TJSONObject;
      LBPLFile := LPackage.GetValue('bpl_file').Value;
      LDCPFile := LPackage.GetValue('dcp_file').Value;
      LInstalled := LPackage.GetValue('installed');
      if Assigned(LInstalled) and (LInstalled is TJSONTrue) then
        if not UninstallPackage(LDCPFile) then
          break;

      Result := DeleteFile(LDCPFile) and DeleteFile(LBPLFile);
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
    LPathArray := SplitString(LPathes.Value, ';');
    for LPath in LPathArray do
    begin
      Result := RemoveSearchPath(LPath);
      if not Result then
        Break;
    end;
  end;
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
