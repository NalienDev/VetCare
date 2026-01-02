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
            <div class="menu-icon">👤</div>
            <h2>Meu Perfil</h2>
            <p>Visualize as suas informações pessoais e animais registados</p>
        </a>

        <a href="consultar_fichas.jsp" class="menu-card">
            <div class="menu-icon">📄</div>
            <h2>Consultar Fichas</h2>
            <p>Ver fichas clínicas dos seus animais</p>
        </a>

        <a href="agendar_servico.jsp" class="menu-card">
            <div class="menu-icon">📅</div>
            <h2>Agendar Consulta</h2>
            <p>Marque uma nova consulta para o seu animal</p>
        </a>

        <a href="gestao_consultas.jsp" class="menu-card">
            <div class="menu-icon">📋</div>
            <h2>Gestão de Consultas</h2>
            <p>Visualize, reagende ou cancele as suas consultas</p>
        </a>
    </div>
</div>

<style>
    .menu-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 24px;
        margin-top: 30px;
    }

    .menu-card {
        background: white;
        border: 2px solid #E7EEF4;
        border-radius: 24px 8px 24px 8px;
        padding: 32px 24px;
        text-decoration: none;
        color: inherit;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 0 4px 12px rgba(0,0,0,0.06);
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
    }

    .menu-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 12px 28px rgba(0,0,0,0.12);
        border-color: #0B2A42;
    }

    .menu-icon {
        font-size: 64px;
        margin-bottom: 16px;
        line-height: 1;
    }

    .menu-card h2 {
        font-size: 22px;
        font-weight: 900;
        color: #0B2A42;
        margin: 0 0 12px 0;
    }

    .menu-card p {
        font-size: 14px;
        font-weight: 600;
        color: #57606F;
        margin: 0;
        line-height: 1.5;
    }

    @media (max-width: 768px) {
        .menu-grid {
            grid-template-columns: 1fr;
        }
    }
</style>

</body>
</html>
