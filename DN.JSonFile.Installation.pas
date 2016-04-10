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
  DN.Compiler.Intf;

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
    procedure LoadSourceFolders(const AFolders: TJSONArray);
    procedure LoadRawFolders(const ARawFolders: TJSONArray);
    procedure LoadProjects(const AProjects: TJSONArray);
    procedure LoadExperts(const AExperts: TJSonArray);
    function GetPlatforms(const APlatforms: string): TDNCompilerPlatforms;
  public
    property SearchPathes: TArray<TSearchPath> read FSearchPath;
    property BrowsingPathes: TArray<TSearchPath> read FBrowsingPathes;
    property SourceFolders: TArray<TFolder> read FSourceFolders;
    property RawFolders: TArray<TRawFolder> read FRawFolders;
    property Projects: TArray<TProject> read FProjects;
    property Experts: TArray<TExpert> read FExperts;
  end;

implementation

uses
  SysUtils,
  StrUtils;

{ TInstallationFile }

function TInstallationFile.GetPlatforms(
  const APlatforms: string): TDNCompilerPlatforms;
var
  LPlatforms: TStringDynArray;
  LPlatform: string;
begin
  LPlatforms := SplitString(APlatforms, ';');
  if Length(LPlatforms) > 0 then
  begin
    Result := [];
    for LPlatform in LPlatforms do
    begin
      if SameText(LPlatform, 'Win32') then
        Result := Result + [cpWin32]
      else if SameText(LPlatform, 'Win64') then
        Result := Result + [cpWin64]
      else if SameText(LPlatform, 'OSX32') then
        Result := Result + [cpOSX32]
    end;
  end
  else
  begin
    Result := [cpWin32];
  end;
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

end.
