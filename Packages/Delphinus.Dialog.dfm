object DelphinusDialog: TDelphinusDialog
  Left = 0
  Top = 0
  Caption = 'Delphinus Packagemanager'
  ClientHeight = 450
  ClientWidth = 984
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 96
  TextHeight = 13
  object pnlPackages: TPanel
    Left = 0
    Top = 32
    Width = 984
    Height = 418
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlPackages'
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    object pnlWarning: TPanel
      Left = 0
      Top = 0
      Width = 984
      Height = 32
      Align = alTop
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      Visible = False
      DesignSize = (
        984
        32)
      object imgMessageSymbol: TImage
        Left = 0
        Top = 0
        Width = 32
        Height = 32
      end
      object imgCloseWarning: TImage
        Left = 961
        Top = 6
        Width = 16
        Height = 16
        Anchors = [akTop, akRight]
        OnClick = imgCloseWarningClick
      end
      object lbMessage: TLabel
        Left = 38
        Top = 0
        Width = 917
        Height = 29
        Anchors = [akLeft, akTop, akRight, akBottom]
        AutoSize = False
        Caption = 'lbMessage'
        WordWrap = True
      end
    end
  end
  object pnlToolBar: TPanel
    Left = 0
    Top = 0
    Width = 984
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pnlToolBar'
    Color = cl3DLight
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
    DesignSize = (
      984
      32)
    object ToolBar1: TToolBar
      Left = 0
      Top = 0
      Width = 124
      Align = alLeft
      AutoSize = True
      ButtonHeight = 30
      ButtonWidth = 31
      Caption = 'ToolBar1'
      DoubleBuffered = False
      Images = ilMenu
      ParentDoubleBuffered = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      object ToolButton1: TToolButton
        Left = 0
        Top = 0
        Action = actRefresh
      end
      object ToolButton2: TToolButton
        Left = 31
        Top = 0
        Action = actOptions
      end
      object btnInstallFolder: TToolButton
        Left = 62
        Top = 0
        Action = actInstallFolder
      end
      object btnAbout: TToolButton
        Left = 93
        Top = 0
        Action = actAbout
      end
    end
    object edSearch: TButtonedEdit
      AlignWithMargins = True
      Left = 130
      Top = 5
      Width = 847
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Images = ilSmall
      LeftButton.ImageIndex = 1
      LeftButton.Visible = True
      RightButton.ImageIndex = 0
      RightButton.Visible = True
      TabOrder = 1
      TextHint = 'Search'
      OnKeyPress = edSearchKeyPress
      OnLeftButtonClick = edSearchLeftButtonClick
      OnRightButtonClick = edSearchRightButtonClick
    end
  end
  object ilMenu: TImageList
    ColorDepth = cd32Bit
    Height = 24
    Width = 24
    Left = 464
    Top = 80
  end
  object DialogActions: TActionList
    Left = 472
    Top = 136
    object actRefresh: TAction
      Caption = 'Refresh'
      Hint = 'Refresh'
      ImageIndex = 0
      OnExecute = actRefreshExecute
    end
    object actOptions: TAction
      Caption = 'Options'
      Hint = 'Options'
      ImageIndex = 1
      OnExecute = actOptionsExecute
    end
    object actInstallFolder: TAction
      Hint = 'Install from Folder'
      OnExecute = btnInstallFolderClick
    end
    object actAbout: TAction
      Caption = 'About'
      Hint = 'About'
      OnExecute = actAboutExecute
    end
  end
  object dlgSelectInstallFile: TOpenDialog
    Left = 432
    Top = 208
  end
  object dlgSelectUninstallFile: TOpenDialog
    Left = 352
    Top = 128
  end
  object ilSmall: TImageList
    ColorDepth = cd32Bit
    Left = 320
    Top = 192
  end
end
