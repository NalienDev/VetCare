<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, org.json.*" %>

<%
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");

String termo = request.getParameter("termo");
if (termo == null || termo.trim().length() < 2) {
    out.print("[]");
    return;
}

Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

try {
    String sql = "SELECT c.NIF, c.nomeCompleto, COUNT(t.idFichaClin) as numAnimais " +
                 "FROM cliente c " +
                 "LEFT JOIN tutor t ON c.NIF = t.NIF " +
                 "WHERE c.nomeCompleto LIKE ? " +
                 "GROUP BY c.NIF, c.nomeCompleto " +
                 "ORDER BY c.nomeCompleto " +
                 "LIMIT 10";
    
    Connection con = manipula.getLigacao();
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, "%" + termo + "%");
    
    ResultSet rs = ps.executeQuery();
    
    org.json.JSONArray jsonArray = new org.json.JSONArray();
    
    while (rs.next()) {
        org.json.JSONObject obj = new org.json.JSONObject();
        obj.put("nif", rs.getString("NIF"));
        obj.put("nome", rs.getString("nomeCompleto"));
        obj.put("numAnimais", rs.getInt("numAnimais"));
        jsonArray.put(obj);
    }
    
    out.print(jsonArray.toString());
    
    rs.close();
    ps.close();
    
} catch (Exception e) {
    out.print("[]");
    e.printStackTrace();
} finally {
    manipula.desligar();
}
%>
