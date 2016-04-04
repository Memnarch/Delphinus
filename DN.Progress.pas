unit DN.Progress;

interface

uses
  DN.Progress.Intf;

type
  TDNProgress = class(TInterfacedObject, IDNProgress)
  private
    FOnProgress: TDNProgressEvent;
    FTaskSteps: Int64;
    FFinishedTasks: Integer;
    FTasks: array of string;
    function GetOnProgress: TDNProgressEvent;
    function GetTaskSteps: Int64;
    procedure SetOnProgress(const Value: TDNProgressEvent);
    procedure SetTaskSteps(const Value: Int64);
  protected
    procedure DoProgress(const ATask, AItem: string; AProgress, AMax: Int64);
  public
    constructor Create;
    procedure SetTasks(ATasks: array of string);
    procedure AddTask(ATask: string);
    procedure SetTaskProgress(const AItem: string; AProgress, AMax: Int64);
    procedure NextTask;
    procedure Reset;
    procedure Completed;
    property TaskSteps: Int64 read GetTaskSteps write SetTaskSteps;
    property OnProgress: TDNProgressEvent read GetOnProgress write SetOnProgress;
  end;

implementation

{ TProgress }

procedure TDNProgress.AddTask(ATask: string);
begin
  SetLength(FTasks, Length(FTasks) + 1);
  FTasks[High(FTasks)] := ATask;
end;

procedure TDNProgress.Completed;
begin
  DoProgress('Completed', '', Length(FTasks)*FTaskSteps, Length(FTasks)*TaskSteps);
end;

constructor TDNProgress.Create;
begin
  inherited;
  FTaskSteps := 100;
end;

procedure TDNProgress.DoProgress(const ATask, AItem: string; AProgress,
  AMax: Int64);
begin
  if Assigned(FOnProgress) then
    FOnProgress(ATask, AItem, AProgress, AMax);
end;

function TDNProgress.GetOnProgress: TDNProgressEvent;
begin
  Result := FOnProgress;
end;

function TDNProgress.GetTaskSteps: Int64;
begin
  Result := FTaskSteps;
end;

procedure TDNProgress.NextTask;
begin
  if FFinishedTasks < Length(FTasks) - 1 then
  begin
    Inc(FFinishedTasks);
    DoProgress(FTasks[FFinishedTasks], '', FFinishedTasks*FTaskSteps, Length(FTasks)*FTaskSteps);
  end;
end;

procedure TDNProgress.Reset;
begin
  FFinishedTasks := 0;
end;

procedure TDNProgress.SetOnProgress(const Value: TDNProgressEvent);
begin
  FOnProgress := Value;
end;

procedure TDNProgress.SetTaskProgress(const AItem: string; AProgress,
  AMax: Int64);
begin
  DoProgress(FTasks[FFinishedTasks], AItem, FFinishedTasks*FTaskSteps + Round(AProgress / AMax * FTaskSteps), Length(FTasks)*FTaskSteps);
end;

procedure TDNProgress.SetTasks(ATasks: array of string);
var
  i: Integer;
begin
  SetLength(FTasks, Length(ATasks));
  for i := Low(FTasks) to High(FTasks) do
    FTasks[i] := ATasks[i];

  Reset();
  if Length(FTasks) > 0 then
    DoProgress(FTasks[FFinishedTasks], '', FFinishedTasks*FTaskSteps, Length(FTasks) * FTaskSteps);
end;

procedure TDNProgress.SetTaskSteps(const Value: Int64);
begin
  FTaskSteps := Value;
end;

end.
