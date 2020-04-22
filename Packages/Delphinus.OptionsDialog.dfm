object DelphinusOptionsDialog: TDelphinusOptionsDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Options'
  ClientHeight = 179
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
    179)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 3
    Top = 36
    Width = 42
    Height = 13
    Caption = 'Sources:'
  end
  object btnOK: TButton
    Left = 221
    Top = 152
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 302
    Top = 152
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object lvSources: TListView
    AlignWithMargins = True
    Left = 3
    Top = 55
    Width = 126
    Height = 121
    Margins.Top = 25
    Align = alLeft
    Columns = <>
    TabOrder = 2
    ViewStyle = vsList
    OnSelectItem = lvSourcesSelectItem
    ExplicitTop = 65
    ExplicitHeight = 114
  end
  object pnlSettings: TPanel
    Left = 135
    Top = 33
    Width = 242
    Height = 113
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 382
    Height = 30
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 31
    Caption = 'ToolBar1'
    Images = ilToolbar
    TabOrder = 4
    object tbAdd: TToolButton
      Left = 0
      Top = 0
      Caption = 'tbAdd'
      ImageIndex = 0
      OnClick = tbAddClick
    end
    object tbDelete: TToolButton
      Left = 31
      Top = 0
      Caption = 'tbDelete'
      ImageIndex = 1
      OnClick = tbDeleteClick
    end
  end
  object ilToolbar: TImageList
    ColorDepth = cd32Bit
    Height = 24
    Width = 24
    Left = 184
    Top = 88
  end
end
