{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit Delphinus.Main;

interface

uses
  ToolsApi,
  Menus,
  Delphinus.Controller;

procedure Register;

{$R DelphinusImages.res}

implementation

var
  GController: IDelphinusController = nil;



procedure Register;
begin

end;

initialization
  GController := TDelphinusController.Create();


finalization
  GController.Dispose;
  GController := nil;

end.
