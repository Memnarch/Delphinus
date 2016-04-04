unit DN.Progress.Intf;

interface

type
  TDNProgressEvent = procedure(const Task, Item: string; Progress, Max: Int64) of object;

  IDNProgress = interface
    ['{F43650F9-2AEF-4A66-A75D-156ECD5D003F}']
    //getter and setter stuff
    function GetOnProgress: TDNProgressEvent;
    function GetTaskSteps: Int64;
    procedure SetOnProgress(const Value: TDNProgressEvent);
    procedure SetTaskSteps(const Value: Int64);
    //public methods and properties
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

end.
