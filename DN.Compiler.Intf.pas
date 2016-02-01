{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Compiler.Intf;

interface

uses
  Classes,
  DN.Types;

type
  TDNCompilerTarget = (ctBuild, ctCompile);
  TDNCompilerConfig = (ccRelease, ccDebug);
  TDNCompilerPlatform = (cpWin32, cpWin64, cpOSX32);
  TDNCompilerPlatforms = set of TDNCompilerPlatform;

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
    function GetPlatform: TDNCompilerPlatform;
    procedure SetPlatform(const Value: TDNCompilerPlatform);
    function GetBPLOutput: string;
    procedure SetBPLOutput(const Value: string);
    function GetLog: TStrings;
    function GetVersion: TCompilerVersion;

    function Compile(const AProjectFile: string): Boolean;
    function ResolveVars(const APath: string): string;
    property DCUOutput: string read GetDCUOutput write SetDCUOutput;
    property DCPOutput: string read GetDCPOutput write SetDCPOutput;
    property ExeOutput: string read GetExeOutput write SetExeOutput;
    property BPLOutput: string read GetBPLOutput write SetBPLOutput;
    property Target: TDNCompilerTarget read GetTarget write SetTarget;
    property Config: TDNCompilerConfig read GetConfig write SetConfig;
    property Platform: TDNCompilerPlatform read GetPlatform write SetPlatform;
    property Log: TStrings read GetLog;
    property Version: TCompilerVersion read GetVersion;
  end;

const
  TDNCompilerTargetName: array[Low(TDNCompilerTarget)..High(TDNCompilerTarget)] of string = ('Build', 'Compile');
  TDNCompilerConfigName: array[Low(TDNCompilerConfig)..High(TDNCompilerConfig)] of string = ('Release', 'Debug');
  TDNCompilerPlatformName: array[Low(TDNCompilerPlatform)..High(TDNCompilerPlatform)] of string = ('Win32', 'Win64', 'OSX32');

function TryPlatformNameToCompilerPlatform(const AName: string; out APlatform: TDNCompilerPlatform): Boolean;

implementation

uses
  SysUtils;

function TryPlatformNameToCompilerPlatform(const AName: string; out APlatform: TDNCompilerPlatform): Boolean;
var
  LPlatform: TDNCompilerPlatform;
begin
  for LPlatform := Low(TDNCompilerPlatformName) to High(TDNCompilerPlatformName) do
    if SameText(TDNCompilerPlatformName[LPlatform], AName) then
    begin
      APlatform := LPlatform;
      Exit(True);
    end;

  Result := False;
end;

end.
