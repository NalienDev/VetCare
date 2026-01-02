<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gestão de Horários</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>🕐 Gestão de Horários</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <h3>📋 Horários por Clínica</h3>
            
            <table class="tabela">
                <thead>
                    <tr>
                        <th>Localidade</th>
                        <th>Dia da Semana</th>
                        <th>Hora Início</th>
                        <th>Hora Fim</th>
                        <th>Ações</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Configura cfg = new Configura();
                    Manipula manipula = new Manipula(cfg);
                    
                    try {
                        String sql = "SELECT localidade, diaUtil, horaInicio, horaFim FROM horario ORDER BY localidade, diaUtil";
                        
                        Connection con = manipula.getLigacao();
                        PreparedStatement ps = con.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        
                        boolean temDados = false;
                        
                        while (rs.next()) {
                            temDados = true;
                            String localidade = rs.getString("localidade");
                            String diaUtil = rs.getString("diaUtil");
                            %>
                            <tr>
                                <td><%= localidade %></td>
                                <td><%= diaUtil %></td>
                                <td><%= rs.getTime("horaInicio") %></td>
                                <td><%= rs.getTime("horaFim") %></td>
                                <td>
                                    <a href="editar_horario.jsp?localidade=<%= localidade %>&diaUtil=<%= diaUtil %>" 
                                       class="btn btn-primary btn-sm">
                                        ✏️ Editar
                                    </a>
                                </td>
                            </tr>
                            <%
                        }
                        
                        if (!temDados) {
                            %>
                            <tr>
                                <td colspan="5" style="text-align: center; padding: 2rem;">
                                    📭 Nenhum horário cadastrado
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
            
            <div style="margin-top: 2rem;">
                <a href="criar_horario.jsp" class="btn btn-primary">➕ Novo Horário</a>
            </div>
        </div>
    </div>
    
    <style>
        .btn-sm {
            padding: 0.5rem 1rem;
            font-size: 0.9rem;
        }
    </style>
</body>
</html>
