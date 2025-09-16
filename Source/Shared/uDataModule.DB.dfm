object DM_DB: TDM_DB
  OnCreate = DataModuleCreate
  Height = 145
  Width = 179
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=pedidosdb'
      'User_Name=delphi'
      'Password=delphi123'
      'Server=localhost'
      'DriverID=MySQL')
    Left = 32
    Top = 24
  end
  object FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink
    DriverID = 'MySQL'
    VendorLib = 'C:\Users\Babingthon\Desktop\Sistema_Pedidos\App\libmysql.dll'
    Left = 72
    Top = 80
  end
end
