unit DN.Package.Github;

interface

uses
  Classes,
  Types,
  DN.Package,
  DN.PackageProvider.Intf;

type
  TDNGitHubPackage = class(TDNPackage)
  private
    FProvider: IDNPackageProvider;
    FLoadedDetails: Boolean;
    FDefaultBranch: string;
  protected
    function GetVersions: TStringDynArray; override;
  public
    constructor Create(const AProvider: IDNPackageProvider); reintroduce;
    property DefaultBranch: string read FDefaultBranch write FDefaultBranch;
  end;

implementation

uses
  DN.PackageProvider.Github;

{ TDNGitHubPackage }

constructor TDNGitHubPackage.Create(const AProvider: IDNPackageProvider);
begin
  inherited Create();
  FProvider := AProvider;
end;

function TDNGitHubPackage.GetVersions: TStringDynArray;
begin
  if not FLoadedDetails then
  begin
    FLoadedDetails := True;
    Versions := (FProvider as TDNGitHubPackageProvider).LoadVersions(Self);
  end;
  Result := inherited;
end;

end.
