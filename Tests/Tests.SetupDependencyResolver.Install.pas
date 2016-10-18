unit Tests.SetupDependencyResolver.Install;

interface

uses
  TestFramework,
  Generics.Collections,
  DN.Package.Intf,
  DN.Package.Finder.Intf,
  DN.Setup.Dependency.Resolver.Intf,
  DN.Setup.Dependency.Resolver.Install;

type
  TSetupInstallDependencyResolverTest = class(TTestCase)
  private
    FSut: IDNSetupDependencyResolver;
    FInstalled: TList<IDNPackage>;
    FOnline: TList<IDNPackage>;
    FOnlineFinderConstructed: Boolean;
  protected
    function InstalledFinderFactory: IDNPackageFinder;
    function OnlineFinderFactory: IDNPackageFinder;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Resolve_PackageA_RequiresPackageBV1_ExistsOnline_Expect_DependencyIsPackageBAndActionIsInstall;
    procedure Resolve_PackageA_RequiresPackageBV1_ExistsInstalled_Expect_DependencyIsPackageBAndActionIsNoneAndOnlineFinderIsNotConstructed;
    procedure Resolve_PackageA_RequiresPackageBV2_ExistsInstalledAsV1OnlineAsV2_Expect_DependencyIsPackageBAndActionIsUpdate;
    procedure Resolve_PackageA_RequiresPackageBV1WhichRequiresPackageCV1_ExistsOnline_Expect_DependenciesIncludePackageCThenBandActionIsInstall;
    procedure Resolve_PackageA_RequiresPackageBV1WhichRequiresPackageCV1_PackageBExistsOnlinePackageCInstalled_Expect_DependenciesIncludePackageCThenBandActionPackageCIsNoneAndActionPackageBIsInstall;

    procedure Resolve_PackageA_RequiresPackageB_DoesNotExist_Expect_IDIsSetAndActionIsNone;
    procedure Resolve_PackageA_RequiresNothing_Expect_DependenciesAreEmpty;
  end;

implementation

uses
  Types,
  SysUtils,
  Tests.Mocks.Package,
  DN.Package.Finder,
  DN.Setup.Dependency.Intf;

const
  CPackageA: TGUID = '{F08EDD68-78A5-462B-8CFF-76BF2738532E}';
  CPackageB: TGUID = '{63E8DE26-8125-4D84-8781-3544C9BCC063}';
  CPackageC: TGUID = '{2BDEFB4E-492F-4C21-97EC-9A1DE15B2B12}';
  CVersion1 = '1';
  CVersion2 = '2';

{ TSetupInstallDependencyResolverTest }

function TSetupInstallDependencyResolverTest.InstalledFinderFactory: IDNPackageFinder;
begin
  Result := TDNPackageFinder.Create(FInstalled.ToArray);
end;

function TSetupInstallDependencyResolverTest.OnlineFinderFactory: IDNPackageFinder;
begin
  Result := TDNPackageFinder.Create(FOnline.ToArray);
  FOnlineFinderConstructed := True;
end;

procedure TSetupInstallDependencyResolverTest.Resolve_PackageA_RequiresNothing_Expect_DependenciesAreEmpty;
var
  LPackage: IDNPackage;
  LDependencies: TArray<IDNSetupDependency>;
begin
  LPackage := NewPackage(CPackageA);
  LDependencies := FSut.Resolve(LPackage, LPackage.Versions.First);
  CheckEquals(0, Length(LDependencies));
end;

procedure TSetupInstallDependencyResolverTest.Resolve_PackageA_RequiresPackageBV1WhichRequiresPackageCV1_ExistsOnline_Expect_DependenciesIncludePackageCThenBandActionIsInstall;
var
  LPackage: IDNPackage;
  LDependencies: TArray<IDNSetupDependency>;
begin
  FOnline.Add(NewPackage(CPackageB, CVersion1));
  AddDependency(FOnline.First.Versions.First, CPackageC, CVersion1);
  FOnline.Add(NewPackage(CPackageC, CVersion1));
  LPackage := NewPackage(CPackageA);
  AddDependency(LPackage.Versions.First, CPackageB, CVersion1);
  LDependencies := FSut.Resolve(LPackage, LPackage.Versions.First);
  CheckEquals(2, Length(LDependencies));
  CheckEquals(CPackageC.ToString, LDependencies[0].Package.ID.ToString);
  CheckEquals(CPackageB.ToString, LDependencies[1].Package.ID.ToString);
  CheckTrue(LDependencies[0].Action = daInstall);
  CheckTrue(LDependencies[1].Action = daInstall);
end;

procedure TSetupInstallDependencyResolverTest.Resolve_PackageA_RequiresPackageBV1WhichRequiresPackageCV1_PackageBExistsOnlinePackageCInstalled_Expect_DependenciesIncludePackageCThenBandActionPackageCIsNoneAndActionPackageBIsInstall;
var
  LPackage: IDNPackage;
  LDependencies: TArray<IDNSetupDependency>;
begin
  FOnline.Add(NewPackage(CPackageB, CVersion1));
  AddDependency(FOnline.First.Versions.First, CPackageC, CVersion1);
  FInstalled.Add(NewPackage(CPackageC, CVersion1));
  LPackage := NewPackage(CPackageA);
  AddDependency(LPackage.Versions.First, CPackageB, CVersion1);
  LDependencies := FSut.Resolve(LPackage, LPackage.Versions.First);
  CheckEquals(2, Length(LDependencies));
  CheckEquals(CPackageC.ToString, LDependencies[0].Package.ID.ToString);
  CheckEquals(CPackageB.ToString, LDependencies[1].Package.ID.ToString);
  CheckTrue(LDependencies[0].Action = daNone);
  CheckTrue(LDependencies[1].Action = daInstall);
end;

procedure TSetupInstallDependencyResolverTest.Resolve_PackageA_RequiresPackageBV1_ExistsInstalled_Expect_DependencyIsPackageBAndActionIsNoneAndOnlineFinderIsNotConstructed;
var
  LPackage: IDNPackage;
  LDependencies: TArray<IDNSetupDependency>;
begin
  FInstalled.Add(NewPackage(CPackageB, CVersion1));
  LPackage := NewPackage(CPackageA);
  AddDependency(LPackage.Versions.First, CPackageB, CVersion1);
  LDependencies := FSut.Resolve(LPackage, LPackage.Versions.First);
  CheckEquals(1, Length(LDependencies));
  CheckTrue(FInstalled.First = LDependencies[0].Package);
  CheckTrue(LDependencies[0].Action = daNone);
  CheckEquals(FOnlineFinderConstructed, False);
end;

procedure TSetupInstallDependencyResolverTest.Resolve_PackageA_RequiresPackageBV1_ExistsOnline_Expect_DependencyIsPackageBAndActionIsInstall;
var
  LPackage: IDNPackage;
  LDependencies: TArray<IDNSetupDependency>;
begin
  FOnline.Add(NewPackage(CPackageB, CVersion1));
  LPackage := NewPackage(CPackageA);
  AddDependency(LPackage.Versions.First, CPackageB, CVersion1);
  LDependencies := FSut.Resolve(LPackage, LPackage.Versions.First);
  CheckEquals(1, Length(LDependencies));
  CheckTrue(FOnline.First = LDependencies[0].Package);
  CheckTrue(LDependencies[0].Action = daInstall);
end;

procedure TSetupInstallDependencyResolverTest.Resolve_PackageA_RequiresPackageBV2_ExistsInstalledAsV1OnlineAsV2_Expect_DependencyIsPackageBAndActionIsUpdate;
var
  LPackage: IDNPackage;
  LDependencies: TArray<IDNSetupDependency>;
begin
  FInstalled.Add(NewPackage(CPackageB, CVersion1));
  FOnline.Add(NewPackage(CPackageB, CVersion2));
  LPackage := NewPackage(CPackageA);
  AddDependency(LPackage.Versions.First, CPackageB, CVersion2);
  LDependencies := FSut.Resolve(LPackage, LPackage.Versions.First);
  CheckEquals(1, Length(LDependencies));
  CheckTrue(FOnline.First = LDependencies[0].Package);
  CheckTrue(LDependencies[0].Action = daUpdate);
end;

procedure TSetupInstallDependencyResolverTest.Resolve_PackageA_RequiresPackageB_DoesNotExist_Expect_IDIsSetAndActionIsNone;
var
  LPackage: IDNPackage;
  LDependencies: TArray<IDNSetupDependency>;
begin
  LPackage := NewPackage(CPackageA);
  AddDependency(LPackage.Versions.First, CPackageB, CVersion1);
  LDependencies := FSut.Resolve(LPackage, LPackage.Versions.First);
  CheckEquals(1, Length(LDependencies));
  CheckEquals(CPackageB.ToString, LDependencies[0].ID.ToString);
  CheckTrue(LDependencies[0].Action = daNone);
end;

procedure TSetupInstallDependencyResolverTest.SetUp;
begin
  inherited;
  FInstalled := TList<IDNPackage>.Create();
  FOnline := TList<IDNPackage>.Create();
  FSut := TDNSetupInstallDependencyResolver.Create(InstalledFinderFactory, OnlineFinderFactory);
end;

procedure TSetupInstallDependencyResolverTest.TearDown;
begin
  FSut := nil;
  FOnline.Free;
  FInstalled.Free;
  inherited;
end;

initialization
  RegisterTest(TSetupInstallDependencyResolverTest.Suite);

end.
