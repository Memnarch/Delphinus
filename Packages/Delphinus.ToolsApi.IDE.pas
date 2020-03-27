unit Delphinus.ToolsApi.IDE;

interface

uses
  Controls;

procedure RunComponents;

function TryFindControl(const AClassName, AComponentName: string; out AControl: TControl): Boolean;

implementation

uses
  Forms,
  Classes,
  Types,
  Dialogs,
  SysUtils;

function InternalTryFindControl(AParent: TControl; const AClassName, AComponentName: string; out AControl: TControl): Boolean;
var
  i: Integer;
begin
  Result := False;
  if SameText(AParent.ClassName, AClassName) and SameText(AParent.Name, AComponentName) then
  begin
    AControl := AParent;
    Exit(True);
  end;

  if AParent is TWinControl then
  begin
    for i := 0 to Pred(TWinControl(AParent).ControlCount) do
      if InternalTryFindControl(TWinControl(AParent).Controls[i], AClassName, AComponentName, AControl) then
        Exit(True);
  end;
end;
function TryFindControl(const AClassName, AComponentName: string; out AControl: TControl): Boolean;
begin
  Result := InternalTryFindControl(Application.MainForm, AClassName, AComponentName, AControl);
end;

procedure AddChilds(ATarget: TStringList; AParent: TWinControl);
var
  i: Integer;
begin
  ATarget.Add(AParent.ClassName + '|' + AParent.Name);
  for i := 0 to Pred(AParent.ControlCount) do
    if AParent.Controls[i] is TWinControl then
      AddChilds(ATarget, TWinControl(AParent.Controls[i]));
end;

procedure RunComponents;
var
  LNames: TStringList;
  LControl: TWinControl;
begin
  LNames := TStringList.Create();
  LControl := Application.MainForm;
  AddChilds(LNames, LControl);
  ShowMessage(LNames.Text);
end;

end.
