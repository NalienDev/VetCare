<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt" style="height: 100%;">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Animais Idosos </title>
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
    .info-box ul {
      margin: 0.5rem 0 0 1.5rem;
    }
    .info-box li {
      margin: 0.5rem 0;
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
    <h1>👴 Animais Idosos</h1>
    <p>Animais que atingiram ou ultrapassaram 75% da expectativa de vida.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <table class="tabela">
    <thead>
      <tr>
        <th>ID</th>
        <th>Nome</th>
        <th>Raça</th>
        <th>Idade (anos)</th>
        <th>Expectativa (anos)</th>
        <th>% Vida</th>
        <th>Tutor</th>
      </tr>
    </thead>
    <tbody>
      <%
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
        String sql = 
          "SELECT f.idFichaClin, f.nome, f.dataNasc, " +
          "       r.nomeRaca, r.expectativaVida, " +
          "       c.nomeCompleto AS tutor, " +
          "       TIMESTAMPDIFF(YEAR, f.dataNasc, CURDATE()) AS idade, " +
          "       ROUND((TIMESTAMPDIFF(YEAR, f.dataNasc, CURDATE()) / r.expectativaVida) * 100, 1) AS percentVida " +
          "FROM fichaClinicaAnimal f " +
          "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
          "LEFT JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
          "LEFT JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
          "LEFT JOIN cliente c ON t.NIF = c.NIF " +
          "WHERE r.expectativaVida IS NOT NULL " +
          "HAVING percentVida >= 75 " +
          "ORDER BY percentVida DESC";
        
        Connection con = manipula.getLigacao();
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        
        boolean temDados = false;
        
        while (rs.next()) {
          temDados = true;
          double percentVida = rs.getDouble("percentVida");
          String corAlerta = percentVida >= 90 ? "#DC3545" : percentVida >= 80 ? "#FFA500" : "#666";
      %>
          <tr>
            <td><%= rs.getInt("idFichaClin") %></td>
            <td><%= rs.getString("nome") %></td>
            <td><%= rs.getString("nomeRaca") %></td>
            <td><%= rs.getInt("idade") %></td>
            <td><%= rs.getInt("expectativaVida") %></td>
            <td style="color: <%= corAlerta %>; font-weight: bold;">
              <%= String.format("%.1f", percentVida) %>%
            </td>
            <td><%= rs.getString("tutor") %></td>
          </tr>
      <%
        }
        
        if (!temDados) {
      %>
          <tr>
            <td colspan="7" style="text-align: center; padding: 2rem; color: #999;">
              🔭 Nenhum animal idoso encontrado
            </td>
          </tr>
      <%
        }
        
        rs.close();
        ps.close();
        
      } catch (Exception e) {
      %>
        <tr>
          <td colspan="7" style="text-align: center; padding: 2rem; color: #DC3545;">
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

  <div class="info-box" style="margin-top: 2rem;">
    <h3>ℹ️ Legenda:</h3>
    <ul>
      <li><span style="color: #666; font-weight: bold;">75-79%</span> - Idoso (cuidados preventivos)</li>
      <li><span style="color: #FFA500; font-weight: bold;">80-89%</span> - Idoso avançado (monitorização)</li>
      <li><span style="color: #DC3545; font-weight: bold;">90%+</span> - Muito idoso (atenção redobrada)</li>
    </ul>
  </div>
</div>

</body>
</html>