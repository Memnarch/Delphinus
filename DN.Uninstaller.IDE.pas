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
  DN.Uninstaller;

type
  TDNIDEUninstaller = class(TDNUninstaller)
  protected
    function RemoveSearchPath(const ASearchPath: string): Boolean; override;
    function RemoveBrowsingPath(const ABrowsingPath: string): Boolean; override;
    function UninstallPackage(const ABPLFile: string): Boolean; override;
  public
    function Uninstall(const ADirectory: string): Boolean; override;
  end;

implementation

uses
  Registry,
  SysUtils,
  StrUtils,
  Windows,
  ToolsApi,
  DN.Types,
  DN.ToolsApi.Extension.Intf,
  DN.Compiler.Intf;

{ TDNIDEUninstaller }

function TDNIDEUninstaller.RemoveBrowsingPath(
  const ABrowsingPath: string): Boolean;
var
  LService: IDNEnvironmentOptionsService;
  LOption: IDNEnvironmentOptions;
  LPlatform: TDNCompilerPlatform;
  LPathes: TStringDynArray;
  LPath: string;
  LPathStr: string;
begin
  inherited;
  Result := False;
  LService := GDelphinusIDEservices as IDNEnvironmentOptionsService;
  for LPlatform in LService.SupportedPlatforms do
  begin
    LOption := LService.Options[LPlatform];
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
  LService: IDNEnvironmentOptionsService;
  LOption: IDNEnvironmentOptions;
  LPlatform: TDNCompilerPlatform;
  LPathes: TStringDynArray;
  LPath: string;
  LPathStr: string;
begin
  inherited;
  Result := False;
  LService := GDelphinusIDEservices as IDNEnvironmentOptionsService;
  for LPlatform in LService.SupportedPlatforms do
  begin
    LOption := LService.Options[LPlatform];
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
var
  LService: IDNEnvironmentOptionsService;
begin
  LService := GDelphinusIDEServices as IDNEnvironmentOptionsService;
  LService.BeginUpdate();
  try
    Result := inherited;
  finally
    LService.EndUpdate;
  end;
end;

function TDNIDEUninstaller.UninstallPackage(const ABPLFile: string): Boolean;
var
  LService: IOTAPackageServices;
  LPackage: string;
  LResult: Boolean;
begin
  TThread.Synchronize(nil,
  procedure
  var
    i: Integer;
  begin
    LService := BorlandIDEServices as IOTAPackageServices;
    LResult := LService.UninstallPackage(ABPLFile);
    if not LResult then
    begin
      LResult := True;
      LPackage := ExtractFileName(ABPLFile);
      for i := 0 to LService.PackageCount - 1 do
      begin
        if SameText(LService.Package[i].Name, LPackage) then
        begin
          LResult := False;
          Exit;
        end;
      end;
      if LResult then
        DoMessage(mtWarning, 'Package was not installed previously');
    end
  end);
  Result := LResult;
end;

end.
