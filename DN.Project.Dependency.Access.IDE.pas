unit DN.Project.Dependency.Access.IDE;

interface

uses
  ToolsApi,
  XMLIntf,
  DN.Project.Dependency.Access;

type
  TDNIDEProjectDependencyAccess = class(TDNProjectDependencyAccess)
  private
    FProject: IOTAProject;
  protected
    function GetDelphinusNode: IXMLNode; override;
    function GetReadOnlyDelphinusNode: IXMLNode; override;
  public
    constructor Create(const AProject: IOTAProject);
  end;

implementation

{ TDNIDEProjectDependencyAccess }

constructor TDNIDEProjectDependencyAccess.Create(const AProject: IOTAProject);
begin
  inherited Create();
  FProject := AProject;
end;

function TDNIDEProjectDependencyAccess.GetDelphinusNode: IXMLNode;
var
  LStorage: IOTAProjectFileStorage;
begin
  LStorage := BorlandIDEServices as IOTAProjectFileStorage;
  Result := LStorage.GetProjectStorageNode(FProject, 'Delphinus', False);
  if not Assigned(Result) then
    Result := LStorage.AddNewSection(FProject, 'Delphinus', False);
end;

function TDNIDEProjectDependencyAccess.GetReadOnlyDelphinusNode: IXMLNode;
var
  LStorage: IOTAProjectFileStorage;
begin
  LStorage := BorlandIDEServices as IOTAProjectFileStorage;
  Result := LStorage.GetProjectStorageNode(FProject, 'Delphinus', False);
end;

end.
