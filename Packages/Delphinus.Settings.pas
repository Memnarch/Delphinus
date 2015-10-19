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
  Generics.Collections,
  Delphinus.FilterProperties;

type
  TDelphinusSettings = class
  private
    FFilters: TObjectList<TFilterProperties>;
    FOAuthToken: string;
  public
    constructor Create();
    destructor Destroy(); override;
    property OAuthToken: string read FOAuthToken write FOAuthToken;
    property Filters: TObjectList<TFilterProperties> read FFilters;
  end;

implementation

{ TDelphinusSettings }

constructor TDelphinusSettings.Create;
begin
  inherited;
  FFilters := TObjectList<TFilterProperties>.Create(True);
end;

destructor TDelphinusSettings.Destroy;
begin
  FFilters.Free;
  inherited;
end;

end.
