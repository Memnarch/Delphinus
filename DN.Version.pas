unit DN.Version;

interface

uses
  SysUtils;

type
  TDNVersion = record
  private
    function GetIsStable: Boolean;
  public
    Digits: array[0..2] of Word;
    PreReleaseLabel: string;
    class function TryParse(const AText: string; out AVersion: TDNVersion): Boolean; static;
    class function Parse(const AText: string): TDNVersion; static;
    class operator Equal(const ALeft, ARight: TDNVersion): Boolean;
    class operator LessThan(const ALeft, ARight: TDNVersion): Boolean;
    class operator GreaterThan(const ALeft, ARight: TDNVersion): Boolean;
    function ToString: string;
    function Compare(const AVersion: TDNVersion): Integer;
    property Major: Word read Digits[0];
    property Minor: Word read Digits[1];
    property Patch: Word read Digits[2];
    property IsStable: Boolean read GetIsStable;
  end;

  EVersionParseError = Exception;

implementation

{ TDNVersion }

function TDNVersion.Compare(const AVersion: TDNVersion): Integer;
var
  i: Integer;
begin
  for i := Low(Digits) to High(Digits) do
  begin
    Result := Digits[i] - AVersion.Digits[i];
    if Result <> 0 then
      Exit;
  end;
  Result := CompareText(PreReleaseLabel, AVersion.PreReleaseLabel);
end;

class operator TDNVersion.Equal(const ALeft, ARight: TDNVersion): Boolean;
begin
  Result := ALeft.Compare(ARight) = 0;
end;

function TDNVersion.GetIsStable: Boolean;
begin
  Result := PreReleaseLabel <> '';
end;

class operator TDNVersion.GreaterThan(const ALeft, ARight: TDNVersion): Boolean;
begin
  Result := ALeft.Compare(ARight) > 0;
end;

class operator TDNVersion.LessThan(const ALeft, ARight: TDNVersion): Boolean;
begin
  Result := ALeft.Compare(ARight) < 0;
end;

class function TDNVersion.Parse(const AText: string): TDNVersion;
const
  CError = '''%s'' is not a valid version';
begin
  if not TryParse(AText, Result) then
    raise EVersionParseError.CreateFmt(CError, [AText]);
end;

function TDNVersion.ToString: string;
const
  CStable = '%d.%d.%d';
  CUnstable = CStable + '-%s';
begin
  if IsStable then
    Result := Format(CStable, [Major, Minor, Patch])
  else
    Result := Format(CUnstable, [Major, Minor, Patch, PreReleaseLabel]);
end;

class function TDNVersion.TryParse(const AText: string;
  out AVersion: TDNVersion): Boolean;
const
  CDigits = ['0'..'9'];
  CDigitSeperator = '.';
  CLabelSeperator = '-';
var
  i: Integer;
  LStart, LDigit: Integer;
  LDigitText: string;
begin
  Result := False;
  LStart := 1;
  AVersion := Default(TDNVersion);
  //skip all non digit stuff at the beginning
  for i := 1 to Length(AText) do
    if CharInSet(AText[i], CDigits) then
    begin
      Result := True;
      LStart := i;
      Break;
    end;

  if not Result then Exit;

  //for each digit we can store
  for LDigit := Low(AVersion.Digits) to High(AVersion.Digits) do
  begin
    LDigitText := '';
    //read characters as long as it is a digit
    for i := LStart to Length(AText) do
    begin
      LStart := i;
      if CharInSet(AText[i], CDigits) then
      begin
        LDigitText := LDigitText + AText[i];
      end
      else
      begin
        Break;
      end;
    end;
    AVersion.Digits[LDigit] := StrToInt(LDigitText);
    if (AText[LStart] = CDigitSeperator) and (LStart < Length(AText)) then
      Inc(LStart)
    else
      Break;
  end;

  //check for prerelaselabel
  if AText[LStart] = CLabelSeperator then
    AVersion.PreReleaseLabel := Trim(Copy(AText, LStart+1, Length(AText)));
end;

end.
