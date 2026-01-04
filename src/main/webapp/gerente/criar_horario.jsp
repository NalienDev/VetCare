<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Criar Horário</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  <style>
    .info-box {
      background: #E8F4F8;
      border-left: 4px solid #4A90E2;
      padding: 15px;
      margin: 20px 0;
      border-radius: 8px;
    }
    .info-box h3 {
      margin: 0 0 10px 0;
      color: #0B2A42;
      font-size: 16px;
    }
    .info-box p {
      margin: 5px 0;
      color: #555;
      font-size: 14px;
    }
    .time-inputs {
      display: flex;
      gap: 15px;
      align-items: center;
    }
    .time-inputs .form-group {
      flex: 1;
      margin: 0;
    }
    .horario-preview {
      background: #F8FAFC;
      border: 2px solid #E7EEF4;
      border-radius: 12px;
      padding: 15px;
      margin-top: 15px;
    }
    .horario-preview h4 {
      margin: 0 0 10px 0;
      color: #0B2A42;
      font-size: 14px;
      font-weight: 700;
    }
    .horario-item {
      padding: 8px 12px;
      background: white;
      border-radius: 8px;
      margin-bottom: 8px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 1px 3px rgba(0,0,0,0.05);
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
      <a href="menu.jsp">Gerente</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Criar Horário</h1>
    <p>Definir horário de funcionamento para uma clínica.</p>
  </div>
</section>

<div class="page-content">
  <a href="gestao_horarios.jsp" class="btn-voltar">← Voltar</a>

  <%
    String mensagem = "";
    String tipoMensagem = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
      String localidade = request.getParameter("localidade");
      String diaUtil = request.getParameter("diaUtil");
      String horaInicio = request.getParameter("horaInicio");
      String horaFim = request.getParameter("horaFim");

      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);

      try {
        Connection con = manipula.getLigacao();
        con.setAutoCommit(false);

        // Verificar se a localidade existe
        String sqlVerifLoc = "SELECT localidade FROM clinica WHERE localidade = ?";
        PreparedStatement psVerifLoc = con.prepareStatement(sqlVerifLoc);
        psVerifLoc.setString(1, localidade);
        ResultSet rsVerifLoc = psVerifLoc.executeQuery();
        
        if (!rsVerifLoc.next()) {
          mensagem = "❌ A localidade '" + localidade + "' não existe na base de dados. Crie a clínica primeiro.";
          tipoMensagem = "erro";
          rsVerifLoc.close();
          psVerifLoc.close();
          con.rollback();
        } else {
          rsVerifLoc.close();
          psVerifLoc.close();

          // Verificar se já existe horário para esta localidade e dia
          String sqlVerif = "SELECT diaUtil FROM horario WHERE localidade = ? AND diaUtil = ?";
          PreparedStatement psVerif = con.prepareStatement(sqlVerif);
          psVerif.setString(1, localidade);
          psVerif.setString(2, diaUtil);
          ResultSet rsVerif = psVerif.executeQuery();
          
          if (rsVerif.next()) {
            mensagem = "❌ Já existe um horário para " + localidade + " na " + diaUtil + ". Use a opção de editar.";
            tipoMensagem = "erro";
            rsVerif.close();
            psVerif.close();
            con.rollback();
          } else {
            rsVerif.close();
            psVerif.close();

            // Validar horários
            java.sql.Time inicio = java.sql.Time.valueOf(horaInicio + ":00");
            java.sql.Time fim = java.sql.Time.valueOf(horaFim + ":00");

            if (inicio.compareTo(fim) >= 0) {
              mensagem = "❌ A hora de início deve ser anterior à hora de fim.";
              tipoMensagem = "erro";
              con.rollback();
            } else {
              // Inserir horário
              String sqlHorario = "INSERT INTO horario (diaUtil, horaInicio, horaFim, localidade) VALUES (?, ?, ?, ?)";
              PreparedStatement psHorario = con.prepareStatement(sqlHorario);
              psHorario.setString(1, diaUtil);
              psHorario.setTime(2, inicio);
              psHorario.setTime(3, fim);
              psHorario.setString(4, localidade);
              
              int linhas = psHorario.executeUpdate();
              psHorario.close();

              if (linhas > 0) {
                con.commit();
                mensagem = "✅ Horário criado com sucesso para " + localidade + " - " + diaUtil + "!";
                tipoMensagem = "sucesso";
              } else {
                con.rollback();
                mensagem = "❌ Erro ao criar horário";
                tipoMensagem = "erro";
              }
            }
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

  <% if (!mensagem.isEmpty()) { %>
    <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <div class="info-box">
    <h3>ℹ️ Informação sobre Horários</h3>
    <p>Cada clínica pode ter <strong>um horário diferente por dia da semana</strong>.</p>
    <p>Os horários são definidos apenas para dias úteis (Segunda a Sexta-feira).</p>
    <p><strong>Importante:</strong> A localidade (clínica) deve existir na base de dados antes de criar horários.</p>
  </div>

  <form method="POST" class="formulario">
    <div class="form-group">
      <label>Localidade (Clínica) *</label>
      <input 
        type="text" 
        name="localidade" 
        list="localidadesList"
        maxlength="60" 
        placeholder="Ex: Lisboa, Porto, Coimbra..."
        required>
      <datalist id="localidadesList">
        <%
          Configura cfg2 = new Configura();
          Manipula manipula2 = new Manipula(cfg2);
          try {
            Connection con2 = manipula2.getLigacao();
            String sqlLoc = "SELECT DISTINCT localidade FROM clinica ORDER BY localidade";
            PreparedStatement psLoc = con2.prepareStatement(sqlLoc);
            ResultSet rsLoc = psLoc.executeQuery();
            
            while (rsLoc.next()) {
        %>
              <option value="<%= rsLoc.getString("localidade") %>">
        <%
            }
            rsLoc.close();
            psLoc.close();
          } catch (Exception e) {
          } finally {
            manipula2.desligar();
          }
        %>
      </datalist>
      <small style="color: #666; font-size: 12px; display: block; margin-top: 5px;">
        Digite ou selecione uma localidade existente
      </small>
    </div>

    <div class="form-group">
      <label>Dia Útil *</label>
      <select name="diaUtil" required>
        <option value="">Selecione...</option>
        <option value="Segunda">🗓️ Segunda-feira</option>
        <option value="Terça">🗓️ Terça-feira</option>
        <option value="Quarta">🗓️ Quarta-feira</option>
        <option value="Quinta">🗓️ Quinta-feira</option>
        <option value="Sexta">🗓️ Sexta-feira</option>
      </select>
    </div>

    <div class="time-inputs">
      <div class="form-group">
        <label>Hora de Início *</label>
        <input 
          type="time" 
          name="horaInicio" 
          value="09:00"
          required>
      </div>

      <div class="form-group">
        <label>Hora de Fim *</label>
        <input 
          type="time" 
          name="horaFim" 
          value="18:00"
          required>
      </div>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">💾 Guardar</button>
      <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
    </div>
  </form>

  <div class="horario-preview">
    <h4>📅 Horários Registados</h4>
    <%
      Configura cfg3 = new Configura();
      Manipula manipula3 = new Manipula(cfg3);
      try {
        Connection con3 = manipula3.getLigacao();
        String sqlHorarios = "SELECT localidade, diaUtil, horaInicio, horaFim FROM horario ORDER BY localidade, FIELD(diaUtil, 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta')";
        PreparedStatement psHorarios = con3.prepareStatement(sqlHorarios);
        ResultSet rsHorarios = psHorarios.executeQuery();
        
        String localidadeAtual = "";
        boolean temHorarios = false;
        
        while (rsHorarios.next()) {
          temHorarios = true;
          String loc = rsHorarios.getString("localidade");
          
          if (!loc.equals(localidadeAtual)) {
            if (!localidadeAtual.isEmpty()) {
              out.println("</div>");
            }
            localidadeAtual = loc;
            out.println("<div style='margin-bottom: 15px;'>");
            out.println("<strong style='color: #0B2A42; font-size: 15px;'>📍 " + loc + "</strong>");
          }
          
          String dia = rsHorarios.getString("diaUtil");
          String inicio = rsHorarios.getTime("horaInicio").toString().substring(0, 5);
          String fim = rsHorarios.getTime("horaFim").toString().substring(0, 5);
    %>
          <div class="horario-item">
            <span style="font-weight: 600; color: #0B2A42;"><%= dia %>-feira</span>
            <span style="color: #4A90E2; font-weight: 700;"><%= inicio %> - <%= fim %></span>
          </div>
    <%
        }
        
        if (temHorarios) {
          out.println("</div>");
        } else {
    %>
          <p style="color: #999; font-style: italic;">Nenhum horário registado ainda.</p>
    <%
        }
        
        rsHorarios.close();
        psHorarios.close();
      } catch (Exception e) {
    %>
        <p style="color: #DC143C;">Erro ao carregar horários: <%= e.getMessage() %></p>
    <%
      } finally {
        manipula3.desligar();
      }
    %>
  </div>
</div>

</body>
</html>