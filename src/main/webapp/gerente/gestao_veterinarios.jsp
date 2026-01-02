<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Gestão de Veterinários</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>👨‍⚕️ Gestão de Veterinários</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <h3>📋 Lista de Veterinários</h3>
            
            <table class="tabela">
                <thead>
                    <tr>
                        <th>Nº Licença</th>
                        <th>Nome</th>
                        <th>Contacto</th>
                        <th>Ações</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Configura cfg = new Configura();
                    Manipula manipula = new Manipula(cfg);
                    
                    try {
                        String sql = "SELECT nLicenca, nome, contacto FROM veterinario ORDER BY nome";
                        
                        Connection con = manipula.getLigacao();
                        PreparedStatement ps = con.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        
                        boolean temDados = false;
                        
                        while (rs.next()) {
                            temDados = true;
                            String nLicenca = rs.getString("nLicenca");
                            %>
                            <tr>
                                <td><%= nLicenca %></td>
                                <td><%= rs.getString("nome") %></td>
                                <td><%= rs.getString("contacto") %></td>
                                <td>
                                    <a href="editar_veterinario.jsp?nLicenca=<%= nLicenca %>" 
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
                                <td colspan="4" style="text-align: center; padding: 2rem;">
                                    📭 Nenhum veterinário cadastrado
                                </td>
                            </tr>
                            <%
                        }
                        
                        rs.close();
                        ps.close();
                        
                    } catch (Exception e) {
                        %>
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 2rem; color: red;">
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
                <a href="criar_veterinario.jsp" class="btn btn-primary">➕ Novo Veterinário</a>
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
