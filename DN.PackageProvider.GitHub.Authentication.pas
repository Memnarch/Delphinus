unit DN.PackageProvider.GitHub.Authentication;

interface

uses
  IdAuthentication;

type
  TGithubAuthentication = class(TIdAuthentication)
  private
    FSecurityToken: string;
  protected
    function DoNext: TIdAuthWhatsNext; override;
    function GetSteps: Integer; override;
    procedure SetPassword(const Value: string); override;
  public
    function Authentication: string; override;
  end;

implementation

{ TGithubAuthentication }

function TGithubAuthentication.Authentication: string;
begin
  if FSecurityToken <> '' then
    Result := 'token ' + FSecurityToken
  else
    Result := '';
end;

function TGithubAuthentication.DoNext: TIdAuthWhatsNext;
begin
  if FCurrentStep = 0 then
    Result := wnDoRequest
  else
    Result := wnFail;
end;

function TGithubAuthentication.GetSteps: Integer;
begin
  Result := 1;
end;

procedure TGithubAuthentication.SetPassword(const Value: string);
begin
  inherited;
  FSecurityToken := Value;
end;

end.
