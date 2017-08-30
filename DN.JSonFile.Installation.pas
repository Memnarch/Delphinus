{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.JSonFile.Installation;

interface

uses
  Types,
  DN.JSon,
  DN.JSOnFile,
  DN.Types;

type
  TSearchPath = record
    Path: string;
    CompilerMin: Integer;
    CompilerMax: Integer;
    Platforms: TDNCompilerPlatforms;
  end;

  TFolder = record
    Folder: string;
    Recursive: Boolean;
    Filter: string;
    Base: string;
    CompilerMin: Integer;
    CompilerMax: Integer;
  end;

  TRawFolder = record
    Folder: string;
    CompilerMin: Integer;
    CompilerMax: Integer;
  end;

  TProject = record
    Project: string;
    CompilerMin: Integer;
    CompilerMax: Integer;
  end;

  TExpert = record
    Expert: string;
    HotReload: Boolean;
    CompilerMin: Integer;
    CompilerMax: Integer;
  end;

  TInstallationFile = class(TJSonFile)
  private
    FSourceFolders: TArray<TFolder>;
    FSearchPath: TArray<TSearchPath>;
    FProjects: TArray<TProject>;
    FBrowsingPathes: TArray<TSearchPath>;
    FRawFolders: TArray<TRawFolder>;
    FExperts: TArray<TExpert>;
  protected
    procedure LoadPathes(const ARoot: TJSONObject; const AName: string; out APathes: TArray<TSearchPath>);
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
    procedure LoadSourceFolders(const AFolders: TJSONArray);
    procedure LoadRawFolders(const ARawFolders: TJSONArray);
    procedure LoadProjects(const AProjects: TJSONArray);
    procedure LoadExperts(const AExperts: TJSonArray);
    procedure SaveSourceFolders(const AFolders: TJSONArray);
    procedure SaveRawFolders(const ARawFolders: TJSONArray);
    procedure SaveProjects(const AProjects: TJSONArray);
    procedure SaveExperts(const AExperts: TJSonArray);
    procedure SavePathes(const ARoot: TJSONArray; const APathes: TArray<TSearchPath>);
    function GetPlatforms(const APlatforms: string): TDNCompilerPlatforms;
  public
    property SearchPathes: TArray<TSearchPath> read FSearchPath write FSearchPath;
    property BrowsingPathes: TArray<TSearchPath> read FBrowsingPathes write FBrowsingPathes;
    property SourceFolders: TArray<TFolder> read FSourceFolders write FSourceFolders;
    property RawFolders: TArray<TRawFolder> read FRawFolders write FRawFolders;
    property Projects: TArray<TProject> read FProjects write FProjects;
    property Experts: TArray<TExpert> read FExperts write FExperts;
  end;

implementation

uses
  SysUtils,
  StrUtils,
  DN.Utils;

{ TInstallationFile }

function TInstallationFile.GetPlatforms(
  const APlatforms: string): TDNCompilerPlatforms;
var
  LPlatforms: TStringDynArray;
  LPlatform: string;
  LCompilerPlatform: TDNCompilerPlatform;
begin
  Result := [];
  LPlatforms := SplitString(APlatforms, ';');
  if Length(LPlatforms) > 0 then
  begin
    Result := [];
    for LPlatform in LPlatforms do
    begin
      if TryPlatformNameToCompilerPlatform(LPlatform, LCompilerPlatform) then
        Result := Result + [LCompilerPlatform];
    end;
  end;
  if Result = [] then
    Result := [cpWin32];
end;

procedure TInstallationFile.Load(const ARoot: TJSONObject);
var
  LArray: TJSonArray;
begin
  inherited;
  LoadPathes(ARoot, 'search_pathes', FSearchPath);
  LoadPathes(ARoot, 'browsing_pathes', FBrowsingPathes);

  if ReadArray(ARoot, 'source_folders', LArray) then
    LoadSourceFolders(LArray);

  if ReadArray(ARoot, 'raw_folders', LArray) then
    LoadRawFolders(LArray);

  if ReadArray(ARoot, 'projects', LArray) then
    LoadProjects(LArray);

  if ReadArray(ARoot, 'experts', LArray) then
    LoadExperts(LArray);
end;

procedure TInstallationFile.LoadExperts(const AExperts: TJSonArray);
var
  i: Integer;
  LItem: TJSONObject;
  LCompiler: Integer;
begin
  SetLength(FExperts, AExperts.Count);
  for i := 0 to Pred(AExperts.Count) do
  begin
    LItem := AExperts.Items[i] as TJSONObject;
    FExperts[i].Expert := ReadString(LItem, 'expert');
    FExperts[i].HotReload := ReadBoolean(LItem, 'hot_reload');
    LCompiler := ReadInteger(LItem, 'compiler');
    if LCompiler > 0 then
    begin
      FExperts[i].CompilerMin := LCompiler;
      FExperts[i].CompilerMax := LCompiler;
    end
    else
    begin
      FExperts[i].CompilerMin := ReadInteger(LItem, 'compiler_min');
      FExperts[i].CompilerMax := ReadInteger(LItem, 'compiler_max');
    end;
  end;
end;

procedure TInstallationFile.LoadPathes(const ARoot: TJSONObject;
  const AName: string; out APathes: TArray<TSearchPath>);
var
  LArray: TJSonArray;
  LItem: TJSONObject;
  i: Integer;
  LCompiler: Integer;
begin
  if ReadArray(ARoot, AName, LArray) then
  begin
    SetLength(APathes, LArray.Count);
    for i := 0 to Pred(LArray.Count) do
    begin
      LItem := LArray.Items[i] as TJSONObject;
      APathes[i].Path := ReadString(LItem, 'pathes');
      LCompiler := ReadInteger(LItem, 'compiler');
      if LCompiler > 0 then
      begin
        APathes[i].CompilerMin := LCompiler;
        APathes[i].CompilerMax := LCompiler;
      end
      else
      begin
        APathes[i].CompilerMin := ReadInteger(LItem, 'compiler_min');
        APathes[i].CompilerMax := ReadInteger(LItem, 'compiler_max');
      end;
      APathes[i].Platforms := GetPlatforms(ReadString(LItem, 'platforms'));
    end;
  end;
end;

procedure TInstallationFile.LoadProjects(const AProjects: TJSONArray);
var
  i: Integer;
  LItem: TJSONObject;
  LCompiler: Integer;
begin
  SetLength(FProjects, AProjects.Count);
  for i := 0 to Pred(AProjects.Count) do
  begin
    LItem := AProjects.Items[i] as TJSONObject;
    FProjects[i].Project := ReadString(LItem, 'project');
    LCompiler := ReadInteger(LItem, 'compiler');
    if LCompiler > 0 then
    begin
      FProjects[i].CompilerMin := LCompiler;
      FProjects[i].CompilerMax := LCompiler;
    end
    else
    begin
      FProjects[i].CompilerMin := ReadInteger(LItem, 'compiler_min');
      FProjects[i].CompilerMax := ReadInteger(LItem, 'compiler_max');
    end;
  end;
end;

procedure TInstallationFile.LoadRawFolders(const ARawFolders: TJSONArray);
var
  i: Integer;
  LItem: TJSONObject;
  LCompiler: Integer;
begin
  SetLength(FRawFolders, ARawFolders.Count);
  for i := 0 to Pred(ARawFolders.Count) do
  begin
    LItem := ARawFolders.Items[i] as TJSONObject;
    FRawFolders[i].Folder := ReadString(LItem, 'folder');
    LCompiler := ReadInteger(LItem, 'compiler');
    if LCompiler > 0 then
    begin
      FRawFolders[i].CompilerMin := LCompiler;
      FRawFolders[i].CompilerMax := LCompiler;
    end
    else
    begin
      FRawFolders[i].CompilerMin := ReadInteger(LItem, 'compiler_min');
      FRawFolders[i].CompilerMax := ReadInteger(LItem, 'compiler_max');
    end;
  end;
end;

procedure TInstallationFile.LoadSourceFolders(const AFolders: TJSONArray);
var
  i: Integer;
  LItem: TJSONObject;
  LCompiler: Integer;
begin
  SetLength(FSourceFolders, AFolders.Count);
  for i := 0 to Pred(AFolders.Count) do
  begin
    LItem := AFolders.Items[i] as TJSONObject;
    FSourceFolders[i].Folder := ReadString(LItem, 'folder');
    FSourceFolders[i].Base := ReadString(LItem, 'base');
    FSourceFolders[i].Recursive := ReadBoolean(LItem, 'recursive');
    FSourceFolders[i].Filter := ReadString(LItem, 'filter');
    LCompiler := ReadInteger(LItem, 'compiler');
    if LCompiler > 0 then
    begin
      FSourceFolders[i].CompilerMin := LCompiler;
      FSourceFolders[i].CompilerMax := LCompiler;
    end
    else
    begin
      FSourceFolders[i].CompilerMin := ReadInteger(LItem, 'compiler_min');
      FSourceFolders[i].CompilerMax := ReadInteger(LItem, 'compiler_max');
    end;
  end;
end;

procedure TInstallationFile.Save(const ARoot: TJSONObject);
var
  LArray: TJSonArray;
begin
  inherited;
  if Length(FSearchPath) > 0 then
  begin
    LArray := WriteArray(ARoot, 'search_pathes');
    SavePathes(LArray, FSearchPath);;
  end;
  if Length(FBrowsingPathes) > 0 then
  begin
    LArray := WriteArray(ARoot, 'browsing_pathes');
    SavePathes(LArray, FBrowsingPathes);
  end;

  if Length(FSourceFolders) > 0 then
  begin
    LArray := WriteArray(ARoot, 'source_folders');
    SaveSourceFolders(LArray);
  end;

  if Length(FRawFolders) > 0 then
  begin
    LArray := WriteArray(ARoot, 'raw_folders');
    SaveRawFolders(LArray);
  end;

  if Length(FProjects) > 0 then
  begin
    LArray := WriteArray(ARoot, 'projects');
    SaveProjects(LArray);
  end;

  if Length(FExperts) > 0 then
  begin
    LArray := WriteArray(ARoot, 'experts');
    SaveExperts(LArray);
  end;
end;

procedure TInstallationFile.SaveExperts(const AExperts: TJSonArray);
var
  LItem: TJSONObject;
  LExpert: TExpert;
begin
  for LExpert in FExperts do
  begin
    LItem := WriteArrayObject(AExperts);
    if LExpert.Expert <> '' then
      WritePath(LItem, 'expert', LExpert.Expert);
    if LExpert.HotReload then
      WriteBoolean(LItem, 'hot_reload', LExpert.HotReload);
    if LExpert.CompilerMin = LExpert.CompilerMax then
    begin
      if LExpert.CompilerMin > 0 then
        WriteInteger(LItem, 'compiler', LExpert.CompilerMin);
    end
    else
    begin
      if LExpert.CompilerMin > 0 then
        WriteInteger(LItem, 'compiler_min', LExpert.CompilerMin);
      if LExpert.CompilerMax > 0 then
        WriteInteger(LItem, 'compiler_max', LExpert.CompilerMax);
    end;
  end;
end;

procedure TInstallationFile.SavePathes(const ARoot: TJSONArray;
  const APathes: TArray<TSearchPath>);
var
  LItem: TJSONObject;
  LPath: TSearchPath;
begin
  for LPath in APathes do
  begin
    LItem := WriteArrayObject(ARoot);
    if LPath.Path <> '' then
      WritePath(LItem, 'pathes', LPath.Path);
    if LPath.CompilerMin = LPath.CompilerMax then
    begin
      if LPath.CompilerMin > 0 then
        WriteInteger(LItem, 'compiler', LPath.CompilerMin);
    end
    else
    begin
      if LPath.CompilerMin > 0 then
        WriteInteger(LItem, 'compiler_min', LPath.CompilerMin);
      if LPath.CompilerMax > 0 then
        WriteInteger(LItem, 'compiler_max', LPath.CompilerMax);
    end;
    if LPath.Platforms <> [] then
      WriteString(LItem, 'platforms', GeneratePlatformString(LPath.Platforms, ';'));
  end;
end;

procedure TInstallationFile.SaveProjects(const AProjects: TJSONArray);
var
  LItem: TJSONObject;
  LProject: TProject;
begin
  for LProject in FProjects do
  begin
    LItem := WriteArrayObject(AProjects);
    if LProject.Project <> '' then
      WritePath(LItem, 'project', LProject.Project);
    if LProject.CompilerMin = LProject.CompilerMax then
    begin
      if LProject.CompilerMin > 0 then
        WriteInteger(LItem, 'compiler', LProject.CompilerMin);
    end
    else
    begin
      if LProject.CompilerMin > 0 then
        WriteInteger(LItem, 'compiler_min', LProject.CompilerMin);
      if LProject.CompilerMax > 0 then
        WriteInteger(LItem, 'compiler_max', LProject.CompilerMax);
    end;
  end;
end;

procedure TInstallationFile.SaveRawFolders(const ARawFolders: TJSONArray);
var
  LItem: TJSONObject;
  LFolder: TRawFolder;
begin
  for LFolder in FRawFolders do
  begin
    LItem := WriteArrayObject(ARawFolders);
    if LFolder.Folder <> '' then
      WritePath(LItem, 'folder', LFolder.Folder);
    if LFolder.CompilerMin = LFolder.CompilerMax then
    begin
      if LFolder.CompilerMin > 0 then
        WriteInteger(LItem, 'compiler', LFolder.CompilerMin);
    end
    else
    begin
      if LFolder.CompilerMin > 0 then
        WriteInteger(LItem, 'compiler_min', LFolder.CompilerMin);
      if LFolder.CompilerMax > 0 then
        WriteInteger(LItem, 'compiler_max', LFolder.CompilerMax);
    end;
  end;
end;

procedure TInstallationFile.SaveSourceFolders(const AFolders: TJSONArray);
var
  LItem: TJSONObject;
  LFolder: TFolder;
begin
  for LFolder in FSourceFolders do
  begin
    LItem := WriteArrayObject(AFolders);
    if LFolder.Folder <> '' then
      WritePath(LItem, 'folder', LFolder.Folder);
    if LFolder.Base <> '' then
      WritePath(LItem, 'base', LFolder.Base);
    if LFolder.Recursive then
      WriteBoolean(LItem, 'recursive', LFolder.Recursive);
    if LFolder.Filter <> '' then
      WritePath(LItem, 'filter', LFolder.Filter);
    if LFolder.CompilerMin = LFolder.CompilerMax then
    begin
      if LFolder.CompilerMin > 0 then
        WriteInteger(LItem, 'compiler', LFolder.CompilerMin);
    end
    else
    begin
      if LFolder.CompilerMin > 0 then
        WriteInteger(LItem, 'compiler_min', LFolder.CompilerMin);
      if LFolder.CompilerMax > 0 then
        WriteInteger(LItem, 'compiler_max', LFolder.CompilerMax);
    end;
  end;
end;

end.
