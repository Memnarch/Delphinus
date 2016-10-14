unit DN.Setup.Dependency.Processor;

interface

uses
  DN.Types,
  DN.Setup.Intf,
  DN.Setup.Dependency.Intf,
  DN.Setup.Dependency.Processor.Intf,
  DN.Progress.Intf;

type
  TDNSetupDependencyProcessor = class(TInterfacedObject, IDNSetupDependencyProcessor)
  private
    FSetup: IDNSetup;
    FProgress: IDNProgress;
    function GetOnMessage: TMessageEvent;
    function GetOnProgress: TDNProgressEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
    procedure SetOnProgress(const Value: TDNProgressEvent);
    procedure HandleSetupProgress(const Task, Item: string; Progress, Max: Int64);
  public
    constructor Create(const ASetup: IDNSetup);
    function Execute(const ADependencies: TArray<IDNSetupDependency>): Boolean;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
    property OnProgress: TDNProgressEvent read GetOnProgress write SetOnProgress;
  end;

implementation

uses
  DN.Progress;

{ TDNSetupDependencyProcessor }

constructor TDNSetupDependencyProcessor.Create(const ASetup: IDNSetup);
begin
  inherited Create();
  FSetup := ASetup;
  FSetup.OnProgress := HandleSetupProgress;
  FProgress := TDNProgress.Create();
end;

function TDNSetupDependencyProcessor.Execute(
  const ADependencies: TArray<IDNSetupDependency>): Boolean;
var
  LDependency: IDNSetupDependency;
begin
  Result := True;
  FProgress.Reset();
  for LDependency in ADependencies do
    if LDependency.Action <> daNone then
      FProgress.AddTask(LDependency.Package.Name);
  for LDependency in ADependencies do
  begin
    case LDependency.Action of
      daInstall: Result := FSetup.Install(LDependency.Package, LDependency.Version);
      daUpdate: Result := FSetup.Update(LDependency.Package, LDependency.Version);
      daUninstall: Result := FSetup.Uninstall(LDependency.Package);
    end;
    if not Result then
      Exit;
    if LDependency.Action <> daNone then
      FProgress.NextTask();
  end;
  FProgress.Completed();
end;

function TDNSetupDependencyProcessor.GetOnMessage: TMessageEvent;
begin
  Result := FSetup.OnMessage;
end;

function TDNSetupDependencyProcessor.GetOnProgress: TDNProgressEvent;
begin
  Result := FProgress.OnProgress;
end;

procedure TDNSetupDependencyProcessor.HandleSetupProgress(const Task,
  Item: string; Progress, Max: Int64);
begin
  FProgress.SetTaskProgress(Task + ' ' + Item, Progress, Max);
end;

procedure TDNSetupDependencyProcessor.SetOnMessage(const Value: TMessageEvent);
begin
  FSetup.OnMessage := Value;
end;

procedure TDNSetupDependencyProcessor.SetOnProgress(
  const Value: TDNProgressEvent);
begin
  FProgress.OnProgress := Value;
end;

end.
