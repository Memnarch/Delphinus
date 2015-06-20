object DelphinusDialog: TDelphinusDialog
  Left = 0
  Top = 0
  Caption = 'DelphinusDialog'
  ClientHeight = 290
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 554
    Height = 22
    AutoSize = True
    Caption = 'ToolBar1'
    Images = imgMenu
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Action = actRefresh
    end
  end
  object imgMenu: TImageList
    ColorDepth = cd32Bit
    Left = 464
    Top = 80
  end
  object DialogActions: TActionList
    Left = 472
    Top = 136
    object actRefresh: TAction
      Caption = 'Refresh'
      OnExecute = actRefreshExecute
    end
  end
end
