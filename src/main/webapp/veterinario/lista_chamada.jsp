<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Lista de Chamada</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📋 Lista de Chamada</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <div class="formulario">
                <h3>🔍 Filtrar por Veterinário</h3>
                <form method="GET">
                    <div class="form-group">
                        <label>Número de Licença</label>
                        <input type="text" name="nLicenca" required
                               value="<%= request.getParameter("nLicenca") != null ? request.getParameter("nLicenca") : "" %>">
                    </div>
                    <button type="submit" class="btn btn-primary">📋 Ver Lista</button>
                </form>
            </div>
            
            <%
            String nLicenca = request.getParameter("nLicenca");
            if (nLicenca != null && !nLicenca.isEmpty()) {
                Configura cfg = new Configura();
                Manipula manipula = new Manipula(cfg);
                
                try {
                    String sql = 
                        "SELECT a.idAgendamento, a.dtHrAgenda, a.tipoServ, " +
                        "       f.nome AS nomeAnimal, f.idFichaClin, " +
                        "       c.nomeCompleto AS tutor, c.contactos " +
                        "FROM agendamento a " +
                        "INNER JOIN solicita sol ON a.idAgendamento = sol.idAgendamento " +
                        "INNER JOIN servicoVet sv ON sol.idServico = sv.idServico " +
                        "INNER JOIN supervisiona sup ON sv.idServico = sup.idServico " +
                        "INNER JOIN fichaClinicaAnimal f ON sv.idFicha = f.idFichaClin " +
                        "INNER JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
                        "INNER JOIN cliente c ON t.NIF = c.NIF " +
                        "WHERE sup.nLicenca = ? " +
                        "  AND a.statusAgendamento = 'marcado' " +
                        "  AND a.dtHrAgenda >= CURDATE() " +
                        "ORDER BY a.dtHrAgenda ASC";
                    
                    Connection con = manipula.getLigacao();
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setString(1, nLicenca);
                    ResultSet rs = ps.executeQuery();
                    
                    boolean temAgendamentos = false;
                    %>
                    
                    <h3 style="margin-top: 30px;">📅 Agendamentos</h3>
                    <table class="tabela">
                        <thead>
                            <tr>
                                <th>Data/Hora</th>
                                <th>Animal</th>
                                <th>Tutor</th>
                                <th>Contacto</th>
                                <th>Tipo Serviço</th>
                                <th>Ação</th>
                            </tr>
                        </thead>
                        <tbody>
                    <%
                    
                    while (rs.next()) {
                        temAgendamentos = true;
                        %>
                        <tr>
                            <td><%= util.DataFormatter.formatDate(rs.getTimestamp("dtHrAgenda").toString()) %></td>
                            <td><%= rs.getString("nomeAnimal") %></td>
                            <td><%= rs.getString("tutor") %></td>
                            <td><%= rs.getString("contactos") %></td>
                            <td><%= rs.getString("tipoServ") %></td>
                            <td>
                                <a href="historico_clinico.jsp?id=<%= rs.getInt("idFichaClin") %>" 
                                   class="btn btn-primary btn-sm">
                                    📋 Ver Ficha
                                </a>
                            </td>
                        </tr>
                        <%
                    }
                    
                    if (!temAgendamentos) {
                        %>
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 40px;">
                                Nenhum agendamento encontrado para este veterinário
                            </td>
                        </tr>
                        <%
                    }
                    %>
                        </tbody>
                    </table>
                    <%
                    
                    rs.close();
                    ps.close();
                } catch (Exception e) {
                    %>
                    <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
                    <%
                    e.printStackTrace();
                } finally {
                    manipula.desligar();
                }
            }
            %>
        </div>
    </div>
</body>
</html>
