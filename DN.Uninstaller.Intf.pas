{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Uninstaller.Intf;

interface

uses
  DN.Types;

type
  IDNUninstaller = interface
    ['{0FAA025F-21E8-48B4-9CCA-8C62D1065F69}']
    function GetOnMessage: TMessageEvent;
    function GetHasPendingChanges: Boolean;
    procedure SetOnMessage(const Value: TMessageEvent);
    function Uninstall(const ADirectory: string): Boolean;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
    property HasPendingChanges: Boolean read GetHasPendingChanges;
  end;

implementation

end.
