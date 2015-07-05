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
  DN.JSonFile.Installation,
  DN.JSonFile.Uninstallation;

type

  TDNInstaller = class(TInterfacedObject, IDNInstaller)
  private
    FCompiler: IDNCompiler;
    FCompilerVersion: Integer;
    FSearchPathes: string;
    FPackages: TList<TPackage>;
    FOnMessage: TMessageEvent;
    procedure CopyDirectory(const ASource, ATarget: string; AFileFilters: TStringDynArray; ARecursive: Boolean = False);
    procedure ProcessSearchPathes(const APathes: TArray<TSearchPath>; const ARootDirectory: string);
    procedure ProcessSourceFolders(const ASourceFolders: TArray<TFolder>; const ASourceDirectory, ATargetDirectory: string);
    function ProcessProjects(const AProjects: TArray<TProject>; const ASourceDirectory, ATargetDirectory: string): Boolean;
    function ProcessProject(const AProject: IDNProjectInfo): Boolean;
    function IsSupported(ACompiler_Min, ACompiler_Max: Integer): Boolean;
    function FileMatchesFilter(const AFile: string; const AFilter: TStringDynArray): Boolean;

    procedure SaveUninstall(const ATargetDirectory: string);
    procedure Reset();
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
  protected
    procedure DoMessage(AType: TMessageType; const AMessage: string);
    procedure AddSearchPath(const ASearchPath: string; const APlatforms: TDNCompilerPlatforms); virtual;
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
  DN.Uninstaller.Intf,
  DN.JSonFile.Info,
  DN.ToolsApi.Extension.Intf;

const
  CLibDir = 'lib';
  CBinDir = 'bin';
  CSourceDir = 'source';
  CInstallFile = 'install.json';


{ TDNInstaller }

procedure TDNInstaller.AddSearchPath(const ASearchPath: string; const APlatforms: TDNCompilerPlatforms);
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
    DoMessage(mtNotification, ALog.Text);
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
  LInfo: TInfoFile;
begin
  Result := True;
  LSourceInfo := TPath.Combine(ASourceDirectory, 'info.json');
  LTargetInfo := TPath.Combine(ATargetDirectory, 'info.json');
  if TFile.Exists(LSourceInfo) then
  begin
    TFile.Copy(LSourceInfo, LTargetInfo);

    LInfo := TInfoFile.Create();
    try
      if LInfo.LoadFromFile(LSourceInfo) then
      begin
        if LInfo.Picture <> '' then
        begin
          LSourcePic := TPath.Combine(ASourceDirectory, LInfo.Picture);
          LTargetPic := TPath.Combine(ATargetDirectory, LInfo.Picture);
          if TFile.Exists(LSourcePic) then
          begin
            ForceDirectories(ExtractFilePath(LTargetPic));
            TFile.Copy(LSourcePic, LTargetPic);
          end;
        end;
      end;
    finally
      LInfo.Free;
    end;
  end;
end;

constructor TDNInstaller.Create(const ACompiler: IDNCompiler; const ACompilerVersion: Integer);
begin
  inherited Create();
  FCompiler := ACompiler;
  FCompilerVersion := ACompilerVersion;
  FPackages := TList<TPackage>.Create();
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
  LInfo: TInstallationFile;
  LInstallerFile: string;
begin
  Result := False;
  Reset();
  ForceDirectories(ATargetDirectory);
  LInstallerFile := TPath.Combine(ASourceDirectory, CInstallFile);
  if TFile.Exists(LInstallerFile) then
  begin
    LInfo := TInstallationFile.Create();
    try
      LInfo.LoadFromFile(LInstallerFile);
      ProcessSearchPathes(LInfo.SearchPathes, ATargetDirectory);
      ProcessSourceFolders(LInfo.SourceFolders, ASourceDirectory, TPath.Combine(ATargetDirectory, CSourceDir));
      Result := ProcessProjects(LInfo.Projects, ASourceDirectory, ATargetDirectory);
      if Result then
        CopyMetaData(ASourceDirectory, ATargetDirectory);
    finally
      LInfo.Free;
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

function TDNInstaller.IsSupported(ACompiler_Min, ACompiler_Max: Integer): Boolean;
begin
  Result := True;

  if ACompiler_Min > 0 then
    Result := Result and (FCompilerVersion >= ACompiler_Min);

  if ACompiler_Max > 0 then
    Result := Result and (FCompilerVersion <= ACompiler_Max);
end;

function TDNInstaller.ProcessProject(const AProject: IDNProjectInfo): Boolean;
var
  LCompiledPackage: TPackage;
  LPlatform: TDNCompilerPlatform;
  LService: IDNEnvironmentOptionsService;
  LOptions: IDNEnvironmentOptions;
begin
  Result := False;
  LService := GDelphinusIDEServices as IDNEnvironmentOptionsService;
  BeforeCompile(AProject.FileName);
  for LPlatform in AProject.SupportedPlatforms do
  begin
    if LPlatform in LService.SupportedPlatforms then
    begin
      DoMessage(mtNotification, TDNCompilerPlatformName[LPlatform]);
      LOptions := LService.Options[LPlatform];
      FCompiler.BPLOutput := LOptions.BPLOutput;
      FCompiler.DCPOutput := LOptions.DCPOutput;
      FCompiler.Platform := LPlatform;
      Result := FCompiler.Compile(AProject.FileName);
      if Result and AProject.IsPackage then
      begin
        if (not AProject.IsRuntimeOnlyPackage) and (LPlatform = cpWin32) then
        begin
          Result := InstallProject(AProject);
          if Result then
            DoMessage(mtNotification, 'installed')
          else
            DoMessage(mtError, 'failed to install');
        end;
        LCompiledPackage.BPLFile := TPath.Combine(FCompiler.ResolveVars(FCompiler.BPLOutput), AProject.BinaryName);
        LCompiledPackage.DCPFile := TPath.Combine(FCompiler.ResolveVars(FCompiler.DCPOutput), AProject.DCPName);
        LCompiledPackage.Installed := (not AProject.IsRuntimeOnlyPackage) and (LPlatform = cpWin32);
        FPackages.Add(LCompiledPackage);
      end;
      if not Result then
        Break;
    end
    else
    begin
      DoMessage(mtWarning, 'Platform ' + TDNCompilerPlatformName[LPlatform] + ' not supported, skipping');
    end;
  end;
  AfterCompile(AProject.FileName, FCompiler.Log, Result);
end;

function TDNInstaller.ProcessProjects(const AProjects: TArray<TProject>; const ASourceDirectory, ATargetDirectory: string): Boolean;
var
  LProject: TProject;
  LProjectFile, LFileExt: string;
  LInfo: IDNProjectInfo;
  LGroupInfo: IDNProjectGroupInfo;
const
  CGroup = '.groupproj';
  CProject = '.dproj';
begin
  Result := True;
  LInfo := TDNProjectInfo.Create();
  FCompiler.DCUOutput := TPath.Combine(TPath.Combine(ATargetDirectory, CLibDir), '$(Platform)\$(Config)');
  FCompiler.ExeOutput := TPath.Combine(TPath.Combine(ATargetDirectory, CBinDir), '$(Platform)\$(Config)');
  if Length(AProjects) > 0 then
  begin
    for LProject in AProjects do
    begin
      if IsSupported(LProject.CompilerMin, LProject.CompilerMax) then
      begin
        LProjectFile := TPath.Combine(ASourceDirectory, LProject.Project);
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

procedure TDNInstaller.ProcessSearchPathes(const APathes: TArray<TSearchPath>; const ARootDirectory: string);
var
  LPathes: TStringDynArray;
  LPath: TSearchPath;
  LRelPath, LBasePath: string;
begin
  if Length(APathes) > 0 then
  begin
    DoMessage(mtNotification, 'Adding Searchpathes:');
    LBasePath := TPath.Combine(ARootDirectory, CSourceDir);
    for LPath in APathes do
    begin
      if IsSupported(LPath.CompilerMin, LPath.CompilerMax) then
      begin
        LPathes := SplitString(LPath.Path, ';');
        for LRelPath in LPathes do
        begin
          DoMessage(mtNotification, LRelPath);
          if ExtractFileName(ExcludeTrailingPathDelimiter(LRelPath)) <> '.' then
          begin
            AddSearchPath(TPath.Combine(LBasePath, LRelPath), LPath.Platforms);
          end
          else
          begin
            AddSearchPath(TPath.Combine(LBasePath, ExtractFilePath(ExcludeTrailingPathDelimiter(LRelPath))), LPath.Platforms);
          end;
        end;
      end;
    end;
  end;
end;

procedure TDNInstaller.ProcessSourceFolders(const ASourceFolders: TArray<TFolder>; const ASourceDirectory, ATargetDirectory: string);
var
  LFolder: TFolder;
  LFilter: TStringDynArray;
  LRelTargetPath, LBase: string;
begin
  if Length(ASourceFolders) > 0 then
  begin
    DoMessage(mtNotification, 'Copying sourcefolders:');
    for LFolder in ASourceFolders do
    begin
      if IsSupported(LFolder.CompilerMin, LFolder.CompilerMax) then
      begin
        if not TPath.IsRelativePath(LFolder.Folder) then
        begin
          DoMessage(mtError, 'Path is not relative ' + LFolder.Folder);
        end;
        LRelTargetPath := LFolder.Folder;
        if LFolder.Base <> '' then
        begin
          LBase := IncludeTrailingPathDelimiter(LFolder.Base);
          LRelTargetPath := IncludeTrailingPathDelimiter(LFolder.Folder);
          if StartsText(LRelTargetPath, LBase) then
            LRelTargetPath := Copy(LRelTargetPath, Length(LBase) + 1, Length(LRelTargetPath))
          else
            DoMessage(mtError, 'base must be exactly overlapping with folder string to remove it');
        end;

        LFilter := SplitString(LFolder.Filter, ';');

        DoMessage(mtNotification, LFolder.Folder);
        CopyDirectory(
          TPath.Combine(ASourceDirectory, IfThen(LFolder.Folder = '.', '', LFolder.Folder)),
          TPath.Combine(ATargetDirectory, LRelTargetPath), LFilter, LFolder.Recursive);
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
  LUninstall: TUninstallationFile;
begin
  LUninstall := TUninstallationFile.Create();
  try
    LUninstall.SearchPathes := FSearchPathes;
    LUninstall.Packages := FPackages.ToArray;
    LUninstall.SaveToFile(TPath.Combine(ATargetDirectory, CUninstallFile));
  finally
    LUninstall.Free;
  end;
end;

procedure TDNInstaller.SetOnMessage(const Value: TMessageEvent);
begin
  FOnMessage := Value;
end;

end.
