<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VetCare - Tutor</title>
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
      <a href="menu.jsp" class="active">Tutor</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Área do Tutor</h1>
    <p>Gerencie as informações dos seus animais e consultas</p>
  </div>
</section>

<div class="page-content">
    <a href="../index.jsp" class="btn-voltar">← Voltar ao Menu Principal</a>

    <div class="menu-grid">
        <a href="perfil_cliente.jsp" class="menu-card">
            <h2>O Meu Perfil</h2>
            <p>Visualize as suas informações pessoais e animais registados</p>
        </a>

        <a href="consultar_fichas.jsp" class="menu-card">
            <h2>Consultar Fichas</h2>
            <p>Ver fichas clínicas dos seus animais</p>
        </a>

        <a href="agendar_servico.jsp" class="menu-card">
            <h2>Agendar Consulta</h2>
            <p>Marque uma nova consulta para o seu animal</p>
        </a>

        <a href="gestao_consultas.jsp" class="menu-card">
            <h2>Gestão de Consultas</h2>
            <p>Visualize, reagende ou cancele as suas consultas</p>
        </a>
    </div>
</div>

</body>
</html>