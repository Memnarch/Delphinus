unit DN.ComCtrls.Helper;

interface

uses
  ComCtrls;

type
  TProgressbarHelper = class helper for TProgressBar
  private
    function GetPosition: Integer;
    procedure SetPosition(const Value: Integer);
  public
    property Position: Integer read GetPosition write SetPosition;
  end;

implementation

{ TProgressbarHelper }

function TProgressbarHelper.GetPosition: Integer;
begin
  Result := inherited Position;
end;

procedure TProgressbarHelper.SetPosition(const Value: Integer);
begin
  if (Value + 1) < Max then
  begin
    inherited Position := Value + 1;
    inherited Position := Value;
  end
  else
  begin
    inherited Max := Value + 1;
    inherited Position := inherited Max;
    inherited Max := inherited Max - 1;
  end;
end;

end.
