<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, org.json.*" %>
<%
response.setContentType("application/json");
String nif = request.getParameter("nif");

JSONArray result = new JSONArray();

if (nif != null && !nif.isEmpty()) {
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        String sql = 
            "SELECT f.idFichaClin, f.nome, f.sexo, f.dataNasc, " +
            "       r.nomeRaca, e.nomeComum AS especie, " +
            "       TIMESTAMPDIFF(YEAR, f.dataNasc, CURDATE()) AS idade " +
            "FROM fichaClinicaAnimal f " +
            "INNER JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
            "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
            "LEFT JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
            "LEFT JOIN especie e ON r.nomeComum = e.nomeComum " +
            "WHERE t.NIF = ? " +
            "ORDER BY f.nome";
        
        Connection con = manipula.getLigacao();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, nif);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            JSONObject animal = new JSONObject();
            animal.put("idFichaClin", rs.getInt("idFichaClin"));
            animal.put("nome", rs.getString("nome"));
            animal.put("sexo", rs.getString("sexo"));
            animal.put("raca", rs.getString("nomeRaca"));
            animal.put("especie", rs.getString("especie"));
            animal.put("idade", rs.getInt("idade"));
            result.put(animal);
        }
        
        rs.close();
        ps.close();
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        manipula.desligar();
    }
}

out.print(result.toString());
%>
