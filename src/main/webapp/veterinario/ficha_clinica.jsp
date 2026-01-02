<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.time.*, java.time.temporal.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Ficha Clínica</title>
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
    .cores-display {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      margin-top: 8px;
    }
    .cor-bolinha {
      width: 30px;
      height: 30px;
      border-radius: 50%;
      border: 2px solid #fff;
      box-shadow: 0 2px 4px rgba(0,0,0,0.2);
      position: relative;
    }
    .cor-bolinha::after {
      content: attr(data-cor);
      position: absolute;
      bottom: -25px;
      left: 50%;
      transform: translateX(-50%);
      font-size: 10px;
      white-space: nowrap;
      color: #57606F;
      font-weight: 600;
    }
    .peso-form {
      margin-top: 10px;
      display: flex;
      gap: 10px;
      align-items: center;
      flex-wrap: wrap;
    }
    .peso-form input {
      max-width: 150px;
      padding: 8px 12px;
      border: 1px solid #DFE4EA;
      border-radius: 10px;
      font-weight: 700;
    }
    .peso-form button {
      padding: 8px 16px;
      border: none;
      background: #0B2A42;
      color: white;
      border-radius: 10px;
      font-weight: 800;
      cursor: pointer;
      transition: 0.2s;
    }
    .peso-form button:hover {
      background: #164164;
    }
    .mensagem-peso {
      margin-top: 10px;
      padding: 10px 14px;
      border-radius: 10px;
      font-weight: 700;
      font-size: 13px;
    }
    .mensagem-peso.sucesso {
      background: #D4EDDA;
      color: #155724;
    }
    @media(max-width: 900px) {
      .ficha-container {
        flex-direction: column;
      }
      .ficha-foto {
        flex: 1;
      }
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

String mensagemPeso = "";

try {
    Connection con = manipula.getLigacao();

    // ============================
    // ATUALIZAR PESO ATUAL
    // ============================
    String acao = request.getParameter("acao");
    if ("atualizarPeso".equals(acao) && "POST".equalsIgnoreCase(request.getMethod())) {
        String novoPesoParam = request.getParameter("novoPeso");
        if (novoPesoParam != null && !novoPesoParam.trim().isEmpty()) {
            try {
                double novoPeso = Double.parseDouble(novoPesoParam.replace(",", "."));
                
                // ✅ Verifica se já existe registo em caracteristicasFic
                PreparedStatement psCheck = con.prepareStatement(
                    "SELECT idFicha FROM caracteristicasFic WHERE idFicha = ?"
                );
                psCheck.setInt(1, idFicha);
                ResultSet rsCheck = psCheck.executeQuery();
                
                if (rsCheck.next()) {
                    // ✅ Existe: UPDATE
                    PreparedStatement psUpdate = con.prepareStatement(
                        "UPDATE caracteristicasFic SET peso = ? WHERE idFicha = ?"
                    );
                    psUpdate.setDouble(1, novoPeso);
                    psUpdate.setInt(2, idFicha);
                    psUpdate.executeUpdate();
                    psUpdate.close();
                    mensagemPeso = "✅ Peso atualizado com sucesso!";
                } else {
                    // ✅ Não existe: INSERT (precisa de cores, foto e outrasDistint)
                    PreparedStatement psInsert = con.prepareStatement(
                        "INSERT INTO caracteristicasFic (idFicha, cores, fotografia, peso, outrasDistint) " +
                        "VALUES (?, 'N/A', '', ?, 'N/A')"
                    );
                    psInsert.setInt(1, idFicha);
                    psInsert.setDouble(2, novoPeso);
                    psInsert.executeUpdate();
                    psInsert.close();
                    mensagemPeso = "✅ Peso registado com sucesso!";
                }
                
                rsCheck.close();
                psCheck.close();
                
            } catch (NumberFormatException ex) {
                mensagemPeso = "❌ Peso inválido. Use formato: 5.5 ou 5,5";
            } catch (Exception ex) {
                mensagemPeso = "❌ Erro ao atualizar peso: " + ex.getMessage();
            }
        }
    }

    String sql = 
        "SELECT f.*, r.nomeRaca, e.nomeComum AS especie, " +
        "       r.expectativaVida, r.pesoAdlt, r.porte, cf.peso AS pesoAtual, " +
        "       c.nomeCompleto AS tutor, c.contactos, " +
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
        String tutor = rs.getString("tutor");
        String estadoReprod = rs.getString("estadoReprod");
        String alergias = rs.getString("alergias");
        int expectativaVida = rs.getInt("expectativaVida");
        String nTransponder = rs.getString("nTransponder");
        String cores = rs.getString("cores");
        String outrasDistint = rs.getString("outrasDistint");

        LocalDate nascimento = dataNasc.toLocalDate();
        LocalDate hoje = LocalDate.now();

        LocalDate referencia = (dataFal != null) ? dataFal.toLocalDate() : hoje;
        Period periodo = Period.between(nascimento, referencia);

        int anos = periodo.getYears();
        int meses = periodo.getMonths();
        int dias = periodo.getDays();
        long totalDias = ChronoUnit.DAYS.between(nascimento, referencia);
        long totalSemanas = totalDias / 7;

        String status = (dataFal != null) ? "Falecido" : "Vivo";

        String escalao = "";
        String classeEscalao = "";
        if (expectativaVida > 0) {
            double percentVida = (double) anos / expectativaVida * 100;
            if (anos < 1) {
                escalao = "Bebé";
                classeEscalao = "escalao-bebe";
            } else if (percentVida < 25) {
                escalao = "Jovem";
                classeEscalao = "escalao-jovem";
            } else if (percentVida < 75) {
                escalao = "Adulto";
                classeEscalao = "escalao-adulto";
            } else {
                escalao = "Idoso";
                classeEscalao = "escalao-idoso";
            }
        }

        Map<String, String> coresMapa = new HashMap<>();
        coresMapa.put("Preto", "#000000");
        coresMapa.put("Branco", "#FFFFFF");
        coresMapa.put("Castanho", "#8B4513");
        coresMapa.put("Dourado", "#FFD700");
        coresMapa.put("Cinzento", "#808080");
        coresMapa.put("Laranja", "#FFA500");
        coresMapa.put("Tigrado", "linear-gradient(45deg, #8B4513 25%, #D2691E 25%, #D2691E 50%, #8B4513 50%, #8B4513 75%, #D2691E 75%)");
        coresMapa.put("Malhado", "radial-gradient(circle, #000 30%, #fff 30%)");
        coresMapa.put("Tricolor", "linear-gradient(120deg, #000 33%, #fff 33% 66%, #8B4513 66%)");
%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Ficha Clínica: <%= nome %></h1>
    <p>ID: <%= idFicha %> | Tutor: <%= tutor %></p>
  </div>
</section>

<div class="page-content">
  <a href="pesquisar_animal.jsp" class="btn-voltar">← Voltar à Pesquisa</a>

  <div class="ficha-container">
    <div class="ficha-foto">
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
        <h3>📋 Informações Básicas</h3>
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
            <div class="info-value"><%= sexo.equals("M") ? "♂️ Macho" : "♀️ Fêmea" %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Data Nascimento</div>
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
          <% if (nTransponder != null && !nTransponder.isEmpty()) { %>
          <div class="info-item">
            <div class="info-label">Nº Transponder</div>
            <div class="info-value"><%= nTransponder %></div>
          </div>
          <% } %>
        </div>
      </div>

      <div class="info-section">
        <h3>⚖️ Peso Atual</h3>
        <div class="info-value" style="font-size: 24px; margin-bottom: 12px;">
          <%= (rs.getBigDecimal("pesoAtual") != null) ? rs.getBigDecimal("pesoAtual") + " kg" : "Não definido" %>
        </div>

        <!-- ✅ Form para atualizar peso -->
        <form method="POST" class="peso-form">
          <input type="hidden" name="idFichaClin" value="<%= idFicha %>">
          <input type="hidden" name="acao" value="atualizarPeso">
          <input type="number" step="0.01" min="0" name="novoPeso" placeholder="Novo peso (kg)" required>
          <button type="submit">💾 Guardar Peso</button>
        </form>

        <% if (!mensagemPeso.isEmpty()) { %>
        <div class="mensagem-peso sucesso"><%= mensagemPeso %></div>
        <% } %>
      </div>

      <div class="info-section">
        <h3>🎨 Cores e Características Físicas</h3>

        <div class="info-label" style="margin-bottom: 10px;">Cores do Animal</div>
        <div class="cores-display">
          <%
            if (cores != null && !cores.isEmpty() && !cores.equals("N/A")) {
              String[] listaCores = cores.split(",\\s*");
              for (String cor : listaCores) {
                String corStyle = coresMapa.get(cor);
                if (corStyle != null) {
                  if (corStyle.startsWith("linear") || corStyle.startsWith("radial")) {
          %>
                    <div class="cor-bolinha" style="background: <%= corStyle %>" data-cor="<%= cor %>"></div>
          <%
                  } else {
          %>
                    <div class="cor-bolinha" style="background-color: <%= corStyle %>; <%= cor.equals("Branco") ? "border: 2px solid #ddd;" : "" %>" data-cor="<%= cor %>"></div>
          <%
                  }
                }
              }
            } else {
          %>
            <span style="color: #57606F; font-weight: 600;">Não definido</span>
          <%
            }
          %>
        </div>

        <% if (outrasDistint != null && !outrasDistint.isEmpty() && !outrasDistint.equals("N/A")) { %>
        <div style="margin-top: 20px;">
          <div class="info-label">Outras Características</div>
          <div style="padding:12px; background:#F0F4F8; border-radius:10px; color:#0B2A42; font-weight:600;">
            <%= outrasDistint %>
          </div>
        </div>
        <% } %>
      </div>

      <div class="info-section">
        <h3>👤 Tutor</h3>
        <div class="info-grid">
          <div class="info-item">
            <div class="info-label">Nome Completo</div>
            <div class="info-value"><%= tutor %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Contacto</div>
            <div class="info-value"><%= rs.getString("contactos") != null ? rs.getString("contactos") : "-" %></div>
          </div>
        </div>
      </div>

      <div class="info-section">
        <h3>📏 Características da Raça</h3>
        <div class="info-grid">
          <div class="info-item">
            <div class="info-label">Porte</div>
            <div class="info-value"><%= rs.getString("porte") != null ? rs.getString("porte") : "-" %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Peso Adulto Ideal</div>
            <div class="info-value"><%= rs.getBigDecimal("pesoAdlt") != null ? rs.getBigDecimal("pesoAdlt") + " kg" : "-" %></div>
          </div>
          <div class="info-item">
            <div class="info-label">Expectativa de Vida</div>
            <div class="info-value"><%= expectativaVida > 0 ? expectativaVida + " anos" : "-" %></div>
          </div>
        </div>
      </div>

      <% if (alergias != null && !alergias.isEmpty()) { %>
      <div class="info-section">
        <h3>⚠️ Alergias</h3>
        <div style="padding:12px; background:#FFF3CD; border-radius:10px; color:#856404; font-weight:600;">
          <%= alergias %>
        </div>
      </div>
      <% } %>

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
