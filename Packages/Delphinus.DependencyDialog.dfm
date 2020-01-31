object DependencyDialog: TDependencyDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Dependencies'
  ClientHeight = 194
  ClientWidth = 453
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 447
    Height = 13
    Align = alTop
    Caption = 'Doubleclick to read licenses'
    ExplicitWidth = 130
  end
  object lvDependencies: TListView
    AlignWithMargins = True
    Left = 3
    Top = 22
    Width = 447
    Height = 169
    Align = alClient
    Columns = <
      item
        AutoSize = True
        Caption = 'Name'
        MinWidth = 100
      end
      item
        Caption = 'License'
        Width = 120
      end
      item
        Caption = 'Required'
        Width = 60
      end
      item
        Caption = 'Installed'
        Width = 60
      end
      item
        Caption = 'Action'
        Width = 60
      end>
    ReadOnly = True
    RowSelect = True
    SmallImages = ilIcons
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvDependenciesDblClick
  end
  object ilIcons: TImageList
    ColorDepth = cd32Bit
    Height = 24
    Width = 24
    Left = 160
    Top = 104
  end
end
