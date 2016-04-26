unit Tests.Installer;

interface

uses
  Generics.Collections,
  TestFramework,
  DN.JSonFile.Uninstallation,
  DN.JsonFile.Installation,
  DN.ProjectInfo.Intf,
  DN.ProjectGroupInfo.Intf,
  Tests.Installer.Interceptor,
  Tests.Mocks.Compiler;

type
  TInstallerTest = class(TTestCase)
  protected
    FSut: TDNInstallerInterceptor;
    FCompiler: TDNCompilerMock;
    procedure SetUp; override;
    procedure TearDown; override;
    function BuildSearchPath(const APath: string): string;
    function BuildSearchPathes(APathes: array of string): string;
    procedure CheckPackage(const APackage: TPackage; const AProject: IDNProjectInfo);
    procedure CheckPackages(const APackages: TArray<TPackage>; const AProjects: TArray<IDNProjectInfo>);
    procedure CheckFolder(const AExpected, AFolder: TMockedDirectory);
    procedure CheckExpert(const AExpected, AExpert: TInstalledExpert);
    //mocked directories
    function MockedFolderAll: TMockedDirectory;
    function MockedFolderXE2: TMockedDirectory;
    function MockedFolderBase: TMockedDirectory;
    //mocked experts
    function MockedExpert: TInstalledExpert;
    function MockedExpertXE2: TInstalledExpert;
    function MockedExpertHotReload: TInstalledExpert;
    //mocked groupprojects
    function MockedGroupProj: IDNProjectGroupInfo;
    function MockedGroupProjXE2: IDNProjectGroupInfo;
  published
    //tests for Delphinus.Info.json
    procedure Install_DelphinusInfo_IsInvalid_Expect_Failure;
    procedure Install_DelphinusInfo_HasNoID_Expect_Failure;
    procedure Install_DelphinusInfo_HasID_Expect_Success;
    //tests for Delphinus.Install.json
    //general
    procedure Install_DelphinusInstallation_IsInvalid_ExpectFailure;
    procedure Install_DelphinusInstallation_IsEmpty_ExpectSuccess;
    //searchpath
    procedure Install_SearchPath_XE_Expect_AllPath;
    procedure Install_SearchPath_XE2_Expect_AllPath_XE2Path;
    procedure Install_SearchPath_XE2Win64_Expect_Win64Path;
    //browsingpath
    procedure Install_BrowsingPath_XE_Expect_AllPath;
    procedure Install_BrowsingPath_XE2_Expect_AllPath_XE2Path;
    procedure Install_BrowsingPath_XE2Win64_Expect_Win64Path;
    //projects
    procedure Install_Projects_XE_Expect_Package_DesignPackage;
    procedure Install_Projects_XE2_Expect_Package_DesignPackage_PackageXE2;
    procedure Install_Projects_Win64_Expect_PackageWin64;
    procedure Install_Projects_Missing_ExpectFailure;
    //projectgroups
    procedure Install_ProjectGroup_Expect_ProjectA_Project_B;
    procedure Install_ProjectGroupXE2_Expect_ProjectA_ProjectB_ProjectXE2;
    //sourcefolders
    procedure Install_SourceFolder_XE__Expect_FolderAll_FolderBase;
    procedure Install_SourceFolder_XE2_Expect_FolderAll_FolderXE2_FolderBase;
    //experts
    procedure Install_Expert_XE_Expect_Expert_ExpertHotReload;
    procedure Install_Expert_XE2_Expect_Expert_ExpertXE2_ExpertHotReload;
  end;

implementation

uses
  SysUtils,
  IOUtils,
  DN.Compiler.Intf,
  Tests.Data,
  Tests.Mocks.Projects;

const
  CSourceDir = 'SourceDir';
  CTargetDir = 'TargetDir';

  CTestPathAll = 'TestPathAll';
  CTestPathXE2 = 'TestPath23';
  CTestPathWin64 = 'TestPathWin64';

  CPackage = 'Package';
  CDesignPackage = 'DesignPackage';
  CPackageXE2 = 'PackageXE2';
  CPackageWin64 = 'PackageWin64';
  CGroup = 'Group';
  CGroupXE2 = 'GroupXE2';

{ TVariableResolverTest }

function TInstallerTest.BuildSearchPath(const APath: string): string;
begin
  Result := TPath.Combine(CTargetDir, TPath.Combine('source', APath));
end;

function TInstallerTest.BuildSearchPathes(APathes: array of string): string;
var
  LPath: string;
begin
  Result := '';
  for LPath in APathes do
  begin
    if Result <> '' then
      Result := Result + ';';
    Result := Result + BuildSearchPath(LPath);
  end;
end;

procedure TInstallerTest.CheckExpert(const AExpected,
  AExpert: TInstalledExpert);
begin
  CheckEquals(AExpected.Expert, AExpert.Expert, 'Expert');
  CheckEquals(AExpert.HotReload, AExpert.HotReload, 'HotReload');
end;

procedure TInstallerTest.CheckFolder(const AExpected,
  AFolder: TMockedDirectory);
var
  i: Integer;
begin
  CheckEquals(AExpected.Source, AFolder.Source, 'Source');
  CheckEquals(AExpected.Target, AFolder.Target, 'Target');
  CheckEquals(Length(AExpected.FileFilters), Length(AFolder.FileFilters), 'FileFilters.Length');
  for i := 0 to Length(AExpected.FileFilters) - 1 do
    CheckEquals(AExpected.FileFilters[i], AFolder.FileFilters[i], 'FileFilters[' + IntToStr(i) + ']');
  CheckEquals(AExpected.Recursive, AFolder.Recursive);
end;

procedure TInstallerTest.CheckPackage(const APackage: TPackage;
  const AProject: IDNProjectInfo);
begin
  CheckEquals('BPLDIR\' + AProject.BinaryName, APackage.BPLFile, 'Binary');
  CheckEquals('DCPDIR\' + AProject.DCPName, APackage.DCPFile, 'DCP');
  CheckEquals(not AProject.IsRuntimeOnlyPackage, APackage.Installed, 'Installed');
end;

procedure TInstallerTest.CheckPackages(const APackages: TArray<TPackage>;
  const AProjects: TArray<IDNProjectInfo>);
var
  i: Integer;
begin
  CheckEquals(Length(AProjects), Length(APackages), 'Packages.Length');
  for i := 0 to High(APackages) do
    CheckPackage(APackages[i], AProjects[i]);
end;

procedure TInstallerTest.Install_BrowsingPath_XE2Win64_Expect_Win64Path;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJsonInstallBrowsingPath;
  FSut.SupportedPlatforms := [cpWin64];
  FCompiler.Version := CCompilerXE2;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(BuildSearchPath(CTestPathWin64), FSut.BrowsingPathes);
end;

procedure TInstallerTest.Install_BrowsingPath_XE2_Expect_AllPath_XE2Path;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJsonInstallBrowsingPath;
  FCompiler.Version := CCompilerXE2;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(BuildSearchPathes([CTestPathAll, CTestPathXE2]), FSut.BrowsingPathes);
end;

procedure TInstallerTest.Install_BrowsingPath_XE_Expect_AllPath;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJsonInstallBrowsingPath;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(BuildSearchPath(CTestPathAll), FSut.BrowsingPathes);
end;

procedure TInstallerTest.Install_DelphinusInfo_HasID_Expect_Success;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonEmptyJSon;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
end;

procedure TInstallerTest.Install_DelphinusInfo_HasNoID_Expect_Failure;
begin
  FSut.InfoResourceName := CJSonEmptyJSon;
  FSut.InstallResourceName := CJSonEmptyJSon;
  CheckFalse(FSut.Install(CSourceDir, CTargetDir));
end;

procedure TInstallerTest.Install_DelphinusInfo_IsInvalid_Expect_Failure;
begin
  FSut.InfoResourceName := CJSonInvalidJSon;
  FSut.InstallResourceName := CJSonEmptyJSon;
  CheckFalse(FSut.Install(CSourceDir, CTargetDir));
end;

procedure TInstallerTest.Install_DelphinusInstallation_IsEmpty_ExpectSuccess;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonEmptyJSon;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
end;

procedure TInstallerTest.Install_DelphinusInstallation_IsInvalid_ExpectFailure;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInvalidJSon;
  CheckFalse(FSut.Install(CSourceDir, CTargetDir));
end;

procedure TInstallerTest.Install_Expert_XE2_Expect_Expert_ExpertXE2_ExpertHotReload;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallExpert;
  FCompiler.Version := CCompilerXE2;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(3, FSut.Experts.Count);
  CheckExpert(MockedExpert, FSut.Experts[0]);
  CheckExpert(MockedExpertXE2, FSut.Experts[1]);
  CheckExpert(MockedExpertHotReload, FSut.Experts[2]);
end;

procedure TInstallerTest.Install_Expert_XE_Expect_Expert_ExpertHotReload;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallExpert;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(2, FSut.Experts.Count);
  CheckExpert(MockedExpert, FSut.Experts[0]);
  CheckExpert(MockedExpertHotReload, FSut.Experts[1]);
end;

procedure TInstallerTest.Install_ProjectGroupXE2_Expect_ProjectA_ProjectB_ProjectXE2;
var
  LProjects: TList<IDNProjectInfo>;
begin
  LProjects := TList<IDNProjectInfo>.Create();
  try
    FSut.InfoResourceName := CJSonBasicInfo;
    FSut.InstallResourceName := CJSonInstallProjectGroup;
    FCompiler.Version := CCompilerXE2;
    FSut.MockedGroupProjects.Add(TPath.Combine(CTargetDir, 'source\' + CGroup + '.groupproj'), MockedGroupProj);
    FSut.MockedGroupProjects.Add(TPath.Combine(CTargetDir, 'source\' + CGroupXE2 + '.groupproj'), MockedGroupProjXE2);
    LProjects.AddRange(MockedGroupProj.Projects);
    LProjects.AddRange(MockedGroupProjXE2.Projects);
    CheckTrue(FSut.Install(CSourceDir, CTargetDir));
    CheckPackages(FSut.Packages.ToArray, LProjects.ToArray);
  finally
    LProjects.Free;
  end;
end;

procedure TInstallerTest.Install_ProjectGroup_Expect_ProjectA_Project_B;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallProjectGroup;
  FSut.MockedGroupProjects.Add(TPath.Combine(CTargetDir, 'source\' + CGroup + '.groupproj'), MockedGroupProj);
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckPackages(FSut.Packages.ToArray, MockedGroupProj.Projects.ToArray);
end;

procedure TInstallerTest.Install_Projects_Missing_ExpectFailure;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallMissingProject;
  CheckFalse(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(0, FSut.Packages.Count, 'Packages');
end;

procedure TInstallerTest.Install_Projects_Win64_Expect_PackageWin64;
var
  LPackage, LDesignPackage, LPackageWin64: IDNProjectInfo;
begin
  LPackage := MockProjectBPL(CPackage, [cpWin32], False);
  LDesignPackage := MockProjectBPL(CDesignPackage, [cpWin32], True);
  LPackageWin64 := MockProjectBPL(CPackageWin64, [cpWin64], False);
  FSut.MockedProjects.Add(TPath.Combine(CTargetDir, 'source\' + CPackage + '.dproj'), LPackage);
  FSut.MockedProjects.Add(TPath.Combine(CTargetDir, 'source\' + CDesignPackage + '.dproj'), LDesignPackage);
  FSut.MockedProjects.Add(TPath.Combine(CTargetDir, 'source\' + CPackageWin64 + '.dproj'), LPackageWin64);
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallProject;
  FSut.SupportedPlatforms := [cpWin64];
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(1, FSut.Packages.Count, 'Packages');
  CheckPackage(FSut.Packages[0], LPackageWin64);
end;

procedure TInstallerTest.Install_Projects_XE2_Expect_Package_DesignPackage_PackageXE2;
var
  LPackage, LDesignPackage, LPackageXE2, LPackageWin64: IDNProjectInfo;
begin
  LPackage := MockProjectBPL(CPackage, [cpWin32], False);
  LDesignPackage := MockProjectBPL(CDesignPackage, [cpWin32], True);
  LPackageXE2 := MockProjectBPL(CPackageXE2, [cpWin32], False);
  LPackageWin64 := MockProjectBPL(CPackageWin64, [cpWin64], False);
  FSut.MockedProjects.Add(TPath.Combine(CTargetDir, 'source\' + CPackage + '.dproj'), LPackage);
  FSut.MockedProjects.Add(TPath.Combine(CTargetDir, 'source\' + CDesignPackage + '.dproj'), LDesignPackage);
  FSut.MockedProjects.Add(TPath.Combine(CTargetDir, 'source\' + CPackageXE2 + '.dproj'), LPackageXE2);
  FSut.MockedProjects.Add(TPath.Combine(CTargetDir, 'source\' + CPackageWin64 + '.dproj'), LPackageWin64);
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallProject;
  FCompiler.Version := CCompilerXE2;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(3, FSut.Packages.Count, 'Packages');
  CheckPackage(FSut.Packages[0], LPackage);
  CheckPackage(FSut.Packages[1], LDesignPackage);
  CheckPackage(FSut.Packages[2], LPackageXE2);
end;

procedure TInstallerTest.Install_Projects_XE_Expect_Package_DesignPackage;
var
  LPackage, LDesignPackage, LPackageWin64: IDNProjectInfo;
begin
  LPackage := MockProjectBPL(CPackage, [cpWin32], False);
  LDesignPackage := MockProjectBPL(CDesignPackage, [cpWin32], True);
  LPackageWin64 := MockProjectBPL(CPackageWin64, [cpWin64], False);
  FSut.MockedProjects.Add(TPath.Combine(CTargetDir, 'source\' + CPackage + '.dproj'), LPackage);
  FSut.MockedProjects.Add(TPath.Combine(CTargetDir, 'source\' + CDesignPackage + '.dproj'), LDesignPackage);
  FSut.MockedProjects.Add(TPath.Combine(CTargetDir, 'source\' + CPackageWin64 + '.dproj'), LPackageWin64);
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallProject;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(2, FSut.Packages.Count, 'Packages');
  CheckPackage(FSut.Packages[0], LPackage);
  CheckPackage(FSut.Packages[1], LDesignPackage);
end;

procedure TInstallerTest.Install_SearchPath_XE2Win64_Expect_Win64Path;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallSearchPath;
  FSut.SupportedPlatforms := [cpWin64];
  FCompiler.Version := CCompilerXE2;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(BuildSearchPath(CTestPathWin64), FSut.SearchPathes);
end;

procedure TInstallerTest.Install_SearchPath_XE2_Expect_AllPath_XE2Path;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallSearchPath;
  FCompiler.Version := CCompilerXE2;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(BuildSearchPathes([CTestPathAll, CTestPathXE2]), FSut.SearchPathes);
end;

procedure TInstallerTest.Install_SearchPath_XE_Expect_AllPath;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallSearchPath;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(BuildSearchPath(CTestPathAll), FSut.SearchPathes);
end;

procedure TInstallerTest.Install_SourceFolder_XE2_Expect_FolderAll_FolderXE2_FolderBase;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallSourceFolder;
  FCompiler.Version := CCompilerXE2;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(3, FSut.CopiedDirectories.Count, 'CopiedDirectories.Count');
  CheckFolder(MockedFolderAll, FSut.CopiedDirectories[0]);
  CheckFolder(MockedFolderXE2, FSut.CopiedDirectories[1]);
  CheckFolder(MockedFolderBase, FSut.CopiedDirectories[2]);
end;

procedure TInstallerTest.Install_SourceFolder_XE__Expect_FolderAll_FolderBase;
begin
  FSut.InfoResourceName := CJSonBasicInfo;
  FSut.InstallResourceName := CJSonInstallSourceFolder;
  CheckTrue(FSut.Install(CSourceDir, CTargetDir));
  CheckEquals(2, FSut.CopiedDirectories.Count, 'CopiedDirectories.Count');
  CheckFolder(MockedFolderAll, FSut.CopiedDirectories[0]);
  CheckFolder(MockedFolderBase, FSut.CopiedDirectories[1]);
end;

function TInstallerTest.MockedExpert: TInstalledExpert;
begin
  Result.Expert := TPath.Combine(CTargetDir, 'bin\Win32\Release\Foo.dll');
end;

function TInstallerTest.MockedExpertHotReload: TInstalledExpert;
begin
  Result.Expert := TPath.Combine(CTargetDir, 'bin\Win32\Release\FooHotReload.dll');
  Result.HotReload := True;
end;

function TInstallerTest.MockedExpertXE2: TInstalledExpert;
begin
  Result.Expert := TPath.Combine(CTargetDir, 'bin\Win32\Release\FooXE2.dll');
end;

function TInstallerTest.MockedFolderAll: TMockedDirectory;
begin
  Result.Source := TPath.Combine(CSourceDir, 'FolderAll');
  Result.Target := TPath.Combine(CTargetDir, 'source\FolderAll');
  SetLength(Result.FileFilters, 2);
  Result.FileFilters[0] := '*';
  Result.FileFilters[1] := '*.*';
  Result.Recursive := True;
end;

function TInstallerTest.MockedFolderBase: TMockedDirectory;
begin
  Result.Source := TPath.Combine(CSourceDir, 'Base\Folder');
  Result.Target := TPath.Combine(CTargetDir, 'source\Folder');
end;

function TInstallerTest.MockedFolderXE2: TMockedDirectory;
begin
  Result.Source := TPath.Combine(CSourceDir, 'FolderXE2');
  Result.Target := TPath.Combine(CTargetDir, 'source\FolderXE2');
end;

function TInstallerTest.MockedGroupProj: IDNProjectGroupInfo;
var
  LGroup: TMockedGroupProjectInfo;
begin
  LGroup := TMockedGroupProjectInfo.Create();
  LGroup.Projects.Add(MockProjectBPL('ProjectA', [cpWin32], False));
  LGroup.Projects.Add(MockProjectBPL('ProjectB', [cpWin32], True));
  Result := LGroup;
end;

function TInstallerTest.MockedGroupProjXE2: IDNProjectGroupInfo;
var
  LGroup: TMockedGroupProjectInfo;
begin
  LGroup := TMockedGroupProjectInfo.Create();
  LGroup.Projects.Add(MockProjectBPL('ProjectXE2', [cpWin32], False));
  Result := LGroup;
end;

procedure TInstallerTest.SetUp;
begin
  inherited;
  FCompiler := TDNCompilerMock.Create();
  FCompiler.Version := CCompilerXE;
  FSut := TDNInstallerInterceptor.Create(FCompiler as IDNCompiler);
  FSut.SupportedPlatforms := [cpWin32];
end;

procedure TInstallerTest.TearDown;
begin
  inherited;
  FSut.Free;
end;

initialization
  RegisterTest(TInstallerTest.Suite);

end.
