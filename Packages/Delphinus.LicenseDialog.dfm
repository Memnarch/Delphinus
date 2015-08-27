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
  object mLicense: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 548
    Height = 252
    Margins.Bottom = 35
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
  end
  object btnOk: TButton
    Left = 476
    Top = 257
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 1
  end
end
