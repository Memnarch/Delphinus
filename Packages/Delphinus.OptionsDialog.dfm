object DelphinusOptionsDialog: TDelphinusOptionsDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Options'
  ClientHeight = 160
  ClientWidth = 382
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    382
    160)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 221
    Top = 133
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 302
    Top = 133
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object lvSources: TListView
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 126
    Height = 154
    Align = alLeft
    Columns = <>
    TabOrder = 2
    OnSelectItem = lvSourcesSelectItem
  end
  object vleSettings: TValueListEditor
    Left = 135
    Top = 3
    Width = 242
    Height = 124
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    ColWidths = (
      103
      133)
  end
end
