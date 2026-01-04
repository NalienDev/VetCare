<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Pesquisar Animal</title>
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
    <h1>Pesquisar Animal</h1>
    <p>Encontre fichas de animais pelo nome do tutor.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar ao Menu</a>

  <div class="formulario">
    <div class="form-group" style="position:relative;">
      <label>Nome do Tutor</label>
      <input type="text" id="searchTutor" placeholder="Digite o nome do tutor..." onkeypress="handleEnterKey(event)">
      <div id="resultados" style="display:none; position:absolute; background:white; border:1px solid #DFE4EA; border-radius:14px 4px 14px 4px; max-height:300px; overflow-y:auto; width:590px; z-index:100; margin-top:5px; box-shadow:0px 4px 15px rgba(0,0,0,0.1);"></div>
    </div>
  </div>

  <div id="animaisContainer" style="margin-top:30px;"></div>
</div>

<script>
var searchInput = document.getElementById('searchTutor');
var resultadosDiv = document.getElementById('resultados');
var animaisContainer = document.getElementById('animaisContainer');
var timeoutId = null;

// Function to search tutors using XMLHttpRequest
function pesquisarTutores() {
    var query = searchInput.value.trim();
    
    if (query.length < 2) {
        resultadosDiv.style.display = 'none';
        return;
    }

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                
                if (data.length > 0) {
                    var html = '';
                    for (var i = 0; i < data.length; i++) {
                        var tutor = data[i];
                        html += '<div class="resultado-item" onclick="selecionarTutor(\'' + tutor.nif + '\', \'' + escapeHtml(tutor.nome).replace(/'/g, "\\'") + '\')" ';
                        html += 'style="padding:14px; cursor:pointer; border-bottom:1px solid #F1F5F8; transition:0.2s;">';
                        html += '<strong style="color:#0B2A42;">' + escapeHtml(tutor.nome) + '</strong><br>';
                        html += '<small style="color:#57606F;">NIF: ' + tutor.nif + '</small>';
                        html += '</div>';
                    }
                    resultadosDiv.innerHTML = html;
                    resultadosDiv.style.display = 'block';
                } else {
                    resultadosDiv.innerHTML = '<div style="padding:14px; color:#57606F;">🔭 Nenhum tutor encontrado</div>';
                    resultadosDiv.style.display = 'block';
                }
            } catch (e) {
                console.error('Erro ao processar resposta:', e);
                resultadosDiv.innerHTML = '<div style="padding:14px; color:#EB5757;">❌ Erro ao processar dados</div>';
                resultadosDiv.style.display = 'block';
            }
        } else if (xhr.readyState === 4) {
            console.error('Erro no servidor. Status:', xhr.status);
            resultadosDiv.innerHTML = '<div style="padding:14px; color:#EB5757;">❌ Erro ao pesquisar</div>';
            resultadosDiv.style.display = 'block';
        }
    };
    var contextPath = "<%= request.getContextPath() %>";
    xhr.open("GET", contextPath + "/procurarTutores?query=" + encodeURIComponent(query), true);
    xhr.send();
}

// Event listener for input with debounce
searchInput.addEventListener('input', function() {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(pesquisarTutores, 300);
});

// Handle Enter key press
function handleEnterKey(event) {
    if (event.keyCode === 13 || event.which === 13) {
        event.preventDefault();
        clearTimeout(timeoutId);
        pesquisarTutores();
    }
}

function selecionarTutor(nif, nome) {
    searchInput.value = nome;
    resultadosDiv.style.display = 'none';
    carregarAnimais(nif);
}

// Function to load animals using XMLHttpRequest
function carregarAnimais(nif) {
    animaisContainer.innerHTML = '<div style="text-align:center; padding:40px;"><p>⏳ Carregando animais...</p></div>';
    
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            try {
                var data = JSON.parse(xhr.responseText);
                
                if (data.length > 0) {
                    var html = '<div class="table-card"><h3 style="margin:0 0 20px 0; font-size:20px;">🐕 Animais do Tutor</h3><table class="tabela"><thead><tr><th>Nome</th><th>Espécie</th><th>Raça</th><th>Sexo</th><th>Idade</th><th>Ações</th></tr></thead><tbody>';
                    
                    for (var i = 0; i < data.length; i++) {
                        var animal = data[i];
                        html += '<tr>';
                        html += '<td><strong>' + escapeHtml(animal.nome) + '</strong></td>';
                        html += '<td>' + (animal.especie || '-') + '</td>';
                        html += '<td>' + (animal.raca || '-') + '</td>';
                        html += '<td>' + (animal.sexo === 'M' ? '🐕 Macho' : '🐕 Fêmea') + '</td>';
                        html += '<td>' + animal.idade + (animal.idade === 1 ? ' ano' : ' anos') + '</td>';
                        html += '<td><a href="ficha_clinica.jsp?idFichaClin=' + animal.idFichaClin + '" class="btn btn-primary">📋 Ver Ficha Clínica</a></td>';
                        html += '</tr>';
                    }
                    
                    html += '</tbody></table></div>';
                    animaisContainer.innerHTML = html;
                } else {
                    animaisContainer.innerHTML = '<div class="mensagem">🔭 Este tutor não tem animais registados</div>';
                }
            } catch (e) {
                console.error('Erro ao processar resposta:', e);
                animaisContainer.innerHTML = '<div class="mensagem erro">❌ Erro ao processar dados</div>';
            }
        } else if (xhr.readyState === 4) {
            console.error('Erro no servidor. Status:', xhr.status);
            animaisContainer.innerHTML = '<div class="mensagem erro">❌ Erro ao carregar animais</div>';
        }
    };
    var contextPath = "<%= request.getContextPath() %>";
    xhr.open("GET", contextPath + "/carregarAnimais?nif=" + encodeURIComponent(nif), true);
    xhr.send();
}

function escapeHtml(text) {
    var div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Close dropdown when clicking outside
document.addEventListener('click', function(e) {
    if (!searchInput.contains(e.target) && !resultadosDiv.contains(e.target)) {
        resultadosDiv.style.display = 'none';
    }
});

// Hover effects
document.addEventListener('mouseover', function(e) {
    if (e.target.classList.contains('resultado-item') || e.target.closest('.resultado-item')) {
        var item = e.target.classList.contains('resultado-item') ? e.target : e.target.closest('.resultado-item');
        item.style.backgroundColor = '#EAF6FB';
    }
});

document.addEventListener('mouseout', function(e) {
    if (e.target.classList.contains('resultado-item') || e.target.closest('.resultado-item')) {
        var item = e.target.classList.contains('resultado-item') ? e.target : e.target.closest('.resultado-item');
        item.style.backgroundColor = 'white';
    }
});
</script>

</body>
</html>