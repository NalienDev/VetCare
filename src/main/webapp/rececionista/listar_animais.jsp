<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Lista de Animais</title>
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
      <a href="menu.jsp">Rececionista</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Lista de Animais</h1>
    <p>Todos os animais registados (com foto ou avatar).</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <!-- PESQUISA + AUTOCOMPLETE -->
  <form method="GET" style="margin: 20px 0; display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap;" autocomplete="off">
	
	  <div class="form-group" style="margin:0; position:relative; min-width:340px;">
	    <label style="margin-bottom:6px;">Pesquisar tutor</label>

	    <input 
	      type="text"
	      name="q"
	      id="searchTutor"
	      value="<%= request.getParameter("q") != null ? request.getParameter("q") : "" %>"
	      placeholder="Digite o nome do tutor..."
	      style="background:#F8FAFC; font-weight:700;"
	      autocomplete="off"
	    >

	    <!-- dropdown do autocomplete -->
	    <div id="resultados" style="display:none; position:absolute; background:white; border:1px solid #DDE6EE; border-radius:14px 4px 14px 4px; max-height:260px; overflow-y:auto; width:100%; z-index:9999; margin-top:5px; box-shadow:0px 4px 15px rgba(0,0,0,0.15);"></div>
	  </div>

	  <button type="submit" class="btn btn-primary" style="margin-top:26px;">Pesquisar</button>
	  <a href="listar_animais.jsp" class="btn btn-secondary" style="margin-top:26px;">Limpar</a>

	</form>


  <div class="table-card">
    <table class="tabela">
      <thead>
        <tr>
          <th>Foto</th>
          <th>ID</th>
          <th>Nome</th>
          <th>Sexo</th>
          <th>Data Nasc.</th>
          <th>Ações</th>
        </tr>
      </thead>
      <tbody>

        <%
          Configura cfg = new Configura();
          Manipula manipula = new Manipula(cfg);

          try{
            String q = request.getParameter("q");
            PreparedStatement psLista;

            if (q != null && !q.trim().isEmpty()) {
              psLista = manipula.getLigacao().prepareStatement(
                "SELECT f.idFichaClin, f.nome, f.sexo, f.dataNasc, f.dataFalecimento " +
                "FROM fichaClinicaAnimal f " +
                "LEFT JOIN tutor t ON t.idFichaClin = f.idFichaClin " +
                "LEFT JOIN cliente c ON c.NIF = t.NIF " +
                "WHERE c.nomeCompleto LIKE ? " +
                "GROUP BY f.idFichaClin " +
                "ORDER BY f.idFichaClin DESC"
              );
              psLista.setString(1, "%" + q.trim() + "%");
            } else {
              psLista = manipula.getLigacao().prepareStatement(
                "SELECT idFichaClin, nome, sexo, dataNasc, dataFalecimento " +
                "FROM fichaClinicaAnimal ORDER BY idFichaClin DESC"
              );
            }

            ResultSet rs = psLista.executeQuery();
            boolean tem = false;

            while(rs != null && rs.next()){
              tem = true;
              int id = rs.getInt("idFichaClin");
              java.sql.Date dataNasc = rs.getDate("dataNasc");
              java.sql.Date dataFal = rs.getDate("dataFalecimento");
        %>
          <tr>
            <td><img class="animal-avatar" src="../fotoAnimal?id=<%= id %>" alt="foto"></td>
            <td><%= id %></td>
            <td><%= rs.getString("nome") %></td>
            <td><%= rs.getString("sexo") %></td>

            <!-- ✅ DATA NASC + DATA FALECIMENTO AO LADO EM VERMELHO -->
            <td>
              <%= dataNasc != null ? dataNasc.toString() : "-" %>
              <% if(dataFal != null) { %>
                <span style="color:#D72638; font-weight:900; margin-left:10px;">
                  <%= dataFal.toString() %>
                </span>
              <% } %>
            </td>

            <td>
              <a class="btn btn-primary" href="ficha_clinica_rececionista.jsp?idFichaClin=<%= id %>">
                Ver Ficha Clínica
              </a>
            </td>
          </tr>
        <%
            }

            if (!tem) {
        %>
          <tr>
            <td colspan="6" style="text-align:center; padding:2rem; color:#57606F; font-weight:700;">
              📭 Nenhum animal encontrado
            </td>
          </tr>
        <%
            }

            rs.close();
            psLista.close();

          }finally{
            manipula.desligar();
          }
        %>

      </tbody>
    </table>
  </div>
</div>

<script>
var searchInput = document.getElementById('searchTutor');
var resultadosDiv = document.getElementById('resultados');
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
                        html += '<div class="resultado-item" onclick="selecionarTutor(\'' + escapeHtml(tutor.nome).replace(/'/g, "\\'") + '\')" ';
                        html += 'style="padding:14px; cursor:pointer; border-bottom:1px solid #F1F5F8; transition:0.2s;">';
                        html += '<strong style="color:#0B2A42;">' + escapeHtml(tutor.nome) + '</strong><br>';
                        html += '<small style="color:#57606F;">NIF: ' + tutor.nif + '</small>';
                        html += '</div>';
                    }
                    resultadosDiv.innerHTML = html;
                    resultadosDiv.style.display = 'block';
                } else {
                    resultadosDiv.innerHTML = '<div style="padding:14px; color:#57606F;">📭 Nenhum tutor encontrado</div>';
                    resultadosDiv.style.display = 'block';
                }
            } catch (e) {
                console.error('Erro ao processar resposta:', e);
                resultadosDiv.innerHTML = '<div style="padding:14px; color:#EB5757;">⚠️ Erro ao processar dados</div>';
                resultadosDiv.style.display = 'block';
            }
        } else if (xhr.readyState === 4) {
            console.error('Erro no servidor. Status:', xhr.status);
            resultadosDiv.innerHTML = '<div style="padding:14px; color:#EB5757;">⚠️ Erro ao carregar</div>';
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

function selecionarTutor(nome) {
    searchInput.value = nome;
    resultadosDiv.style.display = 'none';
}

function escapeHtml(text) {
    var div = document.createElement('div');
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
