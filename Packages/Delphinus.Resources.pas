unit Delphinus.Resources;

interface

uses
  ImgList;

function AddIconToImageList(AList: TCustomImageList; const AResourceName: string): Integer;

implementation

uses
  Classes,
  SysUtils,
  Types,
  Graphics;

function AddIconToImageList(AList: TCustomImageList; const AResourceName: string): Integer;
var
  LIcon: TIcon;
begin
  LIcon := TIcon.Create();
  try
    LIcon.SetSize(AList.Width, AList.Height);
    LIcon.LoadFromResourceName(HInstance, AResourceName);
    Result := AList.AddIcon(LIcon);
  finally
    LIcon.Free;
  end;
end;

end.
