<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Criar Veterinário</title>
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
    <h1>Criar Veterinário</h1>
    <p>Registar um novo veterinário na clínica.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <%
    String mensagem = "";
    String tipoMensagem = "";
    String licencaGerada = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
      String nome = request.getParameter("nome");
      String contacto = request.getParameter("contacto");

      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);

      try {
        Connection con = manipula.getLigacao();
        con.setAutoCommit(false);

        String sqlMax = "SELECT MAX(CAST(SUBSTRING(nLicenca, 8) AS UNSIGNED)) AS maxNum FROM veterinario WHERE nLicenca LIKE 'PT-VET-%'";
        PreparedStatement psMax = con.prepareStatement(sqlMax);
        ResultSet rsMax = psMax.executeQuery();
        
        int proximoNum = 1;
        if (rsMax.next() && rsMax.getObject("maxNum") != null) {
          proximoNum = rsMax.getInt("maxNum") + 1;
        }
        
        String nLicenca = String.format("PT-VET-%05d", proximoNum);
        licencaGerada = nLicenca;
        
        rsMax.close();
        psMax.close();

        String sqlVet = "INSERT INTO veterinario (nLicenca, nome, contacto) VALUES (?, ?, ?)";
        PreparedStatement psVet = con.prepareStatement(sqlVet);
        psVet.setString(1, nLicenca);
        psVet.setString(2, nome);
        psVet.setString(3, contacto);
        
        int linhas = psVet.executeUpdate();
        psVet.close();

        if (linhas > 0) {
          con.commit();
          mensagem = "✅ Veterinário registado com sucesso! Licença: " + nLicenca;
          tipoMensagem = "sucesso";
        } else {
          con.rollback();
          mensagem = "❌ Erro ao registar veterinário";
          tipoMensagem = "erro";
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
    <h3>ℹ️ Informação sobre o Número de Licença</h3>
    <p>O número de licença profissional é gerado automaticamente no formato: <strong>PT-VET-XXXXX</strong></p>
    <p>Este número é único e atribuído sequencialmente pela Ordem dos Médicos Veterinários.</p>
  </div>

  <form method="POST" class="formulario">
    <div class="form-group">
      <label>Nome Completo *</label>
      <input 
        type="text" 
        name="nome" 
        maxlength="120" 
        placeholder="Dr(a). Nome Completo"
        required>
    </div>

    <div class="form-group">
      <label>Contacto *</label>
      <input 
        type="text" 
        name="contacto" 
        maxlength="100" 
        placeholder="Telefone, email ou ambos"
        required>
      <small style="color: #666; font-size: 12px; display: block; margin-top: 5px;">
        Pode incluir múltiplos contactos separados por vírgula (ex: 912345678, email@vet.pt).
      </small>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">💾 Guardar</button>
      <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
    </div>
  </form>
</div>

</body>
</html>