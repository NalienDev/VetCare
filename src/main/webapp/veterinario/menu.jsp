<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VetCare - Veterinário</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>👨‍⚕️ Área do Veterinário</h1>
            <a href="../index.jsp" class="btn-voltar">← Voltar ao Menu Principal</a>
        </header>
        
        <div class="menu-grid">
            <a href="pesquisar_animal.jsp" class="menu-card">
                <h2>🔍 Pesquisar Animal</h2>
                <p>Encontrar fichas de animais pelo nome do tutor (autocomplete)</p>
            </a>
            
            <a href="historico_clinico.jsp" class="menu-card">
                <h2>📋 Histórico Clínico</h2>
                <p>Consultar registo clínico completo do animal</p>
            </a>
            
            <a href="arvore_genealogica.jsp" class="menu-card">
                <h2>🌳 Árvore Genealógica</h2>
                <p>Visualizar a genealogia do animal</p>
            </a>
            
            <a href="lista_chamada.jsp" class="menu-card">
                <h2>📑 Lista de Chamada</h2>
                <p>Animais agendados sob sua supervisão</p>
            </a>
            
            <a href="atualizar_historico.jsp" class="menu-card">
                <h2>💉 Atualizar Histórico</h2>
                <p>Registar consultas e procedimentos realizados</p>
            </a>
            
            <a href="gestao_agendamentos_vet.jsp" class="menu-card">
                <h2>📅 Gestão de Agendamentos</h2>
                <p>Agendar ou cancelar serviços veterinários</p>
            </a>
        </div>
    </div>
</body>
</html>
