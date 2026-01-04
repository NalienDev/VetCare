<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*" %>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospitais e clínicas veterinárias - VetCare</title>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap');

        :root{
            --bg-hero: #EAF6FB;
            --txt-dark: #0B2A42;
            --txt-muted: #57606F;
            --border: #DFE4EA;
            --green: #A9D6B6;
            --bluebtn: #0B2A42;
            --card-bg: #FFFFFF;
        }

        body{
            margin:0;
            font-family: 'Inter', sans-serif;
            background:white;
            color:var(--txt-dark);
        }
        
        *{
		  box-sizing: border-box;
		}

        /* ====== HEADER (com logo imagem) ====== */
        .main-header{
            background:white;
            border-bottom:1px solid #e6e6e6;
            padding:16px 48px;
            position:sticky;
            top:0;
            z-index:200;
        }
        .header-content{
            display:flex;
            justify-content:space-between;
            align-items:center;
            max-width:1400px;
        }
        .logo{
            display:flex;
            align-items:center;
            gap:12px;
        }
        .logo-img{
            height:42px;
            width:auto;
        }
        .logo-text{
            font-weight:900;
            font-size:20px;
            color:var(--txt-dark);
        }
        .main-nav a{
            margin:0 14px;
            font-weight:700;
            font-size:14px;
            color:var(--txt-dark);
            text-decoration:none;
        }
        .main-nav a:hover{
            text-decoration:underline;
        }

        /* ===== HERO ===== */
        .hero{
            background: var(--bg-hero);
            padding: 46px 0 80px;
        }

        /* alinhado à esquerda */
        .hero-inner{
            max-width:1400px;
            margin-left:80px;
            margin-right:0;
            padding:0;
        }

        .breadcrumb{
            font-size:13px;
            font-weight:600;
            color:var(--txt-muted);
            margin-bottom:10px;
        }

        .hero h1{
            margin:0;
            font-size:48px;
            font-weight:900;
            letter-spacing:-1px;
        }

        .search-grid{
		    display:flex;
		    gap:18px;
		    align-items:center;
		    margin-top:32px;
		}
		
		/* wrapper do input ocupa espaço livre */
		.search-input-wrapper{
		    flex:1;
		    max-width:650px;
		    position:relative;
		    min-width:0;
		}


        /* input com lupa dentro */
        .search-input-wrapper{
            position:relative;
        }
        
        .search-input-wrapper input{
		    width:100%;
		    height:56px;
		    border:1px solid var(--border);
		    border-radius: 14px 4px 14px 4px;
		    padding:0 56px 0 20px;
		    font-size:15px;
		    font-weight:500;
		    outline:none;
		    min-width:0;
		}
		
        .search-input-wrapper input::placeholder{
            color:#999;
        }

        /* botão lupa dentro do input */
        .search-inside-btn{
            position:absolute;
            right:14px;
            top:50%;
            transform:translateY(-50%);
            border:none;
            background:#F0F4F8;
            width:36px;
            height:36px;
            border-radius: 10px 4px 10px 4px;
            cursor:pointer;
            display:flex;
            justify-content:center;
            align-items:center;
        }
        .search-inside-btn img{
            width:16px;
            height:16px;
        }

        .btn-green{
		    flex:0 0 260px;
		    height:56px;
		    border:none;
		    cursor:pointer;
		    font-weight:800;
		    font-size:15px;
		    background: var(--green);
		    color: var(--txt-dark);
		    border-radius: 16px 4px 16px 4px;
		    display:flex;
		    justify-content:center;
		    align-items:center;
		    gap:10px;
		}
		
		.btn-blue{
		    flex:0 0 180px;
		    height:56px;
		    border:none;
		    cursor:pointer;
		    font-weight:800;
		    font-size:15px;
		    background: var(--bluebtn);
		    color:white;
		    border-radius: 16px 4px 16px 4px;
		    display:flex;
		    justify-content:center;
		    align-items:center;
		}
		

        /* icons */
        .btn-icon{
            width:18px;
            height:18px;
        }

        /* tip */
        .tip{
            margin-top:14px;
            font-size:12.5px;
            color: var(--txt-muted);
            font-weight:500;
        }
        .tip b{ font-weight:800; color:var(--txt-dark); }
        .tip a{
            color: var(--txt-dark);
            font-weight:800;
            text-decoration:underline;
        }

        /* filtros */
        .filters{
            display:flex;
            gap:18px;
            margin-top:20px;
            flex-wrap:wrap;
            justify-content:flex-start;
        }
        .filters select{
            height:50px;
            padding:0 16px;
            border:1px solid var(--border);
            border-radius: 14px 4px 14px 4px;
            font-weight:700;
            font-size:13px;
            background:white;
            cursor:pointer;
        }

        /* list alinhada à esquerda */
        .clinics-container{
            max-width:1400px;
            margin-left:80px;
            margin-right:0;
            margin-top:70px;
            padding:0;
        }

        .region-title{
            font-size:34px;
            font-weight:900;
            margin:40px 0 20px;
            color: var(--txt-dark);
        }

        /* card */
        .clinic-card{
            width:560px;
            background: var(--card-bg);
            border:1px solid #E7EEF4;
            border-radius: 24px 6px 24px 6px;
            padding: 26px 28px;
            box-shadow: 0px 1px 0px rgba(0,0,0,0.04);
            margin-bottom:30px;
        }

        .clinic-name{
            font-size:22px;
            font-weight:900;
            margin:0 0 14px;
        }
        .clinic-name a{
            color: var(--txt-dark);
            text-decoration:none;
        }
        .clinic-name a:hover{
            text-decoration:underline;
        }

        .info-row{
            display:flex;
            align-items:center;
            gap:10px;
            margin-bottom:10px;
            font-size:14px;
            color: var(--txt-muted);
        }
        .info-icon{
            width:16px;
            height:16px;
        }

        .hours-row{
            display:flex;
            align-items:center;
            gap:10px;
        }
        .badge-hours{
            background:#F0F4F8;
            padding:5px 12px;
            border-radius:8px;
            font-size:13px;
            font-weight:700;
        }
        .badge-emergency{
            background:#FFEAEA;
            color:#EB5757;
            padding:5px 12px;
            border-radius:8px;
            font-size:13px;
            font-weight:700;
            display:flex;
            align-items:center;
            gap:6px;
        }
        .badge-emergency img{
            width:14px;
            height:14px;
        }

        .phone-box{
            margin-top:14px;
            display:flex;
            align-items:center;
            gap:10px;
            font-size:15px;
            font-weight:700;
        }
        .phone-box img{
            width:18px;
            height:18px;
        }

        .btn-showall{
            display:none;
            margin:30px 0;
            background:var(--green);
            color:var(--txt-dark);
            border:none;
            padding:14px 28px;
            font-weight:800;
            font-size:14px;
            border-radius:14px 4px 14px 4px;
            cursor:pointer;
        }
    </style>
</head>

<body>

<!-- HEADER -->
<header class="main-header">
    <div class="header-content">

        <div class="logo">
            <img src="images/logo.png" class="logo-img" alt="VetCare Logo">
            <span class="logo-text">VetCare</span>
        </div>

        <nav class="main-nav">
            <a href="index.jsp">Início</a>
            <a href="clinicas.jsp">Clínicas</a>
            <a href="#sobre">Sobre Nós</a>
            <a href="#contacto">Contacto</a>
        </nav>

    </div>
</header>

<!-- HERO -->
<section class="hero">
    <div class="hero-inner">
        <div class="breadcrumb">Página inicial / Hospitais e clínicas veterinárias</div>
        <h1>Hospitais e clínicas veterinárias</h1>

        <!-- SEARCH + BOTÕES AO LADO -->
        <form method="GET" action="clinicas.jsp">
            <div class="search-grid">

                <div class="search-input-wrapper" style="position:relative;">
				    <input type="text" name="pesquisa" id="searchClinica"
				       placeholder="Pesquisar clínica..."
				       value="<%= request.getParameter("pesquisa") != null ? request.getParameter("pesquisa") : "" %>"
				       autocomplete="off">
				
				    <button class="search-inside-btn" type="submit">
				        <img src="images/search-icon.png" alt="Pesquisar">
				    </button>
				
				    <div id="resultadosClinica" style="display:none; position:absolute; background:white; border:1px solid #DDE6EE;
				         border-radius:14px 4px 14px 4px; max-height:260px; overflow-y:auto;
				         width:100%; z-index:999999; margin-top:6px;
				         box-shadow:0px 4px 15px rgba(0,0,0,0.15);"></div>
				</div>


                <button type="button" class="btn-green" onclick="getLocation();">
                    <img class="btn-icon" src="images/location-icon.png" alt="">
                    Clínicas mais próximas
                </button>

                <button type="button" class="btn-blue" onclick="alert('Mapa em desenvolvimento!')">
                    Exibir mapa
                </button>

            </div>
        </form>

        <!-- TIP -->
        <div class="tip">
            <b>Dica!</b> Você pode pesquisar pelo nome da clínica, cidade ou usar sua localização para encontrar clínicas perto de você.
            <a href="#" onclick="alert('Ative a localização no navegador.'); return false;">Como habilitar.</a>
        </div>

        <!-- FILTERS -->
        <div class="filters">
            <select><option>Ordenar por: Região</option></select>
            <select><option>Todas as horas</option></select>
            <select><option>Todos os tratamentos</option></select>
            <select><option>Todas as regiões</option></select>
        </div>
    </div>
</section>

<!-- LIST -->
<div class="clinics-container">

<button id="btnShowAll" class="btn-showall" onclick="showAllClinics()">Mostrar todas as clínicas</button>

<%
    String pesquisa = request.getParameter("pesquisa");

    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);

    try {
        String sql =
            "SELECT c.localidade, c.morada, c.codPostal, " +
            "MIN(h.horaInicio) as abre, MAX(h.horaFim) as fecha " +
            "FROM clinica c " +
            "LEFT JOIN horario h ON c.localidade = h.localidade ";

        if(pesquisa != null && !pesquisa.trim().isEmpty()){
            sql += "WHERE c.localidade LIKE ? OR c.arteria LIKE ? ";
        }

        sql += "GROUP BY c.localidade ORDER BY c.localidade";

        Connection con = manipula.getLigacao();
        PreparedStatement ps = con.prepareStatement(sql);

        if(pesquisa != null && !pesquisa.trim().isEmpty()){
            String term = "%" + pesquisa + "%";
            ps.setString(1, term);
            ps.setString(2, term);
        }

        ResultSet rs = ps.executeQuery();

        boolean encontrou = false;
        while(rs.next()){
            encontrou = true;

            String localidade = rs.getString("localidade");
            String morada = rs.getString("morada");
            String codPostal = rs.getString("codPostal");
            String abre = rs.getString("abre");
            String fecha = rs.getString("fecha");

            // GPS sem alterar o SELECT principal
            float lat = 0, lng = 0;
            String sqlGPS = "SELECT latitude, longitude FROM clinica WHERE localidade=?";
            PreparedStatement psGPS = con.prepareStatement(sqlGPS);
            psGPS.setString(1, localidade);
            ResultSet rsGPS = psGPS.executeQuery();
            if(rsGPS.next()){
                lat = rsGPS.getFloat("latitude");
                lng = rsGPS.getFloat("longitude");
            }
            rsGPS.close();
            psGPS.close();

            // telefone + urgencias (hardcoded)
            String telefone = "210 000 000";
            boolean urgencias = false;
            if(localidade.equals("Vila Franca de Xira")){
                telefone = "214263919";
                urgencias = true;
            } else if(localidade.equals("Almada")){
                telefone = "214103629";
                urgencias = false;
            } else if(localidade.equals("Quinta do Conde")){
                telefone = "219598623";
                urgencias = true;
            }
%>

    <div class="region-title"><%= localidade %></div>

    <div class="clinic-card"
         data-lat="<%= lat %>"
         data-lng="<%= lng %>"
         data-localidade="<%= localidade %>">

        <h3 class="clinic-name">
            <a href="clinica.jsp?localidade=<%= localidade %>">
                VetCare <%= localidade %> Hospital Veterinário →
            </a>
        </h3>

        <div class="info-row">
            <img class="info-icon" src="images/icon-pin.png" alt="">
            <div><%= morada %>, <%= codPostal %>, <%= localidade %></div>
        </div>

        <div class="info-row hours-row">
            <img class="info-icon" src="images/icon-clock.png" alt="">
            <div class="badge-hours"><%= abre %> - <%= fecha %></div>

            <% if(urgencias){ %>
                <div class="badge-emergency">
                    <img src="images/red-cross.png" alt="">
                    00 - 24
                </div>
            <% } %>
        </div>

        <div class="phone-box">
            <img src="images/icon-phone.png" alt="">
            <span><%= telefone %></span>
        </div>
    </div>

<%
        }

        if(!encontrou){
%>
    <p style="font-weight:900; font-size:18px;">😔 Nenhuma clínica encontrada</p>
<%
        }

        rs.close();
        ps.close();

    } catch(Exception e){
        out.println("<p style='color:red;'>Erro: "+ e.getMessage() +"</p>");
    } finally {
        manipula.desligar();
    }
%>

</div>

<script>
function getLocation(){
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            function(pos){
                var userLat = pos.coords.latitude;
                var userLng = pos.coords.longitude;
                mostrarClinicaMaisProxima(userLat, userLng);
            },
            function(){
                alert("Não foi possível obter a localização.\nPermite o acesso no navegador.");
            }
        );
    } else {
        alert("Geolocalização não é suportada.");
    }
}

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

function mostrarClinicaMaisProxima(userLat, userLng){
    var cards = document.querySelectorAll(".clinic-card");
    var menorDist = Infinity;
    var maisProxima = null;

    for (var i = 0; i < cards.length; i++) {
        var card = cards[i];
        var cLat = parseFloat(card.dataset.lat);
        var cLng = parseFloat(card.dataset.lng);
        var dist = haversine(userLat, userLng, cLat, cLng);
        if(dist < menorDist){
            menorDist = dist;
            maisProxima = card;
        }
    }

    for (var i = 0; i < cards.length; i++) {
        cards[i].style.display = "none";
    }
    
    var titles = document.querySelectorAll(".region-title");
    for (var i = 0; i < titles.length; i++) {
        titles[i].style.display = "none";
    }

    document.getElementById("btnShowAll").style.display = "inline-block";

    if(maisProxima){
        maisProxima.style.display = "block";
        maisProxima.style.border = "2px solid #A9D6B6";
        maisProxima.style.boxShadow = "0px 10px 30px rgba(169,214,182,0.35)";
        maisProxima.scrollIntoView({behavior:"smooth", block:"center"});
        alert("Clínica mais próxima: " + maisProxima.dataset.localidade +
              "\nDistância: " + menorDist.toFixed(2) + " km");
    }
}

function showAllClinics(){
    var cards = document.querySelectorAll(".clinic-card");
    for (var i = 0; i < cards.length; i++) {
        cards[i].style.display = "block";
    }
    
    var titles = document.querySelectorAll(".region-title");
    for (var i = 0; i < titles.length; i++) {
        titles[i].style.display = "block";
    }
    
    document.getElementById("btnShowAll").style.display = "none";
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
