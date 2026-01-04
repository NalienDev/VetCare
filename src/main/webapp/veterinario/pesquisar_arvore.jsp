<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Pesquisar Árvore Genealógica</title>
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
    <h1>Árvore Genealógica</h1>
    <p>Pesquisar animal para ver ascendência</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <div class="formulario">
    <div class="form-group">
      <label>Nome do Tutor</label>
      <input type="text" id="searchTutor" placeholder="Digite o nome do tutor..." autocomplete="off">
      <div id="resultadosTutor" style="display:none; position:relative; background:white; border:1px solid #DDE6EE; border-radius:8px; max-height:300px; overflow-y:auto; margin-top:5px;"></div>
    </div>

    <div id="animaisSection" style="display:none;">
      <div class="form-group">
        <label>Animal</label>
        <select id="animalSelect" class="form-control">
          <option value="">Selecione um animal...</option>
        </select>
      </div>
      <button onclick="verArvore()" class="btn btn-primary">🌳 Ver Árvore Genealógica</button>
    </div>
  </div>
</div>

<script>
var inputTutor = document.getElementById("searchTutor");
var resultadosTutor = document.getElementById("resultadosTutor");
var animaisSection = document.getElementById("animaisSection");
var animalSelect = document.getElementById("animalSelect");
var timeoutTutor = null;

inputTutor.addEventListener("input", function(){
    clearTimeout(timeoutTutor);
    var query = this.value.trim();

    if(query.length < 2){
        resultadosTutor.style.display = "none";
        animaisSection.style.display = "none";
        return;
    }

    timeoutTutor = setTimeout(function(){
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                var data = JSON.parse(xhr.responseText);
                if(data.length > 0){
                    var html = "";
                    for(var i = 0; i < data.length; i++){
                        var t = data[i];
                        html += '<div onclick="selecionarTutor(\'' + t.nif + '\',\'' + escapeJS(t.nome) + '\')" style="padding:12px; cursor:pointer; border-bottom:1px solid #F1F5F8;">' +
                            '<strong>' + escapeHtml(t.nome) + '</strong><br>' +
                            '<small style="color:#57606F;">NIF: ' + t.nif + '</small>' +
                            '</div>';
                    }
                    resultadosTutor.innerHTML = html;
                    resultadosTutor.style.display = "block";
                } else {
                    resultadosTutor.innerHTML = '<div style="padding:12px; color:#57606F;">Nenhum tutor encontrado</div>';
                    resultadosTutor.style.display = "block";
                }
            }
        };
        var contextPath = "<%= request.getContextPath() %>";
        xhr.open("GET", contextPath + "/procurarTutores?query=" + encodeURIComponent(query), true);
        xhr.send();
    }, 300);
});

function selecionarTutor(nif, nome){
    inputTutor.value = nome;
    resultadosTutor.style.display = "none";
    
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            var data = JSON.parse(xhr.responseText);
            animalSelect.innerHTML = '<option value="">Selecione um animal...</option>';
            for(var i = 0; i < data.length; i++){
                var a = data[i];
                animalSelect.innerHTML += '<option value="' + a.idFichaClin + '">' + escapeHtml(a.nome) + '</option>';
            }
            animaisSection.style.display = "block";
        }
    };
    var contextPath = "<%= request.getContextPath() %>";
    xhr.open("GET", contextPath + "/carregarAnimais?nif=" + encodeURIComponent(nif), true);
    xhr.send();
}

function verArvore(){
    const idFicha = animalSelect.value;
    if(!idFicha){
        alert("Selecione um animal");
        return;
    }
    window.location.href = "arvore_genealogica.jsp?idFichaClin=" + idFicha;
}

function escapeHtml(text){
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
}

function escapeJS(text){
    return text.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
}

document.addEventListener("click", function(e){
    if(!inputTutor.contains(e.target) && !resultadosTutor.contains(e.target)){
        resultadosTutor.style.display = "none";
    }
});
</script>

</body>
</html>