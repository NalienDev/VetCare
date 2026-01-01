<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.math.BigDecimal" %>
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
            <h1>📅 Gestão de Agendamentos</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <%
        String mensagem = "";
        String tipoMensagem = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String acao = request.getParameter("acao");
            
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                if ("cancelar".equals(acao)) {
                    String idAgendamento = request.getParameter("idAgendamento");
                    String sql = "UPDATE agendamento SET statusAgendamento = 'cancelado' WHERE idAgendamento = ?";
                    if (manipula.xDirectiva(sql, Arrays.asList(Integer.parseInt(idAgendamento)))) {
                        mensagem = "✅ Agendamento cancelado!";
                        tipoMensagem = "sucesso";
                    }
                } else if ("agendar".equals(acao)) {
                    String nifCliente = request.getParameter("nifCliente");
                    String dataHora = request.getParameter("dataHora");
                    String tipoServ = request.getParameter("tipoServ");
                    
                    String sql = "INSERT INTO agendamento (custos, dtHrAgenda, statusAgendamento, tipoServ, primeiraVez) VALUES (?,?,?,?,?)";
                    if (manipula.xDirectiva(sql, Arrays.asList(
                        null, 
                        java.sql.Timestamp.valueOf(dataHora.replace("T", " ") + ":00"),
                        "marcado", tipoServ, true
                    ))) {
                        ResultSet rs = manipula.getResultado("SELECT LAST_INSERT_ID() AS id");
                        if (rs.next()) {
                            int idAgendamento = rs.getInt("id");
                            String sqlCliente = "INSERT INTO agenda (idAgendamento, NIF) VALUES (?,?)";
                            manipula.xDirectiva(sqlCliente, Arrays.asList(idAgendamento, nifCliente));
                            mensagem = "✅ Agendamento criado! ID: " + idAgendamento;
                            tipoMensagem = "sucesso";
                        }
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
            
            <h3>➕ Novo Agendamento</h3>
            <form method="POST" class="formulario">
                <input type="hidden" name="acao" value="agendar">
                
                <div class="form-group">
                    <label>NIF do Cliente *</label>
                    <input type="text" name="nifCliente" pattern="[0-9]{9}" maxlength="9" required>
                </div>
                
                <div class="form-group">
                    <label>Data e Hora *</label>
                    <input type="datetime-local" name="dataHora" required
                           min="<%= java.time.LocalDateTime.now().toString().substring(0,16) %>">
                </div>
                
                <div class="form-group">
                    <label>Tipo de Serviço *</label>
                    <select name="tipoServ" required>
                        <option value="consulta">Consulta</option>
                        <option value="exame">Exame</option>
                        <option value="cirurgia">Cirurgia</option>
                        <option value="vacina">Vacina</option>
                    </select>
                </div>
                
                <button type="submit" class="btn btn-primary">📅 Agendar</button>
            </form>
            
            <h3 style="margin-top: 40px;">📋 Agendamentos Ativos</h3>
            
            <table class="tabela">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Cliente</th>
                        <th>Data/Hora</th>
                        <th>Tipo</th>
                        <th>Ação</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Configura cfg = new Configura();
                    Manipula manipula = new Manipula(cfg);
                    
                    try {
                        String sql = 
                            "SELECT a.idAgendamento, a.dtHrAgenda, a.tipoServ, c.nomeCompleto " +
                            "FROM agendamento a " +
                            "INNER JOIN agenda ag ON a.idAgendamento = ag.idAgendamento " +
                            "INNER JOIN cliente c ON ag.NIF = c.NIF " +
                            "WHERE a.statusAgendamento = 'marcado' " +
                            "ORDER BY a.dtHrAgenda ASC " +
                            "LIMIT 20";
                        
                        ResultSet rs = manipula.getResultado(sql);
                        boolean tem = false;
                        
                        while (rs != null && rs.next()) {
                            tem = true;
                            %>
                            <tr>
                                <td><%= rs.getInt("idAgendamento") %></td>
                                <td><%= rs.getString("nomeCompleto") %></td>
                                <td><%= util.DataFormatter.formatDate(rs.getTimestamp("dtHrAgenda").toString()) %></td>
                                <td><%= rs.getString("tipoServ") %></td>
                                <td>
                                    <form method="POST" style="display: inline;">
                                        <input type="hidden" name="acao" value="cancelar">
                                        <input type="hidden" name="idAgendamento" value="<%= rs.getInt("idAgendamento") %>">
                                        <button type="submit" class="btn btn-danger btn-sm">❌ Cancelar</button>
                                    </form>
                                </td>
                            </tr>
                            <%
                        }
                        
                        if (!tem) {
                            %>
                            <tr><td colspan="5" style="text-align: center;">Nenhum agendamento</td></tr>
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
