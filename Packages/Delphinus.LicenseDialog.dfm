object LicenseDialog: TLicenseDialog
  Left = 0
  Top = 0
  Caption = 'LicenseDialog'
  ClientHeight = 290
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    554
    290)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 471
    Top = 263
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 0
  end
  object pcLicenses: TPageControl
    Left = 8
    Top = 8
    Width = 538
    Height = 249
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
end
