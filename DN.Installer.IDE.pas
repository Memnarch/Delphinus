{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Installer.IDE;

interface

uses
  Classes,
  Types,
  DN.Installer,
  DN.ProjectInfo.Intf,
  DN.Compiler.Intf;

type
  TDNIDEInstaller = class(TDNInstaller)
  protected
    procedure AddSearchPath(const ASearchPath: string; const APlatforms: TDNCompilerPlatforms); override;
    procedure AddBrowsingPath(const ABrowsingPath: string; const APlatforms: TDNCompilerPlatforms); override;
    function InstallProject(const AProject: IDNProjectInfo; const ABPLDirectory: string): Boolean; override;
    function GetSupportedPlatforms: TDNCompilerPlatforms; override;
    procedure ConfigureCompiler(const ACompiler: IDNCompiler); override;
  public
    function Install(const ASourceDirectory: string;
      const ATargetDirectory: string): Boolean; override;
  end;

implementation

uses
  Windows,
  SysUtils,
  IOUtils,
  StrUtils,
  Registry,
  DN.Types,
  ToolsApi,
  DN.ToolsApi.Extension.Intf;

{ TDNIDEInstaller }

procedure TDNIDEInstaller.AddBrowsingPath(const ABrowsingPath: string;
  const APlatforms: TDNCompilerPlatforms);
var
  LService: IDNEnvironmentOptionsService;
  LPlatform: TDNCompilerPlatform;
  LPathes: string;
  LLines: TStringList;
begin
  inherited;
  LLines := TStringList.Create();
  try
    LLines.LineBreak := ';';
    LService := GDelphinusIDEServices as IDNEnvironmentOptionsService;
    for LPlatform in APlatforms do
    begin
      if LPlatform in LService.SupportedPlatforms then
      begin
        LPathes := LService.Options[LPlatform].BrowingPath;
        LLines.Text := LPathes;
        if LLines.IndexOf(ABrowsingPath) < 0 then
        begin
          if LPathes <> '' then
            LPathes := LPathes + ';' + ABrowsingPath
          else
            LPathes := ABrowsingPath;

          LService.Options[LPlatform].BrowingPath := LPathes;
        end;
      end;
    end;
  finally
    LLines.Free;
  end;
end;

procedure TDNIDEInstaller.AddSearchPath(const ASearchPath: string; const APlatforms: TDNCompilerPlatforms);
var
  LService: IDNEnvironmentOptionsService;
  LPlatform: TDNCompilerPlatform;
  LPathes: string;
  LLines: TStringList;
begin
  inherited;
  LLines := TStringList.Create();
  try
    LLines.LineBreak := ';';
    LService := GDelphinusIDEServices as IDNEnvironmentOptionsService;
    for LPlatform in APlatforms do
    begin
      if LPlatform in LService.SupportedPlatforms then
      begin
        LPathes := LService.Options[LPlatform].SearchPath;
        LLines.Text := LPathes;
        if LLines.IndexOf(ASearchPath) < 0 then
        begin
          if LPathes <> '' then
            LPathes := LPathes + ';' + ASearchPath
          else
            LPathes := ASearchPath;

          LService.Options[LPlatform].SearchPath := LPathes;
        end;
      end;
    end;
  finally
    LLines.Free;
  end;
end;

procedure TDNIDEInstaller.ConfigureCompiler(const ACompiler: IDNCompiler);
var
  LOptions: IDNEnvironmentOptions;
begin
  inherited;
  LOptions := (GDelphinusIDEServices as IDNEnvironmentOptionsService).Options[ACompiler.Platform];
  ACompiler.BPLOutput := LOptions.BPLOutput;
  ACompiler.DCPOutput := LOptions.DCPOutput;
end;

function TDNIDEInstaller.GetSupportedPlatforms: TDNCompilerPlatforms;
begin
  Result := (GDelphinusIDEServices as IDNEnvironmentOptionsService).SupportedPlatforms;
end;

function TDNIDEInstaller.Install(const ASourceDirectory,
  ATargetDirectory: string): Boolean;
var
  LService: IDNEnvironmentOptionsService;
begin
  LService := GDelphinusIDEServices as IDNEnvironmentOptionsService;
  LService.BeginUpdate();
  try
    Result := inherited;
  finally
    LService.EndUpdate();
  end;
end;

function TDNIDEInstaller.InstallProject(const AProject: IDNProjectInfo; const ABPLDirectory: string): Boolean;
var
  LService: IOTAPackageServices;
  LResult: Boolean;
begin
  TThread.Synchronize(nil,
  procedure
  begin
    try
      LService := BorlandIDEServices as IOTAPackageServices;
      LResult := LService.InstallPackage(TPath.Combine(ABPLDirectory, AProject.BinaryName));
    except
      on E: Exception do
      begin
        LResult := False;
        DoMessage(mtError, E.Message);
      end;
    end;
  end);
  Result := LResult;
end;

end.
