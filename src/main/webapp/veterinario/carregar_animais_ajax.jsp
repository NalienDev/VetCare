<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<%
String nif = request.getParameter("nif");
if (nif == null || nif.trim().isEmpty()) {
    out.print("<div class='mensagem erro'>NIF inválido</div>");
    return;
}

Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

try {
    String sql = 
        "SELECT f.idFichaClin, f.nome, f.sexo, f.dataNasc, " +
        "       r.nomeRaca, e.nomeComum AS especie " +
        "FROM fichaClinicaAnimal f " +
        "INNER JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
        "INNER JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
        "INNER JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
        "INNER JOIN pertence p ON r.nomeRaca = p.nomeRaca " +
        "INNER JOIN especie e ON p.nomeComum = e.nomeComum " +
        "WHERE t.NIF = ?";
    
    Connection con = manipula.getLigacao();
    PreparedStatement ps = con.prepareStatement(sql);
    ps.setString(1, nif);
    ResultSet rs = ps.executeQuery();
    
    boolean temAnimais = false;
    
    while (rs.next()) {
        temAnimais = true;
        int idFicha = rs.getInt("idFichaClin");
        String nome = rs.getString("nome");
        String sexo = rs.getString("sexo");
        java.sql.Date dataNasc = rs.getDate("dataNasc");
        String raca = rs.getString("nomeRaca");
        String especie = rs.getString("especie");
        
        int idade = java.time.Period.between(
            dataNasc.toLocalDate(), 
            java.time.LocalDate.now()
        ).getYears();
        
        String genero = util.DataFormatter.obterGenero(sexo);
        %>
        
        <div class="ficha-animal">
            <div class="ficha-header">
                <div>
                    <h3><%= nome %> (<%= genero %>)</h3>
                    <p><strong>ID:</strong> <%= idFicha %></p>
                </div>
            </div>
            
            <div class="ficha-dados">
                <div class="dado-item">
                    <div class="dado-label">Espécie</div>
                    <%= especie %>
                </div>
                <div class="dado-item">
                    <div class="dado-label">Raça</div>
                    <%= raca %>
                </div>
                <div class="dado-item">
                    <div class="dado-label">Idade</div>
                    <%= idade %> <%= idade == 1 ? "ano" : "anos" %>
                </div>
                <div class="dado-item">
                    <div class="dado-label">Data Nascimento</div>
                    <%= util.DataFormatter.LocalDateToString(dataNasc.toLocalDate()) %>
                </div>
            </div>
            
            <div style="margin-top: 15px;">
                <a href="historico_clinico.jsp?id=<%= idFicha %>" class="btn btn-primary">
                    📋 Ver Histórico Completo
                </a>
            </div>
        </div>
        
        <%
    }
    
    if (!temAnimais) {
        %>
        <div class="mensagem aviso">
            ⚠️ Este tutor ainda não tem animais registados.
        </div>
        <%
    }
    
    rs.close();
    ps.close();
    
} catch (Exception e) {
    out.print("<div class='mensagem erro'>❌ Erro: " + e.getMessage() + "</div>");
    e.printStackTrace();
} finally {
    manipula.desligar();
}
%>
