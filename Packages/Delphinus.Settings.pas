{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit Delphinus.Settings;

interface

uses
  Generics.Collections;

type
  TDelphinusSettings = class
  private
    FOAuthToken: string;
  public
    property OAuthToken: string read FOAuthToken write FOAuthToken;
  end;

implementation

end.
