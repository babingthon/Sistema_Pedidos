unit uInterfaces;

interface

uses
  System.Generics.Collections, uModel.Cliente, uModel.Produto, uModel.Pedido;

type
  IRepositorioClientes = interface
    ['{1F82E2C8-191A-481F-A63A-9A0E386C0B4F}']
    function BuscarClientePorId(ACodigo: Integer): TCliente;
    function ListarTodosClientes: TList<TCliente>;
  end;

  IRepositorioProdutos = interface
    ['{B9E2B639-865B-426C-9A5A-5B0C4A4D7C2C}']
    function BuscarProdutoPorId(ACodigo: Integer): TProduto;
  end;

  IRepositorioPedidos = interface
    ['{A0E5C9C0-5F3C-4C7C-8B0E-4D7A1D8F4F2E}']
    function Salvar(APedido: TPedido): Integer;
    function BuscarPorId(ANumeroPedido: Integer): TPedido;
    function Deletar(ANumeroPedido: Integer): Boolean;
    function GerarProximoNumeroPedido: Integer;
  end;

implementation

end.

