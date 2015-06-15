unit DN.Compiler.MSBuild;

interface

uses
  Windows,
  SysUtils,
  DN.Compiler.Intf,
  DN.Compiler;

type
  TDNMSBuildCompiler = class(TDNCompiler)
  private
    FEmbarcaderoFolder: string;
    FLogFile: string;
    function BuildCommandLine(const AProjectfile: string): string;
    function GetMSBuildProperties: string;
  public
    constructor Create(const AEmbarcaderoFolder: string);
    function Compile(const AProjectFile: string): Boolean; override;
  end;

implementation

uses
  IOUtils,
  ShellApi;

{ TDNMSBuildCompiler }

function TDNMSBuildCompiler.BuildCommandLine(
  const AProjectfile: string): string;
begin
  Result := 'call "' + FEmbarcaderoFolder + '\RSVars.bat"';
  Result := Result + '& msbuild "' + AProjectfile + '" ' + GetMSBuildProperties() + ' > "' + FLogFile + '"';
  Result := 'cmd.exe /c ' + Result;
end;

function TDNMSBuildCompiler.Compile(const AProjectFile: string): Boolean;
var
  LExecInfo: TShellExecuteInfo;
  LExitcode: Cardinal;
begin
  LExecInfo.cbSize := sizeof(TShellExecuteInfo);
  LExecInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  LExecInfo.Wnd := 0;
  LExecInfo.lpVerb := nil;
  LExecInfo.lpFile := 'cmd.exe';
  LExecInfo.lpParameters := PChar(BuildCommandLine(AProjectFile));
  LExecInfo.lpDirectory := nil;
  LExecInfo.nShow := SW_HIDE;
  LExecInfo.hInstApp := 0;

  ShellExecuteEx(@LExecInfo);
  WaitForSingleObject(LExecInfo.hProcess,INFINITE);
  GetExitCodeProcess(LExecInfo.hProcess, LExitcode);
  Result := LExitcode = 0;
  CloseHandle(LExecInfo.hProcess);

  if TFile.Exists(FLogFile) then
  begin
    Log.LoadFromFile(FLogFile);
    TFile.Delete(FLogFile);
  end;
end;

constructor TDNMSBuildCompiler.Create(const AEmbarcaderoFolder: string);
begin
  inherited Create();
  FEmbarcaderoFolder := AEmbarcaderoFolder;
  FLogFile := TPath.GetTempFileName();
end;

function TDNMSBuildCompiler.GetMSBuildProperties: string;
begin
  case Target of
    ctBuild: Result := '/target:Build';
    ctCompile: Result := '/target:Compile';
  end;

  case Config of
    ctRelease: Result := Result + ' /p:config=Release';
    ctDebug: Result := Result + ' /p:config=Debug';
  end;

  if DCUOutput <> '' then
    Result := Result + ' /p:DCC_DcuOutput="' + ExcludeTrailingPathDelimiter(DCUOutput) + '"';

  if DCPOutput <> '' then
    Result := Result + ' /p:DCC_DcpOutput="' + ExcludeTrailingPathDelimiter(DCPOutput) + '"';

  if EXEOutput <> '' then
    Result := Result + ' /p:DCC_ExeOutput="' + ExcludeTrailingPathDelimiter(ExeOutput) + '"';

  if BPLOutput <> '' then
    Result := Result + ' /p:DCC_BplOutput="' + ExcludeTrailingPathDelimiter(BPLOutput) + '"';
end;

end.
