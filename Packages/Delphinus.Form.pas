{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit Delphinus.Form;

interface

uses
  Classes,
  Windows,
  Forms;

type
  TDelphinusForm = class(TForm)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  Delphinus.ResourceNames;

{ TDelphinusForm }

constructor TDelphinusForm.Create(AOwner: TComponent);
begin
  inherited;
  Icon.Handle := LoadImage(HInstance, CIconDelphinus, IMAGE_ICON, 0, 0, 0);
end;

end.
