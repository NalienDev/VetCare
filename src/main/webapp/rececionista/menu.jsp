<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VetCare - Rececionista</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>👨‍💼 Área do Rececionista</h1>
            <a href="../index.jsp" class="btn-voltar">← Voltar ao Menu Principal</a>
        </header>
        
        <div class="menu-grid">
            <a href="criar_tutor.jsp" class="menu-card">
                <h2>📝 Criar/Atualizar Tutor</h2>
                <p>Registar novos tutores ou atualizar dados existentes</p>
            </a>
            
            <a href="criar_animal.jsp" class="menu-card">
                <h2>🐕 Criar/Atualizar Animal</h2>
                <p>Registar animais e adicionar fotografias</p>
            </a>
            
            <a href="agendar_servico.jsp" class="menu-card">
                <h2>📅 Agendar Serviço</h2>
                <p>Marcar consultas e outros serviços veterinários</p>
            </a>
            
            <a href="gestao_agendamentos.jsp" class="menu-card">
                <h2>🔄 Gestão de Agendamentos</h2>
                <p>Cancelar ou reagendar serviços</p>
            </a>
        </div>
    </div>
</body>
</html>
