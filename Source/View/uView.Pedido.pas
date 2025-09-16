unit uView.Pedido;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, System.Generics.Collections, uController.Pedido,
  uModel.Pedido, uModel.Cliente, uModel.Produto, Vcl.ExtCtrls, Vcl.Mask,
  Vcl.Buttons, Vcl.Grids;

type
  TViewPedido = class(TForm)
    PgPedidos: TPageControl;
    TsNovoPedido: TTabSheet;
    TsConsulta: TTabSheet;
    gbCliente: TGroupBox;
    cmbCliente: TComboBox;
    plnCliente: TPanel;
    edtCodigoCliente: TLabeledEdit;
    edtNomeCliente: TLabeledEdit;
    edtCidadeUfCliente: TLabeledEdit;
    plnProduto: TPanel;
    edtCodigoProduto: TLabeledEdit;
    edtDescricaoProduto: TLabeledEdit;
    edtValorUnitario: TLabeledEdit;
    edtQuantidade: TLabeledEdit;
    btnInserirItem: TSpeedButton;
    gbItens: TGroupBox;
    grdItens: TStringGrid;
    plnItens: TPanel;
    edtValorTotal: TLabeledEdit;
    btnGravarPedido: TSpeedButton;
    gbBuscarPedido: TGroupBox;
    btnBuscarPedido: TSpeedButton;
    edtBuscaNumeroPedido: TEdit;
    plnDadosPedido: TPanel;
    edtConsultaNumeroPedido: TLabeledEdit;
    edtConsultaCliente: TLabeledEdit;
    edtConsultaData: TLabeledEdit;
    edtConsultaValorTotal: TLabeledEdit;
    GroupBox1: TGroupBox;
    grdItensConsulta: TStringGrid;
    btnCancelarPedido: TSpeedButton;
    procedure cmbClienteChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtCodigoProdutoExit(Sender: TObject);
    procedure btnInserirItemClick(Sender: TObject);
    procedure btnGravarPedidoClick(Sender: TObject);
    procedure grdItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnBuscarPedidoClick(Sender: TObject);
    procedure btnCancelarPedidoClick(Sender: TObject);
  private
    FController: TControllerPedido;
    FPedido: TPedido;
    FItemSelecionado: TPedidoItem;
    FProdutoSelecionado: TProduto;

    procedure LimparTela(AIniciarNovoPedido: Boolean);
    procedure PreencherGrid;
    procedure AtualizarTotalizador;
    procedure LimparCamposProduto;
    procedure CarregarComboClientes;
    procedure ConfigurarGrid;
    procedure PreencherGridConsulta(APedido: TPedido);
  public
    procedure SetController(const AController: TControllerPedido);
  end;

var
  ViewPedido: TViewPedido;

implementation

{$R *.dfm}

{ TViewPedido }

procedure TViewPedido.AtualizarTotalizador;
var
  LValorTotal: Currency;
begin
  if Assigned(FPedido) then
    LValorTotal := FPedido.ValorTotal
  else
    LValorTotal := 0;

  edtValorTotal.Text := FormatCurr('#,##0.00', LValorTotal);
end;

procedure TViewPedido.btnBuscarPedidoClick(Sender: TObject);
var
  LNumeroPedido: Integer;
  LPedidoEncontrado: TPedido;
begin
  if not TryStrToInt(edtBuscaNumeroPedido.Text, LNumeroPedido) then
  begin
    ShowMessage('Por favor, informe um número de pedido válido.');
    Exit;
  end;

  edtConsultaNumeroPedido.Clear;
  edtConsultaCliente.Clear;
  edtConsultaData.Clear;
  edtConsultaValorTotal.Clear;
  grdItensConsulta.RowCount := 1;

  LPedidoEncontrado := FController.CarregarPedido(LNumeroPedido);

  try
    if Assigned(LPedidoEncontrado) then
    begin
      edtConsultaNumeroPedido.Text := IntToStr(LPedidoEncontrado.NumeroPedido);
      edtConsultaCliente.Text := LPedidoEncontrado.Cliente.Nome;
      edtConsultaData.Text := FormatDateTime('dd/mm/yyyy', LPedidoEncontrado.DataEmissao);
      edtConsultaValorTotal.Text := FormatCurr('#,##0.00', LPedidoEncontrado.ValorTotal);

      PreencherGridConsulta(LPedidoEncontrado);
    end
    else
    begin
      ShowMessage('Pedido número ' + IntToStr(LNumeroPedido) + ' não foi encontrado.');
    end;
  finally
    LPedidoEncontrado.Free;
  end;
end;

procedure TViewPedido.btnCancelarPedidoClick(Sender: TObject);
var
  LInput, LMsg: string;
  LNumeroPedido: Integer;
begin
  if not InputQuery('Cancelar Pedido', 'Digite o número do pedido a ser cancelado:', LInput) then
    Exit;

  if not TryStrToInt(LInput, LNumeroPedido) or (LNumeroPedido <= 0) then
  begin
    ShowMessage('Número do pedido inválido.');
    Exit;
  end;

  LMsg := Format('ATENÇÃO!%s%sTem certeza que deseja cancelar PERMANENTEMENTE o pedido número %d?', [#13#10, #13#10, LNumeroPedido]);
  if MessageDlg(LMsg, mtWarning, [mbYes, mbNo], 0) = mrNo then
    Exit;

  try
    if FController.CancelarPedido(LNumeroPedido) then
    begin
      ShowMessage(Format('Pedido número %d foi cancelado com sucesso.', [LNumeroPedido]));
    end
    else
    begin
      ShowMessage('Pedido não encontrado.');
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Ocorreu um erro inesperado ao cancelar o pedido: ' + E.Message);
    end;
  end;
end;

procedure TViewPedido.btnGravarPedidoClick(Sender: TObject);
var
  LNovoPedidoID: Integer;
begin
  if not Assigned(FPedido) then
    Exit;

  if MessageDlg('Deseja realmente gravar o pedido atual?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
    Exit;

  try
    LNovoPedidoID := FController.SalvarPedido(FPedido);
    ShowMessage(Format('Pedido número %d gravado com sucesso!', [LNovoPedidoID]));

    LimparTela(True);
  except
    on E: Exception do
    begin
      ShowMessage('Ocorreu um erro ao gravar o pedido:' + #13#10 + E.Message);
    end;
  end;
end;

procedure TViewPedido.btnInserirItemClick(Sender: TObject);
var
  LQuantidade: Double;
  LValorUnitario: Currency;
begin
  if not Assigned(FPedido) then
    FPedido := FController.NovoPedido;

  if FPedido.Cliente.Codigo = 0 then
  begin
    ShowMessage('Por favor, selecione um cliente antes de inserir um produto.');
    cmbCliente.SetFocus;
    Exit;
  end;

  if not TryStrToFloat(edtQuantidade.Text, LQuantidade) or (LQuantidade <= 0) then
  begin
    ShowMessage('A quantidade informada é inválida.');
    edtQuantidade.SetFocus;
    Exit;
  end;
  if not TryStrToCurr(edtValorUnitario.Text, LValorUnitario) then
  begin
    ShowMessage('O valor unitário informado é inválido.');
    edtValorUnitario.SetFocus;
    Exit;
  end;

  if Assigned(FItemSelecionado) then
  begin
    FController.AtualizarItemNoPedido(FItemSelecionado, LQuantidade, LValorUnitario);
  end
  else
  begin
    if not Assigned(FProdutoSelecionado) then
    begin
      ShowMessage('Por favor, informe um código de produto válido e pressione TAB.');
      edtCodigoProduto.SetFocus;
      Exit;
    end;

    FController.AdicionarItemAoPedido(FPedido, FProdutoSelecionado, LQuantidade, LValorUnitario);
  end;

  PreencherGrid;
  AtualizarTotalizador;
  LimparCamposProduto;
end;

procedure TViewPedido.CarregarComboClientes;
var
  LClientes: TList<TCliente>;
  LCliente: TCliente;
begin
  cmbCliente.Items.Clear;
  LClientes := FController.ListarClientes;
  try
    cmbCliente.Items.Add('Selecione um cliente...');

    for LCliente in LClientes do
    begin
      cmbCliente.Items.AddObject(Format('%d - %s', [LCliente.Codigo, LCliente.Nome]), TObject(LCliente));
    end;

    cmbCliente.ItemIndex := 0;
  finally
    LClientes.Free;
  end;
end;

procedure TViewPedido.cmbClienteChange(Sender: TObject);
var
  LCliente: TCliente;
begin
  if not Assigned(FPedido) then
    FPedido := FController.NovoPedido;

  if (cmbCliente.ItemIndex <= 0) then
  begin
    edtCodigoCliente.Text := EmptyStr;
    edtNomeCliente.Text := EmptyStr;
    edtCidadeUfCliente.Text := EmptyStr;

    if Assigned(FPedido.Cliente) then
      FPedido.Cliente.Free;

    FPedido.Cliente := TCliente.Create;
    Exit;
  end;

  LCliente := TCliente(cmbCliente.Items.Objects[cmbCliente.ItemIndex]);

  if Assigned(FPedido.Cliente) then
    FPedido.Cliente.Free;

  FPedido.Cliente := LCliente;
  cmbCliente.Items.Objects[cmbCliente.ItemIndex] := nil;

  edtCodigoCliente.Text := LCliente.Codigo.ToString;
  edtNomeCliente.Text := LCliente.Nome;
  edtCidadeUfCliente.Text := Format('%s - %s', [LCliente.Cidade, LCliente.UF]);
end;

procedure TViewPedido.edtCodigoProdutoExit(Sender: TObject);
var
  LProdutoCodigo: Integer;
  LProduto: TProduto;
begin
  if edtCodigoProduto.Text = EmptyStr.Trim then
    Exit;

  if not TryStrToInt(edtCodigoProduto.Text, LProdutoCodigo) then
  begin
    ShowMessage('Código do produto inválido.');
    edtCodigoProduto.SetFocus;
    Exit;
  end;

  LProduto := FController.BuscarProduto(LProdutoCodigo);
  FProdutoSelecionado := LProduto;

  if Assigned(LProduto) then
  begin
    edtDescricaoProduto.Text := LProduto.Descricao;
    edtValorUnitario.Text := FormatCurr('0.00', LProduto.PrecoVenda);
    edtQuantidade.Text := '1';
    edtQuantidade.SetFocus;
  end
  else
  begin
    ShowMessage('Produto com código ' + edtCodigoProduto.Text + ' não encontrado.');
    LimparCamposProduto;
    edtCodigoProduto.SetFocus;
  end;
end;

procedure TViewPedido.FormShow(Sender: TObject);
begin
  PgPedidos.ActivePageIndex := 0;
  CarregarComboClientes;
  ConfigurarGrid;
end;

procedure TViewPedido.grdItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  LItem: TPedidoItem;
begin
  if (Key = VK_DELETE) and (grdItens.Row > 0) then
  begin
    LItem := TPedidoItem(grdItens.Objects[0, grdItens.Row]);
    if not Assigned(LItem) then
      Exit;

    if MessageDlg(Format('Deseja realmente apagar o item "%s"?', [LItem.DescricaoProduto]), mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      Exit;

    FController.RemoverItemDoPedido(FPedido, LItem);
    PreencherGrid;
    AtualizarTotalizador;
    LimparCamposProduto;
    Exit;
  end;

  if (Key = VK_RETURN) and (grdItens.Row > 0) then
  begin
    LItem := TPedidoItem(grdItens.Objects[0, grdItens.Row]);
    if not Assigned(LItem) then
      Exit;

    FItemSelecionado := LItem;

    edtCodigoProduto.Text := IntToStr(LItem.CodigoProduto);
    edtDescricaoProduto.Text := LItem.DescricaoProduto;
    edtQuantidade.Text := Format('%.3f', [LItem.Quantidade]);
    edtValorUnitario.Text := FormatCurr('0.00', LItem.ValorUnitario);

    btnInserirItem.Caption := 'Atualizar Item';
    edtCodigoProduto.Enabled := False;
    edtQuantidade.SetFocus;
  end;
end;

procedure TViewPedido.LimparCamposProduto;
begin
  FProdutoSelecionado := nil;
  edtCodigoProduto.Clear;
  edtDescricaoProduto.Clear;
  edtQuantidade.Clear;
  edtValorUnitario.Clear;

  FItemSelecionado := nil;
  btnInserirItem.Caption := 'Adicionar';
  edtCodigoProduto.Enabled := True;
end;

procedure TViewPedido.LimparTela(AIniciarNovoPedido: Boolean);
begin
  FreeAndNil(FPedido);
  FItemSelecionado := nil;
  FProdutoSelecionado := nil;

  if AIniciarNovoPedido then
    FPedido := FController.NovoPedido;

  cmbCliente.ItemIndex := 0;
  edtCodigoCliente.Text := EmptyStr;
  edtNomeCliente.Text := EmptyStr;
  edtCidadeUfCliente.Text := EmptyStr;

  LimparCamposProduto;
  PreencherGrid;
  AtualizarTotalizador;

  btnGravarPedido.Visible := Assigned(FPedido);
  cmbCliente.SetFocus;
end;

procedure TViewPedido.PreencherGrid;
var
  LItem: TPedidoItem;
  i: Integer;
begin
  grdItens.BeginUpdate;

  try
    grdItens.RowCount := 1;

    if not Assigned(FPedido) then
      Exit;

    grdItens.RowCount := FPedido.Itens.Count + 1;

    for i := 0 to FPedido.Itens.Count - 1 do
    begin
      LItem := FPedido.Itens[i];

      grdItens.Cells[0, i + 1] := IntToStr(LItem.CodigoProduto);
      grdItens.Cells[1, i + 1] := LItem.DescricaoProduto;
      grdItens.Cells[2, i + 1] := Format('%.3f', [LItem.Quantidade]);
      grdItens.Cells[3, i + 1] := FormatCurr('#,##0.00', LItem.ValorUnitario);
      grdItens.Cells[4, i + 1] := FormatCurr('#,##0.00', LItem.ValorTotal);

      grdItens.Objects[0, i + 1] := LItem;
    end;
  finally
    grdItens.EndUpdate;
  end;
end;

procedure TViewPedido.PreencherGridConsulta(APedido: TPedido);
var
  LItem: TPedidoItem;
  i: Integer;
begin
  grdItensConsulta.Cells[0, 0] := 'Cód. Produto';
  grdItensConsulta.Cells[1, 0] := 'Descrição';
  grdItensConsulta.Cells[2, 0] := 'Quantidade';
  grdItensConsulta.Cells[3, 0] := 'Vlr. Unitário';
  grdItensConsulta.Cells[4, 0] := 'Vlr. Total';

  grdItensConsulta.BeginUpdate;
  try
    grdItensConsulta.RowCount := 1;
    if not Assigned(APedido) then
      Exit;

    grdItensConsulta.RowCount := APedido.Itens.Count + 1;

    for i := 0 to APedido.Itens.Count - 1 do
    begin
      LItem := APedido.Itens[i];
      grdItensConsulta.Cells[0, i + 1] := IntToStr(LItem.CodigoProduto);
      grdItensConsulta.Cells[1, i + 1] := LItem.DescricaoProduto;
      grdItensConsulta.Cells[2, i + 1] := Format('%.3f', [LItem.Quantidade]);
      grdItensConsulta.Cells[3, i + 1] := FormatCurr('#,##0.00', LItem.ValorUnitario);
      grdItensConsulta.Cells[4, i + 1] := FormatCurr('#,##0.00', LItem.ValorTotal);
    end;
  finally
    grdItensConsulta.EndUpdate;
  end;
end;

procedure TViewPedido.SetController(const AController: TControllerPedido);
begin
  FController := AController;
end;

procedure TViewPedido.ConfigurarGrid;
begin
  grdItens.Cells[0, 0] := 'Cód. Produto';
  grdItens.Cells[1, 0] := 'Descrição';
  grdItens.Cells[2, 0] := 'Quantidade';
  grdItens.Cells[3, 0] := 'Vlr. Unitário';
  grdItens.Cells[4, 0] := 'Vlr. Total';

  grdItens.ColWidths[0] := 80;   // Cód. Produto
  grdItens.ColWidths[1] := 250;  // Descrição
  grdItens.ColWidths[2] := 100;  // Quantidade
  grdItens.ColWidths[3] := 120;  // Vlr. Unitário
  grdItens.ColWidths[4] := 120;  // Vlr. Total
end;

end.

