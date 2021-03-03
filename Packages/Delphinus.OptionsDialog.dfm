object DelphinusOptionsDialog: TDelphinusOptionsDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Options'
  ClientHeight = 408
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    525
    408)
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
    Left = 364
    Top = 381
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
    ExplicitLeft = 221
    ExplicitTop = 152
  end
  object btnCancel: TButton
    Left = 445
    Top = 381
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    ExplicitLeft = 302
    ExplicitTop = 152
  end
  object lvSources: TListView
    AlignWithMargins = True
    Left = 3
    Top = 55
    Width = 126
    Height = 350
    Margins.Top = 25
    Align = alLeft
    Columns = <>
    TabOrder = 2
    ViewStyle = vsList
    OnSelectItem = lvSourcesSelectItem
    ExplicitHeight = 121
  end
  object pnlSettings: TPanel
    Left = 135
    Top = 33
    Width = 385
    Height = 342
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    ExplicitWidth = 242
    ExplicitHeight = 113
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 525
    Height = 30
    AutoSize = True
    ButtonHeight = 30
    ButtonWidth = 31
    Caption = 'ToolBar1'
    Images = ilToolbar
    TabOrder = 4
    ExplicitWidth = 382
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
