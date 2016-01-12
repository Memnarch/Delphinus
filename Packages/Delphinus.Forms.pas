{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit Delphinus.Forms;

interface

uses
  Classes,
  Windows,
  Graphics,
  Controls,
  Forms;

type
  TForm = class(Forms.TForm)
  protected
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TFrame = class(Forms.TFrame)
  protected
    procedure Loaded; override;
  end;

implementation

uses
  Delphinus.ResourceNames;

{ TDelphinusForm }

constructor TForm.Create(AOwner: TComponent);
begin
  inherited;
  Icon.Handle := LoadImage(HInstance, CIconDelphinus, IMAGE_ICON, 0, 0, 0);
end;

{ TDelphinusFrame }

type
  TProtectedOverrride = class(TControl);

procedure ApplyStyle(const AControl: TWinControl);
var
  i: Integer;
begin
  TProtectedOverrride(AControl).Font.Name := 'Segoe UI';
  for i := 0 to AControl.ControlCount - 1 do
  begin
    TProtectedOverrride(AControl.Controls[i]).Font.Name := TProtectedOverrride(AControl).Font.Name;
    if AControl.Controls[i] is TWinControl then
      ApplyStyle(TWinControl(AControl.Controls[i]));
  end;
end;

procedure TForm.Loaded;
begin
  inherited;
  ApplyStyle(Self);
end;

procedure TFrame.Loaded;
begin
  inherited;
  ApplyStyle(Self);
end;

end.
