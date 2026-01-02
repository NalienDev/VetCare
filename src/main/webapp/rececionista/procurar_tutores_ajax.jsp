<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, org.json.*" %>
<%
response.setContentType("application/json");
String query = request.getParameter("query");

JSONArray result = new JSONArray();

if (query != null && query.length() >= 2) {
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        String sql = "SELECT NIF, nomeCompleto FROM cliente WHERE nomeCompleto LIKE ? ORDER BY nomeCompleto LIMIT 10";
        
        Connection con = manipula.getLigacao();
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, "%" + query + "%");
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            JSONObject tutor = new JSONObject();
            tutor.put("nif", rs.getString("NIF"));
            tutor.put("nome", rs.getString("nomeCompleto"));
            result.put(tutor);
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
