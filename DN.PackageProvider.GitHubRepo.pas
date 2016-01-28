unit DN.PackageProvider.GitHubRepo;

interface

uses
  DN.PackageProvider.GitHub,
  DN.HttpClient.Intf,
  DN.JSon;

type
  TDNGithubRepoPackageProvider = class(TDNGitHubPackageProvider)
  private
    FOwner: string;
    FRepository: string;
  protected
    function GetRepoList(out ARepos: TJSONArray): Boolean; override;
  public
    constructor Create(const AClient: IDNHttpClient; const AOwner, ARepository: string); reintroduce;
  end;

implementation

uses
  SysUtils;

{ TDNGithubRepoPackageProvider }

constructor TDNGithubRepoPackageProvider.Create(const AClient: IDNHttpClient;
  const AOwner, ARepository: string);
begin
  inherited Create(AClient);
  FOwner := AOwner;
  FRepository := ARepository;
end;

function TDNGithubRepoPackageProvider.GetRepoList(
  out ARepos: TJSONArray): Boolean;
var
  LResponse: string;
  LBranch: TJSONString;
const
  CRequest = 'https://api.github.com/repos/%s/%s';
begin
  Result := FClient.GetText(Format(CRequest, [FOwner, FRepository]), LResponse) = HTTPErrorOk;
  if Result then
  begin
    ARepos := TJSonObject.ParseJSONValue('[' + LResponse + ']') as TJSONArray;
    //hack as long as we operate in the featurebranch
    TJSONObject(ARepos.Items[0]).Get('default_branch').JsonValue := TJSONString.Create('feature/WebSetup');
    Result := Assigned(ARepos);
  end;
end;

end.
