unit DN.ProjectInfo;

interface

uses
  Classes,
  Types,
  SysUtils,
  XML.XMLIntf,
  DN.ProjectInfo.Intf,
  DN.Compiler.Intf;

type
  TDNProjectInfo = class(TInterfacedObject, IDNProjectInfo)
  private
    FBinaryName: string;
    FDCPName: string;
    FFileName: string;
    FIsPackage: Boolean;
    FIsRuntimeOnlyPackage: Boolean;
    FSupportedPlatforms: TDNCompilerPlatforms;
    function GetBinaryName: string;
    function GetDCPName: string;
    function GetIsPackage: Boolean;
    function GetDefaultExtension(const AAppType: string): string;
    function GetPropertyGroupOfConfig(const AProject: IXMLNode; const AConfig: string): IXMLNode;
    function GetIsRuntimeOnlyPackage: Boolean;
    function GetFileName: string;
    function GetSupportedPlatforms: TDNCompilerPlatforms;
  public
    function LoadFromFile(const AProjectFile: string): Boolean;
    property IsPackage: Boolean read GetIsPackage;
    property IsRuntimeOnlyPackage: Boolean read GetIsRuntimeOnlyPackage;
    property BinaryName: string read GetBinaryName;
    property DCPName: string read GetDCPName;
    property FileName: string read GetFileName;
    property SupportedPlatforms: TDNCompilerPlatforms read GetSupportedPlatforms;
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
  CBase = 'Base';
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

function TDNProjectInfo.GetFileName: string;
begin
  Result := FFileName;
end;

function TDNProjectInfo.GetIsPackage: Boolean;
begin
  Result := FIsPackage;
end;

function TDNProjectInfo.GetIsRuntimeOnlyPackage: Boolean;
begin
  Result := FIsRuntimeOnlyPackage;
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

function TDNProjectInfo.GetSupportedPlatforms: TDNCompilerPlatforms;
begin
  Result := FSupportedPlatforms;
end;

function TDNProjectInfo.LoadFromFile(const AProjectFile: string): Boolean;
var
  LXML: IXMLDocument;
  LBaseName, LCoreFile, LAppType, LExtension: string;
  LPrefix, LSuffix, LVersion: string;
  LProject, LPropertyGroup, LBase: IXMLNode;
  LProjectExtension, LBorlandProject, LPlatforms, LPlatform: IXMLNode;
begin
  Result := False;
  if TFile.Exists(AProjectFile) then
  begin
    FFileName := AProjectFile;
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
          FDCPName := LBaseName + '.dcp'
        else
          FDCPName := '';

        FIsRuntimeOnlyPackage := False;
        LBase := GetPropertyGroupOfConfig(LProject, CBase);
        if Assigned(LBase) then
        begin
          FIsRuntimeOnlyPackage := StrToBool(VarToStrDef(LBase.ChildValues['RuntimeOnlyPackage'], 'False'));
          //read extensions, post/suffix and version
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
        //detect supported platforms
        FSupportedPlatforms := [];
        LProjectExtension := LProject.ChildNodes.FindNode('ProjectExtensions');
        if Assigned(LProjectExtension) then
        begin
          LBorlandProject := LProjectExtension.ChildNodes.FindNode('BorlandProject');
          if Assigned(LBorlandProject) then
          begin
            LPlatforms := LBorlandProject.ChildNodes.FindNode('Platforms');
            LPlatform := LPlatforms.ChildNodes.First;
            while Assigned(LPlatform) do
            begin
              if SameText(LPlatform.Text, 'True') then
              begin
                if LPlatform.HasAttribute('value') then
                begin
                  if SameText(LPlatform.Attributes['value'], 'Win32') then
                    FSupportedPlatforms := FSupportedPlatforms + [cpWin32]
                  else if SameText(LPlatform.Attributes['value'], 'Win64') then
                    FSupportedPlatforms := FSupportedPlatforms + [cpWin64]
                  else if SameText(LPlatform.Attributes['value'], 'OSX32') then
                    FSupportedPlatforms := FSupportedPlatforms + [cpOSX32]
                end;
              end;
              LPlatform := LPlatform.NextSibling;
            end;
          end;
        end;
        if FSupportedPlatforms = [] then
          FSupportedPlatforms := [cpWin32];
        Result := True;
      end;
    end;
  end;
end;

end.
