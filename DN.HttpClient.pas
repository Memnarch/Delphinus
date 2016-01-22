unit DN.HttpClient;

interface

uses
  Classes,
  SysUtils,
  DN.HttpClient.Intf;

type
  TDNHttpClient = class(TInterfacedObject, IDNHttpClient)
  private
    FAuthentication: string;
    FAccept: string;
    FOnProgress: TProgressEvent;
    FIgnoreCacheExpiration: Boolean;
    function GetAuthentication: string;
    procedure SetAuthentication(const Value: string);
    function GetOnProgress: TProgressEvent;
    procedure SetOnProgress(const Value: TProgressEvent);
    function GetAccept: string;
    procedure SetAccept(const Value: string);
    function GetLastResponseSoure: TResponseSource;
    function GetIgnoreCacheExpiration: Boolean;
    procedure SetIgnoreCacheExpiration(const Value: Boolean);
  protected
    FLastResponseSource: TResponseSource;
    procedure DoProgress(AProgress, AMax: Int64);
  public
    function Get(const AUrl: string; AResponse: TStream): Integer; virtual; abstract;
    function GetText(const AUrl: string; out AResponse: string): Integer; virtual;
    function Download(const AUrl, ATargetFile: string): Integer; virtual;
    procedure BeginWork; virtual;
    procedure EndWork; virtual;
    property Authentication: string read GetAuthentication write SetAuthentication;
    property Accept: string read GetAccept write SetAccept;
    property LastResponseSource: TResponseSource read GetLastResponseSoure;
    property IgnoreCacheExpiration: Boolean read GetIgnoreCacheExpiration write SetIgnoreCacheExpiration;
    property OnProgress: TProgressEvent read GetOnProgress write SetOnProgress;
  end;

implementation

{ TDNHttpClient }

procedure TDNHttpClient.BeginWork;
begin

end;

procedure TDNHttpClient.DoProgress(AProgress, AMax: Int64);
begin
  if Assigned(FOnProgress) then
    FOnProgress(AProgress, AMax);
end;

function TDNHttpClient.Download(const AUrl, ATargetFile: string): Integer;
var
  LFile: TFileStream;
begin
  LFile := TFileStream.Create(ATargetFile, fmCreate or fmOpenReadWrite);
  try
    Result := Get(AUrl, LFile);
  finally
    LFile.Free;
  end;
end;

procedure TDNHttpClient.EndWork;
begin

end;

function TDNHttpClient.GetAccept: string;
begin
  Result := FAccept;
end;

function TDNHttpClient.GetAuthentication: string;
begin
  Result := FAuthentication;
end;

function TDNHttpClient.GetIgnoreCacheExpiration: Boolean;
begin
  Result := FIgnoreCacheExpiration;
end;

function TDNHttpClient.GetLastResponseSoure: TResponseSource;
begin
  Result := FLastResponseSource;
end;

function TDNHttpClient.GetOnProgress: TProgressEvent;
begin
  Result := FOnProgress;
end;

function TDNHttpClient.GetText(const AUrl: string;
  out AResponse: string): Integer;
var
  LText: TStringStream;
begin
  LText := TStringStream.Create('', TEncoding.UTF8);
  try
    Result := Get(AUrl, LText);
    if Result = HTTPErrorOk then
      AResponse := LText.DataString;
  finally
    LText.Free;
  end;
end;

procedure TDNHttpClient.SetAccept(const Value: string);
begin
  FAccept := Value;
end;

procedure TDNHttpClient.SetAuthentication(const Value: string);
begin
  FAuthentication := Value;
end;

procedure TDNHttpClient.SetIgnoreCacheExpiration(const Value: Boolean);
begin
  FIgnoreCacheExpiration := Value;
end;

procedure TDNHttpClient.SetOnProgress(const Value: TProgressEvent);
begin
  FOnProgress := Value;
end;

end.
