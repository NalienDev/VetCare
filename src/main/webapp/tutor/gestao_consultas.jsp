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
    
    .avaliacao-box {
      background: #F8FAFC;
      border: 2px solid #E7EEF4;
      border-radius: 12px;
      padding: 16px;
      margin-top: 12px;
    }
    
    .rating-option {
      display: inline-block;
      margin-right: 8px;
    }
    
    .rating-option input[type="radio"] {
      display: none;
    }
    
    .rating-option label {
      cursor: pointer;
      padding: 8px 16px;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 700;
      display: inline-block;
      opacity: 0.6;
      transition: all 0.2s;
    }
    
    .rating-option input[type="radio"]:checked + label {
      opacity: 1;
      transform: scale(1.05);
      box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }
    
    .rating-adorei { background: #28a745; color: white; }
    .rating-gostei { background: #ffc107; color: #000; }
    .rating-nao { background: #dc3545; color: white; }
    
    .badge-avaliado {
      background: #28a745;
      color: white;
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 11px;
      font-weight: 700;
      margin-left: 8px;
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
    <p>Reagendar, cancelar ou avaliar os seus agendamentos.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <%
  String mensagem = "";
  String tipoMensagem = "";

  String nif = request.getParameter("nif");
  String acao = request.getParameter("acao");

  if (nif != null && !nif.trim().isEmpty() && acao != null && "POST".equalsIgnoreCase(request.getMethod())) {

      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);

      try {
          Connection con = manipula.getLigacao();
          con.setAutoCommit(false);

          String idAgendamento = request.getParameter("idAgendamento");

          // ✅ AVALIAR - SIMPLIFICADO
          if ("avaliar".equals(acao)) {
              String classificacao = request.getParameter("classificacao");
              String opiniao = request.getParameter("opiniao");
              
              if (classificacao == null || classificacao.trim().isEmpty()) {
                  mensagem = "❌ Por favor, selecione uma classificação.";
                  tipoMensagem = "erro";
              } else {
                  // ✅ NOVA ABORDAGEM: Criar servicoVet genérico para o agendamento
                  // Obter próximo ID para servicoVet
                  String sqlMaxId = "SELECT COALESCE(MAX(idServico),0)+1 AS proximoId FROM servicoVet";
                  PreparedStatement psMaxId = con.prepareStatement(sqlMaxId);
                  ResultSet rsMaxId = psMaxId.executeQuery();
                  int idServico = 1;
                  if (rsMaxId.next()) {
                      idServico = rsMaxId.getInt("proximoId");
                  }
                  rsMaxId.close();
                  psMaxId.close();
                  
                  // Criar servicoVet
                  String sqlServico = "INSERT INTO servicoVet (idServico) VALUES (?)";
                  PreparedStatement psServico = con.prepareStatement(sqlServico);
                  psServico.setInt(1, idServico);
                  psServico.executeUpdate();
                  psServico.close();
                  
                  // Ligar ao agendamento via solicita
                  String sqlSolicita = "INSERT INTO solicita (idAgendamento, idServico) VALUES (?, ?)";
                  PreparedStatement psSolicita = con.prepareStatement(sqlSolicita);
                  psSolicita.setInt(1, Integer.parseInt(idAgendamento));
                  psSolicita.setInt(2, idServico);
                  psSolicita.executeUpdate();
                  psSolicita.close();
                  
                  // Verificar se já avaliou
                  String sqlCheck = "SELECT COUNT(*) as total FROM avalia WHERE NIF=? AND idServico=?";
                  PreparedStatement psCheck = con.prepareStatement(sqlCheck);
                  psCheck.setString(1, nif);
                  psCheck.setInt(2, idServico);
                  ResultSet rsCheck = psCheck.executeQuery();
                  
                  boolean jaAvaliou = false;
                  if (rsCheck.next()) {
                      jaAvaliou = rsCheck.getInt("total") > 0;
                  }
                  rsCheck.close();
                  psCheck.close();
                  
                  if (!jaAvaliou) {
                      // Inserir avaliação
                      String sqlAvalia = 
                          "INSERT INTO avalia (NIF, idServico, opiniao, classificacao, dataAv) " +
                          "VALUES (?, ?, ?, ?, CURDATE())";
                      
                      PreparedStatement psAvalia = con.prepareStatement(sqlAvalia);
                      psAvalia.setString(1, nif);
                      psAvalia.setInt(2, idServico);
                      psAvalia.setString(3, opiniao != null && !opiniao.trim().isEmpty() ? opiniao : "Sem comentário");
                      psAvalia.setString(4, classificacao);
                      
                      psAvalia.executeUpdate();
                      psAvalia.close();
                      
                      con.commit();
                      mensagem = "✅ Avaliação registada com sucesso! Obrigado pelo seu feedback.";
                      tipoMensagem = "sucesso";
                  } else {
                      mensagem = "❌ Já avaliou este serviço anteriormente.";
                      tipoMensagem = "erro";
                  }
              }
          }
          else {
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
                  mensagem = "❌ Não é possível alterar consultas realizadas ou canceladas.";
                  tipoMensagem = "erro";
              } else {

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
                          con.commit();
                          mensagem = "✅ Agendamento cancelado com sucesso!";
                          tipoMensagem = "sucesso";
                      } else {
                          mensagem = "❌ Não foi possível cancelar.";
                          tipoMensagem = "erro";
                      }
                      ps.close();
                  }

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
                              
                              con.commit();
                              mensagem = "✅ Agendamento reagendado com sucesso!";
                              tipoMensagem = "sucesso";

                          } catch (Exception ex) {
                              con.rollback();
                              mensagem = "❌ Data inválida.";
                              tipoMensagem = "erro";
                          }

                      } else {
                          mensagem = "❌ Escolha a nova data/hora.";
                          tipoMensagem = "erro";
                      }
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
  if (nif != null && !nif.trim().isEmpty()) {

      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);

      try {
          Connection con = manipula.getLigacao();

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
          
          String badgeClass = "badge-primary";
          if ("cancelado".equalsIgnoreCase(status)) {
              badgeClass = "badge-danger";
          } else if ("realizado".equalsIgnoreCase(status)) {
              badgeClass = "badge-success";
          } else if ("confirmado".equalsIgnoreCase(status)) {
              badgeClass = "badge-info";
          }
          
          boolean podeAlterar = "marcado".equalsIgnoreCase(status);
          boolean podeAvaliar = "realizado".equalsIgnoreCase(status);
          
          // ✅ Verificar se já avaliou (via solicita)
          boolean jaAvaliou = false;
          if (podeAvaliar) {
              String sqlCheckAval = 
                  "SELECT COUNT(*) as total FROM avalia av " +
                  "JOIN solicita sol ON sol.idServico = av.idServico " +
                  "WHERE sol.idAgendamento = ? AND av.NIF = ?";
              
              PreparedStatement psCheck = con.prepareStatement(sqlCheckAval);
              psCheck.setInt(1, idAg);
              psCheck.setString(2, nif);
              ResultSet rsCheck = psCheck.executeQuery();
              
              if (rsCheck.next()) {
                  jaAvaliou = rsCheck.getInt("total") > 0;
              }
              rsCheck.close();
              psCheck.close();
          }
  %>
        <tr>
          <td><strong><%= idAg %></strong></td>
          <td><%= sdf.format(dataHr) %></td>
          <td><%= tipoServ != null ? tipoServ : "-" %></td>
          <td>
            <span class="badge <%= badgeClass %>"><%= status %></span>
            <% if (jaAvaliou) { %>
              <span class="badge-avaliado">⭐ Avaliado</span>
            <% } %>
          </td>
          <td>
            <% if (podeAlterar) { %>
            
            <form method="POST" class="reagendar-box" style="margin-bottom:10px;">
              <input type="hidden" name="nif" value="<%= nif %>">
              <input type="hidden" name="idAgendamento" value="<%= idAg %>">
              <input type="hidden" name="acao" value="reagendar">
              <input type="datetime-local" name="novaData" required>
              <button type="submit" class="btn btn-primary">🕒 Reagendar</button>
            </form>

            <form method="POST" style="display:inline;">
              <input type="hidden" name="nif" value="<%= nif %>">
              <input type="hidden" name="idAgendamento" value="<%= idAg %>">
              <input type="hidden" name="acao" value="cancelar">
              <button type="submit" class="btn btn-danger"
                      onclick="return confirm('Tem a certeza que deseja cancelar?')">
                ❌ Cancelar
              </button>
            </form>
            
            <% } else if (podeAvaliar && !jaAvaliou) { %>
            
            <div class="avaliacao-box">
              <h4 style="margin: 0 0 8px 0; color: #0B2A42; font-size: 14px;">⭐ Avaliar Serviço</h4>
              <form method="POST">
                <input type="hidden" name="nif" value="<%= nif %>">
                <input type="hidden" name="idAgendamento" value="<%= idAg %>">
                <input type="hidden" name="acao" value="avaliar">
                
                <div class="form-group" style="margin-bottom: 12px;">
                  <label style="font-size: 13px; font-weight: 700;">Classificação *</label>
                  <div style="margin-top: 8px;">
                    <div class="rating-option">
                      <input type="radio" name="classificacao" value="adorei" id="adorei_<%= idAg %>" required>
                      <label for="adorei_<%= idAg %>" class="rating-adorei">😍 Adorei</label>
                    </div>
                    <div class="rating-option">
                      <input type="radio" name="classificacao" value="gostei" id="gostei_<%= idAg %>" required>
                      <label for="gostei_<%= idAg %>" class="rating-gostei">🙂 Gostei</label>
                    </div>
                    <div class="rating-option">
                      <input type="radio" name="classificacao" value="não vou voltar" id="nao_<%= idAg %>" required>
                      <label for="nao_<%= idAg %>" class="rating-nao">😞 Não vou voltar</label>
                    </div>
                  </div>
                </div>
                
                <div class="form-group" style="margin-bottom: 12px;">
                  <label style="font-size: 13px; font-weight: 700;">Comentário (opcional)</label>
                  <textarea name="opiniao" rows="2" 
                            style="width: 100%; padding: 8px; border: 1px solid #DDE6EE; border-radius: 8px; font-size: 13px;"
                            maxlength="255"
                            placeholder="Deixe o seu comentário..."></textarea>
                </div>
                
                <button type="submit" class="btn btn-primary" style="font-size: 13px;">
                  ⭐ Enviar Avaliação
                </button>
              </form>
            </div>
            
            <% } else { %>
            
            <span style="color:#57606F; font-weight:700; font-size:13px;">
              <% if (jaAvaliou) { %>
                ✅ Já avaliado
              <% } else { %>
                🔒 Não é possível alterar
              <% } %>
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
              ℹ️ Como é a sua primeira vez na clínica, contacte a rececionista.<br>
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
