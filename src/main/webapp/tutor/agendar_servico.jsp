<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Agendar Consulta</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  
  <style>
    .alerta-info {
      background: #EAF6FB;
      border: 2px solid #B8D4E6;
      border-radius: 16px;
      padding: 16px 20px;
      margin-bottom: 24px;
      display: flex;
      align-items: flex-start;
      gap: 12px;
      font-weight: 700;
      color: #0B2A42;
      line-height: 1.5;
    }
    
    .alerta-aviso {
      background: #FFF3CD;
      border: 2px solid #FFC107;
      border-radius: 16px;
      padding: 16px 20px;
      margin-bottom: 24px;
      display: flex;
      align-items: flex-start;
      gap: 12px;
      font-weight: 700;
      color: #856404;
      line-height: 1.5;
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
      <a href="menu.jsp">Tutor</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Agendar Consulta</h1>
    <p>Marque uma consulta veterinária para o seu animal</p>
  </div>
</section>

<%
String mensagem = "";
String tipoMensagem = "";
String nif = request.getParameter("nif");

// ✅ Se tentou agendar
if ("POST".equalsIgnoreCase(request.getMethod()) && nif != null) {
    String dataHoraStr = request.getParameter("dataHora");
    String tipoServ = request.getParameter("tipoServ");
    
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        Connection con = manipula.getLigacao();
        
        // ✅ VALIDAÇÃO 1: Verificar se já agendou antes (primeiraVez)
        PreparedStatement psCheck = con.prepareStatement(
            "SELECT COUNT(*) as total FROM agenda ag " +
            "JOIN agendamento a ON a.idAgendamento = ag.idAgendamento " +
            "WHERE ag.NIF = ?"
        );
        psCheck.setString(1, nif);
        ResultSet rsCheck = psCheck.executeQuery();
        
        boolean primeiraVez = true;
        if(rsCheck.next()) {
            int total = rsCheck.getInt("total");
            primeiraVez = (total == 0);
        }
        rsCheck.close();
        psCheck.close();
        
        // ✅ VALIDAÇÃO 2: Se é primeira vez, NÃO pode agendar
        if(primeiraVez) {
            mensagem = "❌ Primeira consulta deve ser agendada pela rececionista. Por favor, contacte a clínica.";
            tipoMensagem = "erro";
        } else {
            // ✅ VALIDAÇÃO 3: Verificar se tem pelo menos um animal
            PreparedStatement psAnimais = con.prepareStatement(
                "SELECT COUNT(*) as total FROM tutor WHERE NIF = ?"
            );
            psAnimais.setString(1, nif);
            ResultSet rsAnimais = psAnimais.executeQuery();
            
            int totalAnimais = 0;
            if(rsAnimais.next()) {
                totalAnimais = rsAnimais.getInt("total");
            }
            rsAnimais.close();
            psAnimais.close();
            
            if(totalAnimais == 0) {
                mensagem = "❌ Não tem animais registados. Por favor, contacte a rececionista para registar um animal.";
                tipoMensagem = "erro";
            } else {
                // ✅ PODE AGENDAR!
                con.setAutoCommit(false);
                
                java.sql.Timestamp dataHora = java.sql.Timestamp.valueOf(dataHoraStr.replace("T", " ") + ":00");
                
                String sqlAgendamento = 
                    "INSERT INTO agendamento (dataHrAgenda, tipoServ, statusAgendamento, custos, primeiraVez) " +
                    "VALUES (?, ?, 'marcado', NULL, FALSE)";
                
                PreparedStatement psAgend = con.prepareStatement(sqlAgendamento, Statement.RETURN_GENERATED_KEYS);
                psAgend.setTimestamp(1, dataHora);
                psAgend.setString(2, tipoServ);
                
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
                        mensagem = "✅ Consulta agendada com sucesso! ID: " + idAgendamento;
                        tipoMensagem = "sucesso";
                    }
                    rsKeys.close();
                } else {
                    con.rollback();
                    mensagem = "❌ Erro ao agendar consulta";
                    tipoMensagem = "erro";
                }
                psAgend.close();
            }
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
  
  <div class="alerta-info">
    ℹ️ <div>
      <strong>Atenção:</strong> Se for a sua primeira vez na clínica, por favor contacte a rececionista para fazer o agendamento inicial. Após a primeira consulta, poderá agendar diretamente pelo site.
    </div>
  </div>

  <!-- ✅ PASSO 1: Inserir NIF -->
  <% if (nif == null || nif.trim().isEmpty()) { %>
  
  <div class="formulario">
    <h3 style="margin: 0 0 20px 0; font-size: 20px; font-weight: 900; color: #0B2A42;">
      📋 Passo 1: Identificação
    </h3>
    <form method="GET">
      <div class="form-group">
        <label>Seu NIF *</label>
        <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9" required
               placeholder="Digite o seu NIF para continuar">
      </div>
      <button type="submit" class="btn btn-primary">➡️ Continuar</button>
    </form>
  </div>
  
  <% } else { 
      // ✅ PASSO 2: Verificar se pode agendar
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
          Connection con = manipula.getLigacao();
          
          // Verificar se é primeira vez
          PreparedStatement psCheck = con.prepareStatement(
              "SELECT COUNT(*) as total FROM agenda ag WHERE ag.NIF = ?"
          );
          psCheck.setString(1, nif);
          ResultSet rsCheck = psCheck.executeQuery();
          
          boolean primeiraVez = true;
          if(rsCheck.next()) {
              primeiraVez = (rsCheck.getInt("total") == 0);
          }
          rsCheck.close();
          psCheck.close();
          
          // Verificar animais
          PreparedStatement psAnimais = con.prepareStatement(
              "SELECT COUNT(*) as total FROM tutor WHERE NIF = ?"
          );
          psAnimais.setString(1, nif);
          ResultSet rsAnimais = psAnimais.executeQuery();
          
          int totalAnimais = 0;
          if(rsAnimais.next()) {
              totalAnimais = rsAnimais.getInt("total");
          }
          rsAnimais.close();
          psAnimais.close();
          
          if(primeiraVez) {
  %>
  
  <div class="alerta-aviso">
    ⚠️ <div>
      <strong>Primeira vez na clínica</strong><br>
      Como é a sua primeira consulta, por favor contacte a nossa rececionista para fazer o agendamento inicial.<br>
      <strong>Telefone:</strong> 210 123 456
    </div>
  </div>
  
  <div style="text-align: center; margin-top: 30px;">
    <a href="?nif=" class="btn btn-secondary">← Tentar outro NIF</a>
  </div>
  
  <% 
          } else if(totalAnimais == 0) {
  %>
  
  <div class="alerta-aviso">
    ⚠️ <div>
      <strong>Sem animais registados</strong><br>
      Não encontrámos animais registados com o seu NIF. Por favor, contacte a rececionista para registar o seu animal antes de agendar consultas.<br>
      <strong>Telefone:</strong> 210 123 456
    </div>
  </div>
  
  <div style="text-align: center; margin-top: 30px;">
    <a href="?nif=" class="btn btn-secondary">← Tentar outro NIF</a>
  </div>
  
  <% 
          } else {
              // ✅ PODE AGENDAR!
  %>
  
  <div class="alerta-info">
    ✅ <div>
      <strong>Bem-vindo de volta!</strong><br>
      NIF: <strong><%= nif %></strong> | Animais registados: <strong><%= totalAnimais %></strong><br>
      Preencha o formulário abaixo para agendar a sua consulta.
    </div>
  </div>

  <div class="formulario">
    <h3 style="margin: 0 0 20px 0; font-size: 20px; font-weight: 900; color: #0B2A42;">
      📅 Passo 2: Detalhes da Consulta
    </h3>
    <form method="POST">
      <input type="hidden" name="nif" value="<%= nif %>">
      
      <div class="form-group">
        <label>Data e Hora *</label>
        <input type="datetime-local" name="dataHora" required
               min="<%= java.time.LocalDateTime.now().toString().substring(0,16) %>">
        <small style="color: #57606F; font-weight: 600; margin-top: 6px; display: block;">
          💡 Escolha uma data futura
        </small>
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
      
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">📅 Confirmar Agendamento</button>
        <a href="?nif=" class="btn btn-secondary">← Voltar</a>
      </div>
    </form>
  </div>
  
  <% 
          }
      } catch(Exception e) {
  %>
      <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
  <%
          e.printStackTrace();
      } finally {
          manipula.desligar();
      }
  } 
  %>

</div>

</body>
</html>
