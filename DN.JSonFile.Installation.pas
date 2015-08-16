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

  TProject = record
    Project: string;
    CompilerMin: Integer;
    CompilerMax: Integer;
  end;

  TInstallationFile = class(TJSonFile)
  private
    FSourceFolders: TArray<TFolder>;
    FSearchPath: TArray<TSearchPath>;
    FProjects: TArray<TProject>;
    FBrowsingPathes: TArray<TSearchPath>;
  protected
    procedure LoadPathes(const ARoot: TJSONObject; const AName: string; out APathes: TArray<TSearchPath>);
    procedure Load(const ARoot: TJSONObject); override;
    function GetPlatforms(const APlatforms: string): TDNCompilerPlatforms;
  public
    property SearchPathes: TArray<TSearchPath> read FSearchPath;
    property BrowsingPathes: TArray<TSearchPath> read FBrowsingPathes;
    property SourceFolders: TArray<TFolder> read FSourceFolders;
    property Projects: TArray<TProject> read FProjects;
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
  LItem: TJSONObject;
  i: Integer;
  LCompiler: Integer;
begin
  inherited;
  LoadPathes(ARoot, 'search_pathes', FSearchPath);
  LoadPathes(ARoot, 'browsing_pathes', FBrowsingPathes);

  if ReadArray(ARoot, 'source_folders', LArray) then
  begin
    SetLength(FSourceFolders, LArray.Count);
    for i := 0 to Pred(LArray.Count) do
    begin
      LItem := LArray.Items[i] as TJSONObject;
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

  if ReadArray(ARoot, 'projects', LArray) then
  begin
    SetLength(FProjects, LArray.Count);
    for i := 0 to Pred(LArray.Count) do
    begin
      LItem := LArray.Items[i] as TJSONObject;
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

end.
