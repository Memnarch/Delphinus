unit Tests.Version;

interface

uses
  TestFramework,
  DN.Version;

type
  TVersionTest = class(TTestCase)
  private
    procedure TestParse(const AText: string; const AExpected: TDNVersion);
  published
    procedure Parse_VersionAText_Expect_VersionA;
    procedure Parse_VersionBText_Expect_VersionB;
    procedure Parse_VersionCText_Expect_VersionC;

    procedure Compare_A_Expect_Equal;
    procedure Compare_B_Expect_Equal;
    procedure Compare_C_Expect_LeftIsSmaller;
    procedure Compare_D_Expect_Equal;
    procedure Compare_E_Expect_LeftIsBigger;
    procedure Compare_F_Expect_LeftIsBigger;
    procedure Compare_G_Expect_LeftIsSmaller;

    procedure Compare_StableA_UnstableB_Expect_StableAIsBigger;
    procedure Compare_UnstableB_StableA_Expect_StableAIsBigger;

    procedure IsStable_VersionA_Expect_True;
    procedure IsStable_VersionB_Expect_False;
  end;

implementation

const
  CVersionAText = '1.2.3';
  CVersionA: TDNVersion = (Digits: (1, 2, 3));

  CVersionBText = '1.2.3-Beta';
  CVersionB: TDNVersion = (Digits: (1, 2, 3); PreReleaseLabel: 'Beta');

  CVersionCText = 'Blubba1.2-Alpha ';
  CVersionC: TDNVersion = (Digits: (1, 2, 0); PreReleaseLabel: 'Alpha');

  //for comparing
  CLeftA: TDNVersion = (Digits: (1, 2, 3); PreReleaseLabel: 'Alpha');
  CRightA: TDNVersion = (Digits: (1, 2, 3); PreReleaseLabel: 'Alpha');

  CLeftB: TDNVersion = (Digits: (1, 2, 3); PreReleaseLabel: 'Alpha');
  CRightB: TDNVersion = (Digits: (1, 2, 3); PreReleaseLabel: 'alpha');

  CLeftC: TDNVersion = (Digits: (1, 2, 3); PreReleaseLabel: 'Alpha');
  CRightC: TDNVersion = (Digits: (1, 2, 3); PreReleaseLabel: 'Beta');

  CLeftD: TDNVersion = (Digits: (1, 0, 0); PreReleaseLabel: '');
  CRightD: TDNVersion = (Digits: (1, 0, 0); PreReleaseLabel: '');

  CLeftE: TDNVersion = (Digits: (2, 0, 0); PreReleaseLabel: '');
  CRightE: TDNVersion = (Digits: (1, 0, 0); PreReleaseLabel: '');

  CLeftF: TDNVersion = (Digits: (1, 1, 0); PreReleaseLabel: '');
  CRightF: TDNVersion = (Digits: (1, 0, 0); PreReleaseLabel: '');

  CLeftG: TDNVersion = (Digits: (1, 1, 0); PreReleaseLabel: '');
  CRightG: TDNVersion = (Digits: (1, 1, 1); PreReleaseLabel: '');
{ TVariableResolverTest }

procedure TVersionTest.Compare_A_Expect_Equal;
begin
  CheckEquals(0, CLeftA.Compare(CRightA));
end;

procedure TVersionTest.Compare_B_Expect_Equal;
begin
  CheckEquals(0, CLeftB.Compare(CRightB));
end;

procedure TVersionTest.Compare_C_Expect_LeftIsSmaller;
begin
  CheckEquals(-1, CLeftC.Compare(CRightC));
end;

procedure TVersionTest.Compare_D_Expect_Equal;
begin
  CheckEquals(0, CLeftD.Compare(CRightD));
end;

procedure TVersionTest.Compare_E_Expect_LeftIsBigger;
begin
  CheckTrue(CLeftE.Compare(CRightE) > 0);
end;

procedure TVersionTest.Compare_F_Expect_LeftIsBigger;
begin
  CheckTrue(CLeftF.Compare(CRightF) > 0);
end;

procedure TVersionTest.Compare_G_Expect_LeftIsSmaller;
begin
  CheckTrue(CLeftG.Compare(CRightG) < 0);
end;

procedure TVersionTest.Compare_StableA_UnstableB_Expect_StableAIsBigger;
begin
  CheckTrue(CVersionA.Compare(CVersionB) > 0);
end;

procedure TVersionTest.Compare_UnstableB_StableA_Expect_StableAIsBigger;
begin
  CheckTrue(CVersionB.Compare(CVersionA) < 0);
end;

procedure TVersionTest.IsStable_VersionA_Expect_True;
begin
  CheckTrue(CVersionA.IsStable);
end;

procedure TVersionTest.IsStable_VersionB_Expect_False;
begin
  CheckFalse(CVersionB.IsStable);
end;

procedure TVersionTest.Parse_VersionAText_Expect_VersionA;
begin
  TestParse(CVersionAText, CVersionA);
end;

procedure TVersionTest.Parse_VersionBText_Expect_VersionB;
begin
  TestParse(CVersionBText, CVersionB);
end;

procedure TVersionTest.Parse_VersionCText_Expect_VersionC;
begin
  TestParse(CVersionCText, CVersionC);
end;

procedure TVersionTest.TestParse(const AText: string;
  const AExpected: TDNVersion);
var
  LVersion: TDNVersion;
begin
  LVersion := TDNVersion.Parse(AText);
  CheckEquals(AExpected.Major, LVersion.Major, 'Major');
  CheckEquals(AExpected.Minor, LVersion.Minor, 'Minor');
  CheckEquals(AExpected.Patch, LVersion.Patch, 'Patch');
  CheckEquals(AExpected.PreReleaseLabel, LVersion.PreReleaseLabel, 'PreReleaseLabel');
end;

initialization
  RegisterTest(TVersionTest.Suite);

end.
