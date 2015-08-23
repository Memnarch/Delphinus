{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.ProjectGroupInfo.Intf;

interface

uses
  Generics.Collections,
  DN.ProjectInfo.Intf;

type
  IDNProjectGroupInfo = interface
    ['{992CF336-1A40-4143-BD80-B7478304DA19}']
    function GetFileName: string;
    function GetProjects: TList<IDNProjectInfo>;
    function LoadFromFile(const AFileName: string): Boolean;
    property FileName: string read GetFileName;
    property Projects: TList<IDNProjectInfo> read GetProjects;
  end;

implementation

end.
