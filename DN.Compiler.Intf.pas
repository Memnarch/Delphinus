unit DN.Compiler.Intf;

interface

uses
  Classes;

type
  TDNCompilerTarget = (ctBuild, ctCompile);
  TDNCompilerConfig = (ctRelease, ctDebug);

  IDNCompiler = interface
  ['{AA41BA34-BBD7-454D-A3AA-0730590077A4}']
    function GetExeOutput: string;
    function GetDCPOutput: string;
    function GetDCUOutput: string;
    procedure SetExeOutput(const Value: string);
    procedure SetDCPOutput(const Value: string);
    procedure SetDCUOutput(const Value: string);
    function GetConfig: TDNCompilerConfig;
    function GetTarget: TDNCompilerTarget;
    procedure SetConfig(const Value: TDNCompilerConfig);
    procedure SetTarget(const Value: TDNCompilerTarget);
    function GetBPLOutput: string;
    procedure SetBPLOutput(const Value: string);
    function GetLog: TStrings;
    function Compile(const AProjectFile: string): Boolean;
    property DCUOutput: string read GetDCUOutput write SetDCUOutput;
    property DCPOutput: string read GetDCPOutput write SetDCPOutput;
    property ExeOutput: string read GetExeOutput write SetExeOutput;
    property BPLOutput: string read GetBPLOutput write SetBPLOutput;
    property Target: TDNCompilerTarget read GetTarget write SetTarget;
    property Config: TDNCompilerConfig read GetConfig write SetConfig;
    property Log: TStrings read GetLog;
  end;

implementation

end.
