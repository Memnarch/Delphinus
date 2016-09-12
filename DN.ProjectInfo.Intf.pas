{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.ProjectInfo.Intf;

interface

uses
  DN.Compiler.Intf,
  DN.DPRProperties.Intf;

type
  IDNProjectInfo = interface
    ['{F598002A-B768-44BA-868A-A8CB8C23D4A7}']
    function GetBinaryName: string;
    function GetDCPName: string;
    function GetIsPackage: Boolean;
    function GetIsRuntimeOnlyPackage: Boolean;
    function GetFileName: string;
    function GetSupportedPlatforms: TDNCompilerPlatforms;
    function LoadFromFile(const AProjectFile: string): Boolean;
    function GetLoadingError: string;
    function CreateDPRProperties: IDPRProperties;
    property IsPackage: Boolean read GetIsPackage;
    property IsRuntimeOnlyPackage: Boolean read GetIsRuntimeOnlyPackage;
    property BinaryName: string read GetBinaryName;
    property DCPName: string read GetDCPName;
    property FileName: string read GetFileName;
    property SupportedPlatforms: TDNCompilerPlatforms read GetSupportedPlatforms;
    property LoadingError: string read GetLoadingError;
  end;

implementation

end.
