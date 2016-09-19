unit DN.TextTable;

interface

uses
  Generics.Collections,
  DN.TextTable.Intf;

type
  TDNTextTableColumn = record
    Caption: string;
    Width: Integer;
  end;

  TDNTextTableRecord = record
    Values: TArray<string>;
    constructor Create(const ANumValues: Integer);
  end;

  TDNTextTable = class(TInterfacedObject, IDNTextTable)
  private
    FColumns: TList<TDNTextTableColumn>;
    FRecords: TList<TDNTextTableRecord>;
  protected
    procedure AddColumn(const ACaption: string; ACharWidth: Integer = -1);
    procedure AddRecord(const AValues: array of string);
    function GetText: string;
  public
    constructor Create();
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils,
  Math;

const
  CNoLimit = -1;

{ TTextTable }

procedure TDNTextTable.AddColumn(const ACaption: string; ACharWidth: Integer);
var
  LColumn: TDNTextTableColumn;
begin
  LColumn.Caption := ACaption;
  LColumn.Width := ACharWidth;
  FColumns.Add(LColumn);
end;

procedure TDNTextTable.AddRecord(const AValues: array of string);
var
  i: Integer;
  LRecord: TDNTextTableRecord;
begin
  LRecord := TDNTextTableRecord.Create(Length(AValues));
  for i := Low(AValues) to High(AValues) do
    LRecord.Values[i] := AValues[i];
  FRecords.Add(LRecord);
end;

constructor TDNTextTable.Create;
begin
  inherited;
  FColumns := TList<TDNTextTableColumn>.Create();
  FRecords := TList<TDNTextTableRecord>.Create();
end;

destructor TDNTextTable.Destroy;
begin
  FColumns.Free;
  FRecords.Free;
  inherited;
end;

function TDNTextTable.GetText: string;
var
  LColumn: TDNTextTableColumn;
  LRecord: TDNTextTableRecord;
  LText: string;
  i: Integer;
begin
  Result := '';
  for LColumn in FColumns do
  begin
    if (LColumn.Width > CNoLimit) and (Length(LColumn.Caption) > LColumn.Width) then
      LText := Copy(LColumn.Caption, 1, LColumn.Width)
    else
      LText := LColumn.Caption + StringOfChar(' ', LColumn.Width - Length(LColumn.Caption));
    Result := Result + LText
  end;
  Result := Result + sLineBreak;

  for LRecord in FRecords do
  begin
    for i := 0 to Min(Length(LRecord.Values), FColumns.Count) - 1 do
    begin
      LColumn := FColumns[i];
      if (LColumn.Width > CNoLimit) and (Length(LRecord.Values[i]) > LColumn.Width) then
        LText := Copy(LRecord.Values[i], 1, LColumn.Width)
      else
        LText := LRecord.Values[i] + StringOfChar(' ', LColumn.Width - Length(LRecord.Values[i]));
      Result := Result + LText;
    end;
    Result := Result + sLineBreak;
  end;
end;

{ TTextTableRecord }

constructor TDNTextTableRecord.Create(const ANumValues: Integer);
begin
  SetLength(Values, ANumValues);
end;

end.
