unit DN.ToolsApi.Extension.Intf;

interface

uses
  DN.Compiler.Intf;

type
  IDNEnvironmentOptions = interface
    ['{654C8D31-B119-4B42-B4CB-6558D729B7BB}']
    function GetPlatform: TDNCompilerPlatform;
    function GetBPLOutput: string;
    function GetBrowsingPath: string;
    function GetDCPOutput: string;
    function GetSearchPath: string;
    procedure SetBPLOutput(const Value: string);
    procedure SetBrowsingPath(const Value: string);
    procedure SetDCPOutput(const Value: string);
    procedure SetSearchPath(const Value: string);
    procedure BeginUpdate();
    procedure EndUpdate();
    property Platform: TDNCompilerPlatform read GetPlatform;
    property BrowingPath: string read GetBrowsingPath write SetBrowsingPath;
    property SearchPath: string read GetSearchPath write SetSearchPath;
    property BPLOutput: string read GetBPLOutput write SetBPLOutput;
    property DCPOutput: string read GetDCPOutput write SetDCPOutput;
  end;

  IDNEnvironmentOptionsService = interface
    ['{69DC3646-AC12-4123-A9FA-0ACE6CD2B05A}']
    function GetOptions(
      const APlatform: TDNCompilerPlatform): IDNEnvironmentOptions;
    function GetSupportedPlatforms: TDNCompilerPlatforms;
    procedure BeginUpdate();
    procedure EndUpdate();
    property Options[const APlatform: TDNCompilerPlatform]: IDNEnvironmentOptions read GetOptions;
    property SupportedPlatforms: TDNCompilerPlatforms read GetSupportedPlatforms;
  end;

var
  GDelphinusIDEServices: IInterface;

implementation

end.
