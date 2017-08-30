{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.ProjectInfo;

interface

uses
  Classes,
  Types,
  SysUtils,
  XMLIntf,
  DN.ProjectInfo.Intf,
  DN.Types,
  DN.DPRProperties.Intf;

type
  TDNProjectInfo = class(TInterfacedObject, IDNProjectInfo)
  private
    FBinaryName: string;
    FDCPName: string;
    FFileName: string;
    FIsPackage: Boolean;
    FIsRuntimeOnlyPackage: Boolean;
    FSupportedPlatforms: TDNCompilerPlatforms;
    FLoadingError: string;
    function GetBinaryName: string;
    function GetDCPName: string;
    function GetIsPackage: Boolean;
    function GetDefaultExtension(const AAppType: string): string;
    function GetPropertyGroupOfConfig(const AProject: IXMLNode; const AConfig: string): IXMLNode;
    function GetIsRuntimeOnlyPackage: Boolean;
    function GetFileName: string;
    function GetSupportedPlatforms: TDNCompilerPlatforms;
    function GetLoadingError: string;
    procedure FindDLLVersionDefines(const AProject: IXMLNode; out ADLLPrefix, ADLLSuffix, ADLLVersion: string);
    procedure SetError(const AError: string);
  public
    function LoadFromFile(const AProjectFile: string): Boolean;
    function CreateDPRProperties: IDPRProperties;
    property IsPackage: Boolean read GetIsPackage;
    property IsRuntimeOnlyPackage: Boolean read GetIsRuntimeOnlyPackage;
    property BinaryName: string read GetBinaryName;
    property DCPName: string read GetDCPName;
    property FileName: string read GetFileName;
    property SupportedPlatforms: TDNCompilerPlatforms read GetSupportedPlatforms;
    property LoadingError: string read GetLoadingError;
  end;

implementation

uses
  IOUtils,
  XMLDoc,
  StrUtils,
  Variants,
  DN.DPRProperties;

const
  CPropertyGroup = 'PropertyGroup';
  CProject = 'Project';
  CCondition = '''$(%s)''!=''''';
  CBase = 'Base';
  CBaseWin32 = 'Base_Win32';
  CBaseWin64 = 'Base_Win64';


{ TDNProjectInfo }

function TDNProjectInfo.CreateDPRProperties: IDPRProperties;
begin
  if IsPackage then
    Result := TDPRProperties.Create(ChangeFileExt(FileName, '.dpk'))
  else
    Result := TDPRProperties.Create(ChangeFileExt(FileName, '.dpr'));
end;

procedure TDNProjectInfo.FindDLLVersionDefines(const AProject: IXMLNode;
  out ADLLPrefix, ADLLSuffix, ADLLVersion: string);
var
  LGroup: IXMLNode;
  LValue: string;
begin
  ADLLPrefix := '';
  ADLLSuffix := '';
  ADLLVersion := '';
  LGroup := AProject.ChildNodes.First;
  while Assigned(LGroup) do
  begin
    LValue := VarToStr(LGroup.ChildValues['DllPrefix']);
    if LValue <> '' then
      ADLLPrefix := LValue;
    LValue := VarToStr(LGroup.ChildValues['DllSuffix']);
    if LValue <> '' then
      ADLLSuffix := LValue;
    LValue := VarToStr(LGroup.ChildValues['DllVersion']);
    if LValue <> '' then
      ADLLVersion := LValue;
    LGroup := LGroup.NextSibling;
  end;
end;

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

function TDNProjectInfo.GetLoadingError: string;
begin
  Result := FLoadingError;
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

          FindDLLVersionDefines(LProject, LPrefix, LSuffix, LVersion);
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
            if Assigned(LPlatforms) then
            begin
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
                    else if SameText(LPlatform.Attributes['value'], 'Android') then
                      FSupportedPlatforms := FSupportedPlatforms + [cpAndroid]
                    else if SameText(LPlatform.Attributes['value'], 'iOSDevice32') then
                      FSupportedPlatforms := FSupportedPlatforms + [cpIOSDevice32]
                    else if SameText(LPlatform.Attributes['value'], 'iOSDevice64') then
                      FSupportedPlatforms := FSupportedPlatforms + [cpIOSDevice64]
                    else if SameText(LPlatform.Attributes['value'], 'Linux64') then
                      FSupportedPlatforms := FSupportedPlatforms + [cpLinux64]
                  end;
                end;
                LPlatform := LPlatform.NextSibling;
              end;
            end;
          end;
        end;
        if FSupportedPlatforms = [] then
          FSupportedPlatforms := [cpWin32];
        Result := True;
      end
      else
      begin
        SetError('PropertyGroup-Node not found');
      end;
    end
    else
    begin
      SetError('Project-Node not found');
    end;
  end
  else
  begin
    SetError('File not found');
  end;
end;

procedure TDNProjectInfo.SetError(const AError: string);
begin
  FLoadingError := AError;
end;

end.
