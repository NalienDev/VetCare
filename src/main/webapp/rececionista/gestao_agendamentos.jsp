<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gestão de Agendamentos</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>🔄 Gestão de Agendamentos</h1>
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
                if ("cancelar".equals(acao)) {
                    String sql = "UPDATE agendamento SET statusAgendamento = 'cancelado' WHERE idAgendamento = ?";
                    if (manipula.xDirectiva(sql, Arrays.asList(Integer.parseInt(idAgendamento)))) {
                        mensagem = "✅ Agendamento cancelado com sucesso!";
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
            
            <h2>📋 Agendamentos Pendentes</h2>
            
            <table class="tabela">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Cliente</th>
                        <th>Data/Hora</th>
                        <th>Tipo</th>
                        <th>Status</th>
                        <th>Ações</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Configura cfg = new Configura();
                    Manipula manipula = new Manipula(cfg);
                    
                    try {
                        String sql = 
                            "SELECT a.idAgendamento, a.dtHrAgenda, a.tipoServ, a.statusAgendamento, " +
                            "       c.nomeCompleto " +
                            "FROM agendamento a " +
                            "INNER JOIN agenda ag ON a.idAgendamento = ag.idAgendamento " +
                            "INNER JOIN cliente c ON ag.NIF = c.NIF " +
                            "WHERE a.statusAgendamento = 'marcado' " +
                            "ORDER BY a.dtHrAgenda ASC " +
                            "LIMIT 50";
                        
                        ResultSet rs = manipula.getResultado(sql);
                        boolean temDados = false;
                        
                        while (rs != null && rs.next()) {
                            temDados = true;
                            int id = rs.getInt("idAgendamento");
                            String cliente = rs.getString("nomeCompleto");
                            java.sql.Timestamp dataHora = rs.getTimestamp("dtHrAgenda");
                            String tipo = rs.getString("tipoServ");
                            String status = rs.getString("statusAgendamento");
                            %>
                            <tr>
                                <td><%= id %></td>
                                <td><%= cliente %></td>
                                <td><%= util.DataFormatter.formatDate(dataHora.toString()) %></td>
                                <td><%= tipo %></td>
                                <td><%= status %></td>
                                <td>
                                    <form method="POST" style="display: inline;">
                                        <input type="hidden" name="idAgendamento" value="<%= id %>">
                                        <input type="hidden" name="acao" value="cancelar">
                                        <button type="submit" class="btn btn-danger" 
                                                onclick="return confirm('Confirma cancelamento?')">
                                            ❌ Cancelar
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <%
                        }
                        
                        if (!temDados) {
                            %>
                            <tr>
                                <td colspan="6" style="text-align: center; padding: 40px;">
                                    Nenhum agendamento pendente
                                </td>
                            </tr>
                            <%
                        }
                    } finally {
                        manipula.desligar();
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
