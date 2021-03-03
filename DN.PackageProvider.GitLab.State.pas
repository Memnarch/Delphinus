{
#########################################################
# Author: Matthias Heunecke, Navimatix                  #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.PackageProvider.GitLab.State;

interface

uses
  DN.PackageProvider.State,
  DN.PackageProvider.State.Intf,
  DN.HttpClient.Intf;

type
  TDNGitlabPackageProviderState = class(TDNPackageProviderState)
  private
    FClient: IDNHttpClient;
  protected
    function GetStatisticCount: Integer; override;
    function GetStatisticName(const AIndex: Integer): string; override;
    function GetStatisticValue(const AIndex: Integer): string; override;
  public
    constructor Create(const AClient: IDNHttpClient);
  end;

implementation

{ TDNGitlabPackageProviderState }

constructor TDNGitlabPackageProviderState.Create(const AClient: IDNHttpClient);
begin
  inherited Create;
  FClient := AClient;
end;

function TDNGitlabPackageProviderState.GetStatisticCount: Integer;
begin
  Result := 3;
end;

function TDNGitlabPackageProviderState.GetStatisticName(
  const AIndex: Integer): string;
begin
  case AIndex of
    0: Result := 'Ratelimit';
    1: Result := 'RateLimit-Remaining';
    2: Result := 'RateLimit-Reset';
  else
    Result := '';
  end;
end;

function TDNGitlabPackageProviderState.GetStatisticValue(
  const AIndex: Integer): string;
begin
  case AIndex of
    0: Result := FClient.ResponseHeader['X-RateLimit-Limit'];
    1: Result := FClient.ResponseHeader['X-RateLimit-Remaining'];
    2: Result := FClient.ResponseHeader['X-RateLimit-Reset'];
  else
    Result := '';
  end;
end;

end.
