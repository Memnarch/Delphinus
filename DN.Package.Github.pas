{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Package.Github;

interface

uses
  Classes,
  Types,
  DN.Package;

type
  TDNGitHubPackage = class;

  TGetLicenseCallback = function(const APackage: TDNGithubPackage): string of object;

  TDNGitHubPackage = class(TDNPackage)
  private
    FDefaultBranch: string;
    FRepositoryName: string;
    FLicenseFile: string;
    FOnGetLicense: TGetLicenseCallback;
    FLicenseLoaded: Boolean;
    FRepositoryType: string;
    FRepository: string;
    FRepositoryUser: string;
  protected
    function GetLicenseText: string; override;
  public
    property DefaultBranch: string read FDefaultBranch write FDefaultBranch;
    property RepositoryName: string read FRepositoryName write FRepositoryName;
    property LicenseFile: string read FLicenseFile write FLicenseFile;
    property RepositoryType: string read FRepositoryType write FRepositoryType;
    property RepositoryUser: string read FRepositoryUser write FRepositoryUser;
    property Repository: string read FRepository write FRepository;
    property OnGetLicense: TGetLicenseCallback read FOnGetLicense write FOnGetLicense;
  end;

implementation

{ TDNGitHubPackage }

{ TDNGitHubPackage }

function TDNGitHubPackage.GetLicenseText: string;
begin
  if (not FLicenseLoaded) and Assigned(FOnGetLicense) then
  begin
    LicenseText := FOnGetLicense(Self);
    FLicenseLoaded := True;
  end;
  Result := inherited;
end;

end.

