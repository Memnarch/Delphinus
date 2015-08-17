object SetupDialog: TSetupDialog
  Left = 0
  Top = 0
  Caption = 'Setup'
  ClientHeight = 290
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object mLog: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 548
    Height = 284
    Align = alClient
    ReadOnly = True
    TabOrder = 0
  end
end
