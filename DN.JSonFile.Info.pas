{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.JSonFile.Info;

interface

uses
  Classes,
  Types,
  SysUtils,
  DN.JSon,
  DN.JSonFile;

type
  TInfoFile = class(TJSonFile)
  private
    FCompilerMin: Integer;
    FPicture: string;
    FCompilerMax: Integer;
    FID: TGUID;
    FFirstVersion: string;
    FPackageCompilerMax: Integer;
    FPackageCompilerMin: Integer;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
    function ReadID(const AObject: TJSONObject): TGUID;
  public
    property Picture: string read FPicture;
    property ID: TGUID read FID write FID;
    property FirstVersion: string read FFirstVersion;
    property PackageCompilerMin: Integer read FPackageCompilerMin;
    property PackageCompilerMax: Integer read FPackageCompilerMax;
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
  FFirstVersion := ReadString(ARoot, 'first_version');
  FPackageCompilerMax := ReadInteger(ARoot, 'package_compiler_max');
  FPackageCompilerMin := ReadInteger(ARoot, 'package_compiler_min');
  FCompilerMin := ReadInteger(ARoot, 'compiler_min');
  FCompilerMax := ReadInteger(ARoot, 'compiler_max');
end;

function TInfoFile.ReadID(const AObject: TJSONObject): TGUID;
var
  LID: string;
begin
  LID := ReadString(AObject, 'id');
  try
    if LID <> '' then
      Result := StringToGUID(LID)
    else
      Result := TGUID.Empty;
  except
    Result := TGUID.Empty;
  end;
end;

procedure TInfoFile.Save(const ARoot: TJSONObject);
begin
  inherited;
  WriteString(ARoot, 'picture', FPicture);
  WriteString(ARoot, 'id', FID.ToString);
  WriteString(ARoot, 'first_version', FFirstVersion);
  WriteInteger(ARoot, 'package_compiler_max', FPackageCompilerMax);
  WriteInteger(ARoot, 'package_compiler_min', FPackageCompilerMin);
  WriteInteger(ARoot, 'compiler_min', FCompilerMin);
  WriteInteger(ARoot, 'compiler_max', FCompilerMax);
end;

end.
