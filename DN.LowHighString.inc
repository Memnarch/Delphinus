{$If CompilerVersion < 24}
function Low(const AText: string): Integer; inline;
begin
  Result := 1;
end;

function High(const AText: string): Integer; inline;
begin
  Result := Length(AText);
end;
{$IfEnd}