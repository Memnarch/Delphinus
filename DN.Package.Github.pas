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
  DN.Types,
  DN.Package;

type
  TDNGitHubPackage = class;

  TGetLicenseCallback = function(const APackage: TDNGithubPackage; const ALicense: TDNLicense): string of object;

  TDNGitHubPackage = class(TDNPackage)
  private
    FDefaultBranch: string;
    FRepositoryName: string;
    FOnGetLicense: TGetLicenseCallback;
    FRepositoryType: string;
    FRepository: string;
    FRepositoryUser: string;
  protected
    function GetLicenseText(const AValue: TDNLicense): string; override;
  public
    property DefaultBranch: string read FDefaultBranch write FDefaultBranch;
    property RepositoryName: string read FRepositoryName write FRepositoryName;
    property RepositoryType: string read FRepositoryType write FRepositoryType;
    property RepositoryUser: string read FRepositoryUser write FRepositoryUser;
    property Repository: string read FRepository write FRepository;
    property OnGetLicense: TGetLicenseCallback read FOnGetLicense write FOnGetLicense;
  end;

implementation

{ TDNGitHubPackage }

{ TDNGitHubPackage }

function TDNGitHubPackage.GetLicenseText(const AValue: TDNLicense): string;
begin
  Result := inherited;
  if (Result = '') and not FLicenseTexts.ContainsKey(AValue.LicenseFile) and Assigned(FOnGetLicense) then
  begin
    Result := FOnGetLicense(Self, AValue);
    LicenseText[AValue] := Result;
  end;
end;

end.

