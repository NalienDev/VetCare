<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
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
        idFichaClin = Integer.parseInt(idFichaClinParam.trim());
    }
    if (idFichaClin == 0) {
        throw new Exception("Animal não selecionado.");
    }

    // ============================
    // BUSCAR / CRIAR HISTÓRICO
    // ============================
    PreparedStatement psH = con.prepareStatement("SELECT idHistorico FROM historicoClinico WHERE idFichaClin=?");
    psH.setInt(1, idFichaClin);
    ResultSet rsH = psH.executeQuery();

    if (rsH.next()) idHistorico = rsH.getInt("idHistorico");
    rsH.close(); psH.close();

    if (idHistorico == 0) {
        PreparedStatement psCreate = con.prepareStatement(
            "INSERT INTO historicoClinico (idFichaClin) VALUES (?)",
            Statement.RETURN_GENERATED_KEYS
        );
        psCreate.setInt(1, idFichaClin);
        psCreate.executeUpdate();
        ResultSet gen = psCreate.getGeneratedKeys();
        if (gen.next()) idHistorico = gen.getInt(1);
        gen.close();
        psCreate.close();
    }

    // ============================
    // BUSCAR AGENDAMENTO
    // ============================
    if (idAgendamentoParam != null && !idAgendamentoParam.trim().isEmpty()) {
        PreparedStatement psAg = con.prepareStatement(
            "SELECT dataHrAgenda, tipoServ FROM agendamento WHERE idAgendamento=?"
        );
        psAg.setInt(1, Integer.parseInt(idAgendamentoParam.trim()));
        ResultSet rsAg = psAg.executeQuery();

        if (rsAg.next()) {
            dataHoraAgenda = rsAg.getTimestamp("dataHrAgenda");
            tipoServicoAgenda = rsAg.getString("tipoServ");
        }

        rsAg.close(); psAg.close();
    }

    // ============================
    // DEFINIR TIPO AUTOMÁTICO CORRETO
    // ============================
    if (tipoServicoAgenda != null) {
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
        con.setAutoCommit(false);

        // Parse data/hora manual se fornecida
        Timestamp dataHoraRegisto = dataHoraAgenda;
        if (dataHoraParam != null && !dataHoraParam.trim().isEmpty()) {
            try {
                dataHoraRegisto = Timestamp.valueOf(dataHoraParam.trim().replace("T", " ") + ":00");
            } catch (Exception e) {
                dataHoraRegisto = dataHoraAgenda;
            }
        }

        // ✅ CONSULTA
        if ("consulta".equals(tipoRegistro)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO consultaHist (idHistorico, dataConsulta, motivo, sintomas, diagnostico, medicacao) VALUES (?,?,?,?,?,?)"
            );
            ps.setInt(1, idHistorico);
            ps.setTimestamp(2, dataHoraRegisto);
            ps.setString(3, request.getParameter("motivo"));
            ps.setString(4, request.getParameter("sintomas"));
            ps.setString(5, request.getParameter("diagnostico"));
            ps.setString(6, request.getParameter("medicacao"));
            sucesso = ps.executeUpdate() > 0;
            ps.close();
        }

        // ✅ VACINAÇÃO
        else if ("vacina".equals(tipoRegistro)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO vacinacao (idHistorico, dataVacina, tipoVacina, fabricante) VALUES (?,?,?,?)"
            );
            ps.setInt(1, idHistorico);
            ps.setTimestamp(2, dataHoraRegisto);
            ps.setString(3, request.getParameter("tipoVacina"));
            ps.setString(4, request.getParameter("fabricante"));
            sucesso = ps.executeUpdate() > 0;
            ps.close();
        }

        // ✅ DESPARASITAÇÃO
        else if ("desparasitacao".equals(tipoRegistro)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO desparasitacao (idHistorico, dataDesparasitacao, tipoDesparasitacao, produtosUtilizados) VALUES (?,?,?,?)"
            );
            ps.setInt(1, idHistorico);
            ps.setTimestamp(2, dataHoraRegisto);
            ps.setString(3, request.getParameter("tipoDesparasitacao"));
            ps.setString(4, request.getParameter("produtosUtilizados"));
            sucesso = ps.executeUpdate() > 0;
            ps.close();
        }

        // ✅ RESULTADO EXAME
        else if ("resultadoexame".equals(tipoRegistro)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO resultadoEx (idHistorico, dataHora, tipoExame, resultadosEx) VALUES (?,?,?,?)"
            );
            ps.setInt(1, idHistorico);
            ps.setTimestamp(2, dataHoraRegisto);
            ps.setString(3, request.getParameter("tipoExame"));
            ps.setString(4, request.getParameter("resultadosEx"));
            sucesso = ps.executeUpdate() > 0;
            ps.close();
        }

        // ✅ EXAME FÍSICO
        else if ("examefisico".equals(tipoRegistro)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO exameFis (idHistorico, dataHora, peso, temperatura, freqCard, freqResp) VALUES (?,?,?,?,?,?)"
            );
            ps.setInt(1, idHistorico);
            ps.setTimestamp(2, dataHoraRegisto);
            ps.setDouble(3, Double.parseDouble(request.getParameter("peso")));
            ps.setDouble(4, Double.parseDouble(request.getParameter("temperatura")));
            ps.setInt(5, Integer.parseInt(request.getParameter("freqCard")));
            ps.setInt(6, Integer.parseInt(request.getParameter("freqResp")));
            sucesso = ps.executeUpdate() > 0;
            ps.close();
        }

        // ✅ CIRURGIA
        else if ("cirurgia".equals(tipoRegistro)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO cirurgiaHist (idHistorico, dataCirurgia, tipoCirurgia, notasPosOp) VALUES (?,?,?,?)"
            );
            ps.setInt(1, idHistorico);
            ps.setTimestamp(2, dataHoraRegisto);
            ps.setString(3, request.getParameter("tipoCirurgia"));
            ps.setString(4, request.getParameter("notasPosOp"));
            sucesso = ps.executeUpdate() > 0;
            ps.close();
        }

        // ✅ TRATAMENTO
        else if ("tratamento".equals(tipoRegistro)) {
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO TratTerapHist (idHistorico, dataTrat, descricao, tipoTratamento) VALUES (?,?,?,?)"
            );
            ps.setInt(1, idHistorico);
            ps.setTimestamp(2, dataHoraRegisto);
            ps.setString(3, request.getParameter("descricaoTrat"));
            ps.setString(4, request.getParameter("tipoTratamento"));
            sucesso = ps.executeUpdate() > 0;
            ps.close();
        }

        // ✅ CONCLUIR AUTOMATICAMENTE SEMPRE
        if (sucesso && idAgendamentoParam != null && !idAgendamentoParam.trim().isEmpty()) {
            PreparedStatement psUp = con.prepareStatement(
                "UPDATE agendamento SET statusAgendamento='concluido' WHERE idAgendamento=?"
            );
            psUp.setInt(1, Integer.parseInt(idAgendamentoParam.trim()));
            psUp.executeUpdate();
            psUp.close();
        }

        if (sucesso) {
            con.commit();
            mensagem = "✅ Registo guardado e agendamento concluído automaticamente!";
            tipoMensagem = "sucesso";
        } else {
            con.rollback();
            mensagem = "❌ Erro ao guardar registo.";
            tipoMensagem = "erro";
        }
    }

} catch (Exception e) {
    mensagem = "❌ Erro: " + e.getMessage();
    tipoMensagem = "erro";
    e.printStackTrace();
} finally {
    manipula.desligar();
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
      | 📅 Agendamento: <strong><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(dataHoraAgenda) %></strong>
      | Tipo: <strong><%= tipoServicoAgenda %></strong>
    <% } %>
  </div>

  <div class="formulario">
    <form method="POST">

      <input type="hidden" name="idFichaClin" value="<%= idFichaClin %>">
      <input type="hidden" name="idAgendamento" value="<%= idAgendamentoParam %>">

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
        <input type="datetime-local" name="dataHora" 
               value="<%= dataHoraAgenda != null ? new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm").format(dataHoraAgenda) : "" %>" 
               required>
      </div>

      <!-- CONSULTA -->
      <div id="camposConsulta" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">🩺 Consulta</h3>
        <div class="form-group"><label>Motivo</label><input type="text" name="motivo"></div>
        <div class="form-group"><label>Sintomas *</label><textarea name="sintomas" rows="3" required></textarea></div>
        <div class="form-group"><label>Medicação</label><textarea name="medicacao" rows="2"></textarea></div>
        <div class="form-group"><label>Diagnóstico *</label><textarea name="diagnostico" rows="3" required></textarea></div>
      </div>

      <!-- VACINAÇÃO -->
      <div id="camposVacina" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">💉 Vacinação</h3>
        <div class="form-group"><label>Tipo *</label><input type="text" name="tipoVacina" required></div>
        <div class="form-group"><label>Fabricante *</label><input type="text" name="fabricante" required></div>
      </div>

      <!-- DESPARASITAÇÃO -->
      <div id="camposDes" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">🪱 Desparasitação</h3>
        <div class="form-group"><label>Tipo *</label><input type="text" name="tipoDesparasitacao" required></div>
        <div class="form-group"><label>Produtos Utilizados *</label><input type="text" name="produtosUtilizados" required></div>
      </div>

      <!-- EXAME FÍSICO -->
      <div id="camposExameFis" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">🔬 Exame Físico</h3>
        <div class="form-group"><label>Peso (kg) *</label><input type="number" step="0.01" name="peso" required></div>
        <div class="form-group"><label>Temperatura (°C) *</label><input type="number" step="0.1" name="temperatura" required></div>
        <div class="form-group"><label>Frequência Cardíaca (bpm) *</label><input type="number" name="freqCard" required></div>
        <div class="form-group"><label>Frequência Respiratória (rpm) *</label><input type="number" name="freqResp" required></div>
      </div>

      <!-- RESULTADO EXAME -->
      <div id="camposRes" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">📄 Resultado Exame</h3>
        <div class="form-group"><label>Tipo *</label><input type="text" name="tipoExame" required></div>
        <div class="form-group"><label>Resultados *</label><textarea name="resultadosEx" rows="4" required></textarea></div>
      </div>

      <!-- CIRURGIA -->
      <div id="camposCir" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">🏥 Cirurgia</h3>
        <div class="form-group"><label>Tipo *</label><input type="text" name="tipoCirurgia" required></div>
        <div class="form-group"><label>Notas</label><textarea name="notasPosOp" rows="3"></textarea></div>
      </div>

      <!-- TRATAMENTO -->
      <div id="camposTrat" style="display:none;">
        <h3 style="margin:20px 0 10px 0;">🧾 Tratamento Terapêutico</h3>
        <div class="form-group"><label>Tipo *</label><input type="text" name="tipoTratamento" required></div>
        <div class="form-group"><label>Descrição *</label><textarea name="descricaoTrat" rows="3" required></textarea></div>
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

  document.getElementById("camposConsulta").style.display="none";
  document.getElementById("camposVacina").style.display="none";
  document.getElementById("camposDes").style.display="none";
  document.getElementById("camposExameFis").style.display="none";
  document.getElementById("camposRes").style.display="none";
  document.getElementById("camposCir").style.display="none";
  document.getElementById("camposTrat").style.display="none";

  if(tipo==="consulta") document.getElementById("camposConsulta").style.display="block";
  if(tipo==="vacina") document.getElementById("camposVacina").style.display="block";
  if(tipo==="desparasitacao") document.getElementById("camposDes").style.display="block";
  if(tipo==="examefisico") document.getElementById("camposExameFis").style.display="block";
  if(tipo==="resultadoexame") document.getElementById("camposRes").style.display="block";
  if(tipo==="cirurgia") document.getElementById("camposCir").style.display="block";
  if(tipo==="tratamento") document.getElementById("camposTrat").style.display="block";
}
mostrarCampos();
</script>

</body>
</html>