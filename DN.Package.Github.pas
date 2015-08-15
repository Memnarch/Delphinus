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
    FDefaultBranch: string;
  public
    property DefaultBranch: string read FDefaultBranch write FDefaultBranch;
  end;

implementation

uses
  DN.PackageProvider.Github;

{ TDNGitHubPackage }

end.

