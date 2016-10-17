unit Tests.SetupDependencyResolver.Uninstall;

interface

uses
  TestFramework,
  Generics.Collections,
  DN.Package.Intf,
  DN.Package.Finder.Intf,
  DN.Setup.Dependency.Resolver.Intf,
  DN.Setup.Dependency.Resolver.Uninstall;

type
  TSetupUninstallDependencyResolverTest = class(TTestCase)
  private
    FSut: IDNSetupDependencyResolver;
    FInstalled: TList<IDNPackage>;
    function GetInstalled: TArray<IDNPackage>;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Resolve_PackageA_PackageBDependsOnA_Expect_DependencyIncludeBAndActionIsUninstall;
    procedure Resolve_PackageA_PackageCDependsOnBWhichDependsOnA_Expect_DependencyIncludeCThenBAndActionIsUninstall;
    procedure Resolve_PackageA_NothingDependsOnIt_Expect_DependenciesAreEmpty;
  end;

implementation

uses
  SysUtils,
  Tests.Mocks.Package,
  DN.Setup.Dependency.Intf;

const
  CPackageA: TGUID = '{F08EDD68-78A5-462B-8CFF-76BF2738532E}';
  CPackageB: TGUID = '{63E8DE26-8125-4D84-8781-3544C9BCC063}';
  CPackageC: TGUID = '{2BDEFB4E-492F-4C21-97EC-9A1DE15B2B12}';
  CVersion1 = '1';

{ TSetupUninstallDependencyResolverTest }

function TSetupUninstallDependencyResolverTest.GetInstalled: TArray<IDNPackage>;
begin
  Result := FInstalled.ToArray;
end;

procedure TSetupUninstallDependencyResolverTest.Resolve_PackageA_NothingDependsOnIt_Expect_DependenciesAreEmpty;
var
  LPackage: IDNPackage;
  LDependencies: TArray<IDNSetupDependency>;
begin
  LPackage := NewPackage(CPackageA);
  LDependencies := FSut.Resolve(LPackage, LPackage.Versions.First);
  CheckEquals(0, Length(LDependencies));
end;

procedure TSetupUninstallDependencyResolverTest.Resolve_PackageA_PackageBDependsOnA_Expect_DependencyIncludeBAndActionIsUninstall;
var
  LPackage: IDNPackage;
  LDependencies: TArray<IDNSetupDependency>;
begin
  FInstalled.Add(NewPackage(CPackageB));
  AddDependency(FInstalled.First.Versions.First, CPackageA, CVersion1);
  LPackage := NewPackage(CPackageA);
  LDependencies := FSut.Resolve(LPackage, LPackage.Versions.First);
  CheckEquals(1, Length(LDependencies));
  CheckEquals(CPackageB.ToString, LDependencies[0].ID.ToString);
  CheckTrue(LDependencies[0].Action = daUninstall);
end;

procedure TSetupUninstallDependencyResolverTest.Resolve_PackageA_PackageCDependsOnBWhichDependsOnA_Expect_DependencyIncludeCThenBAndActionIsUninstall;
var
  LPackage: IDNPackage;
  LDependencies: TArray<IDNSetupDependency>;
begin
  FInstalled.Add(NewPackage(CPackageC, CVersion1));
  AddDependency(FInstalled.First.Versions.First, CPackageB, CVersion1);

  FInstalled.Add(NewPackage(CPackageB));
  AddDependency(FInstalled.Last.Versions.First, CPackageA, CVersion1);

  LPackage := NewPackage(CPackageA);
  LDependencies := FSut.Resolve(LPackage, LPackage.Versions.First);
  CheckEquals(2, Length(LDependencies));
  CheckEquals(CPackageC.ToString, LDependencies[0].ID.ToString);
  CheckEquals(CPackageB.ToString, LDependencies[1].ID.ToString);
  CheckTrue(LDependencies[0].Action = daUninstall);
  CheckTrue(LDependencies[1].Action = daUninstall);
end;

procedure TSetupUninstallDependencyResolverTest.SetUp;
begin
  inherited;
  FInstalled := TList<IDNPackage>.Create();
  FSut := TDNSetupUninstallDependencyResolver.Create(GetInstalled);
end;

procedure TSetupUninstallDependencyResolverTest.TearDown;
begin
  inherited;
  FInstalled.Free;
end;

initialization
  RegisterTest(TSetupUninstallDependencyResolverTest.Suite);

end.
