<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gestão de Consultas</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📅 Gestão de Consultas</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <%
        String mensagem = "";
        String tipoMensagem = "";
        String acao = request.getParameter("acao");
        
        if (acao != null && "POST".equalsIgnoreCase(request.getMethod())) {
            String idAgendamento = request.getParameter("idAgendamento");
            
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                if ("rejeitar".equals(acao)) {
                    String sql = "UPDATE agendamento SET statusAgendamento = 'rejeitado' WHERE idAgendamento = ?";
                    if (manipula.xDirectiva(sql, Arrays.asList(Integer.parseInt(idAgendamento)))) {
                        mensagem = "✅ Consulta rejeitada!";
                        tipoMensagem = "sucesso";
                    }
                }
            } catch (Exception e) {
                mensagem = "❌ Erro: " + e.getMessage();
                tipoMensagem = "erro";
            } finally {
                manipula.desligar();
            }
        }
        %>
        
        <div class="content">
            <% if (!mensagem.isEmpty()) { %>
                <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
            <% } %>
            
            <div class="formulario">
                <h3>📋 Ver Minhas Consultas</h3>
                <form method="GET">
                    <div class="form-group">
                        <label>Seu NIF</label>
                        <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9" required
                               value="<%= request.getParameter("nif") != null ? request.getParameter("nif") : "" %>">
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
                        "SELECT a.idAgendamento, a.dtHrAgenda, a.tipoServ, a.statusAgendamento " +
                        "FROM agendamento a " +
                        "INNER JOIN agenda ag ON a.idAgendamento = ag.idAgendamento " +
                        "WHERE ag.NIF = ? " +
                        "ORDER BY a.dtHrAgenda DESC";
                    
                    Connection con = manipula.getLigacao();
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setString(1, nif);
                    ResultSet rs = ps.executeQuery();
                    
                    boolean tem = false;
                    %>
                    <table class="tabela" style="margin-top: 20px;">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Data/Hora</th>
                                <th>Tipo</th>
                                <th>Status</th>
                                <th>Ações</th>
                            </tr>
                        </thead>
                        <tbody>
                    <%
                    while (rs.next()) {
                        tem = true;
                        %>
                        <tr>
                            <td><%= rs.getInt("idAgendamento") %></td>
                            <td><%= util.DataFormatter.formatDate(rs.getTimestamp("dtHrAgenda").toString()) %></td>
                            <td><%= rs.getString("tipoServ") %></td>
                            <td><%= rs.getString("statusAgendamento") %></td>
                            <td>
                                <% if ("marcado".equals(rs.getString("statusAgendamento"))) { %>
                                    <form method="POST" style="display: inline;">
                                        <input type="hidden" name="idAgendamento" value="<%= rs.getInt("idAgendamento") %>">
                                        <input type="hidden" name="acao" value="rejeitar">
                                        <input type="hidden" name="nif" value="<%= nif %>">
                                        <button type="submit" class="btn btn-danger btn-sm">❌ Rejeitar</button>
                                    </form>
                                <% } %>
                            </td>
                        </tr>
                        <%
                    }
                    if (!tem) {
                        %>
                        <tr><td colspan="5" style="text-align: center;">Sem consultas</td></tr>
                        <%
                    }
                    %>
                        </tbody>
                    </table>
                    <%
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
