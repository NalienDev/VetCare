<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.time.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Consultar Fichas Clínicas</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  
  <style>
    .animals-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 20px;
      margin-top: 30px;
    }
    
    .animal-card {
      background: white;
      border: 2px solid #E7EEF4;
      border-radius: 24px 8px 24px 8px;
      padding: 20px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.06);
      transition: all 0.3s;
      cursor: pointer;
      text-decoration: none;
      color: inherit;
      display: block;
      position: relative;
    }
    
    .animal-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 20px rgba(0,0,0,0.12);
      border-color: #0B2A42;
    }

    .animal-card.falecido {
      background: #F1F3F5;
      border-color: #B0B7C3;
      opacity: 0.88;
      filter: grayscale(0.65);
    }
    .animal-card.falecido:hover {
      transform: none;
      box-shadow: 0 4px 12px rgba(0,0,0,0.06);
      border-color: #B0B7C3;
    }

    .falecido-badge {
      position: absolute;
      top: 14px;
      right: 14px;
      background: #D72638;
      color: white;
      padding: 8px 12px;
      border-radius: 999px;
      font-weight: 900;
      font-size: 12px;
      display: flex;
      align-items: center;
      gap: 6px;
      box-shadow: 0 4px 14px rgba(0,0,0,0.25);
    }
    
    .animal-header {
      display: flex;
      gap: 16px;
      align-items: center;
      margin-bottom: 16px;
      padding-bottom: 16px;
      border-bottom: 2px solid #F1F5F8;
    }
    
    .animal-photo {
      width: 70px;
      height: 70px;
      border-radius: 16px;
      object-fit: cover;
      border: 3px solid #E7EEF4;
      box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
    
    .animal-name {
      font-size: 20px;
      font-weight: 900;
      color: #0B2A42;
      margin: 0;
    }
    
    .animal-info {
      font-size: 13px;
      color: #57606F;
      font-weight: 700;
      margin-top: 4px;
    }
    
    .ficha-content {
      background: white;
      border: 2px solid #E7EEF4;
      border-radius: 24px 8px 24px 8px;
      padding: 30px;
      margin-top: 30px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.06);
    }

    /* ✅ ficha cinzenta se falecido */
    .ficha-content.falecido {
      background: #F1F3F5;
      border-color: #B0B7C3;
      opacity: 0.92;
    }

    .falecido-big {
      background: #FDECEC;
      border: 2px solid #D72638;
      color: #D72638;
      padding: 14px 18px;
      border-radius: 18px;
      font-weight: 900;
      font-size: 14px;
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 20px;
    }
    
    .section-title {
      font-size: 20px;
      font-weight: 900;
      color: #0B2A42;
      margin: 30px 0 16px 0;
      padding-bottom: 12px;
      border-bottom: 3px solid #EAF6FB;
    }
    
    .info-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }
    
    .info-item {
      background: #F8FAFC;
      padding: 14px;
      border-radius: 12px;
      border: 1px solid #E7EEF4;
    }
    
    .info-label {
      font-size: 11px;
      font-weight: 800;
      color: #57606F;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 6px;
    }
    
    .info-value {
      font-size: 16px;
      font-weight: 900;
      color: #0B2A42;
    }
    
    .readonly-notice {
      background: #EAF6FB;
      border: 2px solid #B8D4E6;
      border-radius: 16px;
      padding: 16px 20px;
      margin-bottom: 24px;
      display: flex;
      align-items: center;
      gap: 12px;
      font-weight: 700;
      color: #0B2A42;
    }

    .color-tags {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      margin-top: 6px;
    }

    .color-tag {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 8px 12px;
      border-radius: 999px;
      font-weight: 900;
      font-size: 13px;
      border: 2px solid #E7EEF4;
      background: #F8FAFC;
    }

    .color-dot {
      width: 16px;
      height: 16px;
      border-radius: 50%;
      border: 2px solid rgba(0,0,0,0.2);
    }
    
    .icon-inline {
      width: 16px;
      height: 16px;
      vertical-align: middle;
      margin-right: 4px;
    }
    
    .icon-gender {
      width: 18px;
      height: 18px;
      vertical-align: middle;
      margin-right: 6px;
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
      <a href="menu.jsp">Tutor</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Consultar Fichas Clínicas</h1>
    <p>Visualize as informações dos seus animais</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <%
  String nif = request.getParameter("nif");
  String idFichaParam = request.getParameter("idFichaClin");

  if (nif == null || nif.trim().isEmpty()) {
  %>
  
  <div class="formulario">
    <form method="GET">
      <div class="form-group">
        <label>Seu NIF</label>
        <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9"
               placeholder="Digite seu NIF para ver seus animais" required>
      </div>
      <button type="submit" class="btn btn-primary">Consultar</button>
    </form>
  </div>
  
  <%
  } else {
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
          Connection con = manipula.getLigacao();
          
          if (idFichaParam == null) {
  %>
  
  <div class="readonly-notice">
    📖 <span>Estás a visualizar as fichas dos teus animais (somente leitura)</span>
  </div>
  
  <div class="animals-grid">
  <%
              PreparedStatement psAnimais = con.prepareStatement(
                  "SELECT f.idFichaClin, f.nome, f.dataNasc, f.dataFalecimento, r.nomeRaca, e.nomeComum AS especie " +
                  "FROM fichaClinicaAnimal f " +
                  "JOIN tutor t ON t.idFichaClin = f.idFichaClin " +
                  "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
                  "LEFT JOIN raca r ON r.nomeRaca = fr.nomeRaca " +
                  "LEFT JOIN especie e ON e.nomeComum = r.nomeComum " +
                  "WHERE t.NIF=? ORDER BY f.nome"
              );
              psAnimais.setString(1, nif);
              ResultSet rsAnimais = psAnimais.executeQuery();
              
              boolean temAnimais = false;
              while (rsAnimais.next()) {
                  temAnimais = true;
                  int idFicha = rsAnimais.getInt("idFichaClin");
                  String nome = rsAnimais.getString("nome");
                  String especie = rsAnimais.getString("especie");
                  
                  java.sql.Date dataNasc = rsAnimais.getDate("dataNasc");
                  java.sql.Date dataFal = rsAnimais.getDate("dataFalecimento");

                  boolean falecido = (dataFal != null);

                  int idade = 0;
                  if (dataNasc != null) {
                      LocalDate nascimento = dataNasc.toLocalDate();
                      idade = Period.between(nascimento, LocalDate.now()).getYears();
                  }
  %>
    <a href="?nif=<%= nif %>&idFichaClin=<%= idFicha %>" 
       class="animal-card <%= falecido ? "falecido" : "" %>">
       
      <% if(falecido) { %>
        <div class="falecido-badge">FALECIDO</div>
      <% } %>

      <div class="animal-header">
        <img src="../fotoAnimal?id=<%= idFicha %>" class="animal-photo" alt="<%= nome %>">
        <div>
          <h3 class="animal-name"><%= nome %></h3>
          <div class="animal-info">
            <%= especie != null ? especie : "Animal" %> | <%= idade %> <%= idade == 1 ? "ano" : "anos" %>
            <% if(falecido) { %>
              <span style="color:#D72638; font-weight:900;"> | <%= dataFal.toString() %></span>
            <% } %>
          </div>
        </div>
      </div>

      <div style="text-align: center; padding-top: 8px; color: #0B2A42; font-weight: 800; font-size: 13px;">
        <img src="../images/icon-eye.png" alt="Ver" class="icon-inline">Ver Ficha Completa
      </div>

    </a>
  <%
              }

              if (!temAnimais) {
  %>
    <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #57606F; font-weight: 700;">
      📭 Não foram encontrados animais registados com este NIF
    </div>
  <%
              }
              
              rsAnimais.close();
              psAnimais.close();
  %>
  </div>

  <%
          } else {
              int idFicha = Integer.parseInt(idFichaParam);
              
              PreparedStatement psFicha = con.prepareStatement(
                  "SELECT f.*, r.nomeRaca, e.nomeComum AS especie, " +
                  "cf.cores, cf.outrasDistint, cf.peso as pesoAtual, c.nomeCompleto AS tutor " +
                  "FROM fichaClinicaAnimal f " +
                  "JOIN tutor t ON t.idFichaClin = f.idFichaClin " +
                  "JOIN cliente c ON c.NIF = t.NIF " +
                  "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
                  "LEFT JOIN raca r ON r.nomeRaca = fr.nomeRaca " +
                  "LEFT JOIN especie e ON e.nomeComum = r.nomeComum " +
                  "LEFT JOIN caracteristicasFic cf ON cf.idFicha = f.idFichaClin " +
                  "WHERE f.idFichaClin=? AND t.NIF=?"
              );
              psFicha.setInt(1, idFicha);
              psFicha.setString(2, nif);
              ResultSet rsFicha = psFicha.executeQuery();
              
              if (rsFicha.next()) {
                  String nome = rsFicha.getString("nome");
                  String sexo = rsFicha.getString("sexo");
                  java.sql.Date dataNasc = rsFicha.getDate("dataNasc");
                  java.sql.Date dataFal = rsFicha.getDate("dataFalecimento");

                  boolean falecido = (dataFal != null);

                  String raca = rsFicha.getString("nomeRaca");
                  String especie = rsFicha.getString("especie");
                  String estadoReprod = rsFicha.getString("estadoReprod");
                  String alergias = rsFicha.getString("alergias");
                  String cores = rsFicha.getString("cores");
                  String outrasDistint = rsFicha.getString("outrasDistint");
                  String tutor = rsFicha.getString("tutor");
                  double pesoAtual = rsFicha.getDouble("pesoAtual");
                  
                  int idade = 0;
                  if (dataNasc != null) {
                      LocalDate nascimento = dataNasc.toLocalDate();
                      idade = Period.between(nascimento, LocalDate.now()).getYears();
                  }
  %>

  <div class="readonly-notice">
    📖 <span>Ficha clínica de <strong><%= nome %></strong> (somente leitura)</span>
  </div>
  
  <div class="ficha-content <%= falecido ? "falecido" : "" %>">

    <% if(falecido) { %>
      <div class="falecido-big">
        <span>Este animal está marcado como <strong>FALECIDO</strong> — <%= dataFal.toString() %></span>
      </div>
    <% } %>

    <div style="text-align: center; margin-bottom: 30px;">
      <img src="../fotoAnimal?id=<%= idFicha %>" 
           style="width: 200px; height: 200px; object-fit: cover; border-radius: 20px; border: 4px solid #E7EEF4; box-shadow: 0 8px 20px rgba(0,0,0,0.15);"
           alt="<%= nome %>">
      <h2 style="margin: 16px 0 4px 0; font-size: 32px; font-weight: 900; color: #0B2A42;"><%= nome %></h2>
      <p style="margin: 0; color: #57606F; font-weight: 700; font-size: 16px;">
        ID: #<%= idFicha %> | <%= especie != null ? especie : "Animal" %>
        <% if(falecido) { %>
          <span style="color:#D72638; font-weight:900;"> | Falecido</span>
        <% } %>
      </p>
    </div>

    <h3 class="section-title">Informações Básicas</h3>
    <div class="info-grid">
      <div class="info-item">
        <div class="info-label">Sexo</div>
        <div class="info-value">
          <% if ("M".equals(sexo)) { %>
            <img src="../images/icon-male.png" alt="Macho" class="icon-gender">Macho
          <% } else if ("F".equals(sexo)) { %>
            <img src="../images/icon-female.png" alt="Fêmea" class="icon-gender">Fêmea
          <% } else { %>
            ⚧️ Não aplicável
          <% } %>
        </div>
      </div>

      <div class="info-item">
        <div class="info-label">Idade</div>
        <div class="info-value">
          <%= idade %> <%= idade == 1 ? "ano" : "anos" %>
          <% if(falecido) { %>
            <span style="color:#D72638; font-weight:900; font-size:13px;"> (falecido)</span>
          <% } %>
        </div>
      </div>

      <div class="info-item">
        <div class="info-label">Raça</div>
        <div class="info-value"><%= raca != null ? raca : "N/D" %></div>
      </div>

      <div class="info-item">
        <div class="info-label">Peso Atual</div>
        <div class="info-value"><%= pesoAtual > 0 ? String.format("%.2f kg", pesoAtual) : "N/D" %></div>
      </div>

      <div class="info-item">
        <div class="info-label">Estado Reprodutivo</div>
        <div class="info-value"><%= estadoReprod != null ? estadoReprod : "N/D" %></div>
      </div>

      <div class="info-item">
        <div class="info-label">Tutor</div>
        <div class="info-value"><%= tutor %></div>
      </div>
    </div>

    <% if (cores != null && !cores.trim().isEmpty() && !cores.equalsIgnoreCase("N/A")) { %>
    <h3 class="section-title">Características</h3>

    <div class="info-item" style="margin-bottom: 16px;">
      <div class="info-label">Cores</div>

      <div class="color-tags">
        <%
          String[] listaCores = cores.split(",");
          for (String cor : listaCores) {
            cor = cor.trim();

            String corCss = "#CCCCCC"; // default

            if (cor.equalsIgnoreCase("Preto")) corCss = "#111111";
            else if (cor.equalsIgnoreCase("Branco")) corCss = "#FFFFFF";
            else if (cor.equalsIgnoreCase("Castanho")) corCss = "#8B5A2B";
            else if (cor.equalsIgnoreCase("Laranja")) corCss = "#F2994A";
            else if (cor.equalsIgnoreCase("Cinza") || cor.equalsIgnoreCase("Cinzento")) corCss = "#BDBDBD";
            else if (cor.equalsIgnoreCase("Bege")) corCss = "#F2CBA4";
            else if (cor.equalsIgnoreCase("Amarelo")) corCss = "#F2C94C";
            else if (cor.equalsIgnoreCase("Tigrado")) 
              corCss = "repeating-linear-gradient(45deg, #8B5A2B, #8B5A2B 6px, #F2994A 6px, #F2994A 12px)";
            else if (cor.equalsIgnoreCase("Malhado")) 
              corCss = "radial-gradient(circle, #111 25%, transparent 26%), radial-gradient(circle, #111 25%, transparent 26%)";
        %>

        <div class="color-tag">
          <div class="color-dot"
               style="background: <%= corCss %>;
                      border: 2px solid <%= cor.equalsIgnoreCase("Branco") ? "#999" : "rgba(0,0,0,0.2)" %>;">
          </div>
          <%= cor %>
        </div>

        <%
          }
        %>
      </div>
    </div>
    <% } %>

    <% if (outrasDistint != null && !outrasDistint.equals("N/A") && !outrasDistint.trim().isEmpty()) { %>
    <div class="info-item" style="margin-bottom: 16px;">
      <div class="info-label">Outras Características</div>
      <div class="info-value"><%= outrasDistint %></div>
    </div>
    <% } %>
    
    <% if (alergias != null && !alergias.trim().isEmpty()) { %>
    <h3 class="section-title">⚠️ Alergias</h3>
    <div class="info-item" style="margin-bottom: 16px;">
      <div class="info-value" style="color: #EB5757;"><%= alergias %></div>
    </div>
    <% } %>
    
    <div style="margin-top: 30px; text-align: center;">
      <a href="?nif=<%= nif %>" class="btn btn-secondary">← Voltar aos Meus Animais</a>
    </div>
  </div>

  <%
              } else {
  %>
    <div class="mensagem erro">❌ Animal não encontrado ou não pertence a este NIF</div>
  <%
              }
              
              rsFicha.close();
              psFicha.close();
          }
          
      } catch (Exception e) {
  %>
    <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
  <%
          e.printStackTrace();
      } finally {
          manipula.desligar();
      }
  }
  %>
  
</div>

</body>
</html>
