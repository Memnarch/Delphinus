{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.PackageProvider.Installed;

interface

uses
  Classes,
  Types,
  SysUtils,
  DN.PackageProvider,
  DN.Package.Intf;

type
  TDNInstalledPackageProvider = class(TDNPackageProvider)
  private
    FComponentDirectory: string;
    function LoadLicenceText(const AFile: string): string;
    procedure LoadDetails(const APackage: IDNPackage; const AInfoFile: string);
  public
    constructor Create(const AComponentDirectory: string);
    function Reload: Boolean; override;
  end;

implementation

uses
  IOUtils,
  jpeg,
  pngimage,
  DN.Types,
  DN.Package,
  DN.Uninstaller.Intf,
  DN.JSonFile.InstalledInfo,
  DN.Package.Version,
  DN.Package.Version.Intf;

{ TDNInstalledPackageProvider }

constructor TDNInstalledPackageProvider.Create(
  const AComponentDirectory: string);
begin
  inherited Create();
  FComponentDirectory := AComponentDirectory;
end;

procedure TDNInstalledPackageProvider.LoadDetails(const APackage: IDNPackage;
  const AInfoFile: string);
var
  LJPG: TJPEGImage;
  LPNG: TPNGImage;
  LImageFile: string;
  LInfo: TInstalledInfoFile;
  LVersion: IDNPackageVersion;
begin
  if TFile.Exists(AInfoFile) then
  begin
    LInfo := TInstalledInfoFile.Create();
    try
      if LInfo.LoadFromFile(AInfoFile) then
      begin
        APackage.Author := LInfo.Author;
        APackage.Description := LInfo.Description;
        APackage.ID := LInfo.ID;
        APackage.CompilerMin := LInfo.CompilerMin;
        APackage.CompilerMax := LInfo.CompilerMax;
        APackage.Platforms := LInfo.Platforms;
        APackage.LicenseType := LInfo.LicenseType;
        APackage.LicenseText := LoadLicenceText(TPath.Combine(FComponentDirectory, LInfo.LicenseFile));
        APackage.ProjectUrl := LInfo.ProjectUrl;
        APackage.HomepageUrl := LInfo.HomepageUrl;
        APackage.ReportUrl := LInfo.ReportUrl;
        if LInfo.Version <> '' then
        begin
          LVersion := TDNPackageVersion.Create();
          if LInfo.Version <> '' then
            LVersion.Name := LInfo.Version;

          LVersion.CompilerMin := LInfo.CompilerMin;
          LVersion.CompilerMax := LInfo.CompilerMax;
          APackage.Versions.Add(LVersion);
        end;
        if LInfo.Picture <> '' then
        begin
          LImageFile := TPath.Combine(ExtractFilePath(AInfoFile), LInfo.Picture);
          if TFile.Exists(LImageFile) then
          begin
            if LowerCase(ExtractFileExt(LImageFile)) = '.png' then
            begin
              LPNG := TPNGImage.Create();
              try
                LPNG.LoadFromFile(LImageFile);
                APackage.Picture.Graphic := LPNG;
              finally
                LPNG.Free;
              end;
            end
            else
            begin
              LJPG := TJPEGImage.Create();
              try
                LJPG.LoadFromFile(LImageFile);
                APackage.Picture.Graphic := LJPG;
              finally
                LJPG.Free;
              end;
            end;
          end;
        end;
      end;
    finally
      LInfo.Free;
    end;
  end;
end;

function TDNInstalledPackageProvider.LoadLicenceText(
  const AFile: string): string;
var
  LFile: TStringStream;
begin
  Result := '';
  if TFile.Exists(AFile) then
  begin
    LFile := TStringStream.Create();
    try
      LFile.LoadFromFile(AFile);
      Result := LFile.DataString;
    finally
      LFile.Free;
    end;
  end;
end;

function TDNInstalledPackageProvider.Reload: Boolean;
var
  LDirectories: TStringDynArray;
  LDirectory: string;
  LPackage: IDNPackage;
begin
  Result := False;
  if TDirectory.Exists(FComponentDirectory) then
  begin
    Packages.Clear();
    LDirectories := TDirectory.GetDirectories(FComponentDirectory);
    for LDirectory in LDirectories do
    begin
      if TFile.Exists(TPath.Combine(LDirectory, CUninstallFile))
        //when uninstalling we rename directories for delete on reboot with a ~
        //exclude them here!
        and (Pos('~', ExtractFileName(ExcludeTrailingPathDelimiter(LDirectory))) < 1) then
      begin
        LPackage := TDNPackage.Create();
        LPackage.Name := ExtractFileName(LDirectory);
        LoadDetails(LPackage, TPath.Combine(LDirectory, CInfoFile));
        Packages.Add(LPackage);
      end;
    end;
    Result := True;
  end;
end;

end.
