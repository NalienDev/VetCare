<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Minhas Fichas Clínicas</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📄 Minhas Fichas Clínicas</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <div class="formulario">
                <form method="GET">
                    <div class="form-group">
                        <label>Seu NIF</label>
                        <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9" 
                               value="<%= request.getParameter("nif") != null ? request.getParameter("nif") : "" %>"
                               placeholder="Digite seu NIF" required>
                    </div>
                    <button type="submit" class="btn btn-primary">🔍 Consultar</button>
                </form>
            </div>
            
            <%
            String nif = request.getParameter("nif");
            if (nif != null && !nif.isEmpty()) {
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
                        "WHERE t.NIF = ? " +
                        "ORDER BY f.nome";
                    
                    Connection con = manipula.getLigacao();
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setString(1, nif);
                    ResultSet rs = ps.executeQuery();
                    
                    boolean temAnimais = false;
                    
                    while (rs.next()) {
                        temAnimais = true;
                        %>
                        <div class="animal-card" style="margin-top: 20px;">
                            <h3><%= rs.getString("nome") %></h3>
                            <p><strong>Raça:</strong> <%= rs.getString("nomeRaca") %> 
                               (<%= rs.getString("especie") %>)</p>
                            <p><strong>Idade:</strong> 
                               <%= java.time.Period.between(
                                   rs.getDate("dataNasc").toLocalDate(), 
                                   java.time.LocalDate.now()
                               ).getYears() %> anos</p>
                            <a href="../veterinario/historico_clinico.jsp?id=<%= rs.getInt("idFichaClin") %>" 
                               class="btn btn-primary">Ver Histórico</a>
                        </div>
                        <%
                    }
                    
                    if (!temAnimais) {
                        %>
                        <div class="mensagem aviso" style="margin-top: 20px;">
                            Nenhum animal encontrado para este NIF
                        </div>
                        <%
                    }
                    
                    rs.close();
                    ps.close();
                } finally {
                    manipula.desligar();
                }
            }
            %>
        </div>
    </div>
</body>
</html>
