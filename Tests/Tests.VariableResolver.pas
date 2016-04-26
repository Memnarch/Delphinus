unit Tests.VariableResolver;

interface

uses
  TestFramework,
  DN.VariableResolver,
  DN.VariableResolver.Intf;

type
  TVariableResolverTest = class(TTestCase)
  protected
    FSut: IVariableResolver;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Create_UnevenVarValueLists_Expect_Exception;
    procedure Resolve_ExistingVar_CorrectCase_Expect_Resolved;
    procedure Resolve_ExistingVar_DifferentCase_Expect_Resolved;
    procedure Resolve_UnknownVar_Expect_Untouched;
    procedure Resolve_TextWithoutVars_IncludingIdentifierOfExistingVar_Expect_Untouched;
  end;

implementation

uses
  SysUtils;

const
  CTestInputA = 'Here is some $(FooVar)';
  CTestOutputA = 'Here is some FooVal';
  CTestInputB = 'Here is some $(foovar) for you';
  CTestOutputB = 'Here is some FooVal for you';
  CTestInputC = 'Here is some $(unknown) for you';
  CTestOutputC = CTestInputC;
  CTestInputD = 'Here is some FooVar for you';
  CTestOutputD = CTestInputD;

{ TVariableReplacementTest }


procedure TVariableResolverTest.Create_UnevenVarValueLists_Expect_Exception;
begin
  ExpectedException := EArgumentException;
  FSut := TVariableResolver.Create(['Val'], []);
end;

procedure TVariableResolverTest.Resolve_ExistingVar_CorrectCase_Expect_Resolved;
begin
  CheckEquals(CTestOutputA, FSut.Resolve(CTestInputA));
end;

procedure TVariableResolverTest.Resolve_ExistingVar_DifferentCase_Expect_Resolved;
begin
  CheckEquals(CTestOutputB, FSut.Resolve(CTestInputB));
end;

procedure TVariableResolverTest.Resolve_TextWithoutVars_IncludingIdentifierOfExistingVar_Expect_Untouched;
begin
  CheckEquals(CTestOutputD, FSut.Resolve(CTestInputD));
end;

procedure TVariableResolverTest.Resolve_UnknownVar_Expect_Untouched;
begin
  CheckEquals(CTestOutputC, FSut.Resolve(CTestInputC));
end;

procedure TVariableResolverTest.SetUp;
begin
  inherited;
  FSut := TVariableResolver.Create(['FooVar'], ['FooVal']);
end;

procedure TVariableResolverTest.TearDown;
begin
  inherited;
  FSut := nil;
end;

initialization;

RegisterTest(TVariableResolverTest.Suite);

end.
