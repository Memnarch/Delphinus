{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
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
  DN.JSonFile.Uninstallation,
  DN.Progress.Intf;

type
  TDNInstaller = class(TInterfacedObject, IDNInstaller, IDNProgress)
  private
    FCompiler: IDNCompiler;
    FCompilerVersion: Integer;
    FSearchPathes: string;
    FBrowsingPathes: string;
    FPackages: TList<TPackage>;
    FOnMessage: TMessageEvent;
    FProgress: IDNProgress;
    FTargetDirectory: string;
    procedure CopyDirectory(const ASource, ATarget: string; AFileFilters: TStringDynArray; ARecursive: Boolean = False);
    procedure ProcessPathes(const APathes: TArray<TSearchPath>; const ARootDirectory: string; APathType: TPathType);
    procedure ProcessSourceFolders(const ASourceFolders: TArray<TFolder>; const ASourceDirectory, ATargetDirectory: string);
    function ProcessProjects(const AProjects: TArray<TProject>; const ATargetDirectory: string): Boolean;
    function ProcessProject(const AProject: IDNProjectInfo; var AProcessedPlatforms: TDNCompilerPlatforms): Boolean;
    function IsSupported(ACompiler_Min, ACompiler_Max: Integer): Boolean;
    function FileMatchesFilter(const AFile: string; const AFilter: TStringDynArray): Boolean;

    procedure SaveUninstall(const ATargetDirectory: string);
    procedure Reset();
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
    function GetSourceFolder(const ADirectory: string): string;
    function UndecoratePath(const APath: string): string;
    function LoadSupportedProjects(const ABaseDirectory: string; const AProjects: TArray<TProject>; ASupportedProjects: TList<IDNProjectInfo>): Boolean;
  protected
    procedure DoMessage(AType: TMessageType; const AMessage: string);
    procedure AddSearchPath(const ASearchPath: string; const APlatforms: TDNCompilerPlatforms); virtual;
    procedure AddBrowsingPath(const ABrowsingPath: string; const APlatforms: TDNCompilerPlatforms); virtual;
    procedure BeforeCompile(const AProjectFile: string); virtual;
    procedure AfterCompile(const AProjectFile: string; const ALog: TStrings; ASuccessFull: Boolean); virtual;
    function InstallProject(const AProject: IDNProjectInfo; const ABPLDirectory: string): Boolean; virtual;
    function CopyMetaData(const ASourceDirectory, ATargetDirectory: string): Boolean; virtual;
    procedure CopyLicense(const ASourceDirectory, ATargetDirectory, ALicense: string);
    function GetSupportedPlatforms: TDNCompilerPlatforms; virtual; abstract;
    procedure ConfigureCompiler(const ACompiler: IDNCompiler); virtual;
    function GetTargetDirectory: string;
    function GetLibBaseDir: string;
    function GetBinBaseDir: string;
    //properties for interface redirection
    property Progress: IDNProgress read FProgress implements IDNProgress;
  public
    constructor Create(const ACompiler: IDNCompiler);
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
  DN.Progress;

const
  CLibDir = 'lib';
  CBinDir = 'bin';
  CSourceDir = 'source';


{ TDNInstaller }

procedure TDNInstaller.AddBrowsingPath(const ABrowsingPath: string;
  const APlatforms: TDNCompilerPlatforms);
begin
  if FBrowsingPathes = '' then
    FBrowsingPathes := ABrowsingPath
  else
    FBrowsingPathes := FBrowsingPathes + ';' + ABrowsingPath;
end;

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

procedure TDNInstaller.ConfigureCompiler(const ACompiler: IDNCompiler);
begin
  FCompiler.DCUOutput := TPath.Combine(GetLibBaseDir(), '$(Platform)\$(Config)');
  FCompiler.ExeOutput := TPath.Combine(GetBinBaseDir(), '$(Platform)\$(Config)');
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

procedure TDNInstaller.CopyLicense(const ASourceDirectory,
  ATargetDirectory, ALicense: string);
var
  LSource, LTarget: string;
begin
  LSource := TPath.Combine(ASourceDirectory, ALicense);
  LTarget := TPath.Combine(ATargetDirectory, ExtractFileName(ALicense));
  if TFile.Exists(LSource) then
    TFile.Copy(LSource, LTarget, True);
end;

function TDNInstaller.CopyMetaData(const ASourceDirectory,
  ATargetDirectory: string): Boolean;
var
  LSourceInfo, LTargetInfo, LSourcePic, LTargetPic: string;
  LSourceInstall, LTargetInstall: string;
  LInfo: TInfoFile;
begin
  Result := True;
  LSourceInfo := TPath.Combine(ASourceDirectory, CInfoFile);
  LTargetInfo := TPath.Combine(ATargetDirectory, CInfoFile);
  if TFile.Exists(LSourceInfo) then
  begin
    TFile.Copy(LSourceInfo, LTargetInfo, True);

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
            TFile.Copy(LSourcePic, LTargetPic, True);
          end;
        end;
      end;
    finally
      LInfo.Free;
    end;
  end;
  LSourceInstall := TPath.Combine(ASourceDirectory, CInstallFile);
  LTargetInstall := TPath.Combine(ATargetDirectory, CInstallFile);
  TFile.Copy(LSourceInstall, LTargetInstall, True);
end;

constructor TDNInstaller.Create(const ACompiler: IDNCompiler);
begin
  inherited Create();
  FCompiler := ACompiler;
  FCompilerVersion := Trunc(ACompiler.Version);
  FPackages := TList<TPackage>.Create();
  FProgress := TDNProgress.Create();
end;

destructor TDNInstaller.Destroy;
begin
  FPackages.Free();
  FProgress := nil;
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

function TDNInstaller.GetBinBaseDir: string;
begin
  Result := TPath.Combine(GetTargetDirectory, CBinDir);
end;

function TDNInstaller.GetLibBaseDir: string;
begin
  Result := TPath.Combine(GetTargetDirectory, CLibDir);
end;

function TDNInstaller.GetOnMessage: TMessageEvent;
begin
  Result := FOnMessage;
end;

function TDNInstaller.GetSourceFolder(const ADirectory: string): string;
begin
  Result := TPath.Combine(ADirectory, CSourceDir);
end;

function TDNInstaller.GetTargetDirectory: string;
begin
  Result := FTargetDirectory;
end;

function TDNInstaller.LoadSupportedProjects(const ABaseDirectory: string; const AProjects: TArray<TProject>; ASupportedProjects: TList<IDNProjectInfo>): Boolean;
var
  LProject: TProject;
  LInfo: IDNProjectInfo;
  LGroup: IDNProjectGroupInfo;
const
  CGroup = '.groupproj';
  CProject = '.dproj';
begin
  Result := True;
  for LProject in AProjects do
  begin
    if IsSupported(LProject.CompilerMin, LProject.CompilerMax) then
    begin
      case AnsiIndexText(ExtractFileExt(LProject.Project), [CProject, CGroup]) of
        0:
        begin
          LInfo := TDNProjectInfo.Create();
          if not LInfo.LoadFromFile(TPath.Combine(ABaseDirectory, LProject.Project)) then
          begin
            DoMessage(mtError, 'Failed to load project ' + LProject.Project);
            DoMessage(mtError, LInfo.LoadingError);
            Break;
          end;
          ASupportedProjects.Add(LInfo);
        end;
        1:
        begin
          LGroup := TDNProjectGroupInfo.Create();
          if not LGroup.LoadFromFile(TPath.Combine(ABaseDirectory, LProject.Project)) then
          begin
            DoMessage(mtError, 'Failed to load group ' + LProject.Project);
            DoMessage(mtError, LGroup.LoadingError);
            Break;
          end;
          ASupportedProjects.AddRange(LGroup.Projects);
        end
        else
        begin
          DoMessage(mtError, 'Unknown fileextension for project ' + LProject.Project);
        end;
      end;
    end;
  end;
end;

function TDNInstaller.Install(const ASourceDirectory,
  ATargetDirectory: string): Boolean;
var
  LInstallInfo: TInstallationFile;
  LInfo: TInfoFile;
  LInstallerFile, LInfoFile, LLicenseFile: string;
begin
  Reset();
  if not ForceDirectories(ATargetDirectory) then
  begin
    DoMessage(mtError, 'Failed to create directory ' + QuotedStr(ATargetDirectory));
    Exit(False);
  end;
  try
    FTargetDirectory := ATargetDirectory;
    LInfoFile := TPath.Combine(ASourceDirectory, CInfoFile);
    if TFile.Exists(LInfoFile) then
    begin
      LInfo := TInfoFile.Create();
      try
        Result := LInfo.LoadFromFile(LInfoFile);
        if Result then
        begin
          if LInfo.ID = TGuid.Empty then
          begin
            DoMessage(mtError, 'no ID provided');
            Exit(False);
          end;
          if LInfo.LicenseType <> '' then
            LLicenseFile := LInfo.LicenseFile;
        end
        else
        begin
          DoMessage(mtError, CInfoFile + ' seems to be corrupt');
          Exit(False);
        end;
      finally
        LInfo.Free;
      end;
    end
    else
    begin
      DoMessage(mtError, 'no info-file provided');
      Exit(False);
    end;
    LInstallerFile := TPath.Combine(ASourceDirectory, CInstallFile);
    if TFile.Exists(LInstallerFile) then
    begin
      LInstallInfo := TInstallationFile.Create();
      try
        Result := LInstallInfo.LoadFromFile(LInstallerFile);
        if Result then
        begin
          FProgress.SetTasks(['Adding Pathes', 'Copy Source', 'Compile Projects']);
          FProgress.SetTaskProgress('SearchPath', 0, 1);
          ProcessPathes(LInstallInfo.SearchPathes, ATargetDirectory, tpSearchPath);
          FProgress.SetTaskProgress('BrowsingPath', 1, 1);
          ProcessPathes(LInstallInfo.BrowsingPathes, ATargetDirectory, tpBrowsingPath);
          FProgress.NextTask();
          ProcessSourceFolders(LInstallInfo.SourceFolders, ASourceDirectory, GetSourceFolder(ATargetDirectory));
          CopyMetaData(ASourceDirectory, ATargetDirectory);
          CopyLicense(ASourceDirectory, ATargetDirectory, LLicenseFile);
          FProgress.NextTask();
          Result := ProcessProjects(LInstallInfo.Projects, ATargetDirectory);
          FProgress.Completed();
        end
        else
        begin
          DoMessage(mtError, CInstallFile + ' seems to be corrupt');
        end;
      finally
        LInstallInfo.Free;
      end;
    end
    else
    begin
      DoMessage(mtError, 'No installation file');
    end;
  finally
    SaveUninstall(ATargetDirectory);
  end;
end;

function TDNInstaller.InstallProject(const AProject: IDNProjectInfo; const ABPLDirectory: string): Boolean;
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

function TDNInstaller.ProcessProject(const AProject: IDNProjectInfo; var AProcessedPlatforms: TDNCompilerPlatforms): Boolean;
var
  LCompiledPackage: TPackage;
  LPlatform: TDNCompilerPlatform;
begin
  Result := False;
  BeforeCompile(AProject.FileName);
  for LPlatform in AProject.SupportedPlatforms do
  begin
    if LPlatform in GetSupportedPlatforms() then
    begin
      DoMessage(mtNotification, TDNCompilerPlatformName[LPlatform]);
      FCompiler.Platform := LPlatform;
      ConfigureCompiler(FCompiler);

      AProcessedPlatforms := AProcessedPlatforms + [LPlatform];
      Result := FCompiler.Compile(AProject.FileName);
      if Result and AProject.IsPackage then
      begin
        if (not AProject.IsRuntimeOnlyPackage) and (LPlatform = cpWin32) then
        begin
          Result := InstallProject(AProject, FCompiler.ResolveVars(FCompiler.BPLOutput));
          if Result then
            DoMessage(mtNotification, 'installed')
          else
            DoMessage(mtError, 'failed to install');
        end;

        if LPlatform = cpOSX32 then
        begin
          LCompiledPackage.BPLFile := TPath.Combine(FCompiler.ResolveVars(FCompiler.BPLOutput), CMacPackagePrefix + AProject.BinaryName);
          LCompiledPackage.BPLFile := ChangeFileExt(LCompiledPackage.BPLFile, CMacPackageExtension);
        end
        else
        begin
          LCompiledPackage.BPLFile := TPath.Combine(FCompiler.ResolveVars(FCompiler.BPLOutput), AProject.BinaryName);
        end;

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

function TDNInstaller.ProcessProjects(const AProjects: TArray<TProject>; const ATargetDirectory: string): Boolean;
var
  LProject: IDNProjectInfo;
  LProjects: TList<IDNProjectInfo>;
  LProcessedPlatforms: TDNCompilerPlatforms;
  LPlatform: TDNCompilerPlatform;
  i: Integer;
begin
  Result := True;
  LProcessedPlatforms := [];
  LProjects := TList<IDNProjectInfo>.Create();
  try
    if LoadSupportedProjects(GetSourceFolder(ATargetDirectory), AProjects, LProjects) and (LProjects.Count > 0) then
    begin
      for i := 0 to LProjects.Count - 1 do
      begin
        LProject := LProjects[i];
        FProgress.SetTaskProgress(ExtractFileName(LProject.FileName), i, LProjects.Count);
        Result := ProcessProject(LProject, LProcessedPlatforms);
        if not Result then
          Break;
      end;
    end;
  finally
    LProjects.Free;
  end;

  if Result then
  begin
    for LPlatform in LProcessedPlatforms do
      AddSearchPath(TPath.Combine(GetLibBaseDir(), TDNCompilerPlatformName[LPlatform] + '\' + TDNCompilerConfigName[FCompiler.Config]), [LPlatform]);
  end;

end;

procedure TDNInstaller.ProcessPathes(const APathes: TArray<TSearchPath>; const ARootDirectory: string; APathType: TPathType);
var
  LPathes: TStringDynArray;
  LPath: TSearchPath;
  LRelPath, LBasePath, LFullPath: string;
begin
  if Length(APathes) > 0 then
  begin
    case APathType of
      tpSearchPath: DoMessage(mtNotification, 'Adding Searchpathes:');
      tpBrowsingPath: DoMessage(mtNotification, 'Adding Browsingpathes:');
    else
      DoMessage(mtError, 'Unknown PathType');
      Exit;
    end;
    LBasePath := TPath.Combine(ARootDirectory, CSourceDir);
    for LPath in APathes do
    begin
      if IsSupported(LPath.CompilerMin, LPath.CompilerMax) then
      begin
        LPathes := SplitString(LPath.Path, ';');
        for LRelPath in LPathes do
        begin
          DoMessage(mtNotification, LRelPath);
          LFullPath := TPath.Combine(LBasePath, UndecoratePath(LRelPath));
          case APathType of
            tpSearchPath: AddSearchPath(LFullPath, LPath.Platforms);
            tpBrowsingPath: AddBrowsingPath(LFullPath, LPath.Platforms);
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
          DoMessage(mtWarning, 'Path is not relative ' + LFolder.Folder);
        end;
        LRelTargetPath := LFolder.Folder;
        if LFolder.Base <> '' then
        begin
          LBase := IncludeTrailingPathDelimiter(LFolder.Base);
          LRelTargetPath := IncludeTrailingPathDelimiter(LFolder.Folder);
          if StartsText(LBase, LRelTargetPath) then
            LRelTargetPath := Copy(LRelTargetPath, Length(LBase) + 1, Length(LRelTargetPath))
          else
            DoMessage(mtError, 'base must be exactly overlapping with folder string to remove it');
        end;

        LFilter := SplitString(LFolder.Filter, ';');

        DoMessage(mtNotification, LFolder.Folder);
        CopyDirectory(
          TPath.Combine(ASourceDirectory, UndecoratePath(LFolder.Folder)),
          TPath.Combine(ATargetDirectory, UndecoratePath(LRelTargetPath)), LFilter, LFolder.Recursive);
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
    LUninstall.BrowsingPathes := FBrowsingPathes;
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

function TDNInstaller.UndecoratePath(const APath: string): string;
begin
  if StartsStr('..', APath) then
    Result := Copy(APath, 3, Length(APath))
  else if StartsStr('.', APath) then
    Result := Copy(APath, 2, Length(APath))
  else
    Result := APath;

  if StartsStr('\', Result) then
    Result := Copy(Result, 2, Length(Result));
end;

end.
