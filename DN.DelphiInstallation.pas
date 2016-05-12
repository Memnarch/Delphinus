unit DN.DelphiInstallation;

interface

uses
  DN.DelphiInstallation.Intf,
  Graphics;

type
  TDNDelphInstallation = class(TInterfacedObject, IDNDelphiInstallation)
  private
    FName: string;
    FShortName: string;
    FRoot: string;
    FDirectory: string;
    FApplication: string;
    FEdition: string;
    FBDSVersion: string;
    FBDSCommonDir: string;
    FIcon: TIcon;
    procedure Load;
    function GetIcon: TIcon;
    function GetName: string;
    function GetShortName: string;
    function GetRoot: string;
    function GetDirectory: string;
    function GetApplication: string;
    function GetEdition: string;
    function GetBDSVersion: string;
    function GetBDSCommonDir: string;
    function ReadShortName(const AName: string): string;
  public
    constructor Create(const ARoot: string);
    destructor Destroy; override;
    function IsRunning: Boolean;
    property Name: string read GetName;
    property ShortName: string read GetShortName;
    property Edition: string read GetEdition;
    property BDSVersion: string read GetBDSVersion;
    property Icon: TIcon read GetIcon;
    property Root: string read GetRoot;
    property Directory: string read GetDirectory;
    property Application: string read GetApplication;
    property BDSCommonDir: string read GetBDSCommonDir;
  end;

implementation

uses
  Classes,
  Windows,
  Registry,
  SysUtils,
  IOUtils,
  ShellApi,
  TLHelp32,
  StrUtils;

{ TDNDelphInstallationInfo }

constructor TDNDelphInstallation.Create(const ARoot: string);
begin
  inherited Create();
  FRoot := ARoot;
  Load();
end;

destructor TDNDelphInstallation.Destroy;
begin
  if Assigned(FIcon) then
    FIcon.Free();
  inherited;
end;

function TDNDelphInstallation.GetApplication: string;
begin
  Result := FApplication;
end;

function TDNDelphInstallation.GetBDSCommonDir: string;
var
  LFile: TStringList;
  LLine: string;
const
  CPrefix = '@SET BDSCOMMONDIR=';
begin
  if FBDSCommonDir = '' then
  begin
    LFile := TStringList.Create();
    try
      LFile.LoadFromFile(TPath.Combine(ExtractFilePath(Application), 'rsvars.bat'));
      for LLine in LFile do
      begin
        if StartsText(CPrefix, LLine) then
        begin
          FBDSCommonDir := Copy(LLine, Length(CPrefix) + 1, Length(LLine));
          Break;
        end;
      end;
      if FBDSCommonDir = '' then
        raise Exception.Create('Failed to read BDSCommonDir for BDS ' + BDSVersion);
    finally
      LFile.Free;
    end;
  end;
  Result := FBDSCommonDir;
end;

function TDNDelphInstallation.GetBDSVersion: string;
begin
  Result := FBDSVersion;
end;

function TDNDelphInstallation.GetDirectory: string;
begin
  Result := FDirectory;
end;

function TDNDelphInstallation.GetEdition: string;
begin
  Result := FEdition;
end;

function TDNDelphInstallation.GetIcon: TIcon;
begin
  if not Assigned(FIcon) then
  begin
    FIcon := TIcon.Create();
    FIcon.Handle := ExtractIcon(HInstance, PChar(FApplication), 0);
  end;
  Result := FIcon;
end;

function TDNDelphInstallation.GetName: string;
begin
  Result := FName;
end;

function TDNDelphInstallation.GetShortName: string;
begin
  Result := FShortName;
end;

function TDNDelphInstallation.ReadShortName(const AName: string): string;
var
  i, LStart: Integer;
begin
  LStart := 1;
  for i := Length(AName) downto 1 do
  begin
    if AName[i] = ' ' then
      Break;
    LStart := i;
  end;
  Result := Copy(AName, LStart, Length(AName));
end;

function TDNDelphInstallation.GetRoot: string;
begin
  Result := FRoot;
end;

function QueryFullProcessImageName(
  hProcess: THandle;
  dwFlags: DWord;
  lpExeName: PChar;
  out lpdwSize: DWord
): BOOL; stdcall external kernel32 name 'QueryFullProcessImageNameW';

function GetFullProcessImageName(APid: DWord): string;
var
  LBuffer: PChar;
  LSize: DWord;
  LProcess: THandle;
begin
  Result := '';
  LProcess := OpenProcess(PROCESS_QUERY_INFORMATION, False, APid);
  if LProcess <> INVALID_HANDLE_VALUE then
  begin
    try
      LSize := MAX_PATH;
      LBuffer := GetMemory(LSize * SizeOf(Char));
      try
        if QueryFullProcessImageName(LProcess, 0, LBuffer, LSize) then
        begin
          Result := LBuffer;
        end;
      finally
        FreeMemory(LBuffer);
      end;
    finally
      CloseHandle(LProcess);
    end;
  end;
end;

function TDNDelphInstallation.IsRunning: Boolean;
var
  LSnapshot: THandle;
  LProcess: TProcessEntry32;
  LExe: string;
begin
  LSnapShot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    LProcess.dwSize := SizeOf(LProcess);
    if Process32First(LSnapshot, LProcess) then
    begin
      LExe := ExtractFileName(Application);
      repeat
        if SameText(LProcess.szExeFile, LExe)
          and SameText(GetFullProcessImageName(LProcess.th32ProcessID), Application) then
          Exit(true);
      until not Process32Next(LSnapshot, LProcess);
    end;
    Result := False;
  finally
    CloseHandle(LSnapshot)
  end;
end;

procedure TDNDelphInstallation.Load;
var
  LRegistry: TRegistry;
const
  CDelphiWin32 = 'Delphi.Win32';
begin
  FBDSVersion := ExtractFileName(ExcludeTrailingPathDelimiter(FRoot));
  LRegistry := TRegistry.Create();
  try
    LRegistry.Access := LRegistry.Access or KEY_WOW64_64KEY;
    LRegistry.RootKey := HKEY_CURRENT_USER;
    if LRegistry.OpenKey(FRoot, False) then
    begin
      FDirectory := LRegistry.ReadString('RootDir');
      FApplication := LRegistry.ReadString('App');
      FEdition := LRegistry.ReadString('Edition');
      LRegistry.CloseKey();
      if LRegistry.OpenKey(TPath.Combine(FRoot, 'Personalities'), False) then
      begin
        if LRegistry.ValueExists(CDelphiWin32) then
          FName := LRegistry.ReadString(CDelphiWin32)
        else
          FName := LRegistry.ReadString('');

        FShortName := ReadShortName(FName);
      end;
    end;
  finally
    LRegistry.Free();
  end;
end;

end.
