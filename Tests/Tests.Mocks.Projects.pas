unit Tests.Mocks.Projects;

interface

uses
  Generics.Collections,
  DN.Compiler.Intf,
  DN.ProjectInfo.Intf,
  DN.ProjectGroupInfo.Intf;

type
  TMockedProjectInfo = class(TInterfacedObject, IDNProjectInfo)
  private
    FBinaryName: string;
    FFileName: string;
    FSupportedPlatforms: TDNCompilerPlatforms;
    FLoadingError: string;
    FIsPackage: Boolean;
    FDCPName: string;
    FIsRuntimeOnlyPackage: Boolean;
    function GetBinaryName: string;
    function GetDCPName: string;
    function GetFileName: string;
    function GetIsPackage: Boolean;
    function GetIsRuntimeOnlyPackage: Boolean;
    function GetLoadingError: string;
    function GetSupportedPlatforms: TDNCompilerPlatforms;
  public
    function LoadFromFile(const AProjectFile: string): Boolean;
    property IsPackage: Boolean read GetIsPackage write FIsPackage;
    property IsRuntimeOnlyPackage: Boolean read GetIsRuntimeOnlyPackage write FIsRuntimeOnlyPackage;
    property BinaryName: string read GetBinaryName write FBinaryName;
    property DCPName: string read GetDCPName write FDCPName;
    property FileName: string read GetFileName write FFileName;
    property SupportedPlatforms: TDNCompilerPlatforms read GetSupportedPlatforms write FSupportedPlatforms;
    property LoadingError: string read GetLoadingError write FLoadingError;
  end;

  TMockedGroupProjectInfo = class(TInterfacedObject, IDNProjectGroupInfo)
  private
    FFileName: string;
    FLoadingError: string;
    FProjects: TList<IDNProjectInfo>;
    function GetFileName: string;
    function GetLoadingError: string;
    function GetProjects: TList<IDNProjectInfo>;
  public
    constructor Create;
    destructor Destroy; override;
    function LoadFromFile(const AFileName: string): Boolean;
    property FileName: string read GetFileName write FFileName;
    property Projects: TList<IDNProjectInfo> read GetProjects;
    property LoadingError: string read GetLoadingError write FLoadingError;
  end;

  function MockProjectExe(const AName: string; APlatforms: TDNCompilerPlatforms): IDNProjectInfo;
  function MockProjectBPL(const AName: string; APlatforms: TDNCompilerPlatforms; ADesignTime: Boolean): IDNProjectInfo;
  function MockGroupProject(const AName: string; AProjects: array of IDNProjectInfo): IDNProjectGroupInfo;

implementation

//factory functions
function MockProjectExe(const AName: string; APlatforms: TDNCompilerPlatforms): IDNProjectInfo;
var
  LProject: TMockedProjectInfo;
begin
  LProject := TMockedProjectInfo.Create();
  LProject.FBinaryName := AName + '.exe';
  LProject.FFileName := AName + '.dproj';
  LProject.FSupportedPlatforms := APlatforms;
  Result := LProject;
end;

function MockProjectBPL(const AName: string; APlatforms: TDNCompilerPlatforms; ADesignTime: Boolean): IDNProjectInfo;
var
  LProject: TMockedProjectInfo;
begin
  LProject := TMockedProjectInfo.Create();
  LProject.FBinaryName := AName + '.bpl';
  LProject.FFileName := AName + '.dproj';
  LProject.FSupportedPlatforms := APlatforms;
  LProject.FIsPackage := True;
  LProject.FIsRuntimeOnlyPackage := not ADesignTime;
  LProject.FDCPName := AName + '.dcp';
  Result := LProject;
end;

function MockGroupProject(const AName: string; AProjects: array of IDNProjectInfo): IDNProjectGroupInfo;
var
  LGroup: TMockedGroupProjectInfo;
begin
  LGroup := TMockedGroupProjectInfo.Create();
  LGroup.FFileName := AName + '.groupproj';
  LGroup.FProjects.AddRange(AProjects);
  Result := LGroup;
end;

{ TMockedProjectInfo }

function TMockedProjectInfo.GetBinaryName: string;
begin
  Result := FBinaryName;
end;

function TMockedProjectInfo.GetDCPName: string;
begin
  Result := FDCPName;
end;

function TMockedProjectInfo.GetFileName: string;
begin
  Result := FFileName;
end;

function TMockedProjectInfo.GetIsPackage: Boolean;
begin
  Result := FIsPackage;
end;

function TMockedProjectInfo.GetIsRuntimeOnlyPackage: Boolean;
begin
  Result := FIsRuntimeOnlyPackage;
end;

function TMockedProjectInfo.GetLoadingError: string;
begin
  Result := FLoadingError;
end;

function TMockedProjectInfo.GetSupportedPlatforms: TDNCompilerPlatforms;
begin
  Result := FSupportedPlatforms;
end;

function TMockedProjectInfo.LoadFromFile(const AProjectFile: string): Boolean;
begin
  Result := False;
end;

{ TMockedGroupProjectInfo }

constructor TMockedGroupProjectInfo.Create;
begin
  inherited;
  FProjects := TList<IDNProjectInfo>.Create();
end;

destructor TMockedGroupProjectInfo.Destroy;
begin
  FProjects.Free;
  inherited;
end;

function TMockedGroupProjectInfo.GetFileName: string;
begin
  Result := FFileName;
end;

function TMockedGroupProjectInfo.GetLoadingError: string;
begin
  Result := FLoadingError;
end;

function TMockedGroupProjectInfo.GetProjects: TList<IDNProjectInfo>;
begin
  Result := FProjects;
end;

function TMockedGroupProjectInfo.LoadFromFile(const AFileName: string): Boolean;
begin
  Result := False;
end;

end.
