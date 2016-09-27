unit DN.HttpClient.WinHttp;

interface

uses
  Classes,
  SysUtils,
  DN.ActiveX,
  DN.HttpClient,
  DN.Import.WinHttp,
  DN.HttpClient.Cache.Intf;

type
  TDNWinHttpClient = class(TDNHttpClient)
  private
    FRequest: IWinHttpRequest;
    FLastThreadID: Cardinal;
    FCache: IDNHttpCache;
    FEvents: IWinHttpRequestEvents;
    FEventsCookie: Integer;
    FContentLength: Int64;
    FContentProgress: Int64;
  protected
    procedure HandleResponseStart(Status: Integer; const ContentType: string);
    procedure HandleResponseDataAvailable(var Data: PSafeArray);
    procedure AddEvents(ARequest: IWinHttpRequest; var ACookie: Integer);
    procedure RemoveEvents(ARequest: IWinHttpRequest; ACookie: Integer);
    procedure RequiresRequest;
    function GetResponseHeader(const AName: string): string; override;
  public
    constructor Create;
    destructor Destroy; override;
    function Get(const AUrl: string; AResponse: TStream): Integer; override;
    procedure BeginWork; override;
    procedure EndWork; override;
  end;

  TOnResponseStart = procedure(Status: Integer; const ContentType: string) of object;
  TOnResponseDataAvailable = procedure(var Data: PSafeArray) of object;
  TOnResponseFinished = procedure of object;
  TOnError = procedure(ErrorNumber: Integer; const ErrorDescription: string) of object;

  TDNWinHttpClientEvents = class(TInterfacedObject, IWinHttpRequestEvents)
  private
    FOnResponseDataAvailable: TOnResponseDataAvailable;
    FOnResponseFinished: TOnResponseFinished;
    FOnResponseStart: TOnResponseStart;
    FOnError: TOnError;
    procedure ResponseStart(Status: Integer; const ContentType: WideString); stdcall;
    procedure ResponseDataAvailable(var Data: PSafeArray); stdcall;
    procedure ResponseFinished; stdcall;
    procedure Error(ErrorNumber: Integer; const ErrorDescription: WideString); stdcall;
    //interface
    procedure IWinHttpRequestEvents.OnResponseStart = ResponseStart;
    procedure IWinHttpRequestEvents.OnResponseDataAvailable = ResponseDataAvailable;
    procedure IWinHttpRequestEvents.OnResponseFinished = ResponseFinished;
    procedure IWinHttpRequestEvents.OnError = Error;
  public
    property OnResponseStart: TOnResponseStart read FOnResponseStart write FOnResponseStart;
    property OnResponseDataAvailable: TOnResponseDataAvailable read FOnResponseDataAvailable write FOnResponseDataAvailable;
    property OnResponseFinished: TOnResponseFinished read FOnResponseFinished write FOnResponseFinished;
    property OnError: TOnError read FOnError write FOnError;
  end;

implementation

uses
  Windows,
  IOUtils,
  DN.Environment,
  DN.HttpClient.Intf,
  DN.HttpClient.Cache;

{ TDNWinHttpClient }

procedure TDNWinHttpClient.AddEvents(ARequest: IWinHttpRequest;
  var ACookie: Integer);
var
  LContainer: IConnectionPointContainer;
  LConnectionPoint: IConnectionPoint;
begin
  LContainer := ARequest as IConnectionPointContainer;
  if LContainer.FindConnectionPoint(IID_IWinHttpRequestEvents, LConnectionPoint) = S_OK then
    LConnectionPoint.Advise(FEvents, ACookie);
end;

procedure TDNWinHttpClient.BeginWork;
begin
  inherited;
  FCache.OpenCache();
end;

constructor TDNWinHttpClient.Create;
var
  LEvents: TDNWinHttpClientEvents;
begin
  FCache := TDNHttpCache.Create(TPath.Combine(GetDelphinusTempFolder(), 'HttpCache'));
  LEvents := TDNWinHttpClientEvents.Create();
  LEvents.OnResponseStart := HandleResponseStart;
  LEvents.OnResponseDataAvailable := HandleResponseDataAvailable;
  FEvents := LEvents;
  inherited;
end;

destructor TDNWinHttpClient.Destroy;
begin
  if Assigned(FRequest) then
    RemoveEvents(FRequest, FEventsCookie);
  FCache := nil;
  FRequest := nil;
  FEvents := nil;
  inherited;
end;

procedure TDNWinHttpClient.EndWork;
begin
  inherited;
  FCache.CloseCache();
end;

function TDNWinHttpClient.Get(const AUrl: string; AResponse: TStream): Integer;
var
  LResponse: IStream;
  LAdapter: IStream;
  LRead, LWritten: UInt64;
  LEntry: IDNHttpCacheEntry;
  LETag, LCacheControl: WideString;
begin
  FLastResponseSource := rsServer;
  RequiresRequest();

  FRequest.Open('Get', AUrl, False);

  if Authentication <> '' then
    FRequest.SetRequestHeader('Authorization', Authentication);

  if Accept <> '' then
    FRequest.SetRequestHeader('Accept', Accept);

  FCache.OpenCache();
  try
    if FCache.TryGetCache(AUrl, LEntry) then
    begin
      if IgnoreCacheExpiration or not LEntry.IsExpired then
      begin
        LEntry.Load(AResponse);
        FLastResponseSource := rsCache;
        Exit(HTTPErrorOk);
      end
      else
      begin
        FRequest.SetRequestHeader('If-None-Match', LEntry.ETag);
      end;
    end;

    FRequest.Send('');
    Result := FRequest.Status;
    if (Result = HTTPErrorNotModified) and Assigned(LEntry) then
    begin
      LEntry.Load(AResponse);
      //if it expired but is still valid revalidate it for its last MaxAge
      LEntry.LastModified := Now();
      FLastResponseSource := rsCache;
      Exit(HTTPErrorOk);
    end;

    if Result = HTTPErrorOk then
    begin
      LResponse := IUnknown(FRequest.ResponseStream) as IStream;
      LAdapter := TStreamAdapter.Create(AResponse) as IStream;
      LResponse.CopyTo(LAdapter, High(Int64), LRead, LWritten);
      DoProgress(LWritten, LWritten);
      if FRequest.GetResponseHeader('ETag', LETag) = S_OK then
      begin
        if not FRequest.GetResponseHeader('cache-control', LCacheControl) = S_OK then
          LCacheControl := '';
        FCache.AddCache(AUrl, AResponse, LCacheControl, LETag);
      end;
    end;
  finally
    FCache.CloseCache();
  end;
end;

function TDNWinHttpClient.GetResponseHeader(const AName: string): string;
var
  LResult: WideString;
begin
  if FRequest.GetResponseHeader(AName, LResult) = S_OK then
    Result := LResult
  else
    Result := '';
end;

procedure TDNWinHttpClient.HandleResponseDataAvailable(var Data: PSafeArray);
begin
  if (FContentLength > 0) and (Data.cbElements > 0) then
  begin
    Inc(FContentProgress, Data.rgsabound[0].cElements);
    DoProgress(FContentProgress, FContentLength);
  end;
end;

procedure TDNWinHttpClient.HandleResponseStart(Status: Integer;
  const ContentType: string);
var
  LLength: WideString;
begin
  FContentLength := -1;
  FContentProgress := 0;
  if FRequest.GetResponseHeader('Content-Length', LLength) = S_OK then
    FContentLength := StrToInt64Def(LLength, -1);
end;

procedure TDNWinHttpClient.RemoveEvents(ARequest: IWinHttpRequest;
  ACookie: Integer);
var
  LContainer: IConnectionPointContainer;
  LConnectionPoint: IConnectionPoint;
begin
  //for some reason, we can not query the interface while the IDE is closing/unloading
  //so in this case we just leave it as it is
  if Supports(ARequest, IConnectionPointContainer, LContainer) then
  begin
    if LContainer.FindConnectionPoint(IID_IWinHttpRequestEvents, LConnectionPoint) = S_OK then
      LConnectionPoint.Unadvise(ACookie);
  end;
end;

procedure TDNWinHttpClient.RequiresRequest;
begin
  if (not Assigned(FRequest)) or (FLastThreadID <> GetCurrentThreadId())  then
  begin
    if Assigned(FRequest) then
      RemoveEvents(FRequest, FEventsCookie);
    FRequest := CoWinHttpRequest.Create();
    AddEvents(FRequest, FEventsCookie);
    FLastThreadID := GetCurrentThreadId();
  end;
end;

{ TDNWinHttpClientEvents }

procedure TDNWinHttpClientEvents.Error(ErrorNumber: Integer;
  const ErrorDescription: WideString);
begin
  if Assigned(FOnError) then
    FOnError(ErrorNumber, ErrorDescription);
end;

procedure TDNWinHttpClientEvents.ResponseDataAvailable(var Data: PSafeArray);
begin
  if Assigned(FOnResponseDataAvailable) then
    FOnResponseDataAvailable(Data);
end;

procedure TDNWinHttpClientEvents.ResponseFinished;
begin
  if Assigned(FOnResponseFinished) then
    FOnResponseFinished();
end;

procedure TDNWinHttpClientEvents.ResponseStart(Status: Integer;
  const ContentType: WideString);
begin
  if Assigned(FOnResponseStart) then
    FOnResponseStart(Status, ContentType);
end;

end.
