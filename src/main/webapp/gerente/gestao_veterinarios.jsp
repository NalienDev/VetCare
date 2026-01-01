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
            <h1>⚕️ Gestão de Veterinários</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <%
        String mensagem = "";
        String tipoMensagem = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String nLicenca = request.getParameter("nLicenca");
            String nome = request.getParameter("nome");
            String contacto = request.getParameter("contacto");
            String especialidade = request.getParameter("especialidade");
            
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                String sql = "INSERT INTO veterinario (nLicenca, nome, contacto, especialidade) VALUES (?,?,?,?)";
                if (manipula.xDirectiva(sql, Arrays.asList(nLicenca, nome, contacto, especialidade))) {
                    mensagem = "✅ Veterinário registado com sucesso!";
                    tipoMensagem = "sucesso";
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
            
            <h3>➕ Registar Veterinário</h3>
            <form method="POST" class="formulario">
                <div class="form-group">
                    <label>Nº Licença *</label>
                    <input type="text" name="nLicenca" required>
                </div>
                
                <div class="form-group">
                    <label>Nome Completo *</label>
                    <input type="text" name="nome" maxlength="150" required>
                </div>
                
                <div class="form-group">
                    <label>Contacto *</label>
                    <input type="text" name="contacto" maxlength="100" required>
                </div>
                
                <div class="form-group">
                    <label>Especialidade</label>
                    <input type="text" name="especialidade" maxlength="100">
                </div>
                
                <button type="submit" class="btn btn-primary">💾 Guardar</button>
            </form>
            
            <h3 style="margin-top: 40px;">📋 Veterinários Registados</h3>
            
            <table class="tabela">
                <thead>
                    <tr>
                        <th>Nº Licença</th>
                        <th>Nome</th>
                        <th>Contacto</th>
                        <th>Especialidade</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Configura cfg = new Configura();
                    Manipula manipula = new Manipula(cfg);
                    
                    try {
                        ResultSet rs = manipula.getResultado("SELECT * FROM veterinario ORDER BY nome");
                        boolean tem = false;
                        
                        while (rs != null && rs.next()) {
                            tem = true;
                            %>
                            <tr>
                                <td><%= rs.getString("nLicenca") %></td>
                                <td><%= rs.getString("nome") %></td>
                                <td><%= rs.getString("contacto") %></td>
                                <td><%= rs.getString("especialidade") %></td>
                            </tr>
                            <%
                        }
                        
                        if (!tem) {
                            %>
                            <tr><td colspan="4" style="text-align: center;">Nenhum veterinário registado</td></tr>
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
