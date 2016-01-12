object ProgressDialog: TProgressDialog
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = 'ProgressDialog'
  ClientHeight = 43
  ClientWidth = 278
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 272
    Height = 13
    Align = alTop
    Caption = 'Label1'
    ExplicitWidth = 31
  end
  object ProgressBar1: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 22
    Width = 272
    Height = 17
    Align = alTop
    TabOrder = 0
  end
end
