<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt" style="height: 100%;">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tutores com Animais com Excesso de Peso - VetCare</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">

  <style>
    html, body { height: 100%; margin: 0; padding: 0; }
    body { display: flex; flex-direction: column; min-height: 100vh; }
    .page-content { flex: 1; }

    .tutor-row {
      cursor: pointer;
      transition: 0.2s;
    }
    .tutor-row:hover {
      background: #EAF6FB;
    }

    .badge-count {
      display: inline-block;
      padding: 6px 12px;
      border-radius: 999px;
      background: #DC3545;
      color: white;
      font-weight: 900;
      font-size: 13px;
    }

    .expand-row td {
      padding: 0 !important;
      background: #F8FAFC;
    }

    .expand-content {
      padding: 18px 22px;
      border-top: 1px solid #DDE6EE;
    }

    .animals-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 16px;
      margin-top: 14px;
    }

    .animal-card {
      background: white;
      border: 1px solid #E7EEF4;
      border-radius: 18px 6px 18px 6px;
      padding: 16px;
      display: flex;
      gap: 14px;
      align-items: flex-start;
      box-shadow: 0 3px 10px rgba(0,0,0,0.06);
      transition: 0.2s;
      position: relative;
    }

    .animal-card:hover {
      transform: translateY(-3px);
      box-shadow: 0 8px 18px rgba(0,0,0,0.10);
      border-color: #0B2A42;
    }

    .animal-card.falecido {
      background: #F1F3F5;
      border-color: #B0B7C3;
      opacity: 0.85;
      filter: grayscale(0.7);
    }

    .animal-card.falecido:hover {
      transform: none;
      box-shadow: 0 3px 10px rgba(0,0,0,0.06);
      border-color: #B0B7C3;
    }

    .falecido-badge {
      position: absolute;
      top: 12px;
      right: 12px;
      background: #D72638;
      color: white;
      padding: 6px 10px;
      border-radius: 999px;
      font-size: 11px;
      font-weight: 900;
      display: flex;
      align-items: center;
      gap: 6px;
      box-shadow: 0 3px 10px rgba(0,0,0,0.15);
    }

    .animal-photo {
      width: 70px;
      height: 70px;
      border-radius: 14px;
      object-fit: cover;
      border: 2px solid #E7EEF4;
      flex-shrink: 0;
      background: linear-gradient(135deg,#f5f7fa,#c3cfe2);
    }

    .animal-info {
      flex: 1;
      min-width: 0;
    }

    .animal-name {
      font-size: 17px;
      font-weight: 900;
      color: #0B2A42;
      margin: 0 0 4px 0;
    }

    .animal-sub {
      font-size: 13px;
      font-weight: 700;
      color: #57606F;
      margin-bottom: 10px;
    }

    .animal-stats {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
    }

    .mini-stat {
      background: #F1F5F8;
      border-radius: 12px;
      padding: 10px;
      border: 1px solid #E7EEF4;
    }

    .mini-label {
      font-size: 10px;
      font-weight: 900;
      color: #57606F;
      text-transform: uppercase;
      margin-bottom: 4px;
      letter-spacing: 0.4px;
    }

    .mini-value {
      font-size: 14px;
      font-weight: 900;
      color: #0B2A42;
    }

    .excesso {
      color: #DC3545;
      font-weight: 900;
    }

    .toggle-arrow {
      font-weight: 900;
      margin-right: 8px;
      color: #0B2A42;
    }

    @media (max-width: 700px) {
      .animals-grid { grid-template-columns: 1fr; }
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
      <a href="menu.jsp">Gerente</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Tutores com Animais com Excesso de Peso</h1>
    <p>Clica num tutor para ver os animais com excesso (com foto e detalhes).</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

<%
  Configura cfg = new Configura();
  Manipula manipula = new Manipula(cfg);

  Map<String, List<Map<String, Object>>> tutorAnimais = new LinkedHashMap<>();
  Map<String, Map<String, Object>> tutorInfo = new LinkedHashMap<>();

  try {
    String sql =
      "SELECT c.NIF AS nifTutor, c.nomeCompleto AS tutor, " +
      "       f.idFichaClin, f.nome AS nomeAnimal, f.dataFalecimento, " +
      "       r.nomeRaca, r.pesoAdlt, " +
      "       cf.peso AS pesoAtual, " +
      "       ROUND(((cf.peso - r.pesoAdlt) / r.pesoAdlt) * 100, 2) AS excesso " +
      "FROM fichaClinicaAnimal f " +
      "JOIN tutor t ON t.idFichaClin = f.idFichaClin " +
      "JOIN cliente c ON c.NIF = t.NIF " +
      "LEFT JOIN fichaRaca fr ON fr.idFichaClin = f.idFichaClin " +
      "LEFT JOIN raca r ON r.nomeRaca = fr.nomeRaca " +
      "LEFT JOIN caracteristicasFic cf ON cf.idFicha = f.idFichaClin " +
      "WHERE r.pesoAdlt IS NOT NULL " +
      "  AND cf.peso IS NOT NULL " +
      "  AND cf.peso > r.pesoAdlt " +
      "ORDER BY c.nomeCompleto ASC, f.nome ASC";

    Connection con = manipula.getLigacao();
    PreparedStatement ps = con.prepareStatement(sql);
    ResultSet rs = ps.executeQuery();

    while(rs.next()){
      String nif = rs.getString("nifTutor");
      String tutor = rs.getString("tutor");

      tutorInfo.putIfAbsent(nif, new HashMap<>());
      tutorInfo.get(nif).put("nome", tutor);
      tutorInfo.get(nif).put("nif", nif);

      tutorAnimais.putIfAbsent(nif, new ArrayList<>());

      Map<String, Object> animal = new HashMap<>();
      animal.put("idFichaClin", rs.getInt("idFichaClin"));
      animal.put("nomeAnimal", rs.getString("nomeAnimal"));
      animal.put("nomeRaca", rs.getString("nomeRaca"));
      animal.put("pesoAtual", rs.getDouble("pesoAtual"));
      animal.put("pesoIdeal", rs.getDouble("pesoAdlt"));
      animal.put("excesso", rs.getDouble("excesso"));
      animal.put("dataFalecimento", rs.getDate("dataFalecimento"));

      tutorAnimais.get(nif).add(animal);
    }

    rs.close();
    ps.close();

  } catch(Exception e) {
%>
    <div class="mensagem erro">❌ Erro ao carregar dados: <%= e.getMessage() %></div>
<%
    e.printStackTrace();
  } finally {
    manipula.desligar();
  }

  if(tutorAnimais.isEmpty()){
%>
    <div class="mensagem aviso" style="margin-top:20px;">
      🔭 Nenhum tutor com animais acima do peso adulto encontrado.
    </div>
<%
  } else {
%>

  <div class="table-card" style="margin-top:22px;">
    <table class="tabela">
      <thead>
        <tr>
          <th>Tutor</th>
          <th>NIF</th>
          <th>Animais com excesso</th>
        </tr>
      </thead>
      <tbody>

<%
    for(String nif : tutorAnimais.keySet()){
      Map<String,Object> info = tutorInfo.get(nif);
      List<Map<String,Object>> lista = tutorAnimais.get(nif);
      int total = lista.size();
%>

        <tr class="tutor-row" onclick="toggleExpand('<%= nif %>')">
          <td>
            <span class="toggle-arrow" id="arrow-<%= nif %>">▶</span>
            <strong><%= info.get("nome") %></strong>
          </td>
          <td><%= info.get("nif") %></td>
          <td><span class="badge-count"><%= total %></span></td>
        </tr>

        <tr class="expand-row" id="expand-<%= nif %>" style="display:none;">
          <td colspan="3">
            <div class="expand-content">
              <strong style="color:#0B2A42; font-weight:900;">Animais com excesso de peso</strong>

              <div class="animals-grid">

              <%
                for(Map<String,Object> a : lista){
                  int idFicha = (Integer) a.get("idFichaClin");
                  String nomeAnimal = (String) a.get("nomeAnimal");
                  String nomeRaca = (String) a.get("nomeRaca");
                  double pesoAtual = (Double) a.get("pesoAtual");
                  double pesoIdeal = (Double) a.get("pesoIdeal");
                  double excesso = (Double) a.get("excesso");
                  java.sql.Date dataFalecimento = (java.sql.Date) a.get("dataFalecimento");

                  boolean falecido = (dataFalecimento != null);
              %>

                <div class="animal-card <%= falecido ? "falecido" : "" %>">

                  <% if(falecido) { %>
                    <div class="falecido-badge">
                      FALECIDO (<%= dataFalecimento.toString() %>)
                    </div>
                  <% } %>

                  <img src="../fotoAnimal?id=<%= idFicha %>" class="animal-photo" alt="Foto">

                  <div class="animal-info">
                    <div class="animal-name"><%= nomeAnimal %></div>
                    <div class="animal-sub">
                      ID #<%= idFicha %>
                      <% if(nomeRaca != null) { %> | <%= nomeRaca %><% } %>
                    </div>

                    <div class="animal-stats">
                      <div class="mini-stat">
                        <div class="mini-label">Peso Atual</div>
                        <div class="mini-value"><%= String.format("%.2f kg", pesoAtual) %></div>
                      </div>

                      <div class="mini-stat">
                        <div class="mini-label">Peso Ideal</div>
                        <div class="mini-value"><%= String.format("%.2f kg", pesoIdeal) %></div>
                      </div>

                      <div class="mini-stat" style="grid-column: 1 / -1;">
                        <div class="mini-label">Excesso</div>
                        <div class="mini-value excesso">+<%= String.format("%.1f", excesso) %>%</div>
                      </div>
                    </div>

                  </div>
                </div>

              <%
                }
              %>

              </div>
            </div>
          </td>
        </tr>

<%
    }
%>

      </tbody>
    </table>
  </div>

<%
  }
%>

</div>

<script>
function toggleExpand(nif) {
  const row = document.getElementById("expand-" + nif);
  const arrow = document.getElementById("arrow-" + nif);

  if (!row) return;

  if (row.style.display === "none") {
    row.style.display = "table-row";
    arrow.textContent = "▼";
  } else {
    row.style.display = "none";
    arrow.textContent = "▶";
  }
}
</script>

</body>
</html>
