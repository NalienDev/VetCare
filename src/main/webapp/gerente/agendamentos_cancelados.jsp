<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.time.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Agendamentos Cancelados - Último Trimestre</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .ranking {
            counter-reset: ranking;
        }
        
        .ranking-item {
            background: #f8f9fa;
            padding: 20px;
            margin-bottom: 15px;
            border-radius: 10px;
            border-left: 5px solid #dc3545;
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .ranking-item::before {
            counter-increment: ranking;
            content: counter(ranking) "º";
            font-size: 2em;
            font-weight: bold;
            color: #dc3545;
            min-width: 50px;
            text-align: center;
        }
        
        .tutor-info {
            flex: 1;
        }
        
        .tutor-nome {
            font-size: 1.2em;
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        
        .tutor-detalhes {
            color: #666;
            font-size: 0.9em;
        }
        
        .badge-cancelamentos {
            background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-size: 1.1em;
            font-weight: bold;
            min-width: 100px;
            text-align: center;
        }
        
        .periodo-info {
            background: #fff3cd;
            border: 1px solid #ffeeba;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            color: #856404;
        }
        
        .sem-dados {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .filtros {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>❌ Tutores com Mais Cancelamentos</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <%
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            // Calcular as datas do último trimestre
            LocalDate hoje = LocalDate.now();
            LocalDate inicioTrimestre = hoje.minusMonths(3);
            
            // Permite filtrar por período personalizado
            String dataInicio = request.getParameter("dataInicio");
            String dataFim = request.getParameter("dataFim");
            
            if (dataInicio != null && !dataInicio.isEmpty()) {
                inicioTrimestre = LocalDate.parse(dataInicio);
            }
            if (dataFim != null && !dataFim.isEmpty()) {
                hoje = LocalDate.parse(dataFim);
            }
            
            java.sql.Date sqlInicio = java.sql.Date.valueOf(inicioTrimestre);
            java.sql.Date sqlFim = java.sql.Date.valueOf(hoje);
            %>
            
            <!-- Informação do Período -->
            <div class="periodo-info">
                <strong>📅 Período Analisado:</strong> 
                <%= util.DataFormatter.LocalDateToString(inicioTrimestre) %> 
                até 
                <%= util.DataFormatter.LocalDateToString(hoje) %>
                (últimos <%= java.time.temporal.ChronoUnit.DAYS.between(inicioTrimestre, hoje) %> dias)
            </div>
            
            <!-- Filtros Personalizados -->
            <div class="filtros">
                <form method="GET" class="form-row">
                    <div class="form-group">
                        <label>Data Início</label>
                        <input type="date" name="dataInicio" 
                               value="<%= inicioTrimestre %>" 
                               max="<%= hoje %>">
                    </div>
                    <div class="form-group">
                        <label>Data Fim</label>
                        <input type="date" name="dataFim" 
                               value="<%= hoje %>" 
                               max="<%= hoje %>">
                    </div>
                    <div class="form-group" style="align-self: flex-end;">
                        <button type="submit" class="btn btn-primary">🔍 Filtrar</button>
                        <a href="agendamentos_cancelados.jsp" class="btn btn-secondary">🔄 Limpar</a>
                    </div>
                </form>
            </div>
            
            <%
            try {
                // SQL para listar tutores ordenados por número de cancelamentos
                String sql = 
                    "SELECT " +
                    "    c.NIF, " +
                    "    c.nomeCompleto, " +
                    "    c.contactos, " +
                    "    COUNT(a.idAgendamento) AS totalCancelamentos, " +
                    "    GROUP_CONCAT(DISTINCT sv.idServico ORDER BY a.dtHrAgenda DESC SEPARATOR ', ') AS servicosCancelados " +
                    "FROM cliente c " +
                    "INNER JOIN agenda ag ON c.NIF = ag.NIF " +
                    "INNER JOIN agendamento a ON ag.idAgendamento = a.idAgendamento " +
                    "LEFT JOIN solicita s ON a.idAgendamento = s.idAgendamento " +
                    "LEFT JOIN servicoVet sv ON s.idServico = sv.idServico " +
                    "WHERE a.statusAgendamento IN ('cancelado', 'rejeitado') " +
                    "  AND a.dtHrAgenda BETWEEN ? AND ? " +
                    "GROUP BY c.NIF, c.nomeCompleto, c.contactos " +
                    "HAVING totalCancelamentos > 0 " +
                    "ORDER BY totalCancelamentos DESC, c.nomeCompleto ASC " +
                    "LIMIT 20";
                
                Connection con = manipula.getLigacao();
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setDate(1, sqlInicio);
                ps.setDate(2, sqlFim);
                
                ResultSet rs = ps.executeQuery();
                
                boolean temDados = false;
                %>
                
                <div class="ranking">
                <%
                while (rs.next()) {
                    temDados = true;
                    String nif = rs.getString("NIF");
                    String nome = rs.getString("nomeCompleto");
                    String contactos = rs.getString("contactos");
                    int totalCancelamentos = rs.getInt("totalCancelamentos");
                    String servicosCancelados = rs.getString("servicosCancelados");
                    %>
                    
                    <div class="ranking-item">
                        <div class="tutor-info">
                            <div class="tutor-nome">
                                <%= nome %>
                            </div>
                            <div class="tutor-detalhes">
                                <strong>NIF:</strong> <%= nif %> | 
                                <strong>Contacto:</strong> <%= contactos %><br>
                                <% if (servicosCancelados != null && !servicosCancelados.isEmpty()) { %>
                                    <strong>Serviços:</strong> <%= servicosCancelados %>
                                <% } %>
                            </div>
                        </div>
                        <div class="badge-cancelamentos">
                            <%= totalCancelamentos %>
                            <%= totalCancelamentos == 1 ? "cancelamento" : "cancelamentos" %>
                        </div>
                    </div>
                    
                <%
                }
                %>
                </div>
                
                <%
                if (!temDados) {
                %>
                    <div class="sem-dados">
                        <h2>✅ Sem Cancelamentos</h2>
                        <p>Não foram encontrados agendamentos cancelados no período selecionado.</p>
                        <p style="color: #28a745; font-weight: 600;">Excelente trabalho! 🎉</p>
                    </div>
                <%
                }
                
                rs.close();
                ps.close();
                
            } catch (SQLException e) {
                %>
                <div class="mensagem erro">
                    ❌ Erro ao carregar dados: <%= e.getMessage() %>
                </div>
                <%
                e.printStackTrace();
            } finally {
                manipula.desligar();
            }
            %>
            
            <!-- Estatísticas Adicionais -->
            <%
            try {
                manipula = new Manipula(cfg);
                Connection con = manipula.getLigacao();
                
                // Total de agendamentos no período
                String sqlTotal = 
                    "SELECT COUNT(*) AS total " +
                    "FROM agendamento " +
                    "WHERE dtHrAgenda BETWEEN ? AND ?";
                
                PreparedStatement psTotal = con.prepareStatement(sqlTotal);
                psTotal.setDate(1, sqlInicio);
                psTotal.setDate(2, sqlFim);
                ResultSet rsTotal = psTotal.executeQuery();
                
                int totalAgendamentos = 0;
                if (rsTotal.next()) {
                    totalAgendamentos = rsTotal.getInt("total");
                }
                
                // Total de cancelamentos
                String sqlCancelados = 
                    "SELECT COUNT(*) AS totalCancelados " +
                    "FROM agendamento " +
                    "WHERE statusAgendamento IN ('cancelado', 'rejeitado') " +
                    "  AND dtHrAgenda BETWEEN ? AND ?";
                
                PreparedStatement psCancelados = con.prepareStatement(sqlCancelados);
                psCancelados.setDate(1, sqlInicio);
                psCancelados.setDate(2, sqlFim);
                ResultSet rsCancelados = psCancelados.executeQuery();
                
                int totalCancelados = 0;
                if (rsCancelados.next()) {
                    totalCancelados = rsCancelados.getInt("totalCancelados");
                }
                
                double percentagem = totalAgendamentos > 0 ? 
                    (totalCancelados * 100.0 / totalAgendamentos) : 0;
                %>
                
                <div class="info-card" style="margin-top: 30px;">
                    <h3>📊 Estatísticas do Período</h3>
                    <div class="form-row">
                        <div>
                            <strong>Total de Agendamentos:</strong> <%= totalAgendamentos %>
                        </div>
                        <div>
                            <strong>Total Cancelados/Rejeitados:</strong> <%= totalCancelados %>
                        </div>
                        <div>
                            <strong>Taxa de Cancelamento:</strong> 
                            <%= String.format("%.2f", percentagem) %>%
                        </div>
                    </div>
                </div>
                
                <%
                rsTotal.close();
                psTotal.close();
                rsCancelados.close();
                psCancelados.close();
                
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                manipula.desligar();
            }
            %>
            
        </div>
    </div>
</body>
</html>
