{
#########################################################
# Author: Matthias Heunecke, Navimatix                  #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Package.Gitlab;

interface

uses
  Classes,
  Types,
  DN.Types,
  DN.Package;

type
  TDNGitLabPackage = class;

  TGetLicenseCallback = function(const APackage: TDNGitLabPackage; const ALicense: TDNLicense): string of object;

  TDNGitLabPackage = class(TDNPackage)
  private
    FRepoID: string;
    FRepoReleases: string;
    FDefaultBranch: string;
    FRepositoryName: string;
    FOnGetLicense: TGetLicenseCallback;
    FRepositoryType: string;
    FRepository: string;
    FRepositoryUser: string;
  protected
    function GetLicenseText(const AValue: TDNLicense): string; override;
  public
    property RepoID: string read FRepoID write FRepoID;
    property RepoReleases: string read FRepoReleases write FRepoReleases;
    property DefaultBranch: string read FDefaultBranch write FDefaultBranch;
    property RepositoryName: string read FRepositoryName write FRepositoryName;
    property RepositoryType: string read FRepositoryType write FRepositoryType;
    property RepositoryUser: string read FRepositoryUser write FRepositoryUser;
    property Repository: string read FRepository write FRepository;
    property OnGetLicense: TGetLicenseCallback read FOnGetLicense write FOnGetLicense;
  end;

implementation

{ TDNGitLabPackage }

function TDNGitLabPackage.GetLicenseText(const AValue: TDNLicense): string;
begin
  Result := inherited;
  if (Result = '') and not FLicenseTexts.ContainsKey(AValue.LicenseFile) and Assigned(FOnGetLicense) then
  begin
    Result := FOnGetLicense(Self, AValue);
    LicenseText[AValue] := Result;
  end;
end;

end.

