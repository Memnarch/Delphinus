unit DN.JSonFile.Info;

interface

uses
  Classes,
  Types,
  SysUtils,
  JSon,
  DBXJSon,
  DN.JSonFile;

type
  TInfoFile = class(TJSonFile)
  private
    FCompilerMin: Integer;
    FPicture: string;
    FCompilerMax: Integer;
    FID: TGUID;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
    function ReadID(const AObject: TJSONObject): TGUID;
  public
    property Picture: string read FPicture;
    property ID: TGUID read FID write FID;
    property CompilerMin: Integer read FCompilerMin;
    property CompilerMax: Integer read FCompilerMax;
  end;

implementation

{ TInfoFile }

procedure TInfoFile.Load(const ARoot: TJSONObject);
begin
  inherited;
  FPicture := ReadString(ARoot, 'picture');
  FID := ReadID(ARoot);
  FCompilerMin := ReadInteger(ARoot, 'compiler_min');
  FCompilerMax := ReadInteger(ARoot, 'compiler_max');
end;

function TInfoFile.ReadID(const AObject: TJSONObject): TGUID;
begin
  try
    Result := StringToGUID(ReadString(AObject, 'id'));
  except
    Result := TGUID.Empty;
  end;
end;

procedure TInfoFile.Save(const ARoot: TJSONObject);
begin
  inherited;
  WriteString(ARoot, 'picture', FPicture);
  WriteString(ARoot, 'id', FID.ToString);
  WriteInteger(ARoot, 'compiler_min', FCompilerMin);
  WriteInteger(ARoot, 'compiler_max', FCompilerMax);
end;

end.
