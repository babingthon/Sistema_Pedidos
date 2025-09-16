unit uModel.Pedido;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, uModel.Cliente,
  uModel.Produto;

type
  TPedidoItem = class
  private
    FAutoincrem: Integer;
    FNumeroPedido: Integer;
    FCodigoProduto: Integer;
    FDescricaoProduto: string;
    FQuantidade: Double;
    FValorUnitario: Currency;
    FValorTotal: Currency;
  public
    constructor Create;
    property Autoincrem: Integer read FAutoincrem write FAutoincrem;
    property NumeroPedido: Integer read FNumeroPedido write FNumeroPedido;
    property CodigoProduto: Integer read FCodigoProduto write FCodigoProduto;
    property DescricaoProduto: string read FDescricaoProduto write FDescricaoProduto;
    property Quantidade: Double read FQuantidade write FQuantidade;
    property ValorUnitario: Currency read FValorUnitario write FValorUnitario;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
  end;

  TPedido = class
  private
    FNumeroPedido: Integer;
    FDataEmissao: TDate;
    FCliente: TCliente;
    FItens: TList<TPedidoItem>;
    function GetValorTotal: Currency;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AdicionarItem(AItem: TPedidoItem);
    procedure LimparItens;
    property NumeroPedido: Integer read FNumeroPedido write FNumeroPedido;
    property DataEmissao: TDate read FDataEmissao write FDataEmissao;
    property Cliente: TCliente read FCliente write FCliente;
    property ValorTotal: Currency read GetValorTotal;
    property Itens: TList<TPedidoItem> read FItens;
  end;

implementation

{ TPedidoItem }

constructor TPedidoItem.Create;
begin
  inherited Create;
  FAutoincrem := 0;
  FNumeroPedido := 0;
  FCodigoProduto := 0;
  FDescricaoProduto := '';
  FQuantidade := 0;
  FValorUnitario := 0;
  FValorTotal := 0;
end;

{ TPedido }

constructor TPedido.Create;
begin
  inherited Create;
  FNumeroPedido := 0;
  FDataEmissao := Now;
  FCliente := TCliente.Create;
  FItens := TList<TPedidoItem>.Create;
end;

destructor TPedido.Destroy;
begin
  FCliente.Free;
  LimparItens;
  FItens.Free;
  inherited Destroy;
end;

procedure TPedido.AdicionarItem(AItem: TPedidoItem);
begin
  FItens.Add(AItem);
end;

procedure TPedido.LimparItens;
var
  Item: TPedidoItem;
begin
  for Item in FItens do
    Item.Free;
  FItens.Clear;
end;

function TPedido.GetValorTotal: Currency;
var
  Item: TPedidoItem;
  LTotal: Currency;
begin
  LTotal := 0;
  for Item in FItens do
    LTotal := LTotal + Item.ValorTotal;
  Result := LTotal;
end;

end.

