<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, org.json.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Exportar Dados</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📤 Exportar Dados</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
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
            
            <div class="info-card">
                <h3>📋 Exportar Ficha Clínica</h3>
                <p>Selecione o formato e o ID da ficha clínica para exportar.</p>
            </div>
            
            <form method="GET" class="formulario">
                <div class="form-group">
                    <label>ID da Ficha Clínica *</label>
                    <input type="number" name="idFicha" required>
                </div>
                
                <div class="form-group">
                    <label>Formato *</label>
                    <select name="formato" required>
                        <option value="">Selecione...</option>
                        <option value="json">JSON</option>
                        <option value="xml">XML</option>
                    </select>
                </div>
                
                <button type="submit" class="btn btn-primary">📥 Exportar</button>
            </form>
        </div>
    </div>
</body>
</html>
