<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VetCare - Gerente</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>💼 Área do Gerente</h1>
            <a href="../index.jsp" class="btn-voltar">← Voltar ao Menu Principal</a>
        </header>
        
        <div class="menu-grid">
            <!-- Gestão de Dados -->
            <a href="gestao_veterinarios.jsp" class="menu-card">
                <h2>⚕️ Gestão de Veterinários</h2>
                <p>Criar e atualizar dados dos médicos veterinários</p>
            </a>
            
            <a href="gestao_tutores.jsp" class="menu-card">
                <h2>👥 Gestão de Tutores</h2>
                <p>Criar e atualizar dados de tutores e animais</p>
            </a>
            
            <a href="gestao_horarios.jsp" class="menu-card">
                <h2>📅 Gestão de Horários</h2>
                <p>Atribuir supervisão de períodos a veterinários</p>
            </a>
            
            <!-- Exportação/Importação -->
            <a href="exportar_dados.jsp" class="menu-card">
                <h2>📤 Exportar Dados</h2>
                <p>Exportar fichas clínicas para XML/JSON</p>
            </a>
            
            <a href="importar_dados.jsp" class="menu-card">
                <h2>📥 Importar Dados</h2>
                <p>Importar fichas clínicas de XML/JSON</p>
            </a>
            
            <!-- Relatórios -->
            <a href="animais_idosos.jsp" class="menu-card">
                <h2>👴 Animais Idosos</h2>
                <p>Lista de animais que ultrapassaram expectativa de vida</p>
            </a>
            
            <a href="animais_excesso_peso.jsp" class="menu-card">
                <h2>⚖️ Excesso de Peso</h2>
                <p>Tutores com animais acima do peso ideal</p>
            </a>
            
            <a href="agendamentos_cancelados.jsp" class="menu-card">
                <h2>❌ Agendamentos Cancelados</h2>
                <p>Tutores com mais cancelamentos no último trimestre</p>
            </a>
            
            <a href="agendamentos_proxima_semana.jsp" class="menu-card">
                <h2>📊 Previsão Semanal</h2>
                <p>Agendamentos previstos por serviço para próxima semana</p>
            </a>
        </div>
    </div>
</body>
</html>
