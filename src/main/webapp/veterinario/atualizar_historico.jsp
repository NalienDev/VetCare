<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Atualizar Histórico Clínico</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📝 Atualizar Histórico Clínico</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <%
        String mensagem = "";
        String tipoMensagem = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String idFicha = request.getParameter("idFicha");
            String tipoRegistro = request.getParameter("tipoRegistro");
            String dataHora = request.getParameter("dataHora");
            
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                Connection con = manipula.getLigacao();
                con.setAutoCommit(false);
                
                if ("consulta".equals(tipoRegistro)) {
                    String motivo = request.getParameter("motivo");
                    String sintomas = request.getParameter("sintomas");
                    String diagnostico = request.getParameter("diagnostico");
                    String medicacao = request.getParameter("medicacao");
                    
                    String sql = "INSERT INTO consultaHist (idFichaClin, dataHora, motivo, sintomas, diagnostico, medicacao) VALUES (?,?,?,?,?,?)";
                    if (manipula.xDirectiva(sql, Arrays.asList(
                        Integer.parseInt(idFicha),
                        java.sql.Timestamp.valueOf(dataHora.replace("T", " ") + ":00"),
                        motivo, sintomas, diagnostico, medicacao
                    ))) {
                        con.commit();
                        mensagem = "✅ Consulta registada com sucesso!";
                        tipoMensagem = "sucesso";
                    }
                } else if ("vacina".equals(tipoRegistro)) {
                    String vacina = request.getParameter("vacina");
                    
                    String sql = "INSERT INTO vacinacao (idFichaClin, dataHora, vacina) VALUES (?,?,?)";
                    if (manipula.xDirectiva(sql, Arrays.asList(
                        Integer.parseInt(idFicha),
                        java.sql.Timestamp.valueOf(dataHora.replace("T", " ") + ":00"),
                        vacina
                    ))) {
                        con.commit();
                        mensagem = "✅ Vacinação registada!";
                        tipoMensagem = "sucesso";
                    }
                }
                
            } catch (Exception e) {
                mensagem = "❌ Erro: " + e.getMessage();
                tipoMensagem = "erro";
                e.printStackTrace();
            } finally {
                manipula.desligar();
            }
        }
        %>
        
        <div class="content">
            <% if (!mensagem.isEmpty()) { %>
                <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
            <% } %>
            
            <form method="POST" class="formulario">
                <div class="form-group">
                    <label>ID da Ficha Clínica *</label>
                    <input type="number" name="idFicha" required>
                </div>
                
                <div class="form-group">
                    <label>Data e Hora *</label>
                    <input type="datetime-local" name="dataHora" required
                           value="<%= java.time.LocalDateTime.now().toString().substring(0,16) %>">
                </div>
                
                <div class="form-group">
                    <label>Tipo de Registro *</label>
                    <select name="tipoRegistro" id="tipoRegistro" required onchange="mostrarCampos()">
                        <option value="">Selecione...</option>
                        <option value="consulta">Consulta</option>
                        <option value="vacina">Vacinação</option>
                    </select>
                </div>
                
                <div id="camposConsulta" style="display: none;">
                    <div class="form-group">
                        <label>Motivo *</label>
                        <input type="text" name="motivo" maxlength="255">
                    </div>
                    
                    <div class="form-group">
                        <label>Sintomas *</label>
                        <textarea name="sintomas" rows="3"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label>Diagnóstico *</label>
                        <textarea name="diagnostico" rows="3"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label>Medicação Prescrita</label>
                        <textarea name="medicacao" rows="2"></textarea>
                    </div>
                </div>
                
                <div id="camposVacina" style="display: none;">
                    <div class="form-group">
                        <label>Vacina Aplicada *</label>
                        <input type="text" name="vacina" maxlength="100">
                    </div>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">💾 Registar</button>
                    <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function mostrarCampos() {
            const tipo = document.getElementById('tipoRegistro').value;
            document.getElementById('camposConsulta').style.display = tipo === 'consulta' ? 'block' : 'none';
            document.getElementById('camposVacina').style.display = tipo === 'vacina' ? 'block' : 'none';
        }
    </script>
</body>
</html>
