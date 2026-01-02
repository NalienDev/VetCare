<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.time.*, java.time.temporal.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Ficha do Animal (Rececionista)</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">

  <style>
    .ficha-container {
      display: flex;
      gap: 30px;
      margin-top: 30px;
    }
    .ficha-foto {
      flex: 0 0 300px;
    }
    .ficha-foto img {
      width: 100%;
      height: 300px;
      object-fit: cover;
      border-radius: 24px 6px 24px 6px;
      box-shadow: 0px 4px 15px rgba(0,0,0,0.15);
      background: linear-gradient(135deg, #EAF6FB 0%, #A9D6B6 100%);
    }
    .ficha-dados {
      flex: 1;
    }
    .info-section {
      background: white;
      border: 1px solid #E7EEF4;
      border-radius: 24px 6px 24px 6px;
      padding: 22px;
      margin-bottom: 20px;
      box-shadow: 0px 2px 10px rgba(0,0,0,0.05);
    }
    .info-section h3 {
      margin: 0 0 16px 0;
      font-size: 18px;
      font-weight: 900;
      color: #0B2A42;
    }
    .info-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 14px;
    }
    .info-item {
      padding: 12px;
      background: #F0F4F8;
      border-radius: 10px;
    }
    .info-label {
      font-size: 11px;
      font-weight: 800;
      color: #57606F;
      text-transform: uppercase;
      margin-bottom: 6px;
    }
    .info-value {
      font-size: 14px;
      font-weight: 700;
      color: #0B2A42;
    }
    .idade-box {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 20px;
      border-radius: 20px;
      text-align: center;
      margin-top: 20px;
    }
    .idade-box .numero {
      font-size: 48px;
      font-weight: 900;
      line-height: 1;
    }
    .idade-box .unidade {
      font-size: 16px;
      font-weight: 600;
      opacity: 0.9;
    }
    .escalao-badge {
      display: inline-block;
      padding: 8px 16px;
      border-radius: 20px;
      font-weight: 800;
      font-size: 13px;
      margin-top: 10px;
    }
    .escalao-bebe { background: #FFE5B4; color: #8B4513; }
    .escalao-jovem { background: #D4EDDA; color: #155724; }
    .escalao-adulto { background: #CCE5FF; color: #004085; }
    .escalao-idoso { background: #F8D7DA; color: #721C24; }

    @media(max-width: 900px) {
      .ficha-container { flex-direction: column; }
      .ficha-foto { flex: 1; }
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
      <a href="menu.jsp">Rececionista</a>
    </nav>
  </div>
</header>

<%
String idParam = request.getParameter("idFichaClin");
if (idParam == null) {
    response.sendRedirect("listar_animais.jsp");
    return;
}

int idFicha = Integer.parseInt(idParam);
Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

String mensagem = "";
String tipoMensagem = "";

try {
    Connection con = manipula.getLigacao();

    // ===================================================
    // MARCAR FALECIMENTO (RECECIONISTA)
    // ===================================================
    String acao = request.getParameter("acao");
    if ("marcarFalecimento".equals(acao)) {
        String dataFal = request.getParameter("dataFalecimento");
        if (dataFal != null && !dataFal.trim().isEmpty()) {
            PreparedStatement psFal = con.prepareStatement(
                "UPDATE fichaClinicaAnimal SET dataFalecimento = ? WHERE idFichaClin = ?"
            );
            psFal.setDate(1, java.sql.Date.valueOf(dataFal));
            psFal.setInt(2, idFicha);
            psFal.executeUpdate();
            psFal.close();

            mensagem = "✅ Animal marcado como falecido com sucesso.";
            tipoMensagem = "sucesso";
        } else {
            mensagem = "❌ Tem de escolher uma data de falecimento.";
            tipoMensagem = "erro";
        }
    }

    // ===================================================
    // CARREGAR DADOS DO ANIMAL + TUTOR
    // ===================================================
    String sql =
        "SELECT f.*, r.nomeRaca, e.nomeComum AS especie, r.expectativaVida, " +
        "       c.NIF AS nifTutor, c.nomeCompleto AS tutor, c.contactos, " +
        "       c.arteria, c.numero, c.andar, c.distrito, c.concelho, c.freguesia, " +
        "       cf.cores, cf.outrasDistint " +
        "FROM fichaClinicaAnimal f " +
        "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
        "LEFT JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
        "LEFT JOIN especie e ON r.nomeComum = e.nomeComum " +
        "LEFT JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
        "LEFT JOIN cliente c ON t.NIF = c.NIF " +
        "LEFT JOIN caracteristicasFic cf ON f.idFichaClin = cf.idFicha " +
        "WHERE f.idFichaClin = ?";

    PreparedStatement ps = con.prepareStatement(sql);
    ps.setInt(1, idFicha);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {

        String nome = rs.getString("nome");
        String sexo = rs.getString("sexo");
        java.sql.Date dataNasc = rs.getDate("dataNasc");
        java.sql.Date dataFal = rs.getDate("dataFalecimento");

        String raca = rs.getString("nomeRaca");
        String especie = rs.getString("especie");
        String estadoReprod = rs.getString("estadoReprod");

        String nifTutor = rs.getString("nifTutor");
        String tutor = rs.getString("tutor");
        String contactos = rs.getString("contactos");

        String arteria = rs.getString("arteria");
        int numero = rs.getInt("numero");
        String andar = rs.getString("andar");
        String distrito = rs.getString("distrito");
        String concelho = rs.getString("concelho");
        String freguesia = rs.getString("freguesia");

        int expectativaVida = rs.getInt("expectativaVida");

        LocalDate nascimento = dataNasc.toLocalDate();
        LocalDate hoje = LocalDate.now();

        // ✅ idade com referência: hoje ou falecimento
        LocalDate referencia = (dataFal != null) ? dataFal.toLocalDate() : hoje;
        Period periodo = Period.between(nascimento, referencia);
        int anos = periodo.getYears();
        int meses = periodo.getMonths();
        int dias = periodo.getDays();
        long totalDias = ChronoUnit.DAYS.between(nascimento, referencia);
        long totalSemanas = totalDias / 7;

        // ✅ escalão etário
        String escalao = "";
        String classeEscalao = "";
        if (expectativaVida > 0) {
            double percentVida = (double) anos / expectativaVida * 100;
            if (anos < 1) {
                escalao = "Bebé"; classeEscalao = "escalao-bebe";
            } else if (percentVida < 25) {
                escalao = "Jovem"; classeEscalao = "escalao-jovem";
            } else if (percentVida < 75) {
                escalao = "Adulto"; classeEscalao = "escalao-adulto";
            } else {
                escalao = "Idoso"; classeEscalao = "escalao-idoso";
            }
        }

        String status = (dataFal != null) ? "Falecido" : "Vivo";
%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Ficha do Animal (Rececionista): <%= nome %></h1>
    <p>ID: <%= idFicha %> | Tutor: <%= tutor %></p>
  </div>
</section>

<div class="page-content">
  <a href="listar_animais.jsp" class="btn-voltar">← Voltar à Lista</a>

  <% if (!mensagem.isEmpty()) { %>
    <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <div class="ficha-container">

    <div class="ficha-foto">
      <!-- ✅ Foto sempre do servlet / BD -->
      <img src="../fotoAnimal?id=<%= idFicha %>" alt="<%= nome %>">

      <div class="idade-box">
        <div class="numero"><%= anos %></div>
        <div class="unidade"><%= anos == 1 ? "ANO" : "ANOS" %></div>

        <div style="font-size:13px; margin-top:8px; opacity:0.9;">
          <%= meses %> <%= meses == 1 ? "mês" : "meses" %>, <%= dias %> <%= dias == 1 ? "dia" : "dias" %>
        </div>
        <div style="font-size:12px; margin-top:5px; opacity:0.8;">
          <%= totalSemanas %> semanas | <%= totalDias %> dias
        </div>

        <% if (!escalao.isEmpty()) { %>
          <div class="escalao-badge <%= classeEscalao %>"><%= escalao %></div>
        <% } %>
      </div>
    </div>

    <div class="ficha-dados">

      <div class="info-section">
        <h3>📋 Dados do Animal</h3>
        <div class="info-grid">
          <div class="info-item">
            <div class="info-label">Nome</div>
            <div class="info-value"><%= nome %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Espécie</div>
            <div class="info-value"><%= especie != null ? especie : "-" %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Raça</div>
            <div class="info-value"><%= raca != null ? raca : "-" %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Sexo</div>
            <div class="info-value"><%= "M".equals(sexo) ? "🐕 Macho" : "🐕 Fêmea" %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Data de Nascimento</div>
            <div class="info-value"><%= util.DataFormatter.LocalDateToString(nascimento) %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Estado Reprodutivo</div>
            <div class="info-value"><%= estadoReprod %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Status</div>
            <div class="info-value">
              <%= status %>
              <% if (dataFal != null) { %>
                | <strong><%= util.DataFormatter.LocalDateToString(dataFal.toLocalDate()) %></strong>
              <% } %>
            </div>
          </div>
        </div>

        <div style="display:flex; gap:12px; margin-top:18px; flex-wrap:wrap;">
          <!-- ✅ Botão atualizar animal (deves ter/ criar a página) -->
          <a href="atualizar_animal.jsp?idFichaClin=<%= idFicha %>" class="btn btn-primary">
            ✏️ Atualizar Dados do Animal
          </a>
        </div>
      </div>

      <div class="info-section">
        <h3>👤 Tutor</h3>
        <div class="info-grid">
          <div class="info-item">
            <div class="info-label">NIF</div>
            <div class="info-value"><%= nifTutor != null ? nifTutor : "-" %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Nome Completo</div>
            <div class="info-value"><%= tutor != null ? tutor : "-" %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Contactos</div>
            <div class="info-value"><%= contactos != null ? contactos : "-" %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Morada</div>
            <div class="info-value">
              <%= arteria != null ? arteria : "-" %>, <%= numero %>
              <%= (andar != null && !andar.isEmpty()) ? (", " + andar) : "" %>
              <br>
              <%= (freguesia != null ? freguesia : "-") %>,
              <%= (concelho != null ? concelho : "-") %>,
              <%= (distrito != null ? distrito : "-") %>
            </div>
          </div>
        </div>

        <div style="display:flex; gap:12px; margin-top:18px; flex-wrap:wrap;">
          <!-- ✅ Botão atualizar tutor -->
          <a href="atualizar_tutor.jsp?NIF=<%= nifTutor %>&idFichaClin=<%= idFicha %>" class="btn btn-primary">
            ✏️ Atualizar Dados do Tutor
          </a>
        </div>
      </div>

      <!-- ✅ Marcar Falecimento -->
      <div class="info-section">
        <h3>⚠️ Falecimento</h3>

        <% if (dataFal == null) { %>
          <form method="POST" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
            <input type="hidden" name="idFichaClin" value="<%= idFicha %>">
            <input type="hidden" name="acao" value="marcarFalecimento">
            <input type="date" name="dataFalecimento" required max="<%= java.time.LocalDate.now() %>" style="max-width:220px;">
            <button type="submit" class="btn btn-primary">🐾 Animal faleceu</button>
          </form>
          <p style="margin-top:10px; color:#57606F; font-weight:600;">
            Após marcar falecimento, a idade passa a ser calculada com base na data de falecimento.
          </p>
        <% } else { %>
          <div class="mensagem erro">
            ⚠️ Este animal está marcado como falecido desde <strong><%= util.DataFormatter.LocalDateToString(dataFal.toLocalDate()) %></strong>.
          </div>
        <% } %>
      </div>

      <!-- ✅ Histórico (apenas consulta) -->
      <div style="display:flex; gap:14px; margin-top:20px; flex-wrap:wrap;">
        <a href="historico_clinico.jsp?idFichaClin=<%= idFicha %>" class="btn btn-primary">
          📋 Ver Histórico Clínico
        </a>
      </div>

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
    rs.close();
    ps.close();
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
