{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Uninstaller.IDE;

interface

uses
  Classes,
  Types,
  DN.Uninstaller,
  DN.ExpertService.Intf,
  DN.FileService.Intf,
  DN.EnvironmentOptions.Intf,
  DN.BPLService.Intf;

type
  TDNIDEUninstaller = class(TDNUninstaller)
  private
    FEnvironmentOptionsService: IDNEnvironmentOptionsService;
    FBPLService: IDNBPLService;
  protected
    function RemoveSearchPath(const ASearchPath: string): Boolean; override;
    function RemoveBrowsingPath(const ABrowsingPath: string): Boolean; override;
    function UninstallPackage(const ABPLFile: string): Boolean; override;
  public
    constructor Create(
      const AEnvironmentOptionsService: IDNEnvironmentOptionsService;
      const ABPLService: IDNBPLService;
      const AExpertService: IDNExpertService = nil;
      const AFileService: IDNFileService = nil);
    function Uninstall(const ADirectory: string): Boolean; override;
  end;

implementation

uses
  Registry,
  SysUtils,
  StrUtils,
  Windows,
  DN.Types,
  DN.Compiler.Intf;

{ TDNIDEUninstaller }

constructor TDNIDEUninstaller.Create(
  const AEnvironmentOptionsService: IDNEnvironmentOptionsService;
  const ABPLService: IDNBPLService;
  const AExpertService: IDNExpertService;
  const AFileService: IDNFileService);
begin
  inherited Create(AExpertService, AFileService);
  FEnvironmentOptionsService := AEnvironmentOptionsService;
  FBPLService := ABPLService;
end;

function TDNIDEUninstaller.RemoveBrowsingPath(
  const ABrowsingPath: string): Boolean;
var
  LOption: IDNEnvironmentOptions;
  LPlatform: TDNCompilerPlatform;
  LPathes: TStringDynArray;
  LPath: string;
  LPathStr: string;
begin
  inherited;
  Result := False;
  for LPlatform in FEnvironmentOptionsService.SupportedPlatforms do
  begin
    LOption := FEnvironmentOptionsService.Options[LPlatform];
    LPathes := SplitString(LOption.BrowingPath, ';');
    LPathStr := '';
    for LPath in LPathes do
    begin
      if LPath <> ABrowsingPath then
        if LPathStr <> '' then
          LPathStr := LPathStr + ';' + LPath
        else
          LPathStr := LPath;
    end;
    LOption.BrowingPath := LPathStr;
    Result := True;
  end;
end;

function TDNIDEUninstaller.RemoveSearchPath(const ASearchPath: string): Boolean;
var
  LOption: IDNEnvironmentOptions;
  LPlatform: TDNCompilerPlatform;
  LPathes: TStringDynArray;
  LPath: string;
  LPathStr: string;
begin
  inherited;
  Result := False;
  for LPlatform in FEnvironmentOptionsService.SupportedPlatforms do
  begin
    LOption := FEnvironmentOptionsService.Options[LPlatform];
    LPathes := SplitString(LOption.SearchPath, ';');
    LPathStr := '';
    for LPath in LPathes do
    begin
      if LPath <> ASearchPath then
        if LPathStr <> '' then
          LPathStr := LPathStr + ';' + LPath
        else
          LPathStr := LPath;
    end;
    LOption.SearchPath := LPathStr;
    Result := True;
  end;
end;

function TDNIDEUninstaller.Uninstall(const ADirectory: string): Boolean;
begin
  FEnvironmentOptionsService.BeginUpdate();
  try
    Result := inherited;
  finally
    FEnvironmentOptionsService.EndUpdate;
  end;
end;

function TDNIDEUninstaller.UninstallPackage(const ABPLFile: string): Boolean;
begin
  Result := FBPLService.Uninstall(ABPLFile);
end;

end.
