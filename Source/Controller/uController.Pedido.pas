unit uController.Pedido;

interface

uses
  System.SysUtils, uInterfaces, uModel.Pedido, uModel.Cliente, uModel.Produto,
  System.Generics.Collections;

type
  TControllerPedido = class
  private
    FPedidoRepo: IRepositorioPedidos;
    FClienteRepo: IRepositorioClientes;
    FProdutoRepo: IRepositorioProdutos;
  public
    constructor Create(const APedidoRepo: IRepositorioPedidos; const AClienteRepo: IRepositorioClientes; const AProdutoRepo: IRepositorioProdutos);
    function NovoPedido: TPedido;
    function CarregarPedido(ANumeroPedido: Integer): TPedido;
    function SalvarPedido(const APedido: TPedido): Integer;
    function CancelarPedido(ANumeroPedido: Integer): Boolean;

    function BuscarCliente(ACodigo: Integer): TCliente;
    function ListarClientes: TList<TCliente>;
    function BuscarProduto(ACodigo: Integer): TProduto;

    procedure AdicionarItemAoPedido(const APedido: TPedido; const AProduto: TProduto; AQuantidade: Double; AValorUnitario: Currency);
    procedure AtualizarItemNoPedido(AItem: TPedidoItem; ANovaQuantidade: Double; ANovoValorUnitario: Currency);
    procedure RemoverItemDoPedido(const APedido: TPedido; AItem: TPedidoItem);
  end;

implementation

{ TControllerPedido }

constructor TControllerPedido.Create(const APedidoRepo: IRepositorioPedidos; const AClienteRepo: IRepositorioClientes; const AProdutoRepo: IRepositorioProdutos);
begin
  inherited Create;
  FPedidoRepo := APedidoRepo;
  FClienteRepo := AClienteRepo;
  FProdutoRepo := AProdutoRepo;
end;

function TControllerPedido.ListarClientes: TList<TCliente>;
begin
  Result := FClienteRepo.ListarTodosClientes;
end;

function TControllerPedido.NovoPedido: TPedido;
begin
  Result := TPedido.Create;
  Result.NumeroPedido := FPedidoRepo.GerarProximoNumeroPedido;
end;

function TControllerPedido.CarregarPedido(ANumeroPedido: Integer): TPedido;
begin
  Result := FPedidoRepo.BuscarPorId(ANumeroPedido);
end;

function TControllerPedido.SalvarPedido(const APedido: TPedido): Integer;
begin
  if not Assigned(APedido.Cliente) or (APedido.Cliente.Codigo = 0) then
    raise Exception.Create('É necessário informar um cliente para o pedido.');

  if APedido.Itens.Count = 0 then
    raise Exception.Create('O pedido deve conter pelo menos um item.');

  Result := FPedidoRepo.Salvar(APedido);
end;

function TControllerPedido.CancelarPedido(ANumeroPedido: Integer): Boolean;
begin
  Result := FPedidoRepo.Deletar(ANumeroPedido);
end;

function TControllerPedido.BuscarCliente(ACodigo: Integer): TCliente;
begin
  Result := FClienteRepo.BuscarClientePorId(ACodigo);
end;

function TControllerPedido.BuscarProduto(ACodigo: Integer): TProduto;
begin
  Result := FProdutoRepo.BuscarProdutoPorId(ACodigo);
end;

procedure TControllerPedido.AdicionarItemAoPedido(const APedido: TPedido; const AProduto: TProduto; AQuantidade: Double; AValorUnitario: Currency);
var
  LItem: TPedidoItem;
begin
  if not Assigned(APedido) then
    Exit;
  if not Assigned(AProduto) then
    Exit;

  LItem := TPedidoItem.Create;
  LItem.CodigoProduto := AProduto.Codigo;
  LItem.DescricaoProduto := AProduto.Descricao;
  LItem.Quantidade := AQuantidade;
  LItem.ValorUnitario := AValorUnitario;
  LItem.ValorTotal := LItem.Quantidade * LItem.ValorUnitario;

  APedido.AdicionarItem(LItem);
end;

procedure TControllerPedido.AtualizarItemNoPedido(AItem: TPedidoItem; ANovaQuantidade: Double; ANovoValorUnitario: Currency);
begin
  if not Assigned(AItem) then
    Exit;

  AItem.Quantidade := ANovaQuantidade;
  AItem.ValorUnitario := ANovoValorUnitario;
  AItem.ValorTotal := AItem.Quantidade * AItem.ValorUnitario;
end;

procedure TControllerPedido.RemoverItemDoPedido(const APedido: TPedido; AItem: TPedidoItem);
begin
  if not Assigned(APedido) or not Assigned(AItem) then
    Exit;

  APedido.Itens.Remove(AItem);
  AItem.Free;
end;

end.

