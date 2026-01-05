<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*" %>

<%
    String localidade = request.getParameter("localidade");
    if(localidade == null || localidade.trim().isEmpty()){
        response.sendRedirect("clinicas.jsp");
        return;
    }

    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);

    String morada = "";
    String codPostal = "";
    float lat = 0;
    float lng = 0;

    String abre = "";
    String fecha = "";

    String heroImg = "images/default.jpg";
    String telefone = "210 000 000";
    String email = "info@vetcare.pt";
    boolean urgencias24h = false;

    if(localidade.equals("Vila Franca de Xira")){
        heroImg = "images/vfx.jpg";
        telefone = "214 263 919";
        email = "geral.vfx@vetcare.pt";
        urgencias24h = true;
    }
    else if(localidade.equals("Almada")){
        heroImg = "images/almada.jpg";
        telefone = "214 103 629";
        email = "geral.almada@vetcare.pt";
        urgencias24h = false;
    }
    else if(localidade.equals("Quinta do Conde")){
        heroImg = "images/quintaconde.jpg";
        telefone = "219 598 623";
        email = "geral.quintaconde@vetcare.pt";
        urgencias24h = true;
    }

    try {
        String sql = "SELECT localidade, morada, codPostal, latitude, longitude " +
                     "FROM clinica WHERE localidade = ?";
        Connection con = manipula.getLigacao();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, localidade);
        ResultSet rs = ps.executeQuery();

        if(rs.next()){
            morada = rs.getString("morada");
            codPostal = rs.getString("codPostal");
            lat = rs.getFloat("latitude");
            lng = rs.getFloat("longitude");
        } else {
            response.sendRedirect("clinicas.jsp");
            return;
        }
        rs.close();
        ps.close();

        String sql2 = "SELECT horaInicio, horaFim FROM horario WHERE localidade = ? LIMIT 1";
        PreparedStatement ps2 = con.prepareStatement(sql2);
        ps2.setString(1, localidade);
        ResultSet rs2 = ps2.executeQuery();

        if(rs2.next()){
            abre = rs2.getString("horaInicio");
            fecha = rs2.getString("horaFim");
        }
        rs2.close();
        ps2.close();

    } catch(Exception e){
        out.println("Erro: " + e.getMessage());
    } finally {
        manipula.desligar();
    }
%>

<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>VetCare <%= localidade %></title>

<style>
    body { margin:0; font-family: 'Inter', Arial, sans-serif; background:#f7fafc; }

    .topbar {
        background: white;
        padding: 16px 48px;
        display:flex;
        justify-content:space-between;
        align-items:center;
        border-bottom: 1px solid #e6e6e6;
    }
    .logo {
        display: flex;
        align-items: center;
        gap: 12px;
    }
    .logo-img {
        height: 42px;
        width: auto;
    }
    .logo-text {
        font-weight: 900;
        font-size: 20px;
        color: #0B2A42;
    }
    .topbar a {
        color:#0B2A42;
        text-decoration:none;
        font-weight:700;
        margin:0 12px;
        font-size: 14px;
    }
    .topbar a:hover { text-decoration:underline; }

    .hero {
        height: 520px;
        background-image: url('<%= heroImg %>');
        background-size: cover;
        background-position: center;
        position:relative;
        display:flex;
        align-items:center;
        justify-content:center;
        text-align:center;
    }
    .hero::after{
        content:"";
        position:absolute;
        inset:0;
        background: rgba(0,0,0,0.35);
    }
    .hero-content{
        position:relative;
        color:white;
        z-index:2;
        max-width:900px;
    }
    .hero-content h1{
        font-size:56px;
        font-weight:900;
        margin:0;
    }
    .hero-content p{
        font-size:18px;
        font-weight:700;
        margin-top:16px;
    }

    /* INFO STRIP */
    .info-strip{
        background:#EAF6FB;
        padding:20px 48px;
        display:flex;
        gap:32px;
        align-items:center;
        flex-wrap:wrap;
    }
    .info-item{
        display:flex;
        gap:10px;
        align-items:center;
        font-weight:700;
        color:#0b2a42;
        font-size:15px;
    }
    .info-icon{ font-size:20px; }

    /* CONTENT GRID */
    .content{
        max-width:1200px;
        margin:40px auto;
        padding:0 20px;
        display:grid;
        grid-template-columns: 1.2fr 1fr;
        gap:30px;
    }
    .card{
        background:white;
        border-radius:24px 6px 24px 6px;
        box-shadow: 0px 4px 12px rgba(0,0,0,0.06);
        padding:24px;
        border: 1px solid #E7EEF4;
    }
    .card h2{
        margin:0 0 18px;
        font-size:20px;
        font-weight:900;
        color:#0b2a42;
    }
    iframe{
        width:100%;
        height:280px;
        border:0;
        border-radius:14px;
    }

    /* HORÁRIOS */
    .hours-box{
        background:#ffffff;
        border-radius:16px;
        border:1px solid #edf2f7;
        padding:20px;
        margin-bottom:20px;
    }
    .hours-title{
        font-weight:900;
        font-size:17px;
        color:#0b2a42;
        margin-bottom:14px;
        display:flex;
        align-items:center;
        gap:10px;
    }
    .hours-content{
        font-size:15px;
        color:#57606F;
        font-weight:700;
    }

    /* SPECIALTIES SECTION */
    .specialties-section{
        max-width:1200px;
        margin:40px auto;
        padding:0 20px;
    }
    .specialties-box{
        background:white;
        border-radius:24px 6px 24px 6px;
        box-shadow:0px 4px 12px rgba(0,0,0,0.06);
        padding:32px;
        border: 1px solid #E7EEF4;
    }
    .specialties-title{
        font-size:24px;
        font-weight:900;
        color:#0b2a42;
        margin-bottom:24px;
        display:flex;
        align-items:center;
        gap:12px;
    }
    .specialties-grid{
        display:grid;
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap:12px;
    }
    .specialty-card{
        background:#F8FAFC;
        padding:14px 18px;
        border-radius:12px;
        font-weight:700;
        color:#0B2A42;
        font-size:14px;
        border: 1px solid #E7EEF4;
        transition: all 0.2s;
    }
    .specialty-card:hover {
        background:#EAF6FB;
        border-color:#B8D4E6;
    }

    @media(max-width: 900px){
        .content{ grid-template-columns: 1fr; }
        .hero-content h1{ font-size:36px; }
    }
</style>

</head>
<body>

<div class="topbar">
    <div class="logo">
        <img src="images/logo.png" alt="VetCare Logo" class="logo-img">
        <span class="logo-text">VetCare</span>
    </div>
    <nav>
        <a href="index.jsp">Início</a>
        <a href="clinicas.jsp">Clínicas</a>
    </nav>
</div>

<div class="hero">
    <div class="hero-content">
        <h1>VetCare <%= localidade %></h1>
        <p>Cuidados veterinários de excelência na sua região</p>
    </div>
</div>

<div class="info-strip">
    <div class="info-item">
        <span class="info-icon">📍</span>
        <span><%= morada %>, <%= codPostal %></span>
    </div>
    <div class="info-item">
        <span class="info-icon">📞</span>
        <span><%= telefone %></span>
    </div>
    <div class="info-item">
        <span class="info-icon">✉️</span>
        <span><%= email %></span>
    </div>
    <% if (urgencias24h) { %>
    <div class="info-item">
        <span class="info-icon">🚨</span>
        <span>Urgências 24h</span>
    </div>
    <% } %>
</div>

<div class="content">
    <div>
        <div class="card">
            <h2>📍 Localização</h2>
            <iframe
                src="https://www.google.com/maps?q=<%= lat %>,<%= lng %>&output=embed"
                loading="lazy"
                referrerpolicy="no-referrer-when-downgrade">
            </iframe>
        </div>
    </div>

    <div>
        <div class="hours-box">
            <div class="hours-title">
                <span>🕒</span> Horário de Funcionamento
            </div>
            <div class="hours-content">
                <% if (!abre.isEmpty() && !fecha.isEmpty()) { %>
                    Aberto das <%= abre %> às <%= fecha %>
                <% } else { %>
                    Contacte a clínica para mais informações
                <% } %>
            </div>
        </div>

        <div class="card">
            <h2>📞 Contactos</h2>
            <div style="font-size:15px; color:#57606F; font-weight:600; line-height:1.8;">
                <div><strong>Telefone:</strong> <%= telefone %></div>
                <div><strong>Email:</strong> <%= email %></div>
                <div><strong>Morada:</strong> <%= morada %></div>
                <div><strong>Código Postal:</strong> <%= codPostal %></div>
            </div>
        </div>
    </div>
</div>

<section class="specialties-section">
    <div class="specialties-box">
        <div class="specialties-title">
            Serviços Disponíveis
        </div>

        <div class="specialties-grid">
            <div class="specialty-card">Consulta Médica</div>
            <div class="specialty-card">Exame Físico/Diagnóstico</div>
            <div class="specialty-card">Vacinação</div>
            <div class="specialty-card">Desparasitação</div>
            <div class="specialty-card">Intervenção Cirúrgica</div>
            <div class="specialty-card">Medicina Preventiva</div>
            <div class="specialty-card">Tratamento Terapêutico</div>
            <% if (urgencias24h) { %>
            <div class="specialty-card" style="background:#FFF3CD; border-color:#FFC107;">🚨 Urgências 24h</div>
            <% } %>
        </div>
    </div>
</section>

</body>
</html>
