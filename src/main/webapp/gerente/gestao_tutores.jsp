<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gestão de Tutores</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>👥 Gestão de Tutores</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <h3>📋 Lista de Tutores (Pessoas)</h3>
            
            <table class="tabela">
                <thead>
                    <tr>
                        <th>NIF</th>
                        <th>Nome</th>
                        <th>Contacto</th>
                        <th>Morada</th>
                        <th>Nº Animais</th>
                        <th>Ações</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Configura cfg = new Configura();
                    Manipula manipula = new Manipula(cfg);
                    
                    try {
                        String sql = 
                            "SELECT c.NIF, c.nomeCompleto, c.contactos, " +
                            "       CONCAT(c.arteria, ', ', c.numero, " +
                            "              COALESCE(CONCAT(', ', c.andar), '')) AS morada, " +
                            "       COUNT(t.idFichaClin) AS numAnimais " +
                            "FROM cliente c " +
                            "INNER JOIN pessoa p ON c.NIF = p.NIF " +
                            "LEFT JOIN tutor t ON c.NIF = t.NIF " +
                            "GROUP BY c.NIF, c.nomeCompleto, c.contactos, morada " +
                            "ORDER BY c.nomeCompleto";
                        
                        Connection con = manipula.getLigacao();
                        PreparedStatement ps = con.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        
                        boolean temDados = false;
                        
                        while (rs.next()) {
                            temDados = true;
                            String nif = rs.getString("NIF");
                            %>
                            <tr>
                                <td><%= nif %></td>
                                <td><%= rs.getString("nomeCompleto") %></td>
                                <td><%= rs.getString("contactos") %></td>
                                <td><%= rs.getString("morada") %></td>
                                <td><%= rs.getInt("numAnimais") %></td>
                                <td>
                                    <a href="../veterinario/pesquisar_animal.jsp?nif=<%= nif %>" 
                                       class="btn btn-primary btn-sm">
                                        🔍 Ver Animais
                                    </a>
                                </td>
                            </tr>
                            <%
                        }
                        
                        if (!temDados) {
                            %>
                            <tr>
                                <td colspan="6" style="text-align: center; padding: 2rem;">
                                    📭 Nenhum tutor cadastrado
                                </td>
                            </tr>
                            <%
                        }
                        
                        rs.close();
                        ps.close();
                        
                    } catch (Exception e) {
                        %>
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 2rem; color: red;">
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
                <a href="../rececionista/criar_tutor.jsp" class="btn btn-primary">➕ Novo Tutor</a>
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
