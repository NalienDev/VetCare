<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt" style="height: 100%;">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Animais com Excesso de Peso - VetCare</title>
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
    <h1>Animais com Excesso de Peso</h1>
    <p>Animais que excedem o peso adulto da raça.</p>
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
        <th>Peso Atual (kg)</th>
        <th>Peso Ideal (kg)</th>
        <th>Excesso (%)</th>
        <th>Tutor</th>
      </tr>
    </thead>
    <tbody>
      <%
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
        String sql = 
          "SELECT f.idFichaClin, f.nome, r.nomeRaca, r.pesoAdlt, " +
          "       ef.peso AS pesoAtual, " +
          "       c.nomeCompleto AS tutor, " +
          "       ROUND(((ef.peso - r.pesoAdlt) / r.pesoAdlt) * 100, 2) AS excesso " +
          "FROM fichaClinicaAnimal f " +
          "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
          "LEFT JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
          "LEFT JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
          "LEFT JOIN cliente c ON t.NIF = c.NIF " +
          "LEFT JOIN historicoClinico h ON f.idFichaClin = h.idFichaClin " +
          "LEFT JOIN ( " +
          "    SELECT idHistorico, peso, dataHora " +
          "    FROM exameFis ef1 " +
          "    WHERE dataHora = ( " +
          "        SELECT MAX(dataHora) " +
          "        FROM exameFis ef2 " +
          "        WHERE ef2.idHistorico = ef1.idHistorico " +
          "    ) " +
          ") ef ON h.idHistorico = ef.idHistorico " +
          "WHERE r.pesoAdlt IS NOT NULL " +
          "  AND ef.peso IS NOT NULL " +
          "  AND ef.peso > r.pesoAdlt " +
          "ORDER BY excesso DESC";
        
        Connection con = manipula.getLigacao();
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        
        boolean temDados = false;
        
        while (rs.next()) {
          temDados = true;
      %>
          <tr>
            <td><%= rs.getInt("idFichaClin") %></td>
            <td><%= rs.getString("nome") %></td>
            <td><%= rs.getString("nomeRaca") %></td>
            <td><%= String.format("%.2f", rs.getDouble("pesoAtual")) %></td>
            <td><%= String.format("%.2f", rs.getDouble("pesoAdlt")) %></td>
            <td style="color: #DC3545; font-weight: bold;">
              +<%= String.format("%.1f", rs.getDouble("excesso")) %>%
            </td>
            <td><%= rs.getString("tutor") %></td>
          </tr>
      <%
        }
        
        if (!temDados) {
      %>
          <tr>
            <td colspan="7" style="text-align: center; padding: 2rem; color: #999;">
              🔭 Nenhum animal com excesso de peso encontrado ou sem dados de peso registados
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
</div>

</body>
</html>