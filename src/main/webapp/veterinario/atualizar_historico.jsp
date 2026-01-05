<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Atualizar Histórico</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
</head>
<body>

<header class="main-header">
  <div class="header-content">
    <div class="logo">
      <img src="../images/logo.png" class="logo-img" alt="VetCare Logo">
      <span class="logo-text">VetCare</span>
    </div>
    <nav class="main-nav">
      <a href="../index.jsp">Início</a>
      <a href="menu.jsp">Veterinário</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Atualizar Histórico Clínico</h1>
    <p>Adicionar registos médicos durante a prestação de serviços.</p>
  </div>
</section>

<%
String mensagem = "";
String tipoMensagem = "";

String idFichaClinParam = request.getParameter("idFichaClin");
String idAgendamentoParam = request.getParameter("idAgendamento");

Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

int idFichaClin = 0;
int idHistorico = 0;

Timestamp dataHoraAgenda = null;
String tipoServicoAgenda = "";
String tipoRegistroAuto = "";

try {
    Connection con = manipula.getLigacao();

    // ============================
    // VALIDAR ANIMAL
    // ============================
    if (idFichaClinParam != null && !idFichaClinParam.trim().isEmpty()) {
        try {
            idFichaClin = Integer.parseInt(idFichaClinParam.trim());
        } catch (NumberFormatException e) {
            throw new Exception("ID do animal inválido.");
        }
    }
    
    if (idFichaClin == 0) {
        throw new Exception("Animal não selecionado.");
    }

    // ============================
    // BUSCAR / CRIAR HISTÓRICO
    // ============================
    String sqlHistorico = "SELECT idHistorico FROM historicoClinico WHERE idFichaClin=?";
    PreparedStatement psH = con.prepareStatement(sqlHistorico);
    psH.setInt(1, idFichaClin);
    ResultSet rsH = psH.executeQuery();

    if (rsH.next()) {
        idHistorico = rsH.getInt("idHistorico");
    }
    rsH.close(); 
    psH.close();

    // Criar histórico se não existir
    if (idHistorico == 0) {
        String sqlInsert = "INSERT INTO historicoClinico (idFichaClin) VALUES (?)";
        PreparedStatement psCreate = con.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS);
        psCreate.setInt(1, idFichaClin);
        int rowsInserted = psCreate.executeUpdate();
        
        if (rowsInserted > 0) {
            ResultSet gen = psCreate.getGeneratedKeys();
            if (gen.next()) {
                idHistorico = gen.getInt(1);
            }
            gen.close();
        }
        psCreate.close();
        
        if (idHistorico == 0) {
            throw new Exception("Erro ao criar histórico clínico.");
        }
    }

    // ============================
    // BUSCAR AGENDAMENTO
    // ============================
    if (idAgendamentoParam != null && !idAgendamentoParam.trim().isEmpty()) {
        try {
            int idAgendamento = Integer.parseInt(idAgendamentoParam.trim());
            String sqlAgenda = "SELECT dataHrAgenda, tipoServ FROM agendamento WHERE idAgendamento=?";
            PreparedStatement psAg = con.prepareStatement(sqlAgenda);
            psAg.setInt(1, idAgendamento);
            ResultSet rsAg = psAg.executeQuery();

            if (rsAg.next()) {
                dataHoraAgenda = rsAg.getTimestamp("dataHrAgenda");
                tipoServicoAgenda = rsAg.getString("tipoServ");
            }

            rsAg.close(); 
            psAg.close();
        } catch (NumberFormatException e) {
            // ID de agendamento inválido - continua sem dados do agendamento
        }
    }

    // ============================
    // DEFINIR TIPO AUTOMÁTICO
    // ============================
    if (tipoServicoAgenda != null && !tipoServicoAgenda.trim().isEmpty()) {
        String ts = tipoServicoAgenda.toLowerCase();

        if (ts.contains("consulta")) tipoRegistroAuto = "consulta";
        else if (ts.contains("vacina")) tipoRegistroAuto = "vacina";
        else if (ts.contains("desparasit")) tipoRegistroAuto = "desparasitacao";
        else if (ts.contains("exame") && !ts.contains("fisico")) tipoRegistroAuto = "resultadoexame";
        else if (ts.contains("fisico")) tipoRegistroAuto = "examefisico";
        else if (ts.contains("cirurgia")) tipoRegistroAuto = "cirurgia";
        else if (ts.contains("tratamento")) tipoRegistroAuto = "tratamento";
        else tipoRegistroAuto = "consulta";
    }

    // ============================
    // POST -> GUARDAR REGISTO
    // ============================
    if ("POST".equalsIgnoreCase(request.getMethod())) {

        String tipoRegistro = request.getParameter("tipoRegistro");
        String dataHoraParam = request.getParameter("dataHora");
        boolean sucesso = false;
        
        // Desativar autocommit para controlo manual da transação
        con.setAutoCommit(false);

        try {
            // Parse data/hora
            Timestamp dataHoraRegisto = null;
            
            if (dataHoraParam != null && !dataHoraParam.trim().isEmpty()) {
                try {
                    // Formato: 2024-01-15T14:30 -> 2024-01-15 14:30:00
                    String dataFormatada = dataHoraParam.trim().replace("T", " ");
                    if (dataFormatada.length() == 16) { // yyyy-MM-dd HH:mm
                        dataFormatada += ":00";
                    }
                    dataHoraRegisto = Timestamp.valueOf(dataFormatada);
                } catch (Exception e) {
                    System.err.println("Erro ao converter data: " + e.getMessage());
                    dataHoraRegisto = dataHoraAgenda;
                }
            }
            
            // Se ainda não temos data, usar a do agendamento ou atual
            if (dataHoraRegisto == null) {
                dataHoraRegisto = (dataHoraAgenda != null) ? dataHoraAgenda : new Timestamp(System.currentTimeMillis());
            }

            // ============================
            // EXECUTAR INSERT CONFORME TIPO
            // ============================
            
            if ("consulta".equals(tipoRegistro)) {
                // ✅ CONSULTA
                String sql = "INSERT INTO consultaHist (idHistorico, dataConsulta, motivo, sintomas, diagnostico, medicacao) VALUES (?,?,?,?,?,?)";
                List<Object> params = new ArrayList<>();
                params.add(idHistorico);
                params.add(dataHoraRegisto);
                params.add(request.getParameter("motivo"));
                params.add(request.getParameter("sintomas"));
                params.add(request.getParameter("diagnostico"));
                params.add(request.getParameter("medicacao"));
                
                sucesso = manipula.xDirectiva(sql, params);
            }
            else if ("vacina".equals(tipoRegistro)) {
                // ✅ VACINAÇÃO
                String sql = "INSERT INTO vacinacao (idHistorico, dataVacina, tipoVacina, fabricante) VALUES (?,?,?,?)";
                List<Object> params = new ArrayList<>();
                params.add(idHistorico);
                params.add(dataHoraRegisto);
                params.add(request.getParameter("tipoVacina"));
                params.add(request.getParameter("fabricante"));
                
                sucesso = manipula.xDirectiva(sql, params);
            }
            else if ("desparasitacao".equals(tipoRegistro)) {
                // ✅ DESPARASITAÇÃO
                String sql = "INSERT INTO desparasitacao (idHistorico, dataDesparasitacao, tipoDesparasitacao, produtosUtilizados) VALUES (?,?,?,?)";
                List<Object> params = new ArrayList<>();
                params.add(idHistorico);
                params.add(dataHoraRegisto);
                params.add(request.getParameter("tipoDesparasitacao"));
                params.add(request.getParameter("produtosUtilizados"));
                
                sucesso = manipula.xDirectiva(sql, params);
            }
            else if ("resultadoexame".equals(tipoRegistro)) {
                // ✅ RESULTADO EXAME
                String sql = "INSERT INTO resultadoEx (idHistorico, dataHora, tipoExame, resultadosEx) VALUES (?,?,?,?)";
                List<Object> params = new ArrayList<>();
                params.add(idHistorico);
                params.add(dataHoraRegisto);
                params.add(request.getParameter("tipoExame"));
                params.add(request.getParameter("resultadosEx"));
                
                sucesso = manipula.xDirectiva(sql, params);
            }
            else if ("examefisico".equals(tipoRegistro)) {
                // ✅ EXAME FÍSICO
                String sql = "INSERT INTO exameFis (idHistorico, dataHora, peso, temperatura, freqCard, freqResp) VALUES (?,?,?,?,?,?)";
                List<Object> params = new ArrayList<>();
                params.add(idHistorico);
                params.add(dataHoraRegisto);
                
                // Converter strings para números com validação
                try {
                    params.add(Double.parseDouble(request.getParameter("peso")));
                    params.add(Double.parseDouble(request.getParameter("temperatura")));
                    params.add(Integer.parseInt(request.getParameter("freqCard")));
                    params.add(Integer.parseInt(request.getParameter("freqResp")));
                    
                    sucesso = manipula.xDirectiva(sql, params);
                } catch (NumberFormatException e) {
                    throw new Exception("Valores numéricos inválidos no exame físico.");
                }
            }
            else if ("cirurgia".equals(tipoRegistro)) {
                // ✅ CIRURGIA
                String sql = "INSERT INTO cirurgiaHist (idHistorico, dataCirurgia, tipoCirurgia, notasPosOp) VALUES (?,?,?,?)";
                List<Object> params = new ArrayList<>();
                params.add(idHistorico);
                params.add(dataHoraRegisto);
                params.add(request.getParameter("tipoCirurgia"));
                params.add(request.getParameter("notasPosOp"));
                
                sucesso = manipula.xDirectiva(sql, params);
            }
            else if ("tratamento".equals(tipoRegistro)) {
                // ✅ TRATAMENTO
                String sql = "INSERT INTO TratTerapHist (idHistorico, dataTrat, descricao, tipoTratamento) VALUES (?,?,?,?)";
                List<Object> params = new ArrayList<>();
                params.add(idHistorico);
                params.add(dataHoraRegisto);
                params.add(request.getParameter("descricaoTrat"));
                params.add(request.getParameter("tipoTratamento"));
                
                sucesso = manipula.xDirectiva(sql, params);
            }
            else {
                throw new Exception("Tipo de registo inválido: " + tipoRegistro);
            }

            // ============================
            // ATUALIZAR AGENDAMENTO
            // ============================
            if (sucesso && idAgendamentoParam != null && !idAgendamentoParam.trim().isEmpty()) {
                try {
                    String sqlUpdate = "UPDATE agendamento SET statusAgendamento='realizado' WHERE idAgendamento=?";
                    List<Object> paramsUpdate = new ArrayList<>();
                    paramsUpdate.add(Integer.parseInt(idAgendamentoParam.trim()));
                    manipula.xDirectiva(sqlUpdate, paramsUpdate);
                } catch (NumberFormatException e) {
                    // Não conseguiu atualizar agendamento mas o registo foi salvo
                }
            }

            // ============================
            // COMMIT OU ROLLBACK
            // ============================
            if (sucesso) {
                con.commit();
                mensagem = "✅ Registo guardado com sucesso!";
                if (idAgendamentoParam != null && !idAgendamentoParam.trim().isEmpty()) {
                    mensagem += " Agendamento concluído automaticamente.";
                }
                tipoMensagem = "sucesso";
            } else {
                con.rollback();
                mensagem = "❌ Erro ao guardar registo na base de dados.";
                tipoMensagem = "erro";
            }
            
        } catch (Exception e) {
            con.rollback();
            mensagem = "❌ Erro ao processar registo: " + e.getMessage();
            tipoMensagem = "erro";
            e.printStackTrace();
        } finally {
            con.setAutoCommit(true);
        }
    }

} catch (Exception e) {
    mensagem = "❌ Erro: " + e.getMessage();
    tipoMensagem = "erro";
    e.printStackTrace();
} finally {
    // Não fechar a conexão aqui se ainda precisamos exibir dados
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        manipula.desligar();
    }
}
%>

<div class="page-content">
  <a href="lista_chamada.jsp" class="btn-voltar">← Voltar à Lista de Chamada</a>

  <% if (!mensagem.isEmpty()) { %>
    <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <div class="mensagem">
    🐾 Animal ID: <strong><%= idFichaClin %></strong> |
    📌 Histórico ID: <strong><%= idHistorico %></strong>
    <% if (dataHoraAgenda != null) { %>
      | 📅 Agendamento: <strong><%= new SimpleDateFormat("dd/MM/yyyy HH:mm").format(dataHoraAgenda) %></strong>
      | Tipo: <strong><%= tipoServicoAgenda %></strong>
    <% } %>
  </div>

  <div class="formulario">
    <form method="POST" onsubmit="return validarFormulario()">

      <input type="hidden" name="idFichaClin" value="<%= idFichaClin %>">
      <input type="hidden" name="idAgendamento" value="<%= idAgendamentoParam != null ? idAgendamentoParam : "" %>">

      <div class="form-group">
        <label>Tipo de Registo *</label>
        <select name="tipoRegistro" id="tipoRegistro" required onchange="mostrarCampos()">
          <option value="consulta" <%= "consulta".equals(tipoRegistroAuto) ? "selected" : "" %>>🩺 Consulta</option>
          <option value="vacina" <%= "vacina".equals(tipoRegistroAuto) ? "selected" : "" %>>💉 Vacinação</option>
          <option value="desparasitacao" <%= "desparasitacao".equals(tipoRegistroAuto) ? "selected" : "" %>>🪱 Desparasitação</option>
          <option value="examefisico" <%= "examefisico".equals(tipoRegistroAuto) ? "selected" : "" %>>🔬 Exame Físico</option>
          <option value="resultadoexame" <%= "resultadoexame".equals(tipoRegistroAuto) ? "selected" : "" %>>📄 Resultado Exame</option>
          <option value="cirurgia" <%= "cirurgia".equals(tipoRegistroAuto) ? "selected" : "" %>>🏥 Cirurgia</option>
          <option value="tratamento" <%= "tratamento".equals(tipoRegistroAuto) ? "selected" : "" %>>🧾 Tratamento Terapêutico</option>
        </select>
      </div>

      <div class="form-group">
        <label>Data e Hora *</label>
        <input type="datetime-local" name="dataHora" id="dataHora"
               value="<%= dataHoraAgenda != null ? new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(dataHoraAgenda) : "" %>" 
               required>
      </div>

      <!-- CONSULTA -->
      <div id="camposConsulta" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">🩺 Consulta</h3>
        <div class="form-group"><label>Motivo</label><input type="text" name="motivo" id="motivo"></div>
        <div class="form-group"><label>Sintomas *</label><textarea name="sintomas" id="sintomas" rows="3"></textarea></div>
        <div class="form-group"><label>Medicação</label><textarea name="medicacao" id="medicacao" rows="2"></textarea></div>
        <div class="form-group"><label>Diagnóstico *</label><textarea name="diagnostico" id="diagnostico" rows="3"></textarea></div>
      </div>

      <!-- VACINAÇÃO -->
      <div id="camposVacina" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">💉 Vacinação</h3>
        <div class="form-group"><label>Tipo *</label><input type="text" name="tipoVacina" id="tipoVacina"></div>
        <div class="form-group"><label>Fabricante *</label><input type="text" name="fabricante" id="fabricante"></div>
      </div>

      <!-- DESPARASITAÇÃO -->
      <div id="camposDes" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">🪱 Desparasitação</h3>
        <div class="form-group"><label>Tipo *</label><input type="text" name="tipoDesparasitacao" id="tipoDesparasitacao"></div>
        <div class="form-group"><label>Produtos Utilizados *</label><input type="text" name="produtosUtilizados" id="produtosUtilizados"></div>
      </div>

      <!-- EXAME FÍSICO -->
      <div id="camposExameFis" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">🔬 Exame Físico</h3>
        <div class="form-group"><label>Peso (kg) *</label><input type="number" step="0.01" name="peso" id="peso"></div>
        <div class="form-group"><label>Temperatura (°C) *</label><input type="number" step="0.1" name="temperatura" id="temperatura"></div>
        <div class="form-group"><label>Frequência Cardíaca (bpm) *</label><input type="number" name="freqCard" id="freqCard"></div>
        <div class="form-group"><label>Frequência Respiratória (rpm) *</label><input type="number" name="freqResp" id="freqResp"></div>
      </div>

      <!-- RESULTADO EXAME -->
      <div id="camposRes" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">📄 Resultado Exame</h3>
        <div class="form-group"><label>Tipo *</label><input type="text" name="tipoExame" id="tipoExame"></div>
        <div class="form-group"><label>Resultados *</label><textarea name="resultadosEx" id="resultadosEx" rows="4"></textarea></div>
      </div>

      <!-- CIRURGIA -->
      <div id="camposCir" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">🏥 Cirurgia</h3>
        <div class="form-group"><label>Tipo *</label><input type="text" name="tipoCirurgia" id="tipoCirurgia"></div>
        <div class="form-group"><label>Notas</label><textarea name="notasPosOp" id="notasPosOp" rows="3"></textarea></div>
      </div>

      <!-- TRATAMENTO -->
      <div id="camposTrat" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">🧾 Tratamento Terapêutico</h3>
        <div class="form-group"><label>Tipo *</label><input type="text" name="tipoTratamento" id="tipoTratamento"></div>
        <div class="form-group"><label>Descrição *</label><textarea name="descricaoTrat" id="descricaoTrat" rows="3"></textarea></div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn btn-primary">💾 Guardar</button>
      </div>
    </form>
  </div>
</div>

<script>
function mostrarCampos() {
  const tipo = document.getElementById("tipoRegistro").value;

  // Esconder todos
  document.getElementById("camposConsulta").style.display="none";
  document.getElementById("camposVacina").style.display="none";
  document.getElementById("camposDes").style.display="none";
  document.getElementById("camposExameFis").style.display="none";
  document.getElementById("camposRes").style.display="none";
  document.getElementById("camposCir").style.display="none";
  document.getElementById("camposTrat").style.display="none";

  // Remover required de todos os campos
  document.querySelectorAll('#camposConsulta input, #camposConsulta textarea').forEach(el => el.removeAttribute('required'));
  document.querySelectorAll('#camposVacina input').forEach(el => el.removeAttribute('required'));
  document.querySelectorAll('#camposDes input').forEach(el => el.removeAttribute('required'));
  document.querySelectorAll('#camposExameFis input').forEach(el => el.removeAttribute('required'));
  document.querySelectorAll('#camposRes input, #camposRes textarea').forEach(el => el.removeAttribute('required'));
  document.querySelectorAll('#camposCir input').forEach(el => el.removeAttribute('required'));
  document.querySelectorAll('#camposTrat input, #camposTrat textarea').forEach(el => el.removeAttribute('required'));

  // Mostrar campos do tipo selecionado e adicionar required
  if(tipo==="consulta") {
    document.getElementById("camposConsulta").style.display="block";
    document.getElementById("sintomas").required = true;
    document.getElementById("diagnostico").required = true;
  }
  if(tipo==="vacina") {
    document.getElementById("camposVacina").style.display="block";
    document.getElementById("tipoVacina").required = true;
    document.getElementById("fabricante").required = true;
  }
  if(tipo==="desparasitacao") {
    document.getElementById("camposDes").style.display="block";
    document.getElementById("tipoDesparasitacao").required = true;
    document.getElementById("produtosUtilizados").required = true;
  }
  if(tipo==="examefisico") {
    document.getElementById("camposExameFis").style.display="block";
    document.getElementById("peso").required = true;
    document.getElementById("temperatura").required = true;
    document.getElementById("freqCard").required = true;
    document.getElementById("freqResp").required = true;
  }
  if(tipo==="resultadoexame") {
    document.getElementById("camposRes").style.display="block";
    document.getElementById("tipoExame").required = true;
    document.getElementById("resultadosEx").required = true;
  }
  if(tipo==="cirurgia") {
    document.getElementById("camposCir").style.display="block";
    document.getElementById("tipoCirurgia").required = true;
  }
  if(tipo==="tratamento") {
    document.getElementById("camposTrat").style.display="block";
    document.getElementById("tipoTratamento").required = true;
    document.getElementById("descricaoTrat").required = true;
  }
}

function validarFormulario() {
  // Sem validações - aceita qualquer valor
  return true;
}

// Inicializar ao carregar
mostrarCampos();
</script>

<%
// Fechar conexão apenas no final
if (manipula != null) {
    manipula.desligar();
}
%>

</body>
</html>