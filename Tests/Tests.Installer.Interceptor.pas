unit Tests.Installer.Interceptor;

interface

uses
  Classes,
  Types,
  Generics.Collections,
  DN.Installer,
  DN.JSonFile.Installation,
  DN.JSonFile.Uninstallation,
  DN.JSonFile.Info,
  DN.Compiler.Intf,
  DN.ProjectInfo.Intf,
  DN.ProjectGroupInfo.Intf,
  DN.ToolsApi.ExpertService.Intf;

type
  TMockedDirectory = record
    Source: string;
    Target: string;
    FileFilters: TStringDynArray;
    Recursive: Boolean;
  end;

  TDNInstallerInterceptor = class(TDNInstaller)
  private
    FInstallationResourceName: string;
    FInfoResourceName: string;
    FSupportedPlatforms: TDNCompilerPlatforms;
    FMockedGroupProjects: TDictionary<string, IDNProjectGroupInfo>;
    FMockedProjects: TDictionary<string, IDNProjectInfo>;
    FCopiedDirectories: TList<TMockedDirectory>;
  //since i made protected field public, ctrl+shift+c will duplicate them
  //so we add a second private section which is where those fields will end
  //easier for removing them each time
  private
  protected
    function LoadInstallation(const ADirectory: string;
      AInstallation: TInstallationFile): Boolean; override;
    procedure CopyDirectory(const ASource: string; const ATarget: string;
      AFileFilters: TStringDynArray; ARecursive: Boolean = False;
      ACopiedFiles: TStringList = nil); override;
    procedure AddBrowsingPath(const ABrowsingPath: string;
      const APlatforms: TDNCompilerPlatforms); override;
    procedure AddSearchPath(const ASearchPath: string;
      const APlatforms: TDNCompilerPlatforms); override;
    procedure CopyLicense(const ASourceDirectory: string;
      const ATargetDirectory: string; const ALicense: string); override;
    function CopyMetaData(const ASourceDirectory: string;
      const ATargetDirectory: string): Boolean; override;
    function InstallBPL(const ABPL: string): Boolean; override;
    function InstallExpert(const AExpert: string; AHotReload: Boolean): Boolean;
      override;
    function PrepareInstallationDirectory(const ATargetDirectory: string): Boolean;
      override;
    procedure SaveUninstall(const ATargetDirectory: string); override;
    function LoadInfo(const ADirectory: string; AInfo: TInfoFile): Boolean; override;
    function GetSupportedPlatforms: TDNCompilerPlatforms; override;
    function GetBPLDir(APlatform: TDNCompilerPlatform): string; override;
    function GetDCPDir(APlatform: TDNCompilerPlatform): string; override;
    function LoadProject(const AProjectFile: string;
      out AProject: IDNProjectInfo): Boolean; override;
    function LoadProjectGroup(const AGroupFile: string;
      out AGroup: IDNProjectGroupInfo): Boolean; override;
  public
    constructor Create(const ACompiler: IDNCompiler; const AExpertService: IDNExpertService = nil);
    destructor Destroy; override;
    property SearchPathes: string read FSearchPathes;
    property BrowsingPathes: string read FBrowsingPathes;
    property Packages: TList<TPackage> read FPackages;
    property RawFiles: TStringList read FRawFiles;
    property Experts: TList<TInstalledExpert> read FExperts;
    property InfoResourceName: string read FInfoResourceName write FInfoResourceName;
    property InstallResourceName: string read FInstallationResourceName write FInstallationResourceName;
    property SupportedPlatforms: TDNCompilerPlatforms read GetSupportedPlatforms write FSupportedPlatforms;
    property MockedProjects: TDictionary<string, IDNProjectInfo> read FMockedProjects;
    property MockedGroupProjects: TDictionary<string, IDNProjectGroupInfo> read FMockedGroupProjects;
    property CopiedDirectories: TList<TMockedDirectory> read FCopiedDirectories;
  end;

implementation

{ TDNInstallerInterceptor }

procedure TDNInstallerInterceptor.AddBrowsingPath(const ABrowsingPath: string;
  const APlatforms: TDNCompilerPlatforms);
begin
  inherited;
end;

procedure TDNInstallerInterceptor.AddSearchPath(const ASearchPath: string;
  const APlatforms: TDNCompilerPlatforms);
begin
  inherited;
end;

procedure TDNInstallerInterceptor.CopyDirectory(const ASource, ATarget: string;
  AFileFilters: TStringDynArray; ARecursive: Boolean;
  ACopiedFiles: TStringList);
var
  LDir: TMockedDirectory;
begin
  LDir.Source := ASource;
  LDir.Target := ATarget;
  LDir.FileFilters := AFileFilters;
  LDir.Recursive := ARecursive;
  FCopiedDirectories.Add(LDir);
end;

procedure TDNInstallerInterceptor.CopyLicense(const ASourceDirectory,
  ATargetDirectory, ALicense: string);
begin

end;

function TDNInstallerInterceptor.CopyMetaData(const ASourceDirectory,
  ATargetDirectory: string): Boolean;
begin
  Result := True;
end;

constructor TDNInstallerInterceptor.Create(const ACompiler: IDNCompiler;
  const AExpertService: IDNExpertService);
begin
  inherited Create(ACompiler, AExpertService);
  FMockedGroupProjects := TDictionary<string, IDNProjectGroupInfo>.Create();
  FMockedProjects := TDictionary<string, IDNProjectInfo>.Create();
  FCopiedDirectories := TList<TMockedDirectory>.Create();
end;

destructor TDNInstallerInterceptor.Destroy;
begin
  FMockedGroupProjects.Free;
  FMockedProjects.Free;
  FCopiedDirectories.Free;
  inherited;
end;

function TDNInstallerInterceptor.GetBPLDir(
  APlatform: TDNCompilerPlatform): string;
begin
  Result := 'BPLDIR';
end;

function TDNInstallerInterceptor.GetDCPDir(
  APlatform: TDNCompilerPlatform): string;
begin
  Result := 'DCPDIR';
end;

function TDNInstallerInterceptor.GetSupportedPlatforms: TDNCompilerPlatforms;
begin
  Result := FSupportedPlatforms;
end;

function TDNInstallerInterceptor.InstallBPL(const ABPL: string): Boolean;
begin
  Result := True;
end;

function TDNInstallerInterceptor.InstallExpert(const AExpert: string;
  AHotReload: Boolean): Boolean;
begin
  Result := True;
end;

function TDNInstallerInterceptor.LoadInfo(const ADirectory: string;
  AInfo: TInfoFile): Boolean;
var
  LResource: TResourceStream;
  LText: TStringList;
begin
  LResource := TResourceStream.Create(HInstance, FInfoResourceName, RT_RCDATA);
  try
    LText := TStringList.Create();
    try
      LText.LoadFromStream(LResource);
      Result := AInfo.LoadFromString(LText.Text);
    finally
      LText.Free;
    end;
  finally
    LResource.Free;
  end;
end;

function TDNInstallerInterceptor.LoadInstallation(const ADirectory: string;
  AInstallation: TInstallationFile): Boolean;
var
  LResource: TResourceStream;
  LText: TStringList;
begin
  LResource := TResourceStream.Create(HInstance, FInstallationResourceName, RT_RCDATA);
  try
    LText := TStringList.Create();
    try
      LText.LoadFromStream(LResource);
      Result := AInstallation.LoadFromString(LText.Text);
    finally
      LText.Free;
    end;
  finally
    LResource.Free;
  end;
end;

function TDNInstallerInterceptor.LoadProject(const AProjectFile: string;
  out AProject: IDNProjectInfo): Boolean;
begin
  Result := FMockedProjects.TryGetValue(AProjectFile, AProject);
end;

function TDNInstallerInterceptor.LoadProjectGroup(const AGroupFile: string;
  out AGroup: IDNProjectGroupInfo): Boolean;
begin
  Result := FMockedGroupProjects.TryGetValue(AGroupFile, AGroup);
end;

function TDNInstallerInterceptor.PrepareInstallationDirectory(
  const ATargetDirectory: string): Boolean;
begin
  Result := True;
end;

procedure TDNInstallerInterceptor.SaveUninstall(const ATargetDirectory: string);
begin

end;

end.
