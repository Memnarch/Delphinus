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
  Icon.LoadFromResourceName(HInstance, CIconDelphinus);
end;

end.
