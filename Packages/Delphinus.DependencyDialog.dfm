object DependencyDialog: TDependencyDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Dependencies'
  ClientHeight = 194
  ClientWidth = 338
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
  object lvDependencies: TListView
    Left = 0
    Top = 0
    Width = 338
    Height = 194
    Align = alClient
    Columns = <
      item
        AutoSize = True
        Caption = 'Name'
        MinWidth = 100
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
    RowSelect = True
    SmallImages = ilIcons
    TabOrder = 0
    ViewStyle = vsReport
  end
  object ilIcons: TImageList
    ColorDepth = cd32Bit
    Height = 24
    Width = 24
    Left = 160
    Top = 104
  end
end
