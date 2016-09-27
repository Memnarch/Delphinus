unit DN.PackageProvider.GitHub.State;

interface

uses
  DN.PackageProvider.State,
  DN.PackageProvider.State.Intf,
  DN.HttpClient.Intf;

type
  TDNGithubPackageProviderState = class(TDNPackageProviderState)
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

{ TDNGithubPackageProviderState }

constructor TDNGithubPackageProviderState.Create(const AClient: IDNHttpClient);
begin
  inherited Create;
  FClient := AClient;
end;

function TDNGithubPackageProviderState.GetStatisticCount: Integer;
begin
  Result := 3;
end;

function TDNGithubPackageProviderState.GetStatisticName(
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

function TDNGithubPackageProviderState.GetStatisticValue(
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
