unit DN.Compiler.IDE;

interface

uses
  DN.Compiler,
  ToolsApi;

type
  TDNIDECompiler = class(TDNCompiler)
  protected
    procedure ConfigureProject(const AProject: IOTAProject);
    function GetVersion: Single; override;
  public
    function Compile(const AProjectFile: string): Boolean; override;
  end;

implementation

uses
  Classes,
  SysUtils,
  DCCStrs,
  DN.Compiler.Intf;

{ TDNIDECompiler }

function TDNIDECompiler.Compile(const AProjectFile: string): Boolean;
var
  LActions: IOTAActionServices;
  LModuleService: IOTAModuleServices;
  LCompiler: IOTACompileServices;
  LProject: IOTAProject;
  LAsyncResult: Boolean;
begin
  TThread.Synchronize(nil, procedure
  var
    i: Integer;
  begin
    LAsyncResult := False;
    LActions := BorlandIDEServices as IOTAActionServices;
    if LActions.OpenProject(AProjectFile, False) then
    begin
      LModuleService := BorlandIDEServices as IOTAModuleServices;
      LCompiler := BorlandIDEServices as IOTACompileServices;
      for i := 0 to LModuleService.MainProjectGroup.ProjectCount - 1 do
        if SameText(AProjectFile, LModuleService.MainProjectGroup.Projects[i].FileName) then
        begin
          LProject := LModuleService.MainProjectGroup.Projects[i];
          Break;
        end;

      if Assigned(LProject) then
      begin
        try
          ConfigureProject(LProject);
          LAsyncResult := LCompiler.CompileProjects([LProject], cmOTABuild, False, False) = crOTASucceeded;
        finally
          LProject.CloseModule(True);
        end;
      end;
    end;
  end);
  Result := LAsyncResult;
end;

procedure TDNIDECompiler.ConfigureProject(const AProject: IOTAProject);
var
  LBuildConfig: IOTAProjectOptionsConfigurations;
begin
  {$if CompilerVersion >= 24} //XE3 or higher
    AProject.CurrentConfiguration := TDNCompilerConfigName[Config];
    AProject.CurrentPlatform := TDNCompilerPlatformName[Platform];
  {$IfEnd}
  LBuildConfig := AProject.ProjectOptions as IOTAProjectOptionsConfigurations;
  LBuildConfig.ActiveConfiguration.Value[DCCStrs.sExeOutput] := EXEOutput;
  LBuildConfig.ActiveConfiguration.Value[DCCStrs.sBplOutput] := BPLOutput;
  LBuildConfig.ActiveConfiguration.Value[DCCStrs.sDcpOutput] := DCPOutput;
  LBuildConfig.ActiveConfiguration.Value[DCCStrs.sDcuOutput] := DCUOutput;
end;

function TDNIDECompiler.GetVersion: Single;
begin
  Result := CompilerVersion;
end;

end.
