{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
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
    FLoadingError: string;
    FProjects: TList<IDNProjectInfo>;
    function GetFileName: string;
    function GetProjects: TList<IDNProjectInfo>;
    function GetLoadingError: string;
    procedure SetError(const AError: string);
  public
    constructor Create();
    destructor Destroy(); override;
    function LoadFromFile(const AFileName: string): Boolean;
    property FileName: string read GetFileName;
    property Projects: TList<IDNProjectInfo> read GetProjects;
    property LoadingError: string read GetLoadingError;
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

function TDNProjectGroupInfo.GetLoadingError: string;
begin
  Result := FLoadingError;
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
  LBasePath, LProjectFile: string;
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
          LProjectFile := TPath.Combine(LBasePath, LProjects.Attributes['Include']);
          if not LProject.LoadFromFile(LProjectFile) then
          begin
            SetError('Could not load Project ' + LProjectFile + ' Reason: ' + LProject.LoadingError);
            Exit;
          end;

          FProjects.Add(LProject);
          LProjects := LProjects.NextSibling;
        end;
        Result := True;
      end
      else
      begin
        SetError('ItemGroup-Node not found');
      end;
    end
    else
    begin
      SetError('Project-Node not found');
    end;
  end
  else
  begin
    SetError('File does not exist');
  end;
end;

procedure TDNProjectGroupInfo.SetError(const AError: string);
begin
  FLoadingError := AError;
end;

end.
