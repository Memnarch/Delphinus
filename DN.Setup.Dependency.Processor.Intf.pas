unit DN.Setup.Dependency.Processor.Intf;

interface

uses
  DN.Types,
  DN.Setup.Dependency.Intf,
  DN.Progress.Intf;

type
  IDNSetupDependencyProcessor = interface
    ['{8B502102-6A72-4DE8-9E8F-372B454B8AA6}']
    function GetOnMessage: TMessageEvent;
    function GetOnProgress: TDNProgressEvent;
    procedure SetOnMessage(const Value: TMessageEvent);
    procedure SetOnProgress(const Value: TDNProgressEvent);
    function Execute(const ADependencies: TArray<IDNSetupDependency>): Boolean;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
    property OnProgress: TDNProgressEvent read GetOnProgress write SetOnProgress;
  end;

implementation

end.
