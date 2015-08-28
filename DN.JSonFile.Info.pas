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
  DN.Types,
  DN.JSon,
  DN.JSonFile;

type
  TInfoFile = class(TJSonFile)
  private
    FID: TGUID;
    FPicture: string;
    FFirstVersion: string;
    FPackageCompilerMax: TCompilerVersion;
    FPackageCompilerMin: TCompilerVersion;
    FCompilerMin: TCompilerVersion;
    FCompilerMax: TCompilerVersion;
    FName: string;
    FLicenseFile: string;
    FLicenseType: string;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
    function ReadID(const AObject: TJSONObject): TGUID;
  public
    property Picture: string read FPicture;
    property ID: TGUID read FID write FID;
    property Name: string read FName write FName;
    property LicenseType: string read FLicenseType write FLicenseType;
    property LicenseFile: string read FLicenseFile write FLicenseFile;
    property FirstVersion: string read FFirstVersion;
    property PackageCompilerMin: TCompilerVersion read FPackageCompilerMin;
    property PackageCompilerMax: TCompilerVersion read FPackageCompilerMax;
    property CompilerMin: TCompilerVersion read FCompilerMin;
    property CompilerMax: TCompilerVersion read FCompilerMax;
  end;

implementation

{ TInfoFile }

procedure TInfoFile.Load(const ARoot: TJSONObject);
begin
  inherited;
  FPicture := ReadString(ARoot, 'picture');
  FID := ReadID(ARoot);
  FName := ReadString(ARoot, 'name');
  FLicenseType := ReadString(ARoot, 'license_type');
  FLicenseFile := ReadString(ARoot, 'license_file');
  FFirstVersion := ReadString(ARoot, 'first_version');
  FPackageCompilerMax := ReadFloat(ARoot, 'package_compiler_max');
  FPackageCompilerMin := ReadFloat(ARoot, 'package_compiler_min');
  FCompilerMin := ReadFloat(ARoot, 'compiler_min');
  FCompilerMax := ReadFloat(ARoot, 'compiler_max');
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
  WritePath(ARoot, 'picture', FPicture);
  WriteString(ARoot, 'id', FID.ToString);
  WriteString(ARoot, 'name', FName);
  WriteString(ARoot, 'license_type', FLicenseType);
  WritePath(ARoot, 'license_file', FLicenseFile);
  WriteString(ARoot, 'first_version', FFirstVersion);
  WriteFloat(ARoot, 'package_compiler_max', FPackageCompilerMax);
  WriteFloat(ARoot, 'package_compiler_min', FPackageCompilerMin);
  WriteFloat(ARoot, 'compiler_min', FCompilerMin);
  WriteFloat(ARoot, 'compiler_max', FCompilerMax);
end;

end.
