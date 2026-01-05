<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Atualizar Veterinário</title>
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
    .readonly-field {
      background: #F5F5F5;
      cursor: not-allowed;
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

<%
String nLicencaParam = request.getParameter("nLicenca");
if (nLicencaParam == null) {
    response.sendRedirect("gestao_veterinarios.jsp");
    return;
}

String nLicenca = nLicencaParam;
Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

String mensagem = "";
String tipoMensagem = "";

String nome = "";
String contacto = "";

try {
    Connection con = manipula.getLigacao();

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        nome = request.getParameter("nome");
        contacto = request.getParameter("contacto");

        con.setAutoCommit(false);

        PreparedStatement psUp = con.prepareStatement(
            "UPDATE veterinario SET nome=?, contacto=? WHERE nLicenca=?"
        );
        psUp.setString(1, nome);
        psUp.setString(2, contacto);
        psUp.setString(3, nLicenca);
        
        int linhas = psUp.executeUpdate();
        psUp.close();

        if (linhas > 0) {
            con.commit();
            mensagem = "✅ Dados do veterinário atualizados com sucesso!";
            tipoMensagem = "sucesso";
        } else {
            con.rollback();
            mensagem = "❌ Erro ao atualizar veterinário";
            tipoMensagem = "erro";
        }
    }

    PreparedStatement ps = con.prepareStatement(
        "SELECT nLicenca, nome, contacto FROM veterinario WHERE nLicenca=?"
    );
    ps.setString(1, nLicenca);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
        nome = rs.getString("nome");
        contacto = rs.getString("contacto");
    } else {
        response.sendRedirect("gestao_veterinarios.jsp");
        return;
    }

    rs.close();
    ps.close();
%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Atualizar Veterinário: <%= nome %></h1>
    <p>Licença: <%= nLicenca %> | Edite os dados do veterinário</p>
  </div>
</section>

<div class="page-content">
  <a href="gestao_veterinarios.jsp" class="btn-voltar">← Voltar à Lista</a>

  <% if (!mensagem.isEmpty()) { %>
    <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <div class="info-box">
    <h3>ℹ️ Informação</h3>
    <p>O número de licença profissional <strong>não pode ser alterado</strong> após o registo.</p>
    <p>Apenas o nome e o contacto podem ser atualizados.</p>
  </div>

  <form method="POST" class="formulario">
    <div class="form-group">
      <label>Número de Licença Profissional</label>
      <input 
        type="text" 
        value="<%= nLicenca %>" 
        class="readonly-field"
        readonly>
      <small style="color: #666; font-size: 12px; display: block; margin-top: 5px;">
        ℹ️ Este campo não pode ser alterado
      </small>
    </div>

    <div class="form-group">
      <label>Nome Completo *</label>
      <input 
        type="text" 
        name="nome" 
        value="<%= nome != null ? nome : "" %>" 
        maxlength="120" 
        placeholder="Dr(a). Nome Completo"
        required>
    </div>

    <div class="form-group">
      <label>Contacto *</label>
      <input 
        type="text" 
        name="contacto" 
        value="<%= contacto != null ? contacto : "" %>" 
        maxlength="100" 
        placeholder="Telefone, email ou ambos"
        required>
      <small style="color: #666; font-size: 12px; display: block; margin-top: 5px;">
        Pode incluir múltiplos contactos separados por vírgula (ex: 912345678, email@vet.pt).
      </small>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">💾 Guardar Alterações</button>
      <a href="gestao_veterinarios.jsp" class="btn btn-secondary">❌ Cancelar</a>
    </div>
  </form>

  <div class="info-box" style="margin-top: 30px; background: #FFF3CD; border-left-color: #FFC107;">
    <h3>⚠️ Outras Operações</h3>
    <p>Para operações mais complexas (como escalar em horários, supervisionar serviços, etc.), consulte as páginas específicas de gestão.</p>
  </div>
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