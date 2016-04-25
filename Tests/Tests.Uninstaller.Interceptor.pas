unit Tests.Uninstaller.Interceptor;

interface

uses
  Generics.Collections,
  DN.Uninstaller,
  DN.JSonFile.Uninstallation,
  DN.ToolsAPi.ExpertService.Intf,
  DN.FileService.Intf;

type
  TDNUninstallerInterceptor = class(TDNUninstaller)
  private
    FUninstallResourceName: string;
    FUninstalledPackages: TList<string>;
    FRemovedBrowsingPathes: TList<string>;
    FDeletedRawFiles: TList<string>;
    FRemovedSearchPathes: TList<string>;
    FUninstalledExperts: TList<TInstalledExpert>;
    FDeletedComponentFiles: TList<string>;
    FDeletedDirectories: TList<string>;
  protected
    function LoadUninstall(const ADirectory: string; AUninstall: TUninstallationFile): Boolean; override;
    function DeleteFiles(const ADirectory: string): Boolean; override;
    function DeleteRawFiles(const ARawFiles: TArray<string>): Boolean; override;
    function DeleteComponentFile(const AFile: string; const AWarningWhenMissing: Boolean = True): Boolean; override;
    function UninstallPackage(const ABPLFile: string): Boolean; override;
    function UninstallExpert(const AExpert: string; AHotReload: Boolean): Boolean; override;
    function RemoveSearchPath(const ASearchPath: string): Boolean; override;
    function RemoveBrowsingPath(const ABrowsingPath: string): Boolean; override;
  public
    constructor Create(const AExpertService: IDNExpertService = nil;
      const AFileService: IDNFileService = nil);
    destructor Destroy; override;
    property UninstallResourceName: string read FUninstallResourceName write FUninstallResourceName;
    property DeletedDirectories: TList<string> read FDeletedDirectories;
    property DeletedRawFiles: TList<string> read FDeletedRawFiles;
    property DeletedComponentFiles: TList<string> read FDeletedComponentFiles;
    property UninstalledPackages: TList<string> read FUninstalledPackages;
    property UninstalledExperts: TList<TInstalledExpert> read FUninstalledExperts;
    property RemovedSearchPathes: TList<string> read FRemovedSearchPathes;
    property RemovedBrowsingPathes: TList<string> read FRemovedBrowsingPathes;
  end;

implementation

uses
  Classes,
  Types;

{ TDNUninstallerInterceptor }

constructor TDNUninstallerInterceptor.Create(
  const AExpertService: IDNExpertService; const AFileService: IDNFileService);
begin
  inherited;
  FUninstalledPackages := TList<string>.Create();
  FRemovedBrowsingPathes := TList<string>.Create();
  FDeletedRawFiles := TList<string>.Create();
  FRemovedSearchPathes := TList<string>.Create();
  FUninstalledExperts := TList<TInstalledExpert>.Create();
  FDeletedComponentFiles := TList<string>.Create();
  FDeletedDirectories := TList<string>.Create();
end;

function TDNUninstallerInterceptor.DeleteComponentFile(const AFile: string;
  const AWarningWhenMissing: Boolean): Boolean;
begin
  FDeletedComponentFiles.Add(AFile);
  Result := True;
end;

function TDNUninstallerInterceptor.DeleteFiles(
  const ADirectory: string): Boolean;
begin
  FDeletedDirectories.Add(ADirectory);
  Result := True;
end;

function TDNUninstallerInterceptor.DeleteRawFiles(
  const ARawFiles: TArray<string>): Boolean;
begin
  FDeletedRawFiles.AddRange(ARawFiles);
  Result := True;
end;

destructor TDNUninstallerInterceptor.Destroy;
begin
  FUninstalledPackages.Free();
  FRemovedBrowsingPathes.Free();
  FDeletedRawFiles.Free();
  FRemovedSearchPathes.Free();
  FUninstalledExperts.Free();
  FDeletedComponentFiles.Free();
  FDeletedDirectories.Free();
  inherited;
end;

function TDNUninstallerInterceptor.LoadUninstall(const ADirectory: string;
  AUninstall: TUninstallationFile): Boolean;
var
  LRes: TResourceStream;
  LText: TStringList;
begin
  LRes := TResourceStream.Create(HInstance, FUninstallResourceName, RT_RCDATA);
  try
    LText := TStringList.Create();
    try
      LText.LoadFromStream(LRes);
      Result := AUninstall.LoadFromString(LText.Text);
    finally
      LText.Free;
    end;
  finally
    LRes.Free;
  end;
end;

function TDNUninstallerInterceptor.RemoveBrowsingPath(
  const ABrowsingPath: string): Boolean;
begin
  FRemovedBrowsingPathes.Add(ABrowsingPath);
  Result := True;
end;

function TDNUninstallerInterceptor.RemoveSearchPath(
  const ASearchPath: string): Boolean;
begin
  FRemovedSearchPathes.Add(ASearchPath);
  Result := True;
end;

function TDNUninstallerInterceptor.UninstallExpert(const AExpert: string;
  AHotReload: Boolean): Boolean;
var
  LExpert: TInstalledExpert;
begin
  LExpert.Expert := AExpert;
  LExpert.HotReload := AHotReload;
  FUninstalledExperts.Add(LExpert);
  Result := True;
end;

function TDNUninstallerInterceptor.UninstallPackage(
  const ABPLFile: string): Boolean;
begin
  FUninstalledPackages.Add(ABPLFile);
  Result := True;
end;

end.
