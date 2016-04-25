unit Tests.Uninstaller;

interface

uses
  TestFramework,
  DN.JSonFile.Uninstallation,
  Tests.Uninstaller.Interceptor;

type
  TUninstallerTests = class(TTestCase)
  private
    FSut: TDNUninstallerInterceptor;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure CheckStrings(const AExpected, AValues: TArray<string>; const AMessage: string);
    procedure CheckExperts(const AExpected, AValues: TArray<TInstalledExpert>);
    function MockedSearchPathes: TArray<string>;
    function MockedDeletedDirs: TArray<string>;
    function MockedRawFiles: TArray<string>;
    function MockedComponentFiles: TArray<string>;
    function MockedInstalledPackages: TArray<string>;
    function MockedExperts: TArray<TInstalledExpert>;
  published
    procedure Uninstall_InvalidJSon_Expect_Failure;
    procedure Uninstall_Empty_Expect_Success_TargetDirDeleted;
    procedure Uninstall_SearchPathes_Expect_PathA_PathB;
    procedure Uninstall_BrowsingPathes_Expect_PathA_PathB;
    procedure Uninstall_RawFiles_Expect_Foo_FooB;
    procedure Uninstall_Packages_Expect_Foo_Installed_Mac;
    procedure Uninstall_Experts_Expect_Foo_Hot;
  end;


implementation

uses
  Tests.Data,
  SysUtils,
  IOUtils;

const
  CTargetDir = 'TargetDir';

{ TUninstallerTests }

procedure TUninstallerTests.CheckExperts(const AExpected,
  AValues: TArray<TInstalledExpert>);
var
  i: Integer;
begin
  CheckEquals(Length(AExpected), Length(AValues), 'Experts.Length');
  for i := 0 to Length(AExpected) - 1 do
  begin
    CheckEquals(AExpected[i].Expert, AValues[i].Expert, 'Experts[' + IntToStr(i) + '].Expert');
    CheckEquals(AExpected[i].HotReload, AValues[i].HotReload, 'Experts[' + IntToStr(i) + '].HotReload');
  end;
end;

procedure TUninstallerTests.CheckStrings(const AExpected,
  AValues: TArray<string>; const AMessage: string);
var
  i: Integer;
begin
  CheckEquals(Length(AExpected), Length(AValues), AMessage + '.Length');
  for i := 0 to Length(AExpected) - 1 do
    CheckEquals(AExpected[i], AValues[i], AMessage + '[' + IntToStr(i) + ']');
end;

function TUninstallerTests.MockedComponentFiles: TArray<string>;
begin
  SetLength(Result, 12);

  Result[0] := 'Mac.dylib';
  Result[1] := 'Mac.dcp';
  Result[2] := 'Mac.info.plist';
  Result[3] := 'Mac.entitlements';

  Result[4] := 'Installed.bpl';
  Result[5] := 'Installed.dcp';
  Result[6] := 'Installed.bpi';
  Result[7] := 'Installed.lib';

  Result[8] := 'Foo.bpl';
  Result[9] := 'Foo.dcp';
  Result[10] := 'Foo.bpi';
  Result[11] := 'Foo.lib';
end;

function TUninstallerTests.MockedDeletedDirs: TArray<string>;
begin
  SetLength(Result, 1);
  Result[0] := CTargetDir;
end;

function TUninstallerTests.MockedExperts: TArray<TInstalledExpert>;
begin
  SetLength(Result, 2);
  Result[0].Expert := 'Foo.dll';
  Result[0].HotReload := False;
  Result[1].Expert := 'Hot.dll';
  Result[1].HotReload := True;
end;

function TUninstallerTests.MockedInstalledPackages: TArray<string>;
begin
  SetLength(Result, 1);
  Result[0] := 'Installed.bpl';
end;

function TUninstallerTests.MockedRawFiles: TArray<string>;
begin
  SetLength(Result, 2);
  Result[0] := 'Foo.txt';
  Result[1] := 'Folder\FooB.txt';
end;

function TUninstallerTests.MockedSearchPathes: TArray<string>;
begin
  SetLength(Result, 2);
  Result[0] := TPath.Combine(CTargetDir, 'PathA');
  Result[1] := TPath.Combine(CTargetDir, 'PathB\SubFolder');
end;

procedure TUninstallerTests.SetUp;
begin
  inherited;
  FSut := TDNUninstallerInterceptor.Create();
end;

procedure TUninstallerTests.TearDown;
begin
  inherited;
  FSut.Free;
end;

procedure TUninstallerTests.Uninstall_BrowsingPathes_Expect_PathA_PathB;
begin
  FSut.UninstallResourceName := CJSonUninstallBrowsingPathes;
  CheckTrue(FSut.Uninstall(CTargetDir));
  CheckStrings(MockedSearchPathes, FSut.RemovedBrowsingPathes.ToArray, 'BrowsingPathes');
end;

procedure TUninstallerTests.Uninstall_Empty_Expect_Success_TargetDirDeleted;
begin
  FSut.UninstallResourceName := CJSonEmptyJSon;
  CheckTrue(FSut.Uninstall(CTargetDir));
  CheckStrings(MockedDeletedDirs, FSut.DeletedDirectories.ToArray, 'DeletedDirs');
end;

procedure TUninstallerTests.Uninstall_Experts_Expect_Foo_Hot;
begin
  FSut.UninstallResourceName := CJSonUninstallExperts;
  CheckTrue(FSut.Uninstall(CTargetDir));
  CheckExperts(MockedExperts, FSut.UninstalledExperts.ToArray);
end;

procedure TUninstallerTests.Uninstall_InvalidJSon_Expect_Failure;
begin
  FSut.UninstallResourceName := CJSonInvalidJSon;
  CheckFalse(FSut.Uninstall(CTargetDir));
end;

procedure TUninstallerTests.Uninstall_Packages_Expect_Foo_Installed_Mac;
begin
  FSut.UninstallResourceName := CJSonUninstalllPackages;
  CheckTrue(FSut.Uninstall(CTargetDir));
  CheckStrings(MockedInstalledPackages, FSut.UninstalledPackages.ToArray, 'InstaleldPackages');
  CheckStrings(MockedComponentFiles, FSut.DeletedComponentFiles.ToArray, 'ComponentFiles');
end;

procedure TUninstallerTests.Uninstall_RawFiles_Expect_Foo_FooB;
begin
  FSut.UninstallResourceName := CJSonUninstallRawFiles;
  CheckTrue(FSut.Uninstall(CTargetDir));
  CheckStrings(MockedRawFiles, FSut.DeletedRawFiles.ToArray, 'RawFiles');
end;

procedure TUninstallerTests.Uninstall_SearchPathes_Expect_PathA_PathB;
begin
  FSut.UninstallResourceName := CJSonUninstallSearchPathes;
  CheckTrue(FSut.Uninstall(CTargetDir));
  CheckStrings(MockedSearchPathes, FSut.RemovedSearchPathes.ToArray, 'SearchPathes');
end;

initialization
  RegisterTest(TUninstallerTests.Suite);

end.
