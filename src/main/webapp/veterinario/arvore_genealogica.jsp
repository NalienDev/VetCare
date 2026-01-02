<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Árvore Genealógica</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  <style>
    .arvore-container {
      margin-top: 30px;
      padding: 30px;
      background: white;
      border: 1px solid #E7EEF4;
      border-radius: 24px 6px 24px 6px;
      box-shadow: 0px 2px 10px rgba(0,0,0,0.05);
    }
    .arvore-nivel {
      display: flex;
      justify-content: center;
      margin: 20px 0;
      flex-wrap: wrap;
      gap: 20px;
    }
    .animal-card {
      background: #F0F4F8;
      border: 2px solid #0B2A42;
      border-radius: 16px 4px 16px 4px;
      padding: 15px;
      min-width: 200px;
      text-align: center;
    }
    .animal-card.atual {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border-color: #667eea;
    }
    .animal-nome {
      font-size: 16px;
      font-weight: 900;
      margin-bottom: 8px;
    }
    .animal-info {
      font-size: 13px;
      font-weight: 600;
      opacity: 0.8;
    }
    .nivel-label {
      font-size: 14px;
      font-weight: 800;
      color: #57606F;
      text-transform: uppercase;
      margin-top: 30px;
      text-align: center;
    }
    .seta {
      text-align: center;
      font-size: 24px;
      color: #A9D6B6;
      margin: 10px 0;
    }
  </style>
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

<%
String idParam = request.getParameter("idFichaClin");
if (idParam == null) {
    response.sendRedirect("pesquisar_animal.jsp");
    return;
}

int idFicha = Integer.parseInt(idParam);
Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

try {
    Connection con = manipula.getLigacao();
    
    String sql = "SELECT nome, filiacao FROM fichaClinicaAnimal WHERE idFichaClin = ?";
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setInt(1, idFicha);
    ResultSet rs = ps.executeQuery();
    
    if (rs.next()) {
        String nome = rs.getString("nome");
        String filiacao = rs.getString("filiacao");
%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Árvore Genealógica: <%= nome %></h1>
    <p>Ascendência e descendência do animal</p>
  </div>
</section>

<div class="page-content">
  <a href="ficha_clinica.jsp?idFichaClin=<%= idFicha %>" class="btn-voltar">← Voltar à Ficha</a>
  
  <div class="arvore-container">
    <div class="nivel-label">🌳 Ascendentes (Pais)</div>
    <div class="arvore-nivel">
      <div class="animal-card">
        <div class="animal-nome">👨 Pai</div>
        <div class="animal-info">
          <%= filiacao != null && !filiacao.isEmpty() ? filiacao.split(",")[0].trim() : "Desconhecido" %>
        </div>
      </div>
      <div class="animal-card">
        <div class="animal-nome">👩 Mãe</div>
        <div class="animal-info">
          <%= filiacao != null && filiacao.contains(",") && filiacao.split(",").length > 1 ? filiacao.split(",")[1].trim() : "Desconhecida" %>
        </div>
      </div>
    </div>
    
    <div class="seta">↓</div>
    
    <div class="nivel-label">🐾 Animal Atual</div>
    <div class="arvore-nivel">
      <div class="animal-card atual">
        <div class="animal-nome"><%= nome %></div>
        <div class="animal-info">ID: <%= idFicha %></div>
      </div>
    </div>
    
    <div class="seta">↓</div>
    
    <div class="nivel-label">👶 Descendentes</div>
    <%
        rs.close();
        ps.close();
        
        String sqlDescendentes = 
            "SELECT idFichaClin, nome " +
            "FROM fichaClinicaAnimal " +
            "WHERE filiacao LIKE ? " +
            "ORDER BY nome";
        
        PreparedStatement psDesc = con.prepareStatement(sqlDescendentes);
        psDesc.setString(1, "%" + nome + "%");
        ResultSet rsDesc = psDesc.executeQuery();
        
        boolean temDescendentes = false;
    %>
    <div class="arvore-nivel">
    <%
        while (rsDesc.next()) {
            temDescendentes = true;
            int idDesc = rsDesc.getInt("idFichaClin");
            String nomeDesc = rsDesc.getString("nome");
    %>
        <div class="animal-card">
          <div class="animal-nome"><%= nomeDesc %></div>
          <div class="animal-info">ID: <%= idDesc %></div>
          <a href="arvore_genealogica.jsp?idFichaClin=<%= idDesc %>" 
             style="display:inline-block; margin-top:8px; font-size:12px; color:#0B2A42; font-weight:700;">
            Ver Árvore →
          </a>
        </div>
    <%
        }
        
        if (!temDescendentes) {
    %>
        <div style="text-align:center; padding:20px; color:#57606F; font-weight:600;">
          📭 Este animal não tem descendentes registados
        </div>
    <%
        }
        
        rsDesc.close();
        psDesc.close();
    %>
    </div>
    
    <div style="margin-top:30px; padding:20px; background:#EAF6FB; border-radius:10px;">
      <strong style="color:#0B2A42;">ℹ️ Nota:</strong>
      <span style="color:#57606F; font-weight:500;">
        A árvore genealógica é construída com base no campo "filiacao" registado na ficha do animal.
      </span>
    </div>
  </div>
</div>

<%
    } else {
%>
<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Erro</h1>
    <p>Animal não encontrado</p>
  </div>
</section>
<%
    }
    
} catch (Exception e) {
    e.printStackTrace();
%>
<div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
<%
} finally {
    manipula.desligar();
}
%>

</body>
</html>
