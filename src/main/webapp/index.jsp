<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VetCare - Sistema de Gestão Veterinária</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <!-- Header com logo e navegação -->
    <header class="main-header">
        <div class="header-content">
            <div class="logo">
                <img src="images/logo.png" alt="VetCare Logo" class="logo-img">
                <span class="logo-text">VetCare</span>
            </div>
            <nav class="main-nav">
                <a href="clinicas.jsp">Clínicas</a>
                <a href="#sobre">Sobre Nós</a>
                <a href="#contacto">Contacto</a>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <h1 class="hero-title">Porque o seu animal de estimação merece a melhor atenção</h1>
            
            <!-- Menu de busca de clínicas -->
            <div class="clinic-search-box">
                <div class="search-header">
                    <h2>Encontre uma clínica</h2>
                    <a href="clinicas.jsp" class="btn-todas-clinicas">Todas as clínicas</a>
                </div>
                
                <div class="search-input-wrapper" style="position:relative;">
				    <input type="text"
				           placeholder="Pesquisar clínica..."
				           class="search-clinic-input"
				           id="searchClinica"
				           autocomplete="off">
				
				    <button type="button" class="btn-search-clinic">
				        <img src="images/search-icon.png" alt="Pesquisar">
				    </button>
				
				    <div id="resultadosClinica"
				         style="display:none; position:absolute; background:white;
				                border:1px solid #DDE6EE;
				                border-radius:14px 4px 14px 4px;
				                max-height:260px;
				                overflow-y:auto;
				                width:100%;
				                z-index:999999;
				                margin-top:5px;
				                box-shadow:0px 4px 15px rgba(0,0,0,0.15);">
				    </div>
				</div>


                
                <div class="search-info">
                    <p><strong>Dica!</strong> Você pode pesquisar pelo nome da clínica, cidade ou usar sua localização para encontrar clínicas perto de você.</p>
                    <p class="how-enable">Como habilitar:</p>
                </div>
                
                <div class="search-actions">
                    <button class="btn-clinicas-proximas">
                        <img src="images/location-icon.png" alt="Localização">
                        Clínicas mais próximas
                    </button>
                    <button class="btn-urgencias">
                        <img src="images/emergency-icon.png" alt="Urgências">
                        Urgências
                    </button>
                </div>
            </div>
        </div>
        <!-- Adicione sua imagem de animal aqui -->
        <img src="images/hero-cat.jpeg" alt="Gato" class="hero-image">
    </section>

    <!-- Secção de Acesso Rápido -->
    <section class="quick-access">
        <div class="container">
            <h2 class="section-title">Acesso ao Sistema</h2>
            <div class="access-grid">
                <!-- Rececionista -->
                <a href="rececionista/menu.jsp" class="access-card">
                    <div class="card-icon">
                        <img src="images/receptionist-icon.png" alt="Rececionista">
                    </div>
                    <h3>Rececionista</h3>
                    <p>Gestão de tutores, animais e agendamentos</p>
                    <ul class="card-features">
                        <li>Criar e atualizar fichas</li>
                        <li>Agendar serviços</li>
                    </ul>
                </a>

                <!-- Veterinário -->
                <a href="veterinario/menu.jsp" class="access-card">
                    <div class="card-icon">
                        <img src="images/vet-icon.png" alt="Veterinário">
                    </div>
                    <h3>Veterinário</h3>
                    <p>Consulta e atualização de registos clínicos</p>
                    <ul class="card-features">
                        <li>Histórico clínico</li>
                        <li>Lista de chamada</li>
                    </ul>
                </a>

                <!-- Tutor -->
                <a href="tutor/menu.jsp" class="access-card">
                    <div class="card-icon">
                        <img src="images/owner-icon.png" alt="Tutor">
                    </div>
                    <h3>Tutor</h3>
                    <p>Acesso aos dados dos seus animais</p>
                    <ul class="card-features">
                        <li>Consultar fichas</li>
                        <li>Gerir consultas</li>
                    </ul>
                </a>

                <!-- Gerente -->
                <a href="gerente/menu.jsp" class="access-card">
                    <div class="card-icon">
                        <img src="images/manager-icon.png" alt="Gerente">
                    </div>
                    <h3>Gerente</h3>
                    <p>Administração completa do sistema</p>
                    <ul class="card-features">
                        <li>Gestão de recursos</li>
                        <li>Relatórios</li>
                    </ul>
                </a>
            </div>
        </div>
    </section>

    <!-- Secção Sobre -->
    <section id="sobre" class="about-section">
        <div class="container">
            <div class="about-content">
                <div class="about-text">
                    <h2>Cuidados veterinários de excelência</h2>
                    <p>O VetCare é um sistema completo de gestão para clínicas veterinárias, desenvolvido para facilitar o dia-a-dia dos profissionais e melhorar a experiência dos tutores.</p>
                    <p>Com tecnologia moderna e interface intuitiva, garantimos eficiência e qualidade no atendimento aos seus animais de estimação.</p>
                </div>
                <div class="about-image">
                    <img src="images/about-dog.png" alt="Cão">
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="main-footer">
        <div class="container">
            <div class="footer-content">
                <div class="footer-col">
                    <h4>VetCare</h4>
                    <p>Sistema de Gestão de Clínicas Veterinárias</p>
                    <p class="footer-small">ISEL - Sistemas de Bases de Dados - 2025/2026</p>
                </div>
                <div class="footer-col">
                    <h4>Contactos</h4>
                    <p>Email: info@vetcare.pt</p>
                    <p>Telefone: +351 210 000 000</p>
                </div>
                <div class="footer-col">
                    <h4>Desenvolvido por</h4>
                    <p>Sofia Salgado (51694)</p>
                    <p>Lucas Filipe (51793)</p>
                    <p>Daniel Coelho (51812)</p>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2025 VetCare - Todos os direitos reservados</p>
            </div>
        </div>
    </footer>
    
    <script>
	// Clínicas mais próximas
	document.querySelector(".btn-clinicas-proximas").addEventListener("click", function(){
	
	    if(!navigator.geolocation){
	        alert("Geolocalização não suportada.");
	        return;
	    }
	
	    navigator.geolocation.getCurrentPosition(function(pos){
	
	        var userLat = pos.coords.latitude;
	        var userLng = pos.coords.longitude;
	
	        var xhr = new XMLHttpRequest();
	        xhr.onreadystatechange = function() {
	            if (xhr.readyState === 4 && xhr.status === 200) {
	                try {
	                    var data = JSON.parse(xhr.responseText);
	
	                    if(data.length === 0){
	                        alert("Nenhuma clínica na base de dados.");
	                        return;
	                    }
	
	                    var menor = Infinity;
	                    var clinica = null;
	
	                    for (var i = 0; i < data.length; i++) {
	                        var c = data[i];
	                        var dist = haversine(userLat, userLng, c.lat, c.lng);
	                        if(dist < menor){
	                            menor = dist;
	                            clinica = c;
	                        }
	                    }
	
	                    if(clinica){
	                        window.location.href = "clinica.jsp?localidade=" + encodeURIComponent(clinica.localidade);
	                    }
	                } catch (e) {
	                    console.error('Erro ao processar resposta:', e);
	                }
	            }
	        };
	        var contextPath = "<%= request.getContextPath() %>";
	        xhr.open("GET", contextPath + "/procurarClinicas?query=", true);
	        xhr.send();
	
	    }, function(){
	        alert("Permite a localização no navegador.");
	    });
	});
	
	function haversine(lat1, lon1, lat2, lon2) {
	    var R = 6371;
	    var dLat = (lat2 - lat1) * Math.PI/180;
	    var dLon = (lon2 - lon1) * Math.PI/180;
	    var a =
	        Math.sin(dLat/2) * Math.sin(dLat/2) +
	        Math.cos(lat1 * Math.PI/180) * Math.cos(lat2 * Math.PI/180) *
	        Math.sin(dLon/2) * Math.sin(dLon/2);
	    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
	    return R * c;
	}
	</script>
    
   <script>
	var inputClinica = document.getElementById("searchClinica");
	var resultadosClinica = document.getElementById("resultadosClinica");
	
	var timeoutClinica = null;
	
	// Function to search clinics using XMLHttpRequest
	function pesquisarClinicas() {
	    var query = inputClinica.value.trim();
	
	    if(query.length < 1){
	        resultadosClinica.style.display = "none";
	        return;
	    }
	
	    var xhr = new XMLHttpRequest();
	    xhr.onreadystatechange = function() {
	        if (xhr.readyState === 4 && xhr.status === 200) {
	            try {
	                var data = JSON.parse(xhr.responseText);
	
	                if(data.length > 0){
	                    var html = "";
	
	                    for (var i = 0; i < data.length; i++) {
	                        var c = data[i];
	                        html += '<div class="resultado-item" onclick="abrirClinica(\'' + escapeJS(c.localidade) + '\')" ' +
	                            'style="padding:14px; cursor:pointer; border-bottom:1px solid #F1F5F8;">' +
	                            '<strong style="color:#0B2A42;">VetCare ' + escapeHtml(c.localidade) + '</strong><br>' +
	                            '<small style="color:#57606F;">' + escapeHtml(c.morada) + ', ' + escapeHtml(c.codPostal) + '</small>' +
	                            '</div>';
	                    }
	
	                    resultadosClinica.innerHTML = html;
	                    resultadosClinica.style.display = "block";
	
	                } else {
	                    resultadosClinica.innerHTML =
	                        '<div style="padding:14px; color:#57606F;">📭 Nenhuma clínica encontrada</div>';
	                    resultadosClinica.style.display = "block";
	                }
	            } catch (e) {
	                console.error('Erro ao processar resposta:', e);
	                resultadosClinica.innerHTML =
	                    '<div style="padding:14px; color:#EB5757;">⚠️ Erro ao carregar clínicas</div>';
	                resultadosClinica.style.display = "block";
	            }
	        } else if (xhr.readyState === 4) {
	            console.error('Erro no servidor. Status:', xhr.status);
	            resultadosClinica.innerHTML =
	                '<div style="padding:14px; color:#EB5757;">⚠️ Erro ao carregar clínicas</div>';
	            resultadosClinica.style.display = "block";
	        }
	    };
	    var contextPath = "<%= request.getContextPath() %>";
	    xhr.open("GET", contextPath + "/procurarClinicas?query=" + encodeURIComponent(query), true);
	    xhr.send();
	}
	
	inputClinica.addEventListener("input", function(){
	    clearTimeout(timeoutClinica);
	    timeoutClinica = setTimeout(pesquisarClinicas, 250);
	});
	
	function abrirClinica(localidade){
	    window.location.href = "clinica.jsp?localidade=" + encodeURIComponent(localidade);
	}
	
	function escapeHtml(text){
	    var div = document.createElement("div");
	    div.textContent = text;
	    return div.innerHTML;
	}
	
	function escapeJS(text){
	    return text.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
	}
	
	document.addEventListener("click", function(e){
	    if(!inputClinica.contains(e.target) && !resultadosClinica.contains(e.target)){
	        resultadosClinica.style.display = "none";
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
