<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Atualizar Tutor</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
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

<%
String nifParam = request.getParameter("NIF");
String idFichaParam = request.getParameter("idFichaClin");

if (nifParam == null || nifParam.trim().isEmpty()) {
    response.sendRedirect("listar_animais.jsp");
    return;
}

Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

String mensagem = "";
String tipoMensagem = "";

String nomeCompleto = "";
String contactos = "";
String arteria = "";
String andar = "";
String distrito = "";
String concelho = "";
String freguesia = "";
String prefLing = "";
int numero = 0;

try {
    Connection con = manipula.getLigacao();

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        nomeCompleto = request.getParameter("nomeCompleto");
        contactos = request.getParameter("contactos");
        arteria = request.getParameter("arteria");
        andar = request.getParameter("andar");
        distrito = request.getParameter("distrito");
        concelho = request.getParameter("concelho");
        freguesia = request.getParameter("freguesia");
        prefLing = request.getParameter("prefLinguisticas");

        String numStr = request.getParameter("numero");
        if (numStr != null && !numStr.trim().isEmpty()) {
            numero = Integer.parseInt(numStr);
        }

        PreparedStatement psUp = con.prepareStatement(
            "UPDATE cliente SET nomeCompleto=?, contactos=?, arteria=?, numero=?, andar=?, distrito=?, concelho=?, freguesia=?, prefLinguisticas=? " +
            "WHERE NIF=?"
        );
        psUp.setString(1, nomeCompleto);
        psUp.setString(2, contactos);
        psUp.setString(3, arteria);
        psUp.setInt(4, numero);
        psUp.setString(5, (andar != null && !andar.trim().isEmpty()) ? andar : null);
        psUp.setString(6, (distrito != null && !distrito.trim().isEmpty()) ? distrito : null);
        psUp.setString(7, (concelho != null && !concelho.trim().isEmpty()) ? concelho : null);
        psUp.setString(8, (freguesia != null && !freguesia.trim().isEmpty()) ? freguesia : null);
        psUp.setString(9, (prefLing != null && !prefLing.trim().isEmpty()) ? prefLing : null);
        psUp.setString(10, nifParam);

        int ok = psUp.executeUpdate();
        psUp.close();

        if (ok > 0) {
            mensagem = "✅ Dados do tutor atualizados com sucesso!";
            tipoMensagem = "sucesso";
        } else {
            mensagem = "❌ Não foi possível atualizar o tutor (verifique o NIF).";
            tipoMensagem = "erro";
        }
    }

    // Carregar dados atuais
    PreparedStatement ps = con.prepareStatement("SELECT * FROM cliente WHERE NIF=?");
    ps.setString(1, nifParam);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
        nomeCompleto = rs.getString("nomeCompleto");
        contactos = rs.getString("contactos");
        arteria = rs.getString("arteria");
        numero = rs.getInt("numero");
        andar = rs.getString("andar");
        distrito = rs.getString("distrito");
        concelho = rs.getString("concelho");
        freguesia = rs.getString("freguesia");
        prefLing = rs.getString("prefLinguisticas");
    }

    rs.close();
    ps.close();

%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Atualizar Tutor</h1>
    <p>NIF: <%= nifParam %></p>
  </div>
</section>

<div class="page-content">
  <a href="ficha_clinica_rececionista.jsp?idFichaClin=<%= idFichaParam != null ? idFichaParam : "" %>" class="btn-voltar">
    ← Voltar à Ficha
  </a>

  <% if (!mensagem.isEmpty()) { %>
    <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <form method="POST" class="formulario">
    <div class="form-group">
      <label>Nome Completo *</label>
      <input type="text" name="nomeCompleto" value="<%= nomeCompleto != null ? nomeCompleto : "" %>" required>
    </div>

    <div class="form-group">
      <label>Contactos *</label>
      <input type="text" name="contactos" value="<%= contactos != null ? contactos : "" %>" required>
    </div>

    <div class="form-group">
      <label>Rua / Artéria *</label>
      <input type="text" name="arteria" value="<%= arteria != null ? arteria : "" %>" required>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Número *</label>
        <input type="number" name="numero" value="<%= numero %>" required>
      </div>
      <div class="form-group">
        <label>Andar</label>
        <input type="text" name="andar" value="<%= andar != null ? andar : "" %>">
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Distrito</label>
        <input type="text" name="distrito" value="<%= distrito != null ? distrito : "" %>">
      </div>
      <div class="form-group">
        <label>Concelho</label>
        <input type="text" name="concelho" value="<%= concelho != null ? concelho : "" %>">
      </div>
    </div>

    <div class="form-group">
      <label>Freguesia</label>
      <input type="text" name="freguesia" value="<%= freguesia != null ? freguesia : "" %>">
    </div>

    <div class="form-group">
      <label>Preferências Linguísticas</label>
      <input type="text" name="prefLinguisticas" value="<%= prefLing != null ? prefLing : "" %>">
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">💾 Guardar Alterações</button>
    </div>
  </form>
</div>

<%
} catch (Exception e) {
    e.printStackTrace();
%>
  <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
<%
} finally {
    manipula.desligar();
}
%>

</body>
</html>
