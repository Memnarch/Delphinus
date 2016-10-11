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
  DN.Package.Intf,
  DN.Package.DirectoryLoader.Intf;

type
  TDNInstalledPackageProvider = class(TDNPackageProvider)
  private
    FComponentDirectory: string;
    FLoader: IDNPackageDirectoryLoader;
  public
    constructor Create(const AComponentDirectory: string);
    function Reload: Boolean; override;
  end;

implementation

uses
  IOUtils,
  Graphics,
  DN.Types,
  DN.Package,
  DN.Uninstaller.Intf,
  DN.JSonFile.InstalledInfo,
  DN.Package.Version,
  DN.Package.Version.Intf,
  DN.Graphics.Loader,
  DN.Package.DirectoryLoader;

{ TDNInstalledPackageProvider }

constructor TDNInstalledPackageProvider.Create(
  const AComponentDirectory: string);
begin
  inherited Create();
  FComponentDirectory := AComponentDirectory;
  FLoader := TDNPackageDirectoryLoader.Create();
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
        FLoader.Load(LDirectory, LPackage);
        Packages.Add(LPackage);
      end;
    end;
    Result := True;
  end;
end;

end.
