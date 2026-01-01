<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Agendar Serviço</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📅 Agendar Serviço Veterinário</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <%
        String mensagem = "";
        String tipoMensagem = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String nifCliente = request.getParameter("nifCliente");
            String dataHora = request.getParameter("dataHora");
            String tipoServ = request.getParameter("tipoServ");
            String custos = request.getParameter("custos");
            
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                Connection con = manipula.getLigacao();
                con.setAutoCommit(false);
                
                // Criar agendamento
                String sqlAgenda = "INSERT INTO agendamento (custos, dtHrAgenda, statusAgendamento, tipoServ, primeiraVez) VALUES (?,?,?,?,?)";
                List<Object> params = Arrays.asList(
                    custos.isEmpty() ? null : new BigDecimal(custos),
                    java.sql.Timestamp.valueOf(dataHora.replace("T", " ") + ":00"),
                    "marcado",
                    tipoServ,
                    true
                );
                
                if (manipula.xDirectiva(sqlAgenda, params)) {
                    // Obter ID do agendamento
                    ResultSet rs = manipula.getResultado("SELECT LAST_INSERT_ID() AS id");
                    int idAgendamento = 0;
                    if (rs.next()) {
                        idAgendamento = rs.getInt("id");
                    }
                    
                    // Associar cliente ao agendamento
                    String sqlCliente = "INSERT INTO agenda (idAgendamento, NIF) VALUES (?,?)";
                    manipula.xDirectiva(sqlCliente, Arrays.asList(idAgendamento, nifCliente));
                    
                    con.commit();
                    mensagem = "✅ Agendamento criado com sucesso! ID: " + idAgendamento;
                    tipoMensagem = "sucesso";
                } else {
                    con.rollback();
                    mensagem = "❌ Erro ao criar agendamento";
                    tipoMensagem = "erro";
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
                    <label>Cliente (NIF) *</label>
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
                        <option value="">Selecione...</option>
                        <option value="consulta">Consulta</option>
                        <option value="exame">Exame</option>
                        <option value="cirurgia">Cirurgia</option>
                        <option value="vacina">Vacina</option>
                        <option value="desparasitação">Desparasitação</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Custo Estimado (€)</label>
                    <input type="number" name="custos" step="0.01" min="0" placeholder="0.00">
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">📅 Agendar</button>
                    <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
