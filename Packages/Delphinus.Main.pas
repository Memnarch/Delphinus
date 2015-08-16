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
  GController: IInterface = nil;



procedure Register;
begin

end;

initialization
  GController := TDelphinusController.Create();


finalization
  GController := nil;

end.
