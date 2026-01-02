<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Agendamentos Cancelados</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>❌ Agendamentos Cancelados</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <h3>📋 Lista de Agendamentos Cancelados</h3>
            
            <table class="tabela">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Data/Hora</th>
                        <th>Cliente</th>
                        <th>Tipo Serviço</th>
                        <th>Custo</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Configura cfg = new Configura();
                    Manipula manipula = new Manipula(cfg);
                    
                    try {
                        String sql = 
                            "SELECT a.idAgendamento, a.dataHrAgenda, a.tipoServ, a.custos, " +
                            "       c.nomeCompleto " +
                            "FROM agendamento a " +
                            "INNER JOIN agenda ag ON a.idAgendamento = ag.idAgendamento " +
                            "INNER JOIN cliente c ON ag.NIF = c.NIF " +
                            "WHERE a.statusAgendamento = 'cancelado' " +
                            "ORDER BY a.dataHrAgenda DESC " +
                            "LIMIT 100";
                        
                        Connection con = manipula.getLigacao();
                        PreparedStatement ps = con.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        
                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                        boolean temDados = false;
                        
                        while (rs.next()) {
                            temDados = true;
                            %>
                            <tr>
                                <td><%= rs.getInt("idAgendamento") %></td>
                                <td><%= sdf.format(rs.getTimestamp("dataHrAgenda")) %></td>
                                <td><%= rs.getString("nomeCompleto") %></td>
                                <td><%= rs.getString("tipoServ") %></td>
                                <td><%= rs.getBigDecimal("custos") != null ? 
                                        String.format("%.2f €", rs.getBigDecimal("custos")) : "-" %></td>
                            </tr>
                            <%
                        }
                        
                        if (!temDados) {
                            %>
                            <tr>
                                <td colspan="5" style="text-align: center; padding: 2rem;">
                                    📭 Nenhum agendamento cancelado encontrado
                                </td>
                            </tr>
                            <%
                        }
                        
                        rs.close();
                        ps.close();
                        
                    } catch (Exception e) {
                        %>
                        <tr>
                            <td colspan="5" style="text-align: center; padding: 2rem; color: red;">
                                ❌ Erro ao carregar dados: <%= e.getMessage() %>
                            </td>
                        </tr>
                        <%
                        e.printStackTrace();
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
