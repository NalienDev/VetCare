<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt" style="height: 100%;">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Gestão de Horários - VetCare</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  <style>
    html, body {
      height: 100%;
      margin: 0;
      padding: 0;
    }
    body {
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    .page-content {
      flex: 1;
    }
    .btn-sm {
      padding: 8px 16px;
      font-size: 14px;
    }
    .vet-badge {
      background: #28a745;
      color: white;
      padding: 2px 8px;
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
      <a href="menu.jsp">Gerente</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>🕐 Gestão de Horários</h1>
    <p>Horários de funcionamento e atribuição de veterinários.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <div style="margin-bottom: 20px;">
    <a href="criar_horario.jsp" class="btn btn-primary">➕ Novo Horário</a>
  </div>

  <table class="tabela">
    <thead>
      <tr>
        <th>Localidade</th>
        <th>Dia da Semana</th>
        <th>Hora Início</th>
        <th>Hora Fim</th>
        <th>Veterinários</th>
        <th>Ações</th>
      </tr>
    </thead>
    <tbody>
      <%
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
        Connection con = manipula.getLigacao();
        
        String sql = 
            "SELECT h.localidade, h.diaUtil, h.horaInicio, h.horaFim, " +
            "COUNT(e.nLicenca) as numVets " +
            "FROM horario h " +
            "LEFT JOIN escalado e ON e.localidade = h.localidade AND e.diaUtil = h.diaUtil " +
            "GROUP BY h.localidade, h.diaUtil, h.horaInicio, h.horaFim " +
            "ORDER BY h.localidade, FIELD(h.diaUtil, 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta')";
        
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        
        boolean temDados = false;
        
        while (rs.next()) {
          temDados = true;
          String localidade = rs.getString("localidade");
          String diaUtil = rs.getString("diaUtil");
          int numVets = rs.getInt("numVets");
      %>
          <tr>
            <td><strong><%= localidade %></strong></td>
            <td><%= diaUtil %>-feira</td>
            <td><%= rs.getTime("horaInicio").toString().substring(0, 5) %></td>
            <td><%= rs.getTime("horaFim").toString().substring(0, 5) %></td>
            <td>
              <% if (numVets > 0) { %>
                <span class="vet-badge"><%= numVets %> vet<%= numVets > 1 ? "s" : "" %></span>
              <% } else { %>
                <span style="color: #999;">Nenhum</span>
              <% } %>
            </td>
            <td>
              <a href="atribuir_veterinario_horario.jsp?localidade=<%= java.net.URLEncoder.encode(localidade, "UTF-8") %>&diaUtil=<%= java.net.URLEncoder.encode(diaUtil, "UTF-8") %>" 
                 class="btn btn-primary btn-sm" style="margin-right: 5px;">
                👨‍⚕️ Veterinários
              </a>
              <a href="editar_horario.jsp?localidade=<%= java.net.URLEncoder.encode(localidade, "UTF-8") %>&diaUtil=<%= java.net.URLEncoder.encode(diaUtil, "UTF-8") %>" 
                 class="btn btn-primary btn-sm">
                ✏️ Editar
              </a>
            </td>
          </tr>
      <%
        }
        
        if (!temDados) {
      %>
          <tr>
            <td colspan="6" style="text-align: center; padding: 2rem; color: #999;">
              🔭 Nenhum horário cadastrado
            </td>
          </tr>
      <%
        }
        
        rs.close();
        ps.close();
        
      } catch (Exception e) {
      %>
        <tr>
          <td colspan="6" style="text-align: center; padding: 2rem; color: #DC3545;">
            ❌ Erro ao carregar dados: <%= e.getMessage() %>
          </td>
        </tr>
      <%
        e.printStackTrace();
      } finally {
        manipula.desligar();
      }
      %>
    </tbody>
  </table>
</div>

</body>
</html>
