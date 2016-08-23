unit DN.Graphics.Loader;

interface

uses
  Classes,
  Types,
  Graphics;

type
  TGraphicLoader = class
  protected
    class function TryCreateGraphic(const AExtension: string; out AGraphic: TGraphic): Boolean;
  public
    class function TryCreateFromFile(const AFileName: string; out AGraphic: TGraphic): Boolean;
    class function TryCreateFromStream(const AStream: TStream; const AExtension: string; out AGraphic: TGraphic): Boolean;
    class function TryLoadPictureFromFile(const AFileName: string; APicture: TPicture): Boolean;
    class function TryLoadPictureFromStream(const AStream: TStream; const AExtension: string; const APicture: TPicture): Boolean;
  end;

implementation

uses
  PNGImage,
  JPeg,
  SysUtils,
  StrUtils,
  IOUtils;

{ TGraphicLoader }

class function TGraphicLoader.TryCreateFromFile(const AFileName: string;
  out AGraphic: TGraphic): Boolean;
begin
  Result := False;
  if TFile.Exists(AFileName) and TryCreateGraphic(ExtractFileExt(AFileName), AGraphic) then
  begin
    try
      AGraphic.LoadFromFile(AFileName);
      Result := True;
    except
      on EInvalidGraphic do
        AGraphic.Free;
    end;
  end;
end;

class function TGraphicLoader.TryCreateFromStream(const AStream: TStream;
  const AExtension: string; out AGraphic: TGraphic): Boolean;
begin
  Result := False;
  if TryCreateGraphic(AExtension, AGraphic) then
  begin
    try
      AGraphic.LoadFromStream(AStream);
      Result := True;
    except
      on E: EInvalidGraphic do
        FreeAndNil(AGraphic);
    end;
  end;
end;

class function TGraphicLoader.TryCreateGraphic(const AExtension: string;
  out AGraphic: TGraphic): Boolean;
begin
  Result := True;
  case AnsiIndexText(AExtension, ['.png', '.jpg', '.jpeg']) of
    0: AGraphic := TPngImage.Create();
    1, 2: AGraphic := TJPEGImage.Create();
  else
    Result := False;
  end;
end;

class function TGraphicLoader.TryLoadPictureFromFile(const AFileName: string;
  APicture: TPicture): Boolean;
var
  LGraphic: TGraphic;
begin
  Result := False;
  if TryCreateFromFile(AFileName, LGraphic) then
  begin
    try
      APicture.Graphic := LGraphic;
      Result := True;
    finally
      LGraphic.Free;
    end;
  end;
end;

class function TGraphicLoader.TryLoadPictureFromStream(const AStream: TStream;
  const AExtension: string; const APicture: TPicture): Boolean;
var
  LGraphic: TGraphic;
begin
  Result := False;
  if TryCreateFromStream(AStream, AExtension, LGraphic) then
  begin
    try
      APicture.Graphic := LGraphic;
      Result := True;
    finally
      LGraphic.Free;
    end;
  end;
end;

end.
