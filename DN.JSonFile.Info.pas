unit DN.JSonFile.Info;

interface

uses
  JSon,
  DBXJSon,
  DN.JSonFile;

type
  TInfoFile = class(TJSonFile)
  private
    FCompilerMin: Integer;
    FPicture: string;
    FCompilerMax: Integer;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
  public
    property Picture: string read FPicture;
    property CompilerMin: Integer read FCompilerMin;
    property CompilerMax: Integer read FCompilerMax;
  end;

implementation

{ TInfoFile }

procedure TInfoFile.Load(const ARoot: TJSONObject);
begin
  inherited;
  FPicture := ReadString(ARoot, 'picture');
  FCompilerMin := ReadInteger(ARoot, 'compiler_min');
  FCompilerMax := ReadInteger(ARoot, 'compiler_max');
end;

procedure TInfoFile.Save(const ARoot: TJSONObject);
begin
  inherited;
  WriteString(ARoot, 'picture', FPicture);
  WriteInteger(ARoot, 'compiler_min', FCompilerMin);
  WriteInteger(ARoot, 'compiler_max', FCompilerMax);
end;

end.
