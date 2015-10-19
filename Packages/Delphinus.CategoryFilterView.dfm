object CategoryFilterView: TCategoryFilterView
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  OnResize = FrameResize
  object tvCategories: TTreeView
    Left = 0
    Top = 0
    Width = 320
    Height = 105
    Align = alTop
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    HideSelection = False
    Indent = 19
    ParentFont = False
    RowSelect = True
    ShowButtons = False
    ShowLines = False
    TabOrder = 0
    OnAdvancedCustomDrawItem = tvCategoriesAdvancedCustomDrawItem
    OnChange = tvCategoriesChange
    OnChanging = tvCategoriesChanging
    OnCollapsing = tvCategoriesCollapsing
  end
  object tvFilters: TTreeView
    Left = 0
    Top = 105
    Width = 320
    Height = 104
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    HideSelection = False
    Indent = 19
    ParentFont = False
    RowSelect = True
    ShowButtons = False
    ShowLines = False
    TabOrder = 1
    OnAdvancedCustomDrawItem = tvCategoriesAdvancedCustomDrawItem
    OnChange = tvFiltersChange
    OnChanging = tvCategoriesChanging
    OnCollapsing = tvCategoriesCollapsing
  end
  object btnRemove: TButton
    Left = 245
    Top = 212
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Remove'
    TabOrder = 2
    OnClick = btnRemoveClick
  end
  object btnAdd: TButton
    Left = 164
    Top = 212
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Add'
    TabOrder = 3
    OnClick = btnAddClick
  end
end
