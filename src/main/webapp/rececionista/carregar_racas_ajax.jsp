<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, org.json.*" %>
<%
response.setContentType("application/json");
String especie = request.getParameter("especie");

JSONArray result = new JSONArray();

if (especie != null && !especie.isEmpty()) {
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        String sql = "SELECT nomeRaca FROM raca WHERE nomeComum = ? ORDER BY nomeRaca";
        
        Connection con = manipula.getLigacao();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, especie);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            JSONObject raca = new JSONObject();
            raca.put("nomeRaca", rs.getString("nomeRaca"));
            result.put(raca);
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
