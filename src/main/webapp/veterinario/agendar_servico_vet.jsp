<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Agendar Serviço</title>
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
    <h1>Agendar Serviço</h1>
    <p>Marcar serviços para clientes existentes (retorno apenas).</p>
  </div>
</section>

<%
String mensagem = "";
String tipoMensagem = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String nif = request.getParameter("nif");
    String dataHoraStr = request.getParameter("dataHora");
    String tipoServ = request.getParameter("tipoServ");
    String custosStr = request.getParameter("custos");
    
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        Connection con = manipula.getLigacao();
        con.setAutoCommit(false);
        
        java.sql.Timestamp dataHora = java.sql.Timestamp.valueOf(dataHoraStr.replace("T", " ") + ":00");
        java.math.BigDecimal custos = custosStr != null && !custosStr.isEmpty() ? new java.math.BigDecimal(custosStr) : null;
        
        String sqlAgendamento = 
            "INSERT INTO agendamento (dataHrAgenda, tipoServ, statusAgendamento, custos, primeiraVez) " +
            "VALUES (?, ?, 'marcado', ?, FALSE)";
        
        PreparedStatement psAgend = con.prepareStatement(sqlAgendamento, Statement.RETURN_GENERATED_KEYS);
        psAgend.setTimestamp(1, dataHora);
        psAgend.setString(2, tipoServ);
        psAgend.setBigDecimal(3, custos);
        
        if (psAgend.executeUpdate() > 0) {
            ResultSet rsKeys = psAgend.getGeneratedKeys();
            if (rsKeys.next()) {
                int idAgendamento = rsKeys.getInt(1);
                
                String sqlAgenda = "INSERT INTO agenda (idAgendamento, NIF) VALUES (?, ?)";
                PreparedStatement psAgenda = con.prepareStatement(sqlAgenda);
                psAgenda.setInt(1, idAgendamento);
                psAgenda.setString(2, nif);
                psAgenda.executeUpdate();
                psAgenda.close();
                
                con.commit();
                mensagem = "✅ Serviço agendado! ID: " + idAgendamento;
                tipoMensagem = "sucesso";
            }
            rsKeys.close();
        } else {
            con.rollback();
            mensagem = "❌ Erro ao agendar";
            tipoMensagem = "erro";
        }
        psAgend.close();
        
    } catch (Exception e) {
        mensagem = "❌ Erro: " + e.getMessage();
        tipoMensagem = "erro";
        e.printStackTrace();
    } finally {
        manipula.desligar();
    }
}
%>

<div class="page-content">
  <a href="gestao_agendamentos_vet.jsp" class="btn-voltar">← Voltar</a>

  <% if (!mensagem.isEmpty()) { %>
      <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <div style="margin:20px 0; padding:15px; background:#FFF3CD; border-radius:10px; color:#856404;">
    <strong>ℹ️ Nota:</strong> Veterinários só podem agendar para clientes existentes (retorno). 
    Para primeira consulta, contacte a rececionista.
  </div>

  <div class="formulario">
    <form method="POST">
      <div class="form-group">
        <label>NIF do Cliente *</label>
        <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9" required
               placeholder="Cliente que já tem ficha">
      </div>
      
      <div class="form-group">
        <label>Data e Hora *</label>
        <input type="datetime-local" name="dataHora" required>
      </div>
      
      <div class="form-group">
        <label>Tipo de Serviço *</label>
        <select name="tipoServ" required>
          <option value="">Selecione...</option>
          <option value="Consulta Médica">Consulta Médica</option>
          <option value="Exame Físico">Exame Físico</option>
          <option value="Exame Diagnóstico">Exame Diagnóstico</option>
          <option value="Vacinação">Vacinação</option>
          <option value="Desparasitação">Desparasitação</option>
          <option value="Intervenção Cirúrgica">Intervenção Cirúrgica</option>
          <option value="Medicina Preventiva">Medicina Preventiva</option>
          <option value="Tratamento Terapêutico">Tratamento Terapêutico</option>
        </select>
      </div>
      
      <div class="form-group">
        <label>Custo (€)</label>
        <input type="number" name="custos" step="0.01" min="0">
      </div>
      
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">📅 Agendar</button>
        <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
      </div>
    </form>
  </div>
</div>

</body>
</html>
