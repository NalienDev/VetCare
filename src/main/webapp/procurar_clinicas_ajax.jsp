<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, org.json.*" %>

<%
response.setContentType("application/json; charset=UTF-8");

String query = request.getParameter("query");
JSONArray result = new JSONArray();

Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

try {

    Connection con = manipula.getLigacao();

    String sql =
        "SELECT localidade, morada, codPostal, latitude, longitude " +
        "FROM clinica ";

    // ✅ Se existir query, aplica filtro
    if (query != null && !query.trim().isEmpty()) {
        sql += "WHERE localidade LIKE ? OR arteria LIKE ? ";
    }

    sql += "ORDER BY localidade LIMIT 10";

    PreparedStatement ps = con.prepareStatement(sql);

    if (query != null && !query.trim().isEmpty()) {
        String term = "%" + query.trim() + "%";
        ps.setString(1, term);
        ps.setString(2, term);
    }

    ResultSet rs = ps.executeQuery();

    while (rs.next()) {

        JSONObject clinica = new JSONObject();
        clinica.put("localidade", rs.getString("localidade"));
        clinica.put("morada", rs.getString("morada"));
        clinica.put("codPostal", rs.getString("codPostal"));

        clinica.put("lat", rs.getDouble("latitude"));
        clinica.put("lng", rs.getDouble("longitude"));

        result.put(clinica);
    }

    rs.close();
    ps.close();

} catch (Exception e) {
    e.printStackTrace();
} finally {
    manipula.desligar();
}

out.print(result.toString());
%>
