<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gestão de Tutores</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>👥 Gestão de Tutores</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <div class="info-card">
                <h3>📋 Gestão de Tutores e Animais</h3>
                <p>Utilize as funcionalidades abaixo para gerir tutores e animais:</p>
            </div>
            
            <div class="menu-grid">
                <a href="../rececionista/criar_tutor.jsp" class="menu-card">
                    <h3>➕ Criar Tutor</h3>
                    <p>Registar novo tutor no sistema</p>
                </a>
                
                <a href="../rececionista/criar_animal.jsp" class="menu-card">
                    <h3>🐕 Criar Animal</h3>
                    <p>Registar novo animal</p>
                </a>
            </div>
        </div>
    </div>
</body>
</html>
