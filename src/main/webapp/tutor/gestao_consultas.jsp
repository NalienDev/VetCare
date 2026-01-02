<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Gestão de Consultas</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">

  <style>
    .reagendar-box{
      display:flex;
      align-items:center;
      gap:8px;
      flex-wrap:wrap;
    }
    .reagendar-box input[type="datetime-local"]{
      padding:10px;
      border-radius:10px;
      border:1px solid #DDE6EE;
      font-weight:700;
      background:#F8FAFC;
      max-width:220px;
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
    <h1>Gestão de Consultas e Agendamentos</h1>
    <p>Reagendar ou cancelar os seus agendamentos.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <%
  String mensagem = "";
  String tipoMensagem = "";

  String nif = request.getParameter("nif");
  String acao = request.getParameter("acao");

  // =====================================================
  // Só faz ações se já existir nif e ação
  // =====================================================
  if (nif != null && !nif.trim().isEmpty() && acao != null && "POST".equalsIgnoreCase(request.getMethod())) {

      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);

      try {
          Connection con = manipula.getLigacao();

          String idAgendamento = request.getParameter("idAgendamento");

          // ✅ Verificar se pode alterar (só se status for "marcado")
          PreparedStatement psCheck = con.prepareStatement(
              "SELECT a.statusAgendamento FROM agendamento a " +
              "JOIN agenda ag ON ag.idAgendamento = a.idAgendamento " +
              "WHERE a.idAgendamento=? AND ag.NIF=?"
          );
          psCheck.setInt(1, Integer.parseInt(idAgendamento));
          psCheck.setString(2, nif);
          ResultSet rsCheck = psCheck.executeQuery();
          
          boolean podeAlterar = false;
          if(rsCheck.next()) {
              String statusAtual = rsCheck.getString("statusAgendamento");
              podeAlterar = "marcado".equalsIgnoreCase(statusAtual);
          }
          rsCheck.close();
          psCheck.close();
          
          if(!podeAlterar) {
              mensagem = "❌ Não é possível alterar consultas concluídas ou canceladas.";
              tipoMensagem = "erro";
          } else {

              // CANCELAR
              if ("cancelar".equals(acao)) {
                  PreparedStatement ps = con.prepareStatement(
                      "UPDATE agendamento a " +
                      "JOIN agenda ag ON ag.idAgendamento = a.idAgendamento " +
                      "SET a.statusAgendamento='cancelado' " +
                      "WHERE a.idAgendamento=? AND ag.NIF=?"
                  );
                  ps.setInt(1, Integer.parseInt(idAgendamento));
                  ps.setString(2, nif);

                  if(ps.executeUpdate() > 0){
                      mensagem = "✅ Agendamento cancelado com sucesso!";
                      tipoMensagem = "sucesso";
                  } else {
                      mensagem = "❌ Não foi possível cancelar (verifique se pertence ao seu NIF).";
                      tipoMensagem = "erro";
                  }
                  ps.close();
              }

              // REAGENDAR
              if ("reagendar".equals(acao)) {
                  String novaData = request.getParameter("novaData");
                  if (novaData != null && !novaData.trim().isEmpty()) {

                      try {
                          novaData = novaData.replace("T", " ") + ":00";

                          PreparedStatement ps = con.prepareStatement(
                              "UPDATE agendamento a " +
                              "JOIN agenda ag ON ag.idAgendamento = a.idAgendamento " +
                              "SET a.dataHrAgenda=?, a.statusAgendamento='marcado' " +
                              "WHERE a.idAgendamento=? AND ag.NIF=?"
                          );
                          ps.setTimestamp(1, java.sql.Timestamp.valueOf(novaData));
                          ps.setInt(2, Integer.parseInt(idAgendamento));
                          ps.setString(3, nif);

                          ps.executeUpdate();
                          ps.close();

                          mensagem = "✅ Agendamento reagendado com sucesso!";
                          tipoMensagem = "sucesso";

                      } catch (Exception ex) {
                          mensagem = "❌ Data inválida ou já existe agendamento nesse horário.";
                          tipoMensagem = "erro";
                      }

                  } else {
                      mensagem = "❌ Escolha a nova data/hora.";
                      tipoMensagem = "erro";
                  }
              }
          }

      } catch(Exception e) {
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

  <!-- ✅ FORM NIF PRIMEIRO -->
  <div class="formulario">
    <form method="GET">
      <div class="form-group">
        <label>Seu NIF</label>
        <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9"
               value="<%= nif != null ? nif : "" %>"
               placeholder="Digite seu NIF" required>
      </div>
      <button type="submit" class="btn btn-primary">🔍 Consultar</button>
    </form>
  </div>

  <%
  // =====================================================
  // Só mostra consultas depois do NIF
  // =====================================================
  if (nif != null && !nif.trim().isEmpty()) {

      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);

      try {
          Connection con = manipula.getLigacao();

          // ✅ CORRIGIDO: Busca TODOS os agendamentos, não só "consulta"
          String sql =
              "SELECT a.idAgendamento, a.dataHrAgenda, a.statusAgendamento, a.tipoServ " +
              "FROM agendamento a " +
              "JOIN agenda ag ON ag.idAgendamento = a.idAgendamento " +
              "WHERE ag.NIF=? " +
              "ORDER BY a.dataHrAgenda DESC";

          PreparedStatement ps = con.prepareStatement(sql);
          ps.setString(1, nif);
          ResultSet rs = ps.executeQuery();

          SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
          boolean temDados = false;
  %>

  <div class="table-card" style="margin-top:25px;">
    <%
      // Verificar se tem agendamentos para decidir se mostra botão de agendar
      // Se tem agendamentos = não é primeira vez = pode agendar online
      // Se não tem agendamentos = é primeira vez = deve contactar rececionista
    %>
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
      <h3 style="margin: 0;">📋 Meus Agendamentos</h3>
    </div>
    <table class="tabela">
      <thead>
        <tr>
          <th>ID</th>
          <th>Data/Hora</th>
          <th>Tipo de Serviço</th>
          <th>Status</th>
          <th>Ações</th>
        </tr>
      </thead>
      <tbody>

  <%
      while(rs.next()){
          temDados = true;
          int idAg = rs.getInt("idAgendamento");
          Timestamp dataHr = rs.getTimestamp("dataHrAgenda");
          String status = rs.getString("statusAgendamento");
          String tipoServ = rs.getString("tipoServ");
          
          // ✅ Determinar cor do badge
          String badgeClass = "badge-success";
          if ("cancelado".equalsIgnoreCase(status)) {
              badgeClass = "badge-danger";
          } else if ("concluído".equalsIgnoreCase(status) || "concluido".equalsIgnoreCase(status)) {
              badgeClass = "badge-success";
          }
          
          // ✅ Só permite reagendar/cancelar se status for "marcado"
          boolean podeAlterar = "marcado".equalsIgnoreCase(status);
  %>
        <tr>
          <td><strong><%= idAg %></strong></td>
          <td><%= sdf.format(dataHr) %></td>
          <td><%= tipoServ != null ? tipoServ : "-" %></td>
          <td>
            <span class="badge <%= badgeClass %>"><%= status %></span>
          </td>
          <td>
            <% if (podeAlterar) { %>
            
            <!-- ✅ REAGENDAR -->
            <form method="POST" class="reagendar-box" style="margin-bottom:10px;">
              <input type="hidden" name="nif" value="<%= nif %>">
              <input type="hidden" name="idAgendamento" value="<%= idAg %>">
              <input type="hidden" name="acao" value="reagendar">
              <input type="datetime-local" name="novaData" required>
              <button type="submit" class="btn btn-primary">🕒 Reagendar</button>
            </form>

            <!-- ✅ CANCELAR -->
            <form method="POST" style="display:inline;">
              <input type="hidden" name="nif" value="<%= nif %>">
              <input type="hidden" name="idAgendamento" value="<%= idAg %>">
              <input type="hidden" name="acao" value="cancelar">
              <button type="submit" class="btn btn-danger"
                      onclick="return confirm('Tem a certeza que deseja cancelar este agendamento?')">
                ❌ Cancelar
              </button>
            </form>
            
            <% } else { %>
            
            <span style="color:#57606F; font-weight:700; font-size:13px;">
              🔒 Não é possível alterar
            </span>
            
            <% } %>
          </td>
        </tr>
  <%
      }

      if(!temDados){
  %>
        <tr>
          <td colspan="5" style="text-align:center; padding:2rem;">
            <div style="color:#57606F; font-weight:700; margin-bottom: 16px;">
              📭 Não existem agendamentos para este NIF
            </div>
            <div style="background: #FFF3CD; border: 2px solid #FFC107; border-radius: 12px; padding: 16px; max-width: 500px; margin: 0 auto; font-weight: 700; color: #856404;">
              ℹ️ Como é a sua primeira vez na clínica, por favor contacte a rececionista para fazer o agendamento inicial.<br>
              <strong style="display: block; margin-top: 8px;">📞 Telefone: 210 123 456</strong>
            </div>
          </td>
        </tr>
  <%
      }

      rs.close();
      ps.close();
  %>
      </tbody>
    </table>
    
    <% if(temDados) { %>
    <!-- ✅ Só mostra botão se JÁ tem agendamentos (não é primeira vez) -->
    <div style="margin-top: 20px; text-align: center;">
      <a href="agendar_servico.jsp?nif=<%= nif %>" class="btn btn-primary">
        ➕ Agendar Nova Consulta
      </a>
    </div>
    <% } %>
  </div>

  <%
      } catch(Exception e){
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
