<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, org.json.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Pesquisar Animal</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .autocomplete-container {
            position: relative;
            width: 100%;
        }
        
        #resultados {
            position: absolute;
            background: white;
            border: 2px solid #667eea;
            border-top: none;
            max-height: 300px;
            overflow-y: auto;
            width: 100%;
            display: none;
            z-index: 1000;
            border-radius: 0 0 5px 5px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .resultado-item {
            padding: 12px 15px;
            cursor: pointer;
            border-bottom: 1px solid #e0e0e0;
            transition: background 0.2s;
        }
        
        .resultado-item:hover {
            background: #f0f0ff;
        }
        
        .resultado-item strong {
            color: #667eea;
        }
        
        .ficha-animal {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 10px;
            margin-top: 20px;
        }
        
        .ficha-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 20px;
        }
        
        .ficha-foto img {
            max-width: 200px;
            max-height: 200px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .ficha-dados {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
        }
        
        .dado-item {
            padding: 10px;
            background: white;
            border-radius: 5px;
            border-left: 3px solid #667eea;
        }
        
        .dado-label {
            font-weight: 600;
            color: #667eea;
            margin-bottom: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🔍 Pesquisar Animal por Tutor</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <div class="info-card">
                <h3>📌 Como usar:</h3>
                <p>Digite o nome do tutor no campo abaixo. Os resultados aparecem automaticamente conforme você digita.</p>
            </div>
            
            <div class="formulario">
                <div class="form-group">
                    <label>Nome do Tutor</label>
                    <div class="autocomplete-container">
                        <input type="text" id="nomeTutor" placeholder="Digite o nome do tutor..." 
                               autocomplete="off" onkeyup="buscarTutores()">
                        <div id="resultados"></div>
                    </div>
                </div>
            </div>
            
            <div id="fichasAnimais"></div>
        </div>
    </div>
    
    <script>
        let timeoutId;
        
        function buscarTutores() {
            clearTimeout(timeoutId);
            
            const input = document.getElementById('nomeTutor');
            const termo = input.value.trim();
            const resultadosDiv = document.getElementById('resultados');
            
            if (termo.length < 2) {
                resultadosDiv.style.display = 'none';
                return;
            }
            
            timeoutId = setTimeout(() => {
                fetch('buscar_tutores_ajax.jsp?termo=' + encodeURIComponent(termo))
                    .then(response => response.json())
                    .then(data => {
                        if (data.length === 0) {
                            resultadosDiv.innerHTML = '<div class="resultado-item">Nenhum tutor encontrado</div>';
                            resultadosDiv.style.display = 'block';
                            return;
                        }
                        
                        let html = '';
                        data.forEach(tutor => {
                            html += `<div class="resultado-item" onclick="selecionarTutor('${tutor.nif}', '${tutor.nome}')">
                                <strong>${tutor.nome}</strong><br>
                                <small>NIF: ${tutor.nif} | Animais: ${tutor.numAnimais}</small>
                            </div>`;
                        });
                        
                        resultadosDiv.innerHTML = html;
                        resultadosDiv.style.display = 'block';
                    })
                    .catch(error => {
                        console.error('Erro:', error);
                        resultadosDiv.innerHTML = '<div class="resultado-item">Erro ao buscar tutores</div>';
                    });
            }, 300);
        }
        
        function selecionarTutor(nif, nome) {
            document.getElementById('nomeTutor').value = nome;
            document.getElementById('resultados').style.display = 'none';
            carregarAnimais(nif);
        }
        
        function carregarAnimais(nif) {
            fetch('carregar_animais_ajax.jsp?nif=' + encodeURIComponent(nif))
                .then(response => response.text())
                .then(html => {
                    document.getElementById('fichasAnimais').innerHTML = html;
                })
                .catch(error => {
                    console.error('Erro:', error);
                    document.getElementById('fichasAnimais').innerHTML = 
                        '<div class="mensagem erro">Erro ao carregar animais</div>';
                });
        }
        
        // Fechar resultados ao clicar fora
        document.addEventListener('click', function(e) {
            if (!e.target.closest('.autocomplete-container')) {
                document.getElementById('resultados').style.display = 'none';
            }
        });
    </script>
</body>
</html>
