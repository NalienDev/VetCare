<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, org.json.*" %>
<%
String idFicha = request.getParameter("idFicha");

if (idFicha != null) {
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);

    try {
        String sql =
            "SELECT f.*, r.nomeRaca " +
            "FROM fichaClinicaAnimal f " +
            "INNER JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
            "INNER JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
            "WHERE f.idFichaClin = ?";

        Connection con = manipula.getLigacao();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, Integer.parseInt(idFicha));
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            JSONObject json = new JSONObject();
            json.put("idFichaClin", rs.getInt("idFichaClin"));
            json.put("nome", rs.getString("nome"));
            json.put("sexo", rs.getString("sexo"));
            json.put("dataNasc", rs.getDate("dataNasc").toString());
            json.put("raca", rs.getString("nomeRaca"));
            json.put("estadoReprod", rs.getString("estadoReprod"));
            json.put("filiacao", rs.getString("filiacao"));
            json.put("alergias", rs.getString("alergias"));

            response.setContentType("application/json");
            response.setHeader(
              "Content-Disposition",
              "attachment; filename=ficha_" + idFicha + ".json"
            );

            out.print(json.toString(2));
            return;
        }

        rs.close();
        ps.close();
    } finally {
        manipula.desligar();
    }
}
%>
<!DOCTYPE html>
<html lang="pt" style="height: 100%;">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Exportar Ficha Clínica (JSON) - VetCare</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  <style>
    html, body {
      height: 100%;
      margin: 0;
      padding: 0;
    }
    body {
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    .page-content {
      flex: 1;
    }
    .info-box {
      background: #E8F4F8;
      border-left: 4px solid #4A90E2;
      padding: 15px;
      margin: 20px 0;
      border-radius: 8px;
    }
    .info-box h3 {
      margin: 0 0 10px 0;
      color: #0B2A42;
      font-size: 16px;
    }
    .btn-voltar {
      margin-bottom: 30px;
    }
    .icon-inline {
      width: 18px;
      height: 18px;
      vertical-align: middle;
      margin-right: 5px;
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
    <h1>Exportar Ficha Clínica</h1>
    <p>Exportação de dados clínicos em formato JSON.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <div class="info-box">
    <h3><img src="../images/icon-download-b.png" alt="Clipboard" class="icon-inline">Exportar para JSON</h3>
    <p>
      Introduza o ID da ficha clínica para descarregar os dados
      num ficheiro <strong>JSON</strong>, pronto para integração
      com aplicações externas.
    </p>
  </div>

  <form method="GET" class="formulario">
    <div class="form-group">
      <label>ID da Ficha Clínica *</label>
      <input
        type="number"
        name="idFicha"
        min="1"
        placeholder="Ex: 1"
        required>
      <small style="color: #666; font-size: 12px; display: block; margin-top: 5px;">
        Identificador único da ficha clínica
      </small>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">
        <img src="../images/icon-download.png" alt="Exportar" class="icon-inline">Exportar JSON
      </button>
      <button type="reset" class="btn btn-secondary">
        <img src="../images/icon-reset.png" alt="Limpar" class="icon-inline">Limpar
      </button>
    </div>
  </form>

  <div class="info-box" style="margin-top: 30px; background: #FFF3CD; border-left-color: #FFC107;">
    <h3><img src="../images/icon-lightbulb.png" alt="Ideia" class="icon-inline">Nota</h3>
    <p>
      O formato <strong>JSON</strong> é ideal para consumo por APIs,
      aplicações web e sistemas de interoperabilidade.
    </p>
  </div>
</div>

</body>
</html>
