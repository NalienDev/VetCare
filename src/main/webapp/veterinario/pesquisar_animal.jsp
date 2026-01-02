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
      <input type="text" id="searchTutor" placeholder="Digite o nome do tutor..." autocomplete="off">
      <div id="resultados" style="display:none; position:absolute; background:white; border:1px solid #DFE4EA; border-radius:14px 4px 14px 4px; max-height:300px; overflow-y:auto; width:590px; z-index:100; margin-top:5px; box-shadow:0px 4px 15px rgba(0,0,0,0.1);"></div>
    </div>
  </div>

  <div id="animaisContainer" style="margin-top:30px;"></div>
</div>

<script>
const searchInput = document.getElementById('searchTutor');
const resultadosDiv = document.getElementById('resultados');
const animaisContainer = document.getElementById('animaisContainer');

let timeoutId = null;

searchInput.addEventListener('input', function() {
    clearTimeout(timeoutId);
    const query = this.value.trim();
    
    if (query.length < 2) {
        resultadosDiv.style.display = 'none';
        return;
    }

    timeoutId = setTimeout(function() {
        fetch('procurar_tutores_ajax.jsp?query=' + encodeURIComponent(query))
            .then(function(res) { return res.json(); })
            .then(function(data) {
                if (data.length > 0) {
                    let html = '';
                    data.forEach(function(tutor) {
                        html += '<div class="resultado-item" onclick="selecionarTutor(\'' + tutor.nif + '\', \'' + escapeHtml(tutor.nome).replace(/'/g, "\\'") + '\')" ';
                        html += 'style="padding:14px; cursor:pointer; border-bottom:1px solid #F1F5F8; transition:0.2s;">';
                        html += '<strong style="color:#0B2A42;">' + escapeHtml(tutor.nome) + '</strong><br>';
                        html += '<small style="color:#57606F;">NIF: ' + tutor.nif + '</small>';
                        html += '</div>';
                    });
                    resultadosDiv.innerHTML = html;
                    resultadosDiv.style.display = 'block';
                } else {
                    resultadosDiv.innerHTML = '<div style="padding:14px; color:#57606F;">📭 Nenhum tutor encontrado</div>';
                    resultadosDiv.style.display = 'block';
                }
            })
            .catch(function(err) {
                console.error('Erro:', err);
                resultadosDiv.innerHTML = '<div style="padding:14px; color:#EB5757;">❌ Erro ao pesquisar</div>';
                resultadosDiv.style.display = 'block';
            });
    }, 300);
});

function selecionarTutor(nif, nome) {
    searchInput.value = nome;
    resultadosDiv.style.display = 'none';
    carregarAnimais(nif);
}

function carregarAnimais(nif) {
    animaisContainer.innerHTML = '<div style="text-align:center; padding:40px;"><p>⏳ Carregando animais...</p></div>';
    
    fetch('carregar_animais_ajax.jsp?nif=' + nif)
        .then(function(res) { return res.json(); })
        .then(function(data) {
            if (data.length > 0) {
                let html = '<div class="table-card"><h3 style="margin:0 0 20px 0; font-size:20px;">🐕 Animais do Tutor</h3><table class="tabela"><thead><tr><th>Nome</th><th>Espécie</th><th>Raça</th><th>Sexo</th><th>Idade</th><th>Ações</th></tr></thead><tbody>';
                
                data.forEach(function(animal) {
                    html += '<tr>';
                    html += '<td><strong>' + escapeHtml(animal.nome) + '</strong></td>';
                    html += '<td>' + (animal.especie || '-') + '</td>';
                    html += '<td>' + (animal.raca || '-') + '</td>';
                    html += '<td>' + (animal.sexo === 'M' ? '🐕 Macho' : '🐕 Fêmea') + '</td>';
                    html += '<td>' + animal.idade + (animal.idade === 1 ? ' ano' : ' anos') + '</td>';
                    html += '<td><a href="ficha_clinica.jsp?idFichaClin=' + animal.idFichaClin + '" class="btn btn-primary">📋 Ver Ficha Clínica</a></td>';
                    html += '</tr>';
                });
                
                html += '</tbody></table></div>';
                animaisContainer.innerHTML = html;
            } else {
                animaisContainer.innerHTML = '<div class="mensagem">📭 Este tutor não tem animais registados</div>';
            }
        })
        .catch(function(err) {
            console.error('Erro:', err);
            animaisContainer.innerHTML = '<div class="mensagem erro">❌ Erro ao carregar animais</div>';
        });
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

document.addEventListener('click', function(e) {
    if (!searchInput.contains(e.target) && !resultadosDiv.contains(e.target)) {
        resultadosDiv.style.display = 'none';
    }
});

document.addEventListener('mouseover', function(e) {
    if (e.target.classList.contains('resultado-item') || e.target.closest('.resultado-item')) {
        const item = e.target.classList.contains('resultado-item') ? e.target : e.target.closest('.resultado-item');
        item.style.backgroundColor = '#EAF6FB';
    }
});

document.addEventListener('mouseout', function(e) {
    if (e.target.classList.contains('resultado-item') || e.target.closest('.resultado-item')) {
        const item = e.target.classList.contains('resultado-item') ? e.target : e.target.closest('.resultado-item');
        item.style.backgroundColor = 'white';
    }
});
</script>

</body>
</html>
