{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Compiler.MSBuild;

interface

uses
  Windows,
  Classes,
  SysUtils,
  DN.Types,
  DN.Compiler.Intf,
  DN.Compiler;

type
  TDNMSBuildCompiler = class(TDNCompiler)
  private
    FEmbarcaderoBinFolder: string;
    FLogFile: string;
    FVersion: TCompilerVersion;
    function BuildCommandLine(const AProjectfile: string): string;
    function GetMSBuildProperties: string;
    function Execute(const ACommandLine: string): Cardinal;
  protected
    function GetVersion: TCompilerVersion; override;
  public
    constructor Create(const AEmbarcaderoBinFolder: string);
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
  Result := 'call "' + FEmbarcaderoBinFolder + '\RSVars.bat"';
  Result := Result + '& msbuild "' + AProjectfile + '" ' + GetMSBuildProperties() + ' > "' + FLogFile + '"';
  Result := 'cmd.exe /c ' + Result;
end;

function TDNMSBuildCompiler.Compile(const AProjectFile: string): Boolean;
begin
  Result := Execute(BuildCommandLine(AProjectFile)) = 0;
end;

constructor TDNMSBuildCompiler.Create(const AEmbarcaderoBinFolder: string);
begin
  inherited Create();
  FEmbarcaderoBinFolder := AEmbarcaderoBinFolder;
  FLogFile := TPath.GetTempFileName();
end;

function TDNMSBuildCompiler.Execute(const ACommandLine: string): Cardinal;
var
  LExecInfo: TShellExecuteInfo;
begin
  Result := MaxInt;
  LExecInfo.cbSize := sizeof(TShellExecuteInfo);
  LExecInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  LExecInfo.Wnd := 0;
  LExecInfo.lpVerb := nil;
  LExecInfo.lpFile := 'cmd.exe';
  LExecInfo.lpParameters := PChar(ACommandLine);
  LExecInfo.lpDirectory := nil;
  LExecInfo.nShow := SW_HIDE;
  LExecInfo.hInstApp := 0;

  ShellExecuteEx(@LExecInfo);
  WaitForSingleObject(LExecInfo.hProcess,INFINITE);
  GetExitCodeProcess(LExecInfo.hProcess, Result);
  CloseHandle(LExecInfo.hProcess);

  if TFile.Exists(FLogFile) then
  begin
    Log.LoadFromFile(FLogFile);
    TFile.Delete(FLogFile);
  end;
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

function TDNMSBuildCompiler.GetVersion: TCompilerVersion;
var
  LPos: Integer;
  LValue: string;
  LSettings: TFormatSettings;
const
  CWin32Compiler = 'dcc32.exe';
  CCommandLine = 'cmd.exe /c ""%s" --version > "%s""';
begin
  if FVersion = 0 then
  begin
    FVersion := -1;
    if Execute(Format(CCommandLine, [TPath.Combine(FEmbarcaderoBinFolder, CWin32Compiler), FLogFile])) = 0 then
    begin
      if (Log.Count > 0) then
      begin
        LPos := Pos(') ', Log[0]);
        if LPos > 1 then
        begin
          LValue := Copy(Log[0], LPos + 2, Length(Log[0]));
          LSettings := TFormatSettings.Create();
          LSettings.DecimalSeparator := '.';
          FVersion := StrToFloatDef(LValue, -1, LSettings);
        end;
      end;
    end;
  end;
  Result := FVersion;
end;

end.
