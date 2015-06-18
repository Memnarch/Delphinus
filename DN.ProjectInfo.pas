unit DN.ProjectInfo;

interface

uses
  Classes,
  Types,
  SysUtils,
  XML.XMLIntf,
  DN.ProjectInfo.Intf;

type
  TDNProjectInfo = class(TInterfacedObject, IDNProjectInfo)
  private
    FBinaryName: string;
    FDCPName: string;
    FIsPackage: Boolean;
    function GetBinaryName: string;
    function GetDCPName: string;
    function GetIsPackage: Boolean;
    function GetDefaultExtension(const AAppType: string): string;
    function GetPropertyGroupOfConfig(const AProject: IXMLNode; const AConfig: string): IXMLNode;
  public
    function LoadFromFile(const AProjectFile: string): Boolean;
    property IsPackage: Boolean read GetIsPackage;
    property BinaryName: string read GetBinaryName;
    property DCPName: string read GetDCPName;
  end;

implementation

uses
  IOUtils,
  XMLDoc,
  StrUtils,
  Variants;

const
  CPropertyGroup = 'PropertyGroup';
  CProject = 'Project';
  CCondition = '''$(%s)''!=''''';
  CBaseWin32 = 'Base_Win32';
  CBaseWin64 = 'Base_Win64';


{ TDNProjectInfo }

function TDNProjectInfo.GetBinaryName: string;
begin
  Result := FBinaryName;
end;

function TDNProjectInfo.GetDCPName: string;
begin
  Result := FDCPName;
end;

function TDNProjectInfo.GetDefaultExtension(const AAppType: string): string;
begin
  if SameText('Library', AAppType) then
    Result := '.dll'
  else if SameText('Package', AAppType) then
    Result := '.bpl'
  else
    Result := '.exe';
end;

function TDNProjectInfo.GetIsPackage: Boolean;
begin
  Result := FIsPackage;
end;

function TDNProjectInfo.GetPropertyGroupOfConfig(const AProject: IXMLNode;
  const AConfig: string): IXMLNode;
var
  LGroup: IXMLNode;
  LCondition: string;
begin
  Result := nil;
  LCondition := Format(CCondition, [AConfig]);
  LGroup := AProject.ChildNodes.First();
  while Assigned(LGroup) do
  begin
    if SameText(LGroup.LocalName, CPropertyGroup) then
    begin
      if LGroup.HasAttribute('Condition') and SameText(LGroup.Attributes['Condition'], LCondition) then
      begin
        Exit(LGroup);
      end;
    end;
    LGroup := LGroup.NextSibling;
  end;
end;

function TDNProjectInfo.LoadFromFile(const AProjectFile: string): Boolean;
var
  LXML: IXMLDocument;
  LBaseName, LCoreFile, LAppType, LExtension: string;
  LPrefix, LSuffix, LVersion: string;
  LProject, LPropertyGroup, LBase: IXMLNode;
begin
  Result := False;
  if TFile.Exists(AProjectFile) then
  begin
    LXML := TXMLDocument.Create(nil);
    LXML.LoadFromFile(AProjectFile);
    LProject := LXML.ChildNodes.FindNode(CProject);
    if Assigned(LProject) then
    begin
      LPropertyGroup := LProject.ChildNodes.FindNode(CPropertyGroup);
      if Assigned(LPropertyGroup) then
      begin
        LCoreFile := LPropertyGroup.ChildValues['MainSource'];
        LBaseName := ChangeFileExt(LCoreFile, '');
        LAppType := VarToStr(LPropertyGroup.ChildValues['AppType']);
        FIsPackage := SameText(LAppType, 'Package');
        if FIsPackage then
          FDCPName := ChangeFileExt(LBaseName, '.dcp')
        else
          FDCPName := '';
        LBase := GetPropertyGroupOfConfig(LProject, CBaseWin32);
        if Assigned(LBase) then
        begin
          LExtension := VarToStr(LBase.ChildValues['OutputExt']);
          if (LExtension <> '') and (not StartsText('.', LExtension)) then
            LExtension := '.' + LExtension;

          LPrefix := VarToStr(LBase.ChildValues['DllPrefix']);
          LSuffix := VarToStr(LBase.ChildValues['DllSuffix']);
          LVersion := VarToStr(LBase.ChildValues['DllVersion']);
          if LVersion <> '' then
            LVersion := '.' + LVersion;
        end;
        if LExtension = '' then
          LExtension := GetDefaultExtension(LAppType);

        FBinaryName := LPrefix + LBaseName + LSuffix + LVersion + LExtension;
        Result := True;
      end;
    end;
  end;
end;

end.
