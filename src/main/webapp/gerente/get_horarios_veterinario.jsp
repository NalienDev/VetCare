<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<%
String nLicenca = request.getParameter("nLicenca");

if (nLicenca != null && !nLicenca.trim().isEmpty()) {
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        Connection con = manipula.getLigacao();
        
        String sql = 
            "SELECT e.localidade, e.diaUtil, h.horaInicio, h.horaFim " +
            "FROM escalado e " +
            "JOIN horario h ON h.localidade = e.localidade AND h.diaUtil = e.diaUtil " +
            "WHERE e.nLicenca = ? " +
            "ORDER BY FIELD(e.diaUtil, 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'), h.horaInicio";
        
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, nLicenca);
        ResultSet rs = ps.executeQuery();
        
        boolean temHorarios = false;
        StringBuilder sb = new StringBuilder();
        sb.append("<table style='width: 100%; border-collapse: collapse; margin-top: 10px;'>");
        sb.append("<thead>");
        sb.append("<tr style='background: #F8F9FA; border-bottom: 2px solid #DEE2E6;'>");
        sb.append("<th style='padding: 10px; text-align: left;'>Clínica</th>");
        sb.append("<th style='padding: 10px; text-align: left;'>Dia</th>");
        sb.append("<th style='padding: 10px; text-align: left;'>Horário</th>");
        sb.append("</tr>");
        sb.append("</thead>");
        sb.append("<tbody>");
        
        while (rs.next()) {
            temHorarios = true;
            String localidade = rs.getString("localidade");
            String diaUtil = rs.getString("diaUtil");
            java.sql.Time horaInicio = rs.getTime("horaInicio");
            java.sql.Time horaFim = rs.getTime("horaFim");
            
            sb.append("<tr style='border-bottom: 1px solid #DEE2E6;'>");
            sb.append("<td style='padding: 10px;'><strong>" + localidade + "</strong></td>");
            sb.append("<td style='padding: 10px;'>" + diaUtil + "-feira</td>");
            sb.append("<td style='padding: 10px;'>" + 
                     horaInicio.toString().substring(0, 5) + " - " + 
                     horaFim.toString().substring(0, 5) + "</td>");
            sb.append("</tr>");
        }
        
        sb.append("</tbody>");
        sb.append("</table>");
        
        rs.close();
        ps.close();
        
        if (temHorarios) {
            out.print("<p style='margin: 10px 0; color: #555;'>Este veterinário já está escalado nos seguintes horários:</p>");
            out.print(sb.toString());
        } else {
            out.print("<p style='margin: 10px 0; color: #555;'>Este veterinário ainda não tem horários atribuídos.</p>");
        }
        
    } catch (Exception e) {
        out.print("<p style='color: #DC3545;'>Erro ao carregar horários: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        manipula.desligar();
    }
}
%>
