<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt" style="height: 100%;">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Gestão de Tutores - VetCare</title>
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
    .btn-voltar {
      margin-bottom: 30px;
    }
    .icon-inline {
      width: 18px;
      height: 18px;
      vertical-align: middle;
      margin-right: 5px;
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
    <h1>Gestão de Tutores</h1>
    <p>Lista de tutores (pessoas) e seus animais.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <div style="margin-bottom: 20px;">
    <a href="../rececionista/criar_tutor.jsp" class="btn btn-primary">
      <img src="../images/icon-add.png" alt="Adicionar" class="icon-inline">Novo Tutor
    </a>
  </div>

  <table class="tabela">
    <thead>
      <tr>
        <th>NIF</th>
        <th>Nome</th>
        <th>Contacto</th>
        <th>Morada</th>
        <th>Nº Animais</th>
        <th>Ações</th>
      </tr>
    </thead>
    <tbody>
      <%
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
        String sql = 
          "SELECT c.NIF, c.nomeCompleto, c.contactos, " +
          "       CONCAT(c.arteria, ', ', c.numero, " +
          "              COALESCE(CONCAT(', ', c.andar), '')) AS morada, " +
          "       COUNT(t.idFichaClin) AS numAnimais " +
          "FROM cliente c " +
          "INNER JOIN pessoa p ON c.NIF = p.NIF " +
          "LEFT JOIN tutor t ON c.NIF = t.NIF " +
          "GROUP BY c.NIF, c.nomeCompleto, c.contactos, morada " +
          "ORDER BY c.nomeCompleto";
        
        Connection con = manipula.getLigacao();
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        
        boolean temDados = false;
        
        while (rs.next()) {
          temDados = true;
          String nif = rs.getString("NIF");
      %>
          <tr>
            <td><strong><%= nif %></strong></td>
            <td><%= rs.getString("nomeCompleto") %></td>
            <td><%= rs.getString("contactos") %></td>
            <td><%= rs.getString("morada") %></td>
            <td style="text-align: center;"><%= rs.getInt("numAnimais") %></td>
            <td>
              <a href="../rececionista/listar_animais.jsp?nif=<%= nif %>" class="btn btn-primary btn-sm">
                <img src="../images/icon-search.png" alt="Pesquisar" class="icon-inline">Ver Animais
              </a>
            </td>
          </tr>
      <%
        }
        
        if (!temDados) {
      %>
          <tr>
            <td colspan="6" style="text-align: center; padding: 2rem; color: #999;">
              🔭 Nenhum tutor cadastrado
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
