<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.time.*, java.time.temporal.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Histórico Clínico</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📋 Histórico Clínico</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <%
            String idParam = request.getParameter("id");
            if (idParam == null) {
                %>
                <div class="mensagem erro">ID do animal não fornecido</div>
                <%
                return;
            }
            
            int idFicha = Integer.parseInt(idParam);
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                // Buscar dados do animal
                String sqlAnimal = 
                    "SELECT f.*, r.nomeRaca, e.nomeComum AS especie, r.expectativaVida, " +
                    "       c.nomeCompleto AS tutor " +
                    "FROM fichaClinicaAnimal f " +
                    "INNER JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
                    "INNER JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
                    "INNER JOIN pertence p ON r.nomeRaca = p.nomeRaca " +
                    "INNER JOIN especie e ON p.nomeComum = e.nomeComum " +
                    "INNER JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
                    "INNER JOIN cliente c ON t.NIF = c.NIF " +
                    "WHERE f.idFichaClin = ?";
                
                Connection con = manipula.getLigacao();
                PreparedStatement ps = con.prepareStatement(sqlAnimal);
                ps.setInt(1, idFicha);
                ResultSet rs = ps.executeQuery();
                
                if (!rs.next()) {
                    %>
                    <div class="mensagem erro">Animal não encontrado</div>
                    <%
                    return;
                }
                
                String nome = rs.getString("nome");
                String sexo = rs.getString("sexo");
                java.sql.Date dataNasc = rs.getDate("dataNasc");
                String raca = rs.getString("nomeRaca");
                String especie = rs.getString("especie");
                String tutor = rs.getString("tutor");
                int expectativa = rs.getInt("expectativaVida");
                
                // Calcular idade detalhada
                LocalDate nascimento = dataNasc.toLocalDate();
                LocalDate hoje = LocalDate.now();
                Period periodo = Period.between(nascimento, hoje);
                
                long dias = ChronoUnit.DAYS.between(nascimento, hoje);
                long semanas = dias / 7;
                long meses = ChronoUnit.MONTHS.between(nascimento, hoje);
                int anos = periodo.getYears();
                
                // Determinar escalão etário
                String escalao = "";
                if (anos < 1) {
                    escalao = "👶 Bebé";
                } else if (anos < expectativa / 3) {
                    escalao = "🐾 Jovem";
                } else if (anos < expectativa) {
                    escalao = "🦁 Adulto";
                } else {
                    escalao = "👴 Idoso";
                }
                
                String idadeFormatada = "";
                if (dias < 60) {
                    idadeFormatada = dias + (dias == 1 ? " dia" : " dias");
                } else if (semanas < 16) {
                    idadeFormatada = semanas + (semanas == 1 ? " semana" : " semanas");
                } else if (meses < 24) {
                    idadeFormatada = meses + (meses == 1 ? " mês" : " meses");
                } else {
                    idadeFormatada = anos + (anos == 1 ? " ano" : " anos");
                    if (periodo.getMonths() > 0) {
                        idadeFormatada += " e " + periodo.getMonths() + 
                            (periodo.getMonths() == 1 ? " mês" : " meses");
                    }
                }
                %>
                
                <!-- Informações do Animal -->
                <div class="info-card">
                    <h2>🐾 <%= nome %></h2>
                    <div class="form-row">
                        <div>
                            <strong>Espécie:</strong> <%= especie %><br>
                            <strong>Raça:</strong> <%= raca %><br>
                            <strong>Sexo:</strong> <%= util.DataFormatter.obterGenero(sexo) %>
                        </div>
                        <div>
                            <strong>Data Nascimento:</strong> <%= util.DataFormatter.LocalDateToString(nascimento) %><br>
                            <strong>Idade:</strong> <%= idadeFormatada %><br>
                            <strong>Escalão:</strong> <%= escalao %>
                        </div>
                        <div>
                            <strong>Tutor:</strong> <%= tutor %><br>
                            <strong>Expectativa Vida:</strong> <%= expectativa %> anos<br>
                            <strong>ID Ficha:</strong> <%= idFicha %>
                        </div>
                    </div>
                </div>
                
                <h3 style="margin-top: 30px;">📚 Histórico Médico</h3>
                
                <!-- Consultas -->
                <%
                String sqlConsultas = 
                    "SELECT * FROM consultaHist " +
                    "WHERE idFichaClin = ? " +
                    "ORDER BY dataHora DESC";
                
                PreparedStatement psConsultas = con.prepareStatement(sqlConsultas);
                psConsultas.setInt(1, idFicha);
                ResultSet rsConsultas = psConsultas.executeQuery();
                
                boolean temConsultas = false;
                while (rsConsultas.next()) {
                    if (!temConsultas) {
                        %>
                        <h4>🩺 Consultas</h4>
                        <%
                        temConsultas = true;
                    }
                    %>
                    <div class="animal-item" style="margin-bottom: 15px;">
                        <strong>Data:</strong> <%= util.DataFormatter.formatDate(rsConsultas.getTimestamp("dataHora").toString()) %><br>
                        <strong>Motivo:</strong> <%= rsConsultas.getString("motivo") %><br>
                        <strong>Sintomas:</strong> <%= rsConsultas.getString("sintomas") %><br>
                        <strong>Diagnóstico:</strong> <%= rsConsultas.getString("diagnostico") %><br>
                        <strong>Medicação:</strong> <%= rsConsultas.getString("medicacao") %>
                    </div>
                    <%
                }
                rsConsultas.close();
                psConsultas.close();
                
                if (!temConsultas) {
                    %>
                    <p style="color: #666;">Sem consultas registadas</p>
                    <%
                }
                %>
                
                <%
                rs.close();
                ps.close();
                
            } catch (Exception e) {
                %>
                <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
                <%
                e.printStackTrace();
            } finally {
                manipula.desligar();
            }
            %>
        </div>
    </div>
</body>
</html>
