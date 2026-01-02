<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Agendar Serviço</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  
  <style>
    .alerta-aviso {
      background: #FFF3CD;
      border: 2px solid #FFC107;
      border-radius: 16px;
      padding: 16px 20px;
      margin-bottom: 20px;
      font-weight: 700;
      color: #856404;
    }
  </style>
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
      <a href="menu.jsp">Rececionista</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Agendar Serviço</h1>
    <p>Marcar serviços veterinários para clientes (primeira vez ou retorno).</p>
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
    String primeiraVezStr = request.getParameter("primeiraVez");
    
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        Connection con = manipula.getLigacao();
        
        boolean primeiraVez = "sim".equals(primeiraVezStr);
        
        // ✅ Se marcar "primeira vez", verifica se cliente tem animais
        if(primeiraVez) {
            PreparedStatement psCheck = con.prepareStatement(
                "SELECT COUNT(*) as total FROM tutor WHERE NIF = ?"
            );
            psCheck.setString(1, nif);
            ResultSet rsCheck = psCheck.executeQuery();
            
            int totalAnimais = 0;
            if(rsCheck.next()) {
                totalAnimais = rsCheck.getInt("total");
            }
            rsCheck.close();
            psCheck.close();
            
            if(totalAnimais == 0) {
                mensagem = "⚠️ Este cliente não tem animais registados. Por favor, registe um animal antes de agendar a primeira consulta.";
                tipoMensagem = "erro";
            } else {
                // Tem animais, pode agendar
                con.setAutoCommit(false);
                
                java.sql.Timestamp dataHora = java.sql.Timestamp.valueOf(dataHoraStr.replace("T", " ") + ":00");
                java.math.BigDecimal custos = custosStr != null && !custosStr.isEmpty() ? new java.math.BigDecimal(custosStr) : null;
                
                String sqlAgendamento = 
                    "INSERT INTO agendamento (dataHrAgenda, tipoServ, statusAgendamento, custos, primeiraVez) " +
                    "VALUES (?, ?, 'marcado', ?, ?)";
                
                PreparedStatement psAgend = con.prepareStatement(sqlAgendamento, Statement.RETURN_GENERATED_KEYS);
                psAgend.setTimestamp(1, dataHora);
                psAgend.setString(2, tipoServ);
                psAgend.setBigDecimal(3, custos);
                psAgend.setBoolean(4, primeiraVez);
                
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
                        mensagem = "✅ Serviço agendado com sucesso! ID: " + idAgendamento;
                        tipoMensagem = "sucesso";
                    }
                    rsKeys.close();
                } else {
                    con.rollback();
                    mensagem = "❌ Erro ao agendar serviço";
                    tipoMensagem = "erro";
                }
                psAgend.close();
            }
        } else {
            // Não é primeira vez, pode agendar sem validação de animais
            con.setAutoCommit(false);
            
            java.sql.Timestamp dataHora = java.sql.Timestamp.valueOf(dataHoraStr.replace("T", " ") + ":00");
            java.math.BigDecimal custos = custosStr != null && !custosStr.isEmpty() ? new java.math.BigDecimal(custosStr) : null;
            
            String sqlAgendamento = 
                "INSERT INTO agendamento (dataHrAgenda, tipoServ, statusAgendamento, custos, primeiraVez) " +
                "VALUES (?, ?, 'marcado', ?, ?)";
            
            PreparedStatement psAgend = con.prepareStatement(sqlAgendamento, Statement.RETURN_GENERATED_KEYS);
            psAgend.setTimestamp(1, dataHora);
            psAgend.setString(2, tipoServ);
            psAgend.setBigDecimal(3, custos);
            psAgend.setBoolean(4, primeiraVez);
            
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
                    mensagem = "✅ Serviço agendado com sucesso! ID: " + idAgendamento;
                    tipoMensagem = "sucesso";
                }
                rsKeys.close();
            } else {
                con.rollback();
                mensagem = "❌ Erro ao agendar serviço";
                tipoMensagem = "erro";
            }
            psAgend.close();
        }
        
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
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <% if (!mensagem.isEmpty()) { %>
      <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>
  
  <div class="alerta-aviso">
    ⚠️ <strong>Atenção:</strong> Se marcar "Primeira Vez", certifique-se de que o cliente já tem pelo menos um animal registado na base de dados.
  </div>

  <div class="formulario">
    <form method="POST">
      <div class="form-group">
        <label>NIF do Cliente *</label>
        <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9" required
               placeholder="Digite o NIF do cliente">
      </div>
      
      <div class="form-group">
        <label>Data e Hora *</label>
        <input type="datetime-local" name="dataHora" required>
      </div>
      
      <div class="form-group">
        <label>Tipo de Serviço *</label>
        <select name="tipoServ" required>
          <option value="">Selecione...</option>
          <option value="consulta">Consulta Médica</option>
          <option value="exame">Exame Físico/Diagnóstico</option>
          <option value="vacinação">Vacinação</option>
          <option value="desparasitação">Desparasitação</option>
          <option value="cirurgia">Intervenção Cirúrgica</option>
          <option value="preventiva">Medicina Preventiva</option>
          <option value="terapeutico">Tratamento Terapêutico</option>
        </select>
      </div>
      
      <div class="form-group">
        <label>Custo (€)</label>
        <input type="number" name="custos" step="0.01" min="0"
               placeholder="Deixe vazio se não souber">
      </div>
      
      <div class="form-group">
        <label>Primeira Vez? *</label>
        <select name="primeiraVez" required>
          <option value="nao" selected>Não (cliente já veio antes)</option>
          <option value="sim">Sim (primeira consulta do cliente)</option>
        </select>
        <small style="color: #57606F; font-weight: 600; margin-top: 6px; display: block;">
            Se for "Sim", o cliente deve ter pelo menos um animal registado
        </small>
      </div>
      
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">📅 Agendar Serviço</button>
        <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
      </div>
    </form>
  </div>
</div>

</body>
</html>
