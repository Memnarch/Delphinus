unit DN.ProjectGroupInfo;

interface

uses
  Classes,
  Types,
  SysUtils,
  Generics.Collections,
  DN.ProjectInfo.Intf,
  DN.ProjectGroupInfo.Intf;

type
  TDNProjectGroupInfo = class(TInterfacedObject, IDNProjectGroupInfo)
  private
    FFileName: string;
    FProjects: TList<IDNProjectInfo>;
    function GetFileName: string;
    function GetProjects: TList<IDNProjectInfo>;
  public
    constructor Create();
    destructor Destroy(); override;
    function LoadFromFile(const AFileName: string): Boolean;
    property FileName: string read GetFileName;
    property Projects: TList<IDNProjectInfo> read GetProjects;
  end;

implementation

uses
  IOUtils,
  DN.ProjectInfo,
  XMLDoc,
  XMLIntf;

{ TDNProjectGroupInfo }

constructor TDNProjectGroupInfo.Create;
begin
  inherited;
  FProjects := TList<IDNProjectInfo>.Create();
end;

destructor TDNProjectGroupInfo.Destroy;
begin
  FProjects.Free;
  inherited;
end;

function TDNProjectGroupInfo.GetFileName: string;
begin
  Result := FFileName;
end;

function TDNProjectGroupInfo.GetProjects: TList<IDNProjectInfo>;
begin
  Result := FProjects;
end;

function TDNProjectGroupInfo.LoadFromFile(const AFileName: string): Boolean;
var
  LXML: IXMLDocument;
  LItemGroup, LProjects, LProjectRoot: IXMLNode;
  LProject: IDNProjectInfo;
  LBasePath: string;
begin
  Result := False;
  if TFile.Exists(AFileName) then
  begin
    FFileName := AFileName;
    LBasePath := ExtractFilePath(AFileName);
    LXML := TXMLDocument.Create(nil);
    LXML.LoadFromFile(AFileName);
    LProjectRoot := LXML.ChildNodes.FindNode('Project');
    if Assigned(LProjectRoot) then
    begin
      LItemGroup := LProjectRoot.ChildNodes.FindNode('ItemGroup');
      if Assigned(LItemGroup) then
      begin
        LProjects := LItemGroup.ChildNodes.FindNode('Projects');
        while Assigned(LProjects) do
        begin
          LProject := TDNProjectInfo.Create();
          if not LProject.LoadFromFile(TPath.Combine(LBasePath, LProjects.Attributes['Include'])) then
            Exit;

          FProjects.Add(LProject);
          LProjects := LProjects.NextSibling;
        end;
        Result := True;
      end;
    end;
  end;
end;

end.
