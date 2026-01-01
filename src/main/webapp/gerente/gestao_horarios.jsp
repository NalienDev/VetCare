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
            <h1>📅 Gestão de Horários</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <%
        String mensagem = "";
        String tipoMensagem = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String nLicenca = request.getParameter("nLicenca");
            String localidade = request.getParameter("localidade");
            String diaSemana = request.getParameter("diaSemana");
            String horaInicio = request.getParameter("horaInicio");
            String horaFim = request.getParameter("horaFim");
            
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                // Validar: não atribuir em fins de semana
                if ("Sábado".equals(diaSemana) || "Domingo".equals(diaSemana)) {
                    mensagem = "❌ Não é permitido agendar em fins de semana!";
                    tipoMensagem = "erro";
                } else {
                    String sql = "INSERT INTO escalado (nLicenca, localidade, diaSemana) VALUES (?,?,?)";
                    if (manipula.xDirectiva(sql, Arrays.asList(nLicenca, localidade, diaSemana))) {
                        mensagem = "✅ Horário atribuído com sucesso!";
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
            
            <h3>➕ Atribuir Horário</h3>
            <form method="POST" class="formulario">
                <div class="form-group">
                    <label>Nº Licença Veterinário *</label>
                    <input type="text" name="nLicenca" required>
                </div>
                
                <div class="form-group">
                    <label>Localidade da Clínica *</label>
                    <select name="localidade" required>
                        <option value="">Selecione...</option>
                        <%
                        Configura cfg = new Configura();
                        Manipula manipula = new Manipula(cfg);
                        try {
                            ResultSet rs = manipula.getResultado("SELECT localidade FROM clinica ORDER BY localidade");
                            while (rs != null && rs.next()) {
                                %>
                                <option value="<%= rs.getString("localidade") %>">
                                    <%= rs.getString("localidade") %>
                                </option>
                                <%
                            }
                        } finally {
                            manipula.desligar();
                        }
                        %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Dia da Semana *</label>
                    <select name="diaSemana" required>
                        <option value="">Selecione...</option>
                        <option value="Segunda-feira">Segunda-feira</option>
                        <option value="Terça-feira">Terça-feira</option>
                        <option value="Quarta-feira">Quarta-feira</option>
                        <option value="Quinta-feira">Quinta-feira</option>
                        <option value="Sexta-feira">Sexta-feira</option>
                        <option value="Sábado" disabled>Sábado (não permitido)</option>
                        <option value="Domingo" disabled>Domingo (não permitido)</option>
                    </select>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Hora Início</label>
                        <input type="time" name="horaInicio" value="09:00">
                    </div>
                    
                    <div class="form-group">
                        <label>Hora Fim</label>
                        <input type="time" name="horaFim" value="18:00">
                    </div>
                </div>
                
                <button type="submit" class="btn btn-primary">💾 Atribuir</button>
            </form>
            
            <h3 style="margin-top: 40px;">📋 Horários Atribuídos</h3>
            
            <table class="tabela">
                <thead>
                    <tr>
                        <th>Veterinário</th>
                        <th>Clínica</th>
                        <th>Dia da Semana</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    cfg = new Configura();
                    manipula = new Manipula(cfg);
                    
                    try {
                        String sql = 
                            "SELECT e.nLicenca, e.localidade, e.diaSemana " +
                            "FROM escalado e " +
                            "ORDER BY e.diaSemana, e.nLicenca";
                        
                        ResultSet rs = manipula.getResultado(sql);
                        boolean tem = false;
                        
                        while (rs != null && rs.next()) {
                            tem = true;
                            %>
                            <tr>
                                <td><%= rs.getString("nLicenca") %></td>
                                <td><%= rs.getString("localidade") %></td>
                                <td><%= rs.getString("diaSemana") %></td>
                            </tr>
                            <%
                        }
                        
                        if (!tem) {
                            %>
                            <tr><td colspan="3" style="text-align: center;">Nenhum horário atribuído</td></tr>
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
