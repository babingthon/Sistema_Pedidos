unit uModel.Produto;

interface

type
  TProduto = class
  private
    FCodigo: Integer;
    FDescricao: string;
    FPrecoVenda: Currency;
  public
    constructor Create;
    destructor Destroy; override;
    property Codigo: Integer read FCodigo write FCodigo;
    property Descricao: string read FDescricao write FDescricao;
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;
  end;

implementation

{ TProduto }

constructor TProduto.Create;
begin
  inherited Create;
  FCodigo := 0;
  FDescricao := '';
  FPrecoVenda := 0;
end;

destructor TProduto.Destroy;
begin
  inherited Destroy;
end;

end.

