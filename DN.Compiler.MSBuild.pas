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
  Result := '/target:' + TDNCompilerTargetName[Target];
  Result := Result + ' /p:config=' + TDNCompilerConfigName[Config];
  Result := Result + ' /P:platform=' + TDNCompilerPlatformName[Platform];

  if DCUOutput <> '' then
    Result := Result + ' /p:DCC_DcuOutput="' + ResolveVars(ExcludeTrailingPathDelimiter(DCUOutput)) + '"';

  if DCPOutput <> '' then
    Result := Result + ' /p:DCC_DcpOutput="' + ResolveVars(ExcludeTrailingPathDelimiter(DCPOutput)) + '"';

  if EXEOutput <> '' then
    Result := Result + ' /p:DCC_ExeOutput="' + ResolveVars(ExcludeTrailingPathDelimiter(ExeOutput)) + '"';

  if BPLOutput <> '' then
    Result := Result + ' /p:DCC_BplOutput="' + ResolveVars(ExcludeTrailingPathDelimiter(BPLOutput)) + '"';
end;

end.
