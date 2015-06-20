unit DN.PackageProvider;

interface

uses
  Classes,
  Types,
  SysUtils,
  IdHttp,
  Generics.Collections,
  DN.Package.Intf,
  DN.PackageProvider.Intf;

type
  TDNPackageProvider = class(TInterfacedObject, IDNPackageProvider)
  private
    FPackages: TList<IDNPackage>;
    function GetPackages: TList<IDNPackage>;
  public
    constructor Create();
    destructor Destroy(); override;
    function Reload(): Boolean; virtual;
    function Download(const APackage: IDNPackage; const AFolder: string; out AContentFolder: string): Boolean; virtual;
    property Packages: TList<IDNPackage> read GetPackages;
  end;

implementation

{ TPackageProvider }

constructor TDNPackageProvider.Create;
begin
  inherited;
  FPackages := TList<IDNPackage>.Create();
end;

destructor TDNPackageProvider.Destroy;
begin
  FPackages.Clear();
  inherited;
end;

function TDNPackageProvider.Download(const APackage: IDNPackage;
  const AFolder: string; out AContentFolder: string): Boolean;
begin
  Result := False;
end;

function TDNPackageProvider.GetPackages: TList<IDNPackage>;
begin
  Result := FPackages;
end;

function TDNPackageProvider.Reload: Boolean;
begin
  Result := False;
end;

end.
