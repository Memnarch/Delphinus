{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Installer.Intf;

interface

uses
  DN.Types;

type
  IDNInstaller = interface
    ['{BE1681DA-4DC1-4393-9E7A-050CD63468D2}']
    function GetOnMessage: TMessageEvent;
    function GetHasPendingChanges: Boolean;
    procedure SetOnMessage(const Value: TMessageEvent);
    function Install(const ASourceDirectory, ATargetDirectory: string): Boolean;
    property OnMessage: TMessageEvent read GetOnMessage write SetOnMessage;
    property HasPendingChanges: Boolean read GetHasPendingChanges;
  end;

implementation

end.
