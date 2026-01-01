<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.io.*, java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Criar/Atualizar Animal</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>🐕 Criar/Atualizar Animal</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <%
        String mensagem = "";
        String tipoMensagem = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String nifTutor = request.getParameter("nifTutor");
            String nome = request.getParameter("nome");
            String sexo = request.getParameter("sexo");
            String dataNasc = request.getParameter("dataNasc");
            String filiacao = request.getParameter("filiacao");
            String estadoReprod = request.getParameter("estadoReprod");
            String alergias = request.getParameter("alergias");
            String nomeRaca = request.getParameter("nomeRaca");
            
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                Connection con = manipula.getLigacao();
                con.setAutoCommit(false);
                
                // Inserir ficha clínica
                String sqlFicha = "INSERT INTO fichaClinicaAnimal (nome, sexo, dataNasc, filiacao, estadoReprod, alergias) VALUES (?,?,?,?,?,?)";
                List<Object> paramsFicha = Arrays.asList(
                    nome, sexo, 
                    java.sql.Date.valueOf(dataNasc),
                    filiacao.isEmpty() ? null : filiacao,
                    estadoReprod,
                    alergias.isEmpty() ? null : alergias
                );
                
                if (manipula.xDirectiva(sqlFicha, paramsFicha)) {
                    // Obter ID da ficha criada
                    String sqlId = "SELECT LAST_INSERT_ID() AS id";
                    ResultSet rs = manipula.getResultado(sqlId);
                    int idFicha = 0;
                    if (rs.next()) {
                        idFicha = rs.getInt("id");
                    }
                    
                    // Associar raça
                    String sqlRaca = "INSERT INTO fichaRaca (idFichaClin, nomeRaca) VALUES (?,?)";
                    manipula.xDirectiva(sqlRaca, Arrays.asList(idFicha, nomeRaca));
                    
                    // Associar tutor
                    String sqlTutor = "INSERT INTO tutor (NIF, idFichaClin) VALUES (?,?)";
                    manipula.xDirectiva(sqlTutor, Arrays.asList(nifTutor, idFicha));
                    
                    con.commit();
                    mensagem = "✅ Animal registado com sucesso!";
                    tipoMensagem = "sucesso";
                } else {
                    con.rollback();
                    mensagem = "❌ Erro ao registar animal";
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
            
            <form method="POST" class="formulario" enctype="multipart/form-data">
                <div class="form-group">
                    <label>NIF do Tutor *</label>
                    <input type="text" name="nifTutor" pattern="[0-9]{9}" maxlength="9" required>
                </div>
                
                <div class="form-group">
                    <label>Nome do Animal *</label>
                    <input type="text" name="nome" maxlength="100" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Sexo *</label>
                        <select name="sexo" required>
                            <option value="">Selecione...</option>
                            <option value="M">Macho</option>
                            <option value="F">Fêmea</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Data de Nascimento *</label>
                        <input type="date" name="dataNasc" required max="<%= java.time.LocalDate.now() %>">
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Raça *</label>
                    <select name="nomeRaca" required>
                        <option value="">Selecione...</option>
                        <%
                        Configura cfgRaca = new Configura();
                        Manipula manRaca = new Manipula(cfgRaca);
                        try {
                            ResultSet rsRacas = manRaca.getResultado("SELECT nomeRaca FROM raca ORDER BY nomeRaca");
                            while (rsRacas != null && rsRacas.next()) {
                                %>
                                <option value="<%= rsRacas.getString("nomeRaca") %>">
                                    <%= rsRacas.getString("nomeRaca") %>
                                </option>
                                <%
                            }
                        } finally {
                            manRaca.desligar();
                        }
                        %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Filiação</label>
                    <input type="text" name="filiacao" maxlength="255">
                </div>
                
                <div class="form-group">
                    <label>Estado Reprodutivo *</label>
                    <select name="estadoReprod" required>
                        <option value="Inteiro">Inteiro</option>
                        <option value="Castrado">Castrado</option>
                        <option value="Esterilizada">Esterilizada</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Alergias</label>
                    <textarea name="alergias" rows="3"></textarea>
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">💾 Guardar</button>
                    <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
