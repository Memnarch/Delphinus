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
  DN.ProjectGroupInfo.Intf,
  DN.JSonFile.Installation,
  DN.JSonFile.Uninstallation,
  DN.JSonFile.Info,
  DN.Progress.Intf,
  DN.ExpertService.Intf,
  DN.VariableResolver.Compiler.Factory;

type
  TDNInstaller = class(TInterfacedObject, IDNInstaller, IDNProgress)
  private
    FCompiler: IDNCompiler;
    FExpertService: IDNExpertService;
    FOnMessage: TMessageEvent;
    FProgress: IDNProgress;
    FTargetDirectory: string;
    FHasPendingChanges: Boolean;
    procedure ProcessPathes(const APathes: TArray<TSearchPath>; const ARootDirectory: string; APathType: TPathType);
    procedure ProcessSourceFolders(const ASourceFolders: TArray<TFolder>; const ASourceDirectory, ATargetDirectory: string);
    function ProcessProjects(const AProjects: TArray<TProject>; const ATargetDirectory: string): Boolean;
    function ProcessProject(const AProject: IDNProjectInfo): Boolean;
    function ProcessExperts(const AExperts: TArray<TExpert>): Boolean;
    function ProcessRawFolders(const ARawFolders: TArray<TRawFolder>; const ASourceDirectory: string): Boolean;
    function ProcessRawFolder(const ARawFolder, ASourceDirectory: string): Boolean;
    function RegisterRawDesignBPLs(const ADesignBPLs: TArray<string>): Boolean;
    function IsSupported(ACompiler_Min, ACompiler_Max: Integer): Boolean;
    function FileMatchesFilter(const AFile: string; const AFilter: TStringDynArray): Boolean;
    procedure ProcessLibPathes;
    procedure Reset();
    function GetOnMessage: TMessageEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
    function GetSourceFolder(const ADirectory: string): string;
    function UndecoratePath(const APath: string): string;
    function LoadSupportedProjects(const ABaseDirectory: string; const AProjects: TArray<TProject>; ASupportedProjects: TList<IDNProjectInfo>): Boolean;
  protected
    FSearchPathes: string;
    FBrowsingPathes: string;
    FPackages: TList<TPackage>;
    FExperts: TList<TInstalledExpert>;
    FRawFiles: TStringList;
    FVariableResolverFactory: TDNCompilerVariableResolverFacory;
    procedure DoMessage(AType: TMessageType; const AMessage: string); virtual;
    procedure CopyDirectory(const ASource, ATarget: string; AFileFilters: TStringDynArray; ARecursive: Boolean = False; ACopiedFiles: TStringList = nil); virtual;
    procedure AddSearchPath(const ASearchPath: string; const APlatforms: TDNCompilerPlatforms); virtual;
    procedure AddBrowsingPath(const ABrowsingPath: string; const APlatforms: TDNCompilerPlatforms); virtual;
    procedure BeforeCompile(const AProjectFile: string); virtual;
    procedure AfterCompile(const AProjectFile: string; const ALog: TStrings; ASuccessFull: Boolean); virtual;
    function InstallBPL(const ABPL: string): Boolean; virtual;
    function InstallExpert(const AExpert: string; AHotReload: Boolean): Boolean; virtual;
    function CopyMetaData(const ASourceDirectory, ATargetDirectory: string): Boolean; virtual;
    procedure CopyLicense(const ASourceDirectory, ATargetDirectory, ALicense: string); virtual;
    function GetSupportedPlatforms: TDNCompilerPlatforms; virtual; abstract;
    procedure ConfigureCompiler(const ACompiler: IDNCompiler); virtual;
    function GetTargetDirectory: string; virtual;
    function GetLibBaseDir: string; virtual;
    function GetBinBaseDir: string; virtual;
    function GetBPLDir(APlatform: TDNCompilerPlatform): string; virtual; abstract;
    function GetDCPDir(APlatform: TDNCompilerPlatform): string; virtual; abstract;
    function GetHasPendingChanges: Boolean; virtual;
    function PrepareInstallationDirectory(const ATargetDirectory: string): Boolean; virtual;
    function LoadInfo(const ADirectory: string; AInfo: TInfoFile): Boolean; virtual;
    function ValidateInfoAndGetLicenceFile(const ADirectory: string; out ALicenceFile: string): Boolean; virtual;
    function LoadInstallation(const ADirectory: string; AInstallation: TInstallationFile): Boolean; virtual;
    function ProcessInstallation(AInstallation: TInstallationFile;
      const ASourceDirectory, ATargetDirectory, ALicenceFile: string): Boolean; virtual;
    procedure SaveUninstall(const ATargetDirectory: string); virtual;
    function LoadProject(const AProjectFile: string; out AProject: IDNProjectInfo): Boolean; virtual;
    function LoadProjectGroup(const AGroupFile: string; out AGroup: IDNProjectGroupInfo): Boolean; virtual;
    //properties for interface redirection
    property Progress: IDNProgress read FProgress implements IDNProgress;
  public
    constructor Create(const ACompiler: IDNCompiler;
      const AVariableResolverFactory: TDNCompilerVariableResolverFacory;
      const AExpertService: IDNExpertService = nil);
    destructor Destroy(); override;
    function Install(const ASourceDirectory, ATargetDirectory: string): Boolean; virtual;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
    property HasPendingChanges: Boolean read GetHasPendingChanges;
  end;

implementation

uses
  IOUtils,
  StrUtils,
  Masks,
  DN.Utils,
  DN.ProjectInfo,
  DN.ProjectGroupInfo,
  DN.Uninstaller.Intf,
  DN.Progress,
  DN.VariableResolver.Intf;

const
  CLibDir = 'lib';
  CBinDir = 'bin';
  CBPLDir = 'bpl';
  CDCPDir = 'dcp';
  CDesignBPL = 'DesignBPL';
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
  ACompiler.DCUOutput := TPath.Combine(GetLibBaseDir(), '$(Platform)\$(Config)');
  ACompiler.ExeOutput := TPath.Combine(GetBinBaseDir(), '$(Platform)\$(Config)');
  ACompiler.BPLOutput := GetBPLDir(ACompiler.Platform);
  ACompiler.DCPOutput := GetDCPDir(ACompiler.Platform);
end;

procedure TDNInstaller.CopyDirectory(const ASource, ATarget: string; AFileFilters: TStringDynArray; ARecursive: Boolean = False; ACopiedFiles: TStringList = nil);
var
  LDirectories, LFiles: TStringDynArray;
  LDirectory, LFile, LFileName, LTargetFile: string;
  LForcedDirectory: Boolean;
begin
  LForcedDirectory := False;
  if ARecursive then
  begin
    LDirectories := TDirectory.GetDirectories(ASource);
    for LDirectory in LDirectories do
    begin
      CopyDirectory(LDirectory, TPath.Combine(ATarget, ExtractFileName(LDirectory)), AFileFilters, ARecursive, ACopiedFiles);
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
      LTargetFile := TPath.Combine(ATarget, LFileName);
      TFile.Copy(LFile, LTargetFile, True);
      if Assigned(ACopiedFiles) then
        ACopiedFiles.Add(LTargetFile);
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

constructor TDNInstaller.Create(const ACompiler: IDNCompiler;
  const AVariableResolverFactory: TDNCompilerVariableResolverFacory;
  const AExpertService: IDNExpertService);
begin
  inherited Create();
  FCompiler := ACompiler;
  FVariableResolverFactory := AVariableResolverFactory;
  FExpertService := AExpertService;
  FPackages := TList<TPackage>.Create();
  FProgress := TDNProgress.Create();
  FRawFiles := TStringList.Create();
  FExperts := TList<TInstalledExpert>.Create();
end;

destructor TDNInstaller.Destroy;
begin
  FPackages.Free();
  FRawFiles.Free();
  FExperts.Free();
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

function TDNInstaller.GetHasPendingChanges: Boolean;
begin
  Result := FHasPendingChanges;
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

function TDNInstaller.LoadInfo(const ADirectory: string;
  AInfo: TInfoFile): Boolean;
var
  LInfoFile: string;
begin
  LInfoFile := TPath.Combine(ADirectory, CInfoFile);
  if TFile.Exists(LInfoFile) then
  begin
    Result := AInfo.LoadFromFile(LInfoFile);
    if not Result then
    begin
      DoMessage(mtError, CInfoFile + ' seems to be corrupt');
      Exit(False);
    end;
  end
  else
  begin
    DoMessage(mtError, 'no info-file provided');
    Exit(False);
  end;
end;

function TDNInstaller.LoadInstallation(const ADirectory: string;
  AInstallation: TInstallationFile): Boolean;
var
  LInstallerFile: string;
begin
  Result := False;
  LInstallerFile := TPath.Combine(ADirectory, CInstallFile);
  if TFile.Exists(LInstallerFile) then
  begin
    Result := AInstallation.LoadFromFile(LInstallerFile);
    if not Result then
    begin
      DoMessage(mtError, CInstallFile + ' seems to be invalid json');
    end;
  end
  else
  begin
    DoMessage(mtError, 'No installation file');
  end;
end;

function TDNInstaller.LoadProject(const AProjectFile: string;
  out AProject: IDNProjectInfo): Boolean;
begin
  AProject := TDNProjectInfo.Create();
  Result := AProject.LoadFromFile(AProjectFile);
  if not  Result then
  begin
    DoMessage(mtError, 'Failed to load project ' + AProjectFile);
    DoMessage(mtError, AProject.LoadingError);
  end;
end;

function TDNInstaller.LoadProjectGroup(const AGroupFile: string;
  out AGroup: IDNProjectGroupInfo): Boolean;
begin
  AGroup := TDNProjectGroupInfo.Create();
  Result := AGroup.LoadFromFile(AGroupFile);
  if not Result then
  begin
    DoMessage(mtError, 'Failed to load group ' + AGroupFile);
    DoMessage(mtError, AGroup.LoadingError);
  end;
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
          if LoadProject(TPath.Combine(ABaseDirectory, LProject.Project), LInfo) then
          begin
            if ((GetSupportedPlatforms * LInfo.SupportedPlatforms) <> []) then
              ASupportedProjects.Add(LInfo);
          end
          else
            Exit(False);
        end;
        1:
        begin
          if LoadProjectGroup(TPath.Combine(ABaseDirectory,  LProject.Project), LGroup) then
          begin
            for LInfo in LGroup.Projects do
            begin
              if ((GetSupportedPlatforms * LInfo.SupportedPlatforms) <> [])  then
                ASupportedProjects.Add(LInfo);
            end;
          end
          else
            Exit(False)
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
  LLicenseFile: string;
begin
  Reset();
  Result := False;
  if not PrepareInstallationDirectory(ATargetDirectory) then
    Exit;
  try
    FTargetDirectory := ATargetDirectory;
    if not ValidateInfoAndGetLicenceFile(ASourceDirectory, LLicenseFile) then
      Exit;

    LInstallInfo := TInstallationFile.Create();
    try
      if LoadInstallation(ASourceDirectory, LInstallInfo) then
        Result := ProcessInstallation(LInstallInfo, ASourceDirectory, ATargetDirectory, LLicenseFile);
    finally
      LInstallInfo.Free;
    end;

  finally
    SaveUninstall(ATargetDirectory);
  end;
end;

function TDNInstaller.InstallBPL(const ABPL: string): Boolean;
begin
  Result := True;
end;

function TDNInstaller.InstallExpert(const AExpert: string;
  AHotReload: Boolean): Boolean;
var
  LResult: Boolean;
begin
  Result := TFile.Exists(AExpert);
  if Result then
  begin
    DoMessage(mtNotification, AExpert);
    if Assigned(FExpertService) then
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          LResult := FExpertService.RegisterExpert(AExpert, AHotReload);
        end);
      Result := LResult;
      FHasPendingChanges := FHasPendingChanges or not AHotReload;
    end;
  end
  else
  begin
    DoMessage(mtError, 'File not found: ' + AExpert);
  end;
end;

function TDNInstaller.IsSupported(ACompiler_Min, ACompiler_Max: Integer): Boolean;
begin
  Result := True;

  if ACompiler_Min > 0 then
    Result := Result and (Trunc(FCompiler.Version) >= ACompiler_Min);

  if ACompiler_Max > 0 then
    Result := Result and (Trunc(FCompiler.Version) <= ACompiler_Max);
end;

function TDNInstaller.ProcessProject(const AProject: IDNProjectInfo): Boolean;
var
  LCompiledPackage: TPackage;
  LPlatform: TDNCompilerPlatform;
  LResolver: IVariableResolver;
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
      LResolver := FVariableResolverFactory(FCompiler.Platform, FCompiler.Config);

      Result := FCompiler.Compile(AProject.FileName);
      if Result and AProject.IsPackage then
      begin
        if (not AProject.IsRuntimeOnlyPackage) and (LPlatform = cpWin32) then
        begin
          Result := InstallBPL(TPath.Combine(LResolver.Resolve(FCompiler.BPLOutput), AProject.BinaryName));
          if Result then
            DoMessage(mtNotification, 'installed')
          else
            DoMessage(mtError, 'failed to install');
        end;

        if LPlatform = cpOSX32 then
        begin
          LCompiledPackage.BPLFile := TPath.Combine(LResolver.Resolve(FCompiler.BPLOutput), CMacPackagePrefix + AProject.BinaryName);
          LCompiledPackage.BPLFile := ChangeFileExt(LCompiledPackage.BPLFile, CMacPackageExtension);
        end
        else
        begin
          LCompiledPackage.BPLFile := TPath.Combine(LResolver.Resolve(FCompiler.BPLOutput), AProject.BinaryName);
        end;

        LCompiledPackage.DCPFile := TPath.Combine(LResolver.Resolve(FCompiler.DCPOutput), AProject.DCPName);
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
  i: Integer;
begin
  LProjects := TList<IDNProjectInfo>.Create();
  try
    Result := LoadSupportedProjects(GetSourceFolder(ATargetDirectory), AProjects, LProjects);
    if Result then
    begin
      for i := 0 to LProjects.Count - 1 do
      begin
        LProject := LProjects[i];
        FProgress.SetTaskProgress(ExtractFileName(LProject.FileName), i, LProjects.Count);
        Result := ProcessProject(LProject);
        if not Result then
          Break;
      end;
    end;
  finally
    LProjects.Free;
  end;
end;

function TDNInstaller.ProcessRawFolder(const ARawFolder, ASourceDirectory: string): Boolean;
var
  LRawFolder, LSourceFolder: string;
  LSourceLib, LSourceBin, LSourceDCP, LSourceBPL, LSourceDesignBPL: string;
  LPlatformName, LConfig, LPlatformConfig: string;
  LPlatform: TDNCompilerPlatform;
  LDesignBPLs: TStringList;
  LBPLFilter: TStringDynArray;
  LResolver: IVariableResolver;
begin
  Result := True;
  DoMessage(mtNotification, ARawFolder);
  LRawFolder := TPath.Combine(ASourceDirectory, ARawFolder);

  LSourceLib := TPath.Combine(LRawFolder, CLibDir);
  LSourceBin := TPath.Combine(LRawFolder, CBinDir);
  LSourceDCP := TPath.Combine(LRawFolder, CDCPDir);
  LSourceBPL := TPath.Combine(LRawFolder, CBPLDir);
  LSourceDesignBPL := TPath.Combine(LRawFolder, CDesignBPL);
  LConfig := TDNCompilerConfigName[ccRelease];

  for LPlatform in GetSupportedPlatforms() do
  begin
    LPlatformName := TDNCompilerPlatformName[LPlatform];
    LPlatformConfig := IncludeTrailingPathDelimiter(LPlatformName) + LConfig;
    LResolver := FVariableResolverFactory(LPlatform, ccRelease);

    LSourceFolder := TPath.Combine(LSourceLib, LPlatformName);
    if TDirectory.Exists(LSourceFolder) then
      CopyDirectory(LSourceFolder, TPath.Combine(GetLibBaseDir(), LPlatformConfig), nil, True);

    LSourceFolder := TPath.Combine(LSourceBin, LPlatformName);
    if TDirectory.Exists(LSourceFolder) then
      CopyDirectory(LSourceFolder, TPath.Combine(GetBinBaseDir(), LPlatformConfig), nil, True);

    LSourceFolder := TPath.Combine(LSourceDCP, LPlatformName);
    if TDirectory.Exists(LSourceFolder) then
      CopyDirectory(LSourceFolder, LResolver.Resolve(GetDCPDir(LPlatform)), nil, False, FRawFiles);

    LSourceFolder := TPath.Combine(LSourceBPL, LPlatformName);
    if TDirectory.Exists(LSourceFolder) then
      CopyDirectory(LSourceFolder, LResolver.Resolve(GetBPLDir(LPlatform)), nil, False, FRawFiles);

    if LPlatform = cpWin32 then
    begin
      LDesignBPLs := TStringList.Create();
      try
        SetLength(LBPLFilter, 1);
        LBPLFilter[0] := '*.bpl';
        LSourceFolder := TPath.Combine(LSourceDesignBPL, LPlatformName);
        if TDirectory.Exists(LSourceFolder) then
        begin
          CopyDirectory(LSourceFolder, LResolver.Resolve(GetBPLDir(LPlatform)), LBPLFilter, False, LDesignBPLs);
          Result := RegisterRawDesignBPLs(LDesignBPLs.ToStringArray);
          if not Result then
            Break;
        end;
      finally
        LDesignBPLs.Free;
      end;
    end;
  end;
end;

function TDNInstaller.ProcessRawFolders(const ARawFolders: TArray<TRawFolder>;
  const ASourceDirectory: string): Boolean;
var
  LFolder: TRawFolder;
begin
  Result := True;
  if Length(ARawFolders) > 0 then
    DoMessage(mtNotification, 'copying rawfolders:');
  for LFolder in ARawFolders do
  begin
    if IsSupported(LFolder.CompilerMin, LFolder.CompilerMax) then
      Result := Result and ProcessRawFolder(LFolder.Folder, ASourceDirectory);
    if not Result then
      Break;
  end;
end;

function TDNInstaller.PrepareInstallationDirectory(
  const ATargetDirectory: string): Boolean;
begin
  Result := ForceDirectories(ATargetDirectory);
  if not Result then
    DoMessage(mtError, 'Failed to create directory ' + QuotedStr(ATargetDirectory));
end;

function TDNInstaller.ProcessExperts(const AExperts: TArray<TExpert>): Boolean;
var
  LExpert: TExpert;
  LBaseDir, LExpertFile: string;
  LInstalledExpert: TInstalledExpert;
begin
  Result := True;
  if Length(AExperts) > 0 then
    DoMessage(mtNotification, 'Installing Experts:');

  LBaseDir := TPath.Combine(TPath.Combine(GetBinBaseDir, TDNCompilerPlatformName[cpWin32]), TDNCompilerConfigName[ccRelease]);
  for LExpert in AExperts do
  begin
    if IsSupported(LExpert.CompilerMin, LExpert.CompilerMax) then
    begin
      LExpertFile := TPath.Combine(LBaseDir, LExpert.Expert);
      LInstalledExpert.Expert := LExpertFile;
      LInstalledExpert.HotReload := LExpert.HotReload;
      FExperts.Add(LInstalledExpert);
      Result := InstallExpert(LExpertFile, LExpert.HotReload);
    end;
    if not Result then
      Break;
  end;
end;

function TDNInstaller.ProcessInstallation(AInstallation: TInstallationFile;
  const ASourceDirectory, ATargetDirectory, ALicenceFile: string): Boolean;
begin
  FProgress.SetTasks(['Copy Raw', 'Copy Source', 'Compile Projects', 'Adding Experts', 'Adding Pathes']);
  ProcessRawFolders(AInstallation.RawFolders.ToArray, ASourceDirectory);
  FProgress.NextTask();

  ProcessSourceFolders(AInstallation.SourceFolders.ToArray, ASourceDirectory, GetSourceFolder(ATargetDirectory));
  CopyMetaData(ASourceDirectory, ATargetDirectory);
  CopyLicense(ASourceDirectory, ATargetDirectory, ALicenceFile);
  FProgress.NextTask();

  Result := ProcessProjects(AInstallation.Projects.ToArray, ATargetDirectory);
  FProgress.NextTask();

  Result := Result and ProcessExperts(AInstallation.Experts.ToArray);
  FProgress.NextTask();

  FProgress.SetTaskProgress('Libpath', 0, 2);
  ProcessLibPathes();
  FProgress.SetTaskProgress('SearchPath', 1, 2);
  ProcessPathes(AInstallation.SearchPathes.ToArray, ATargetDirectory, tpSearchPath);
  FProgress.SetTaskProgress('BrowsingPath', 2, 2);
  ProcessPathes(AInstallation.BrowsingPathes.ToArray, ATargetDirectory, tpBrowsingPath);
  FProgress.Completed();
end;

procedure TDNInstaller.ProcessLibPathes;
var
  LPlatform: TDNCompilerPlatform;
  LSubDirs: TStringDynArray;
  LPlatformDir, LSubDir: string;
begin
  DoMessage(mtNotification, 'Adding Libpathes:');
  for LPlatform in GetSupportedPlatforms() do
  begin
    LPlatformDir := TPath.Combine(GetLibBaseDir(), TDNCompilerPlatformName[LPlatform]);
    if TDirectory.Exists(LPlatformDir) then
    begin
      LSubDirs := TDirectory.GetDirectories(LPlatformDir, TSEarchOption.soAllDirectories, nil);
      for LSubDir in LSubDirs do
        if Length(TDirectory.GetFiles(LSubDir)) > 0 then
        begin
          DoMessage(mtNotification, LSubDir);
          AddSearchPath(LSubDir, [LPlatform]);
        end;
    end;
  end;
end;

procedure TDNInstaller.ProcessPathes(const APathes: TArray<TSearchPath>; const ARootDirectory: string; APathType: TPathType);
var
  LPathes: TStringDynArray;
  LPath: TSearchPath;
  LRelPath, LBasePath, LFullPath: string;
  LPlatforms: TDNCompilerPlatforms;
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
      LPlatforms := LPath.Platforms * GetSupportedPlatforms();
      if IsSupported(LPath.CompilerMin, LPath.CompilerMax) and (LPlatforms <> []) then
      begin
        LPathes := SplitString(LPath.Path, ';');
        for LRelPath in LPathes do
        begin
          DoMessage(mtNotification, LRelPath);
          LFullPath := TPath.Combine(LBasePath, UndecoratePath(LRelPath));
          case APathType of
            tpSearchPath: AddSearchPath(LFullPath, LPlatforms);
            tpBrowsingPath: AddBrowsingPath(LFullPath, LPlatforms);
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
          begin
            LRelTargetPath := Copy(LRelTargetPath, Length(LBase) + 1, Length(LRelTargetPath));
            LRelTargetPath := ExcludeTrailingPathDelimiter(LRelTargetPath);
          end
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

function TDNInstaller.RegisterRawDesignBPLs(
  const ADesignBPLs: TArray<string>): Boolean;
var
  LBPL: string;
  LPackage: TPackage;
begin
  Result := True;
  for LBPL in ADesignBPLs do
  begin
    LPackage.BPLFile := LBPL;
    LPackage.Installed := True;
    FPackages.Add(LPackage);
    Result := InstallBPL(LBPL);
    if not Result then
      Break;
  end;
end;

procedure TDNInstaller.Reset;
begin
  FSearchPathes := '';
  FBrowsingPathes := '';
  FPackages.Clear();
  FRawFiles.Clear;
  FExperts.Clear();
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
    LUninstall.RawFiles := FRawFiles.ToStringArray;
    LUninstall.Experts := FExperts.ToArray;
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

function TDNInstaller.ValidateInfoAndGetLicenceFile(const ADirectory: string;
  out ALicenceFile: string): Boolean;
var
  LInfo: TInfoFile;
begin
  LInfo := TInfoFile.Create();
  try
    Result := LoadInfo(ADirectory, LInfo);
    if Result then
    begin
      if LInfo.ID = TGuid.Empty then
      begin
        DoMessage(mtError, 'no ID provided');
        Exit(False);
      end;
      if LInfo.LicenseType <> '' then
        ALicenceFile := LInfo.LicenseFile
      else
        ALicenceFile := '';
    end;
  finally
    LInfo.Free;
  end;
end;

end.
