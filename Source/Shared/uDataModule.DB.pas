unit uDataModule.DB;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, uInterfaces, uModel.Cliente, uModel.Produto,
  uModel.Pedido, System.Generics.Collections;

type
  TDM_DB = class(TDataModule, IRepositorioClientes, IRepositorioProdutos, IRepositorioPedidos)
    FDConnection: TFDConnection;
    FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure CriarIni(const AFileName: string);
    procedure LerIni(const AFileName: string);
  public
    function BuscarClientePorId(ACodigo: Integer): TCliente;
    function ListarTodosClientes: TList<TCliente>;
    function BuscarProdutoPorId(ACodigo: Integer): TProduto;
    function Salvar(APedido: TPedido): Integer;
    function BuscarPorId(ANumeroPedido: Integer): TPedido;
    function Deletar(ANumeroPedido: Integer): Boolean;
    function GerarProximoNumeroPedido: Integer;
  end;

var
  DM_DB: TDM_DB;

implementation

{%- raw -%}
{$R *.dfm}
{%- endraw -%}

uses
  System.IniFiles, Winapi.Windows, Vcl.Dialogs, Vcl.Forms, System.IOUtils;

procedure TDM_DB.DataModuleCreate(Sender: TObject);
var
  LIniFileName: string;
begin
  LIniFileName := TPath.Combine(ExtractFilePath(ParamStr(0)), 'database.ini');

  if not TFile.Exists(LIniFileName) then
    CriarIni(LIniFileName);

  LerIni(LIniFileName);

  try
    FDConnection.Connected := True;
  except
    on E: Exception do
    begin
      ShowMessage('Erro ao conectar ao banco de dados: ' + E.Message + #13#10 + 'Por favor, verifique o arquivo database.ini.');
      Application.Terminate;
    end;
  end;
end;

function TDM_DB.BuscarClientePorId(ACodigo: Integer): TCliente;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FDConnection;
    Qry.SQL.Text := 'SELECT codigo, nome, cidade, uf FROM clientes WHERE codigo = :codigo';
    Qry.ParamByName('codigo').AsInteger := ACodigo;
    Qry.Open;

    if not Qry.IsEmpty then
    begin
      Result := TCliente.Create;
      Result.Codigo := Qry.FieldByName('codigo').AsInteger;
      Result.Nome := Qry.FieldByName('nome').AsString;
      Result.Cidade := Qry.FieldByName('cidade').AsString;
      Result.UF := Qry.FieldByName('uf').AsString;
    end;
  finally
    Qry.Free;
  end;
end;

function TDM_DB.BuscarProdutoPorId(ACodigo: Integer): TProduto;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FDConnection;
    Qry.SQL.Text := 'SELECT codigo, descricao, preco_venda FROM produtos WHERE codigo = :codigo';
    Qry.ParamByName('codigo').AsInteger := ACodigo;
    Qry.Open;

    if not Qry.IsEmpty then
    begin
      Result := TProduto.Create;
      Result.Codigo := Qry.FieldByName('codigo').AsInteger;
      Result.Descricao := Qry.FieldByName('descricao').AsString;
      Result.PrecoVenda := Qry.FieldByName('preco_venda').AsCurrency;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TDM_DB.CriarIni(const AFileName: string);
var
  LIniFile: TIniFile;
begin
  ShowMessage('Arquivo "database.ini" não encontrado.' + #13#10 + 'Um novo arquivo será criado com valores padrão.');

  LIniFile := TIniFile.Create(AFileName);
  try
    LIniFile.WriteString('Database', 'Server', 'localhost');
    LIniFile.WriteString('Database', 'Port', '3306');
    LIniFile.WriteString('Database', 'Database', 'pedidosdb');
    LIniFile.WriteString('Database', 'Username', 'delphi');
    LIniFile.WriteString('Database', 'Password', 'delphi123');
    LIniFile.WriteString('Database', 'VendorLib', 'libmysql.dll');
  finally
    LIniFile.Free;
  end;
end;

function TDM_DB.GerarProximoNumeroPedido: Integer;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FDConnection;
    Qry.SQL.Text := 'SELECT COALESCE(MAX(numero_pedido), 0) + 1 AS proximo FROM pedidos';
    Qry.Open;
    Result := Qry.FieldByName('proximo').AsInteger;
  finally
    Qry.Free;
  end;
end;

procedure TDM_DB.LerIni(const AFileName: string);
var
  LIniFile: TIniFile;
  LAppPath: string;
begin
  if FDConnection.Connected then
    FDConnection.Connected := False;

  LAppPath := ExtractFilePath(ParamStr(0));
  LIniFile := TIniFile.Create(AFileName);
  try
    FDConnection.DriverName := 'MySQL';
    FDConnection.Params.Values['UseSSL'] := 'False';
    FDConnection.Params.Values['CharacterSet'] := 'utf8mb4';

    FDConnection.Params.Values['Server'] := LIniFile.ReadString('Database', 'Server', 'localhost');
    FDConnection.Params.Values['Port'] := LIniFile.ReadString('Database', 'Port', '3306');
    FDConnection.Params.Values['Database'] := LIniFile.ReadString('Database', 'Database', 'pedidosdb');
    FDConnection.Params.Values['UserName'] := LIniFile.ReadString('Database', 'Username', 'root');
    FDConnection.Params.Values['Password'] := LIniFile.ReadString('Database', 'Password', 'root');
    FDConnection.Params.Values['VendorLib'] := TPath.Combine(LAppPath, LIniFile.ReadString('Database', 'VendorLib', 'libmysql.dll'));
  finally
    LIniFile.Free;
  end;
end;

function TDM_DB.ListarTodosClientes: TList<TCliente>;
var
  Qry: TFDQuery;
  LCliente: TCliente;
begin
  Result := TList<TCliente>.Create;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FDConnection;
    Qry.SQL.Text := 'SELECT codigo, nome, cidade, uf FROM clientes ORDER BY codigo';
    Qry.Open;

    Qry.First;
    while not Qry.Eof do
    begin
      LCliente := TCliente.Create;
      LCliente.Codigo := Qry.FieldByName('codigo').AsInteger;
      LCliente.Nome := Qry.FieldByName('nome').AsString;
      LCliente.Cidade := Qry.FieldByName('cidade').AsString;
      LCliente.UF := Qry.FieldByName('uf').AsString;
      Result.Add(LCliente);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

function TDM_DB.BuscarPorId(ANumeroPedido: Integer): TPedido;
var
  QryPedido: TFDQuery;
  QryItens: TFDQuery;
  LItem: TPedidoItem;
  LCliente: TCliente;
begin
  Result := nil;
  QryPedido := TFDQuery.Create(nil);
  QryItens := TFDQuery.Create(nil);
  try
    QryPedido.Connection := FDConnection;
    QryPedido.SQL.Text := 'SELECT numero_pedido, data_emissao, codigo_cliente FROM pedidos WHERE numero_pedido = :numero_pedido';
    QryPedido.ParamByName('numero_pedido').AsInteger := ANumeroPedido;
    QryPedido.Open;

    if QryPedido.IsEmpty then
      Exit;

    Result := TPedido.Create;
    Result.NumeroPedido := QryPedido.FieldByName('numero_pedido').AsInteger;
    Result.DataEmissao := QryPedido.FieldByName('data_emissao').AsDateTime;

    LCliente := Self.BuscarClientePorId(QryPedido.FieldByName('codigo_cliente').AsInteger);

    if Assigned(LCliente) then
    begin
      Result.Cliente.Free;
      Result.Cliente := LCliente;
    end;

    QryItens.Connection := FDConnection;
    QryItens.SQL.Text := 'SELECT p.codigo_produto, pr.descricao, p.quantidade, p.vlr_unitario, p.vlr_total ' + 'FROM pedidos_produtos p ' + 'JOIN produtos pr ON p.codigo_produto = pr.codigo ' + 'WHERE p.numero_pedido = :numero_pedido';
    QryItens.ParamByName('numero_pedido').AsInteger := ANumeroPedido;
    QryItens.Open;

    Result.LimparItens;
    QryItens.First;
    while not QryItens.Eof do
    begin
      LItem := TPedidoItem.Create;
      LItem.CodigoProduto := QryItens.FieldByName('codigo_produto').AsInteger;
      LItem.DescricaoProduto := QryItens.FieldByName('descricao').AsString;
      LItem.Quantidade := QryItens.FieldByName('quantidade').AsFloat;
      LItem.ValorUnitario := QryItens.FieldByName('vlr_unitario').AsCurrency;
      LItem.ValorTotal := QryItens.FieldByName('vlr_total').AsCurrency;
      Result.AdicionarItem(LItem);
      QryItens.Next;
    end;

  finally
    QryPedido.Free;
    QryItens.Free;
  end;
end;

function TDM_DB.Deletar(ANumeroPedido: Integer): Boolean;
var
  Cmd: TFDCommand;
begin
  Result := False;
  Cmd := TFDCommand.Create(nil);

  try
    Cmd.Connection := FDConnection;
    FDConnection.StartTransaction;

    try
      Cmd.CommandText.Text := 'DELETE FROM pedidos_produtos WHERE numero_pedido = :numero_pedido';
      Cmd.ParamByName('numero_pedido').AsInteger := ANumeroPedido;
      Cmd.Execute;

      Cmd.CommandText.Text := 'DELETE FROM pedidos WHERE numero_pedido = :numero_pedido';
      Cmd.ParamByName('numero_pedido').AsInteger := ANumeroPedido;
      Cmd.Execute;

      if Cmd.RowsAffected = 0 then
      begin
        FDConnection.Rollback;
        Exit;
      end;

      FDConnection.Commit;
      Result := True;
    except
      on E: Exception do
      begin
        FDConnection.Rollback;
        raise;
      end;
    end;
  finally
    Cmd.Free;
  end;
end;

function TDM_DB.Salvar(APedido: TPedido): Integer;
var
  Qry: TFDQuery;
  Cmd: TFDCommand;
  LItem: TPedidoItem;
  LNewPedidoID: Integer;
begin
  Result := 0;
  FDConnection.StartTransaction;
  Qry := TFDQuery.Create(nil);
  Cmd := TFDCommand.Create(nil);
  try
    Cmd.Connection := FDConnection;
    Cmd.CommandText.Text := 'INSERT INTO pedidos (data_emissao, codigo_cliente, valor_total) VALUES (:data, :cod_cli, :vlr_total)';
    Cmd.ParamByName('data').AsDate := APedido.DataEmissao;
    Cmd.ParamByName('cod_cli').AsInteger := APedido.Cliente.Codigo;
    Cmd.ParamByName('vlr_total').AsCurrency := APedido.ValorTotal;
    Cmd.Execute;

    Qry.Connection := FDConnection;
    Qry.SQL.Text := 'SELECT LAST_INSERT_ID() AS id';
    Qry.Open;
    LNewPedidoID := Qry.FieldByName('id').AsInteger;
    Qry.Close;

    Cmd.CommandText.Text := 'INSERT INTO pedidos_produtos (numero_pedido, codigo_produto, quantidade, vlr_unitario, vlr_total) ' + 'VALUES (:num_ped, :cod_prod, :qtd, :vlr_un, :vlr_tot)';
    for LItem in APedido.Itens do
    begin
      Cmd.ParamByName('num_ped').AsInteger := LNewPedidoID;
      Cmd.ParamByName('cod_prod').AsInteger := LItem.CodigoProduto;
      Cmd.ParamByName('qtd').AsFloat := LItem.Quantidade;
      Cmd.ParamByName('vlr_un').AsCurrency := LItem.ValorUnitario;
      Cmd.ParamByName('vlr_tot').AsCurrency := LItem.ValorTotal;
      Cmd.Execute;
    end;

    FDConnection.Commit;
    Result := LNewPedidoID;
  except
    on E: Exception do
    begin
      FDConnection.Rollback;
      raise Exception.Create('Erro ao salvar o pedido: ' + E.Message);
    end;
  end;
end;

end.

