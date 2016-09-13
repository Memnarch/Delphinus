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
  DN.Compiler.Intf,
  DN.ExpertService.Intf,
  DN.EnvironmentOptions.Intf,
  DN.BPLService.Intf,
  DN.VariableResolver.Compiler.Factory;

type
  TDNIDEInstaller = class(TDNInstaller)
  private
    FEnvironmentOptionsService: IDNEnvironmentOptionsService;
    FBPLService: IDNBPLService;
  protected
    procedure AddSearchPath(const ASearchPath: string; const APlatforms: TDNCompilerPlatforms); override;
    procedure AddBrowsingPath(const ABrowsingPath: string; const APlatforms: TDNCompilerPlatforms); override;
    function InstallBPL(const ABPL: string): Boolean; override;
    function GetSupportedPlatforms: TDNCompilerPlatforms; override;
    function GetBPLDir(APlatform: TDNCompilerPlatform): string; override;
    function GetDCPDir(APlatform: TDNCompilerPlatform): string; override;
  public
    constructor Create(const ACompiler: IDNCompiler;
      const AEnvironmentOptionsService: IDNEnvironmentOptionsService;
      const ABPLService: IDNBPLService;
      const AVariableResolverFactory: TDNCompilerVariableResolverFacory;
      const AExpertService: IDNExpertService = nil);
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
  DN.Types;

{ TDNIDEInstaller }

procedure TDNIDEInstaller.AddBrowsingPath(const ABrowsingPath: string;
  const APlatforms: TDNCompilerPlatforms);
var
  LPlatform: TDNCompilerPlatform;
  LPathes: string;
  LLines: TStringList;
begin
  inherited;
  LLines := TStringList.Create();
  try
    LLines.LineBreak := ';';
    for LPlatform in APlatforms do
    begin
      if LPlatform in FEnvironmentOptionsService.SupportedPlatforms then
      begin
        LPathes := FEnvironmentOptionsService.Options[LPlatform].BrowingPath;
        LLines.Text := LPathes;
        if LLines.IndexOf(ABrowsingPath) < 0 then
        begin
          if LPathes <> '' then
            LPathes := LPathes + ';' + ABrowsingPath
          else
            LPathes := ABrowsingPath;

          FEnvironmentOptionsService.Options[LPlatform].BrowingPath := LPathes;
        end;
      end;
    end;
  finally
    LLines.Free;
  end;
end;

procedure TDNIDEInstaller.AddSearchPath(const ASearchPath: string; const APlatforms: TDNCompilerPlatforms);
var
  LPlatform: TDNCompilerPlatform;
  LPathes: string;
  LLines: TStringList;
begin
  inherited;
  LLines := TStringList.Create();
  try
    LLines.LineBreak := ';';
    for LPlatform in APlatforms do
    begin
      if LPlatform in FEnvironmentOptionsService.SupportedPlatforms then
      begin
        LPathes := FEnvironmentOptionsService.Options[LPlatform].SearchPath;
        LLines.Text := LPathes;
        if LLines.IndexOf(ASearchPath) < 0 then
        begin
          if LPathes <> '' then
            LPathes := LPathes + ';' + ASearchPath
          else
            LPathes := ASearchPath;

          FEnvironmentOptionsService.Options[LPlatform].SearchPath := LPathes;
        end;
      end;
    end;
  finally
    LLines.Free;
  end;
end;

constructor TDNIDEInstaller.Create(const ACompiler: IDNCompiler;
  const AEnvironmentOptionsService: IDNEnvironmentOptionsService;
  const ABPLService: IDNBPLService;
  const AVariableResolverFactory: TDNCompilerVariableResolverFacory;
  const AExpertService: IDNExpertService);
begin
  inherited Create(ACompiler, AVariableResolverFactory, AExpertService);
  FEnvironmentOptionsService := AEnvironmentOptionsService;
  FBPLService := ABPLService;
end;

function TDNIDEInstaller.GetBPLDir(APlatform: TDNCompilerPlatform): string;
begin
  Result := FEnvironmentOptionsService.Options[APlatform].BPLOutput;
end;

function TDNIDEInstaller.GetDCPDir(APlatform: TDNCompilerPlatform): string;
begin
  Result := FEnvironmentOptionsService.Options[APlatform].DCPOutput;
end;

function TDNIDEInstaller.GetSupportedPlatforms: TDNCompilerPlatforms;
begin
  Result := FEnvironmentOptionsService.SupportedPlatforms;
end;

function TDNIDEInstaller.Install(const ASourceDirectory,
  ATargetDirectory: string): Boolean;
begin
  FEnvironmentOptionsService.BeginUpdate();
  try
    Result := inherited;
  finally
    FEnvironmentOptionsService.EndUpdate();
  end;
end;

function TDNIDEInstaller.InstallBPL(const ABPL: string): Boolean;
begin
  Result := FBPLService.Install(ABPL);
end;

end.
