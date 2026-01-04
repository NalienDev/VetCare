<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Veterinário</title>
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
      <a href="menu.jsp">Veterinário</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Área do Veterinário</h1>
    <p>Gestão de consultas e históricos clínicos.</p>
  </div>
</section>

<div class="page-content">
  <a href="../index.jsp" class="btn-voltar">← Voltar ao Menu Principal</a>

  <div class="menu-grid">

    <a href="pesquisar_animal.jsp" class="menu-card">
      <h2>Pesquisar Animal</h2>
      <p>Encontre fichas clínicas pelo nome do tutor (autocomplete).</p>
    </a>

    <a href="lista_chamada.jsp" class="menu-card">
      <h2>Lista de Chamada</h2>
      <p>Agendamentos de hoje e futuros por data-hora.</p>
    </a>

    <a href="gestao_agendamentos_vet.jsp" class="menu-card">
      <h2>Agendar/Cancelar Serviços</h2>
      <p>Gestão de agendamentos de serviços veterinários.</p>
    </a>
    
    <a href="pesquisar_arvore.jsp" class="menu-card">
      <h2>Árvore Genealógica</h2>
      <p>Ver ascendência e descendência de animais.</p>
    </a>

  </div>
</div>

</body>
</html>
