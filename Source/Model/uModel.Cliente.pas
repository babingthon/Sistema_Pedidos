unit uModel.Cliente;

interface

type
  TCliente = class
  private
    FCodigo: Integer;
    FNome: string;
    FCidade: string;
    FUF: string;
  public
    constructor Create;
    destructor Destroy; override;
    property Codigo: Integer read FCodigo write FCodigo;
    property Nome: string read FNome write FNome;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write FUF;
  end;

implementation

{ TCliente }

constructor TCliente.Create;
begin
  inherited Create;
  FCodigo := 0;
  FNome := '';
  FCidade := '';
  FUF := '';
end;

destructor TCliente.Destroy;
begin
  inherited Destroy;
end;

end.

