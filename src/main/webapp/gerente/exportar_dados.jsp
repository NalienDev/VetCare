<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, org.json.*" %>
<!DOCTYPE html>
<html lang="pt" style="height: 100%;">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Exportar Dados - VetCare</title>
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

<%
String formato = request.getParameter("formato");
String idFicha = request.getParameter("idFicha");

if (formato != null && idFicha != null) {
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
            if ("json".equals(formato)) {
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
                response.setHeader("Content-Disposition", "attachment; filename=ficha_" + idFicha + ".json");
                out.print(json.toString(2));
                return;
                
            } else if ("xml".equals(formato)) {
                response.setContentType("application/xml");
                response.setHeader("Content-Disposition", "attachment; filename=ficha_" + idFicha + ".xml");
                
                out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
                out.println("<FichaClinica>");
                out.println("  <id>" + rs.getInt("idFichaClin") + "</id>");
                out.println("  <nome>" + rs.getString("nome") + "</nome>");
                out.println("  <sexo>" + rs.getString("sexo") + "</sexo>");
                out.println("  <dataNascimento>" + rs.getDate("dataNasc") + "</dataNascimento>");
                out.println("  <raca>" + rs.getString("nomeRaca") + "</raca>");
                out.println("  <estadoReprodutivo>" + rs.getString("estadoReprod") + "</estadoReprodutivo>");
                out.println("  <filiacao>" + rs.getString("filiacao") + "</filiacao>");
                out.println("  <alergias>" + (rs.getString("alergias") != null ? rs.getString("alergias") : "") + "</alergias>");
                out.println("</FichaClinica>");
                return;
            }
        }
        
        rs.close();
        ps.close();
    } finally {
        manipula.desligar();
    }
}
%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>📤 Exportar Dados</h1>
    <p>Exportar fichas clínicas para JSON ou XML.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <div class="info-box">
    <h3>📋 Exportar Ficha Clínica</h3>
    <p>Selecione o formato e o ID da ficha clínica para exportar os dados.</p>
  </div>

  <form method="GET" class="formulario">
    <div class="form-group">
      <label>ID da Ficha Clínica *</label>
      <input type="number" name="idFicha" min="1" placeholder="Ex: 1" required>
      <small style="color: #666; font-size: 12px; display: block; margin-top: 5px;">
        Digite o ID da ficha clínica que deseja exportar
      </small>
    </div>
    
    <div class="form-group">
      <label>Formato *</label>
      <select name="formato" required>
        <option value="">Selecione o formato...</option>
        <option value="json">📄 JSON (JavaScript Object Notation)</option>
        <option value="xml">📄 XML (eXtensible Markup Language)</option>
      </select>
    </div>
    
    <div class="form-actions">
      <button type="submit" class="btn btn-primary">📥 Exportar Ficheiro</button>
      <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
    </div>
  </form>

  <div class="info-box" style="margin-top: 30px; background: #FFF3CD; border-left-color: #FFC107;">
    <h3>💡 Informação</h3>
    <p><strong>JSON:</strong> Formato ideal para integração com sistemas web e aplicações modernas.</p>
    <p><strong>XML:</strong> Formato universal compatível com sistemas legados e enterprise.</p>
  </div>
</div>

</body>
</html>