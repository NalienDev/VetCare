<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Rececionista</title>
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

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Área do Rececionista</h1>
    <p>Gestão de tutores, animais e agendamentos.</p>
  </div>
</section>

<div class="page-content">
  <a href="../index.jsp" class="btn-voltar">← Voltar ao Menu Principal</a>

  <div class="menu-grid">

    <a href="criar_tutor.jsp" class="menu-card">
      <h2>Criar Tutor</h2>
      <p>Registar novos tutores.</p>
    </a>

    <a href="criar_animal.jsp" class="menu-card">
      <h2>Criar Animal</h2>
      <p>Registar animais e adicionar foto de perfil opcional.</p>
    </a>

    <a href="agendar_servico.jsp" class="menu-card">
      <h2>Agendar Serviço</h2>
      <p>Marcar serviços veterinários para clientes.</p>
    </a>

    <a href="gestao_agendamentos.jsp" class="menu-card">
      <h2>Gestão de Agendamentos</h2>
      <p>Cancelar ou reagendar serviços pendentes.</p>
    </a>

    <a href="listar_animais.jsp" class="menu-card">
      <h2>Lista de Animais</h2>
      <p>Ver todos os animais registados com foto de perfil.</p>
    </a>

  </div>
</div>

</body>
</html>
