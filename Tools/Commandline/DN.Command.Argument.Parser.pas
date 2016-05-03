unit DN.Command.Argument.Parser;

interface

uses
  DN.Command.Argument.Intf,
  DN.Command.Argument.Parser.Intf;

type
  TDNCommandArgumentParser = class(TInterfacedObject, IDNCommandArgumentParser)
  private
    function Split(const AText: string): TArray<string>;
    function IsSwitch(const AText: string): Boolean;
    function ReadParameters(const AElements: TArray<string>; const AStart: Integer): TArray<string>;
    function ReadSwitch(const AElements: TArray<string>; AStart: Integer): IDNCommandSwitchArgument;
  public
    function FromText(const AText: string): IDNCommandArgument;
  end;

implementation

uses
  SysUtils,
  StrUtils,
  Generics.Collections,
  DN.Command.Argument;

{ TDNCommandParser }

function TDNCommandArgumentParser.FromText(const AText: string): IDNCommandArgument;
var
  LCommand: TDNCommandArgument;
  i: Integer;
  LElements: TArray<string>;
  LSwitches: TList<IDNCommandSwitchArgument>;
  LSwitch: IDNCommandSwitchArgument;
begin
  LCommand := TDNCommandArgument.Create();
  Result := LCommand;
  LElements := Split(AText);
  i := 0;
  if (Length(LElements) > 0) and not IsSwitch(LELements[0]) then
  begin
    LCommand.Name := LElements[0];
    LCommand.Parameters := ReadParameters(LElements, 1);
    Inc(i, Length(LCommand.Parameters) + 1);
  end;

  LSwitches := TList<IDNCommandSwitchArgument>.Create();
  try
    while i < Length(LElements) do
    begin
      LSwitch := ReadSwitch(LElements, i);
      LSwitches.Add(LSwitch);
      Inc(i, Length(LSwitch.Parameters) + 1);
    end;
    LCommand.Switches := LSwitches.ToArray;
  finally
    LSwitches.Free;
  end;
end;

function TDNCommandArgumentParser.IsSwitch(const AText: string): Boolean;
begin
  Result := StartsStr('-', AText);
end;

function TDNCommandArgumentParser.ReadParameters(const AElements: TArray<string>;
  const AStart: Integer): TArray<string>;
var
  LParameters: TList<string>;
  i: Integer;
begin
  LParameters := TList<string>.Create();
  try
    for i := AStart to High(AElements) do
    begin
      if IsSwitch(AElements[i]) then
        Break;
      LParameters.Add(AElements[i]);
    end;
    Result := LParameters.ToArray();
  finally
    LParameters.Free;
  end;
end;

function TDNCommandArgumentParser.ReadSwitch(const AElements: TArray<string>;
  AStart: Integer): IDNCommandSwitchArgument;
var
  LSwitch: TDNCommandSwitchArgument;
begin
  if AStart > High(AElements) then
    raise EArgumentOutOfRangeException.Create('Tried to read switch after ends of elements');

  if not IsSwitch(AElements[AStart]) then
    raise EArgumentException.Create('Expected switch but found ' + QuotedStr(AElements[AStart]));

  LSwitch := TDNCommandSwitchArgument.Create();
  Result := LSwitch;

  LSwitch.Name := Copy(AElements[AStart], 2, Length(AElements[AStart]));//remove '-' at the start
  LSwitch.Parameters := ReadParameters(AElements, AStart + 1);
end;

function TDNCommandArgumentParser.Split(const AText: string): TArray<string>;
var
  LElements: TList<string>;
  LElement: string;
  LStart, i: Integer;
  LInQuote: Boolean;
const
  CDoubleQuote = '"';
  CDelimiters = [#0..#32, ',', ';'];
begin
  LElements := TList<string>.Create();
  try
    LStart := -1;
    LInQuote := False;
    for i := 1 to Length(AText) do
    begin
      //go into startblock when current char is no delimiter
      //we are not in quote
      //haven't reached end of text
      if not CharInSet(AText[i], CDelimiters) and (not LInQuote) and (i < Length(AText)) then
      begin
        if LStart = - 1 then
        begin
          if AText[i] = CDoubleQuote then
          begin
            LStart := i + 1;
            LInQuote := True;
          end
          else
          begin
            LStart := i;
          end;
        end;
      end
      else if LStart > -1 then
      begin
        //if start is marked and not in a quote or at end of a quote
        if not LInQuote or (AText[i] = CDoubleQuote) then
        begin
          //if this is the end of text (and not quote terminator) we have to keep the current char
          //instead of truncating it.
          if (i = Length(AText)) and (AText[i] <> CDoubleQuote)  then
            LElement := Copy(AText, LStart, i - LStart + 1)
          else
            LElement := Copy(AText, LStart, i - LStart);
          LElements.Add(LElement);
          LStart := -1;
          LInQuote := False;
        end;
      end;
    end;
    Result := LElements.ToArray;
  finally
    LElements.Free;
  end;
end;

end.
