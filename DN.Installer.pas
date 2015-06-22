unit DN.Installer;

interface

uses
  Classes,
  Types,
  SysUtils,
  Generics.Collections,
  DN.Types,
  DN.Installer.Intf,
  DN.Compiler.Intf,
  DN.ProjectInfo.Intf,
  JSon,
  DBXJSon;

type
  TCompiledPackage = packed record
    BPLFile: string;
    DCPFile: string;
    Installed: Boolean;
  end;

  TDNInstaller = class(TInterfacedObject, IDNInstaller)
  private
    FCompiler: IDNCompiler;
    FCompilerVersion: Integer;
    FSearchPathes: string;
    FPackages: TList<TCompiledPackage>;
    FOnMessage: TMessageEvent;
    procedure CopyDirectory(const ASource, ATarget: string; AFileFilters: TStringDynArray; ARecursive: Boolean = False);
    procedure ProcessSearchPathes(AObject: TJSONObject; const ARootDirectory: string);
    procedure ProcessSourceFolders(AObject: TJSONObject; const ASourceDirectory, ATargetDirectory: string);
    function ProcessProjects(AObject: TJSONObject; const ASourceDirectory, ATargetDirectory: string): Boolean;
    function ProcessProject(const AProject: IDNProjectInfo): Boolean;
    function IsSupported(AObject: TJSonObject): Boolean;
    function FileMatchesFilter(const AFile: string; const AFilter: TStringDynArray): Boolean;

    procedure SaveUninstall(const ATargetDirectory: string);
    procedure Reset();
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
  protected
    procedure DoMessage(AType: TMessageType; const AMessage: string);
    procedure AddSearchPath(const ASearchPath: string); virtual;
    procedure BeforeCompile(const AProjectFile: string); virtual;
    procedure AfterCompile(const AProjectFile: string; const ALog: TStrings; ASuccessFull: Boolean); virtual;
    function InstallProject(const AProject: IDNProjectInfo): Boolean; virtual;
    function CopyMetaData(const ASourceDirectory, ATargetDirectory: string): Boolean; virtual;
  public
    constructor Create(const ACompiler: IDNCompiler; const ACompilerVersion: Integer);
    destructor Destroy(); override;
    function Install(const ASourceDirectory, ATargetDirectory: string): Boolean; virtual;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
  end;

implementation

uses
  IOUtils,
  StrUtils,
  Masks,
  DN.ProjectInfo,
  DN.ProjectGroupInfo,
  DN.ProjectGroupInfo.Intf,
  DN.Uninstaller.Intf;

const
  CLibDir = 'lib';
  CBinDir = 'bin';
  CSourceDir = 'source';
  CInstallFile = 'install.json';


{ TDNInstaller }

procedure TDNInstaller.AddSearchPath(const ASearchPath: string);
begin
  if FSearchPathes = '' then
    FSearchPathes := ASearchPath
  else
    FSearchPathes := FSearchPathes + ';' + ASearchPath;
end;

procedure TDNInstaller.AfterCompile(const AProjectFile: string;
  const ALog: TStrings; ASuccessFull: Boolean);
begin
  if ASuccessFull then
  begin
    DoMessage(mtNotification, 'Success');
  end
  else
  begin
    DoMessage(mtError, 'Failed');
  end;
end;

procedure TDNInstaller.BeforeCompile(const AProjectFile: string);
begin
  DoMessage(mtNotification, 'Compiling ' + ExtractFileName(AProjectFile));
end;

procedure TDNInstaller.CopyDirectory(const ASource, ATarget: string; AFileFilters: TStringDynArray; ARecursive: Boolean = False);
var
  LDirectories, LFiles: TStringDynArray;
  LDirectory, LFile, LFileName: string;
  LForcedDirectory: Boolean;
begin
  LForcedDirectory := False;
  if ARecursive then
  begin
    LDirectories := TDirectory.GetDirectories(ASource);
    for LDirectory in LDirectories do
    begin
      CopyDirectory(LDirectory, TPath.Combine(ATarget, ExtractFileName(LDirectory)), AFileFilters, ARecursive);
    end;
  end;

  LFiles := TDirectory.GetFiles(ASource);
  for LFile in LFiles do
  begin
    LFileName := ExtractFileName(LFile);
    if FileMatchesFilter(LFileName, AFileFilters) then
    begin
      //lazy directory creation, so directories with no matching files are not created in the target path!
      if not LForcedDirectory then
      begin
        LForcedDirectory := True;
        ForceDirectories(ATarget);
      end;
      TFile.Copy(LFile, TPath.Combine(ATarget, LFileName), True);
    end;
  end;
end;

function TDNInstaller.CopyMetaData(const ASourceDirectory,
  ATargetDirectory: string): Boolean;
var
  LSourceInfo, LTargetInfo, LSourcePic, LTargetPic: string;
  LData: TStringStream;
  LInfo: TJSONObject;
  LValue: TJSONValue;
begin
  Result := True;
  LSourceInfo := TPath.Combine(ASourceDirectory, 'info.json');
  LTargetInfo := TPath.Combine(ATargetDirectory, 'info.json');
  if TFile.Exists(LSourceInfo) then
  begin
    TFile.Copy(LSourceInfo, LTargetInfo);
    LData := TStringStream.Create();
    try
      LData.LoadFromFile(LSourceInfo);
      LInfo := TJSonObject.ParseJSONValue(LData.DataString) as TJSONObject;
      if Assigned(LInfo) then
      begin
        try
          LValue := LInfo.GetValue('picture');
          if Assigned(LValue) then
          begin
            LSourcePic := TPath.Combine(ASourceDirectory, LValue.Value);
            LTargetPic := TPath.Combine(ATargetDirectory, LValue.Value);
            if TFile.Exists(LSourcePic) then
            begin
              ForceDirectories(ExtractFilePath(LTargetPic));
              TFile.Copy(LSourcePic, LTargetPic);
            end;
          end;
        finally
          LInfo.Free;
        end;
      end;
    finally
      LData.Free;
    end;
  end;
end;

constructor TDNInstaller.Create(const ACompiler: IDNCompiler; const ACompilerVersion: Integer);
begin
  inherited Create();
  FCompiler := ACompiler;
  FCompilerVersion := ACompilerVersion;
  FPackages := TList<TCompiledPackage>.Create();
end;

destructor TDNInstaller.Destroy;
begin
  FPackages.Free();
  inherited;
end;

procedure TDNInstaller.DoMessage(AType: TMessageType; const AMessage: string);
begin
  if Assigned(FOnMessage) then
    FOnMessage(AType, AMessage);
end;

function TDNInstaller.FileMatchesFilter(const AFile: string;
  const AFilter: TStringDynArray): Boolean;
var
  LFilter: string;
begin
  Result := Length(AFilter) = 0;
  if not Result then
  begin
    for LFilter in AFilter do
    begin
      Result := MatchesMask(AFile, LFilter);
      if Result then
        Break;
    end;
  end;
end;

function TDNInstaller.GetOnMessage: TMessageEvent;
begin
  Result := FOnMessage;
end;

function TDNInstaller.Install(const ASourceDirectory,
  ATargetDirectory: string): Boolean;
var
  LInfo: TJSONObject;
  LInstallerFile: string;
  LStream: TStringStream;
begin
  Result := False;
  Reset();
  ForceDirectories(ATargetDirectory);
  LInstallerFile := TPath.Combine(ASourceDirectory, CInstallFile);
  if TFile.Exists(LInstallerFile) then
  begin
    LStream := TStringStream.Create();
    try
      LStream.LoadFromFile(LInstallerFile);
      LInfo := TJSONObject.ParseJSONValue(LStream.DataString) as TJSonObject;
      if Assigned(LInfo) then
      begin
        try
          ProcessSearchPathes(LInfo, ATargetDirectory);
          ProcessSourceFolders(LInfo, ASourceDirectory, TPath.Combine(ATargetDirectory, CSourceDir));
          Result := ProcessProjects(LInfo, ASourceDirectory, ATargetDirectory);
          if Result then
            CopyMetaData(ASourceDirectory, ATargetDirectory);
        finally
          LInfo.Free;
        end;
      end;
    finally
      LStream.Free;
    end;
  end
  else
  begin
    DoMessage(mtError, 'No installation file');
  end;
  SaveUninstall(ATargetDirectory);
end;

function TDNInstaller.InstallProject(const AProject: IDNProjectInfo): Boolean;
begin
  Result := True;
end;

function TDNInstaller.IsSupported(AObject: TJSonObject): Boolean;
var
  LMin, LMax, LSpecific: TJSonValue;
begin
  Result := True;
  LSpecific := AObject.GetValue('compiler');
  if Assigned(LSpecific) then
  begin
    Result := FCompilerVersion = StrToIntDef(LSpecific.Value, FCompilerVersion);
  end
  else
  begin
    LMin := AObject.GetValue('compiler_min');
    LMax := AObject.GetValue('compiler_max');
    if Assigned(LMin) then
      Result := Result and (FCompilerVersion >= StrToIntDef(LMin.Value, 0));

    if Assigned(LMax) then
      Result := Result and (FCompilerVersion <= StrToIntDef(LMax.Value, 1000));
  end;
end;

function TDNInstaller.ProcessProject(const AProject: IDNProjectInfo): Boolean;
var
  LCompiledPackage: TCompiledPackage;
begin
  BeforeCompile(AProject.FileName);
  Result := FCompiler.Compile(AProject.FileName);
  AfterCompile(AProject.FileName, FCompiler.Log, Result);
  if AProject.IsPackage then
  begin
    if not AProject.IsRuntimeOnlyPackage then
    begin
      Result := InstallProject(AProject);
      if Result then
        DoMessage(mtNotification, 'installed')
      else
        DoMessage(mtError, 'failed to install');
    end;
    LCompiledPackage.BPLFile := TPath.Combine(FCompiler.BPLOutput, AProject.BinaryName);
    LCompiledPackage.DCPFile := TPath.Combine(FCompiler.DCPOutput, AProject.DCPName);
    LCompiledPackage.Installed := not AProject.IsRuntimeOnlyPackage;
    FPackages.Add(LCompiledPackage);
  end;
end;

function TDNInstaller.ProcessProjects(AObject: TJSONObject; const ASourceDirectory, ATargetDirectory: string): Boolean;
var
  LProjects: TJSONArray;
  LProject: TJSonObject;
  LProjectFile, LFileExt: string;
  i: Integer;
  LInfo: IDNProjectInfo;
  LGroupInfo: IDNProjectGroupInfo;
const
  CGroup = '.groupproj';
  CProject = '.proj';
begin
  Result := True;
  LInfo := TDNProjectInfo.Create();
  FCompiler.DCUOutput := TPath.Combine(TPath.Combine(ATargetDirectory, CLibDir), '$(Platform)\$(Config)');
  FCompiler.ExeOutput := TPath.Combine(TPath.Combine(ATargetDirectory, CBinDir), '$(Platform)\$(Config)');
  LProjects := TJSonArray(AObject.GetValue('projects'));
  if Assigned(LProjects) then
  begin
    for i := 0 to LProjects.Count - 1 do
    begin
      LProject := LProjects.Items[i] as TJSonObject;
      if IsSupported(LProject) then
      begin
        LProjectFile := TPath.Combine(ASourceDirectory, LProject.GetValue('project').Value);
        LFileExt := ExtractFileExt(LProjectFile);
        if SameText(LFileExt, CGroup) then
        begin
          LGroupInfo := TDNProjectGroupInfo.Create();
          Result := LGroupInfo.LoadFromFile(LProjectFile);
          if Result then
          begin
            for LInfo in LGroupInfo.Projects do
            begin
              Result := ProcessProject(LInfo);
              if not Result then
                Break;
            end;
          end;
        end
        else if SameText(LFileExt, CProject) then
        begin
          LInfo := TDNProjectInfo.Create();
          Result := LInfo.LoadFromFile(LProjectFile);
          if Result then
            ProcessProject(LInfo);
        end
        else
        begin
          DoMessage(mtError, 'Unknown fileextension for project ' + LProjectFile);
        end;


        if not Result then
          Break;
      end;
    end;
  end;
end;

procedure TDNInstaller.ProcessSearchPathes(AObject: TJSONObject; const ARootDirectory: string);
var
  LPathes: TStringDynArray;
  LPathArray: TJSONArray;
  LPath: TJSonObject;
  LRelPath, LBasePath: string;
  i: Integer;
begin
  LPathArray := TJSonArray(AObject.GetValue('search_pathes'));
  if Assigned(LPathArray) then
  begin
    DoMessage(mtNotification, 'Adding Searchpathes:');
    LBasePath := TPath.Combine(ARootDirectory, CSourceDir);
    for i := 0 to LPathArray.Count - 1 do
    begin
      LPath := LPathArray.Items[i] as TJSonObject;
      if IsSupported(LPath) then
      begin
        LPathes := SplitString(LPath.GetValue('pathes').Value, ';');
        for LRelPath in LPathes do
        begin
          DoMessage(mtNotification, LRelPath);
          if ExtractFileName(ExcludeTrailingPathDelimiter(LRelPath)) <> '.' then
          begin
            AddSearchPath(TPath.Combine(LBasePath, LRelPath));
          end
          else
          begin
            AddSearchPath(TPath.Combine(LBasePath, ExtractFilePath(ExcludeTrailingPathDelimiter(LRelPath))));
          end;
        end;
      end;
    end;
  end;
end;

procedure TDNInstaller.ProcessSourceFolders(AObject: TJSONObject; const ASourceDirectory, ATargetDirectory: string);
var
  LFolders: TJSONArray;
  LFolder: TJSonObject;
  LValue: TJSONValue;
  LRecursive: Boolean;
  LFilter: TStringDynArray;
  LRelPath: string;
  i: Integer;
begin
  LFolders := TJSonArray(AObject.GetValue('source_folders'));
  if Assigned(LFolders) then
  begin
    DoMessage(mtNotification, 'Copying sourcefolders:');
    for i := 0 to LFolders.Count - 1 do
    begin
      LFolder := LFolders.Items[i] as TJSonObject;
      if IsSupported(LFolder) then
      begin
        LRelPath := LFolder.GetValue('folder').Value;
        LValue := LFolder.GetValue('recursive');
        if Assigned(LValue) then
          LRecursive := StrToBoolDef(LValue.Value, False)
        else
          LRecursive := False;

        LValue := LFolder.GetValue('filter');
        if Assigned(LValue) then
          LFilter := SplitString(LValue.Value, ';')
        else
          SetLength(LFilter, 0);

        DoMessage(mtNotification, LRelPath);
        if SameText(LRelPath, '.') then
          LRelPath := '';
        CopyDirectory(TPath.Combine(ASourceDirectory, LRelPath), TPath.Combine(ATargetDirectory, LRelPath), LFilter, LRecursive);
      end;
    end;
  end;
end;

procedure TDNInstaller.Reset;
begin
  FSearchPathes := '';
  FPackages.Clear();
end;

procedure TDNInstaller.SaveUninstall(const ATargetDirectory: string);
var
  LData: TStringStream;
  LUninstall, LPackage: TJSONObject;
  LPackages: TJSONArray;
  LCompiledPackage: TCompiledPackage;
begin
  LData := TStringStream.Create();
  LUninstall := TJSONObject.Create();
  try
    LUninstall.AddPair('search_pathes', StringReplace(FSearchPathes, '\', '\\', [rfReplaceAll]));
    LPackages := TJSONArray.Create();
    LUninstall.AddPair('packages', LPackages);
    for LCompiledPackage in FPackages do
    begin
      LPackage := TJSONObject.Create();
      LPackage.AddPair('bpl_file', StringReplace(LCompiledPackage.BPLFile, '\', '\\', [rfReplaceAll]));
      LPackage.AddPair('dcp_file', StringReplace(LCompiledPackage.DCPFile, '\', '\\', [rfReplaceAll]));
      LPackage.AddPair('installed', BoolToStr(LCompiledPackage.Installed, True));
      LPackages.AddElement(LPackage);
    end;
    LData.WriteString(LUninstall.ToString);
    LData.SaveToFile(TPath.Combine(ATargetDirectory, CUninstallFile));
  finally
    LUninstall.Free;
    LData.Free;
  end;
end;

procedure TDNInstaller.SetOnMessage(const Value: TMessageEvent);
begin
  FOnMessage := Value;
end;

end.
