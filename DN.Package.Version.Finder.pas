unit DN.Package.Version.Finder;

interface

uses
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Package.Version.Finder.Intf;

type
  TDNVersionFinder = class(TInterfacedObject, IDNVersionFinder)
  public
    function Find(const APackage: IDNPackage;
      const AVersion: string): IDNPackageVersion;
    function TryFind(const APackage: IDNPackage; const AVersion: string;
      out APackageVersion: IDNPackageVersion): Boolean;
  end;

implementation

uses
  SysUtils,
  DN.Version;

{ TDNVersionFinder }

function TDNVersionFinder.Find(const APackage: IDNPackage;
  const AVersion: string): IDNPackageVersion;
begin
  if not TryFind(APackage, AVersion, Result) then
    raise Exception.Create('Version not found: ' + AVersion);
end;

function TDNVersionFinder.TryFind(const APackage: IDNPackage;
  const AVersion: string; out APackageVersion: IDNPackageVersion): Boolean;
var
  LVersion: TDNVersion;
  LPackageVersion: IDNPackageVersion;
begin
  LVersion := TDNVersion.Parse(AVersion);
  for LPackageVersion in APackage.Versions do
    if LPackageVersion.Value = LVersion then
    begin
      APackageVersion := LPackageVersion;
      Exit(True);
    end;
  Result := False;
end;

end.
