<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt" style="height: 100%;">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Gestão de Veterinários - VetCare</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  <style>
    html, body { height: 100%; margin: 0; padding: 0; }
    body { display: flex; flex-direction: column; min-height: 100vh; }
    .page-content { flex: 1; }
    .btn-sm { padding: 8px 16px; font-size: 14px; }
    .btn-voltar { margin-bottom: 30px; }
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
    <h1>Gestão de Veterinários</h1>
    <p>Lista e gestão de médicos veterinários.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <div style="margin-bottom: 20px;">
    <a href="criar_veterinario.jsp" class="btn btn-primary">
      <img src="../images/icon-add.png" alt="Adicionar" class="icon-inline">Novo Veterinário
    </a>
  </div>

  <table class="tabela">
    <thead>
      <tr>
        <th>Nº Licença</th>
        <th>Nome</th>
        <th>Contacto</th>
        <th>Ações</th>
      </tr>
    </thead>
    <tbody>
      <%
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
        String sql = "SELECT nLicenca, nome, contacto FROM veterinario ORDER BY nome";
        Connection con = manipula.getLigacao();
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        
        boolean temDados = false;
        while (rs.next()) {
          temDados = true;
          String nLicenca = rs.getString("nLicenca");
      %>
          <tr>
            <td><strong><%= nLicenca %></strong></td>
            <td><%= rs.getString("nome") %></td>
            <td><%= rs.getString("contacto") %></td>
            <td>
              <a href="editar_veterinario.jsp?nLicenca=<%= nLicenca %>" class="btn btn-primary btn-sm">
                <img src="../images/icon-edit.png" alt="Editar" class="icon-inline">Editar
              </a>
            </td>
          </tr>
      <%
        }
        if (!temDados) {
      %>
          <tr><td colspan="4" style="text-align: center; padding: 2rem; color: #999;">🔭 Nenhum veterinário cadastrado</td></tr>
      <%
        }
        rs.close(); ps.close();
      } catch (Exception e) {
      %>
        <tr><td colspan="4" style="text-align: center; padding: 2rem; color: #DC3545;">❌ Erro: <%= e.getMessage() %></td></tr>
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
