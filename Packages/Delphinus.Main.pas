unit Delphinus.Main;

interface

uses
  ToolsApi,
  Menus,
  Delphinus.Controller;

procedure Register;

implementation

var
  GController: IInterface = nil;



procedure Register;
begin

end;

initialization
  GController := TDelphinusController.Create();


finalization
  GController := nil;

end.
