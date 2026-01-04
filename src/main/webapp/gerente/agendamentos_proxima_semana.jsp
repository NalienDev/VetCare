<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.time.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Previsão de Agendamentos - Próxima Semana</title>
	<link rel="stylesheet" href="../css/vetcare-ui.css">
    <style>
        .servico-card {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 20px;
            border-left: 5px solid #667eea;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .servico-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 2px solid #dee2e6;
        }
        
        .servico-tipo {
            font-size: 1.3em;
            font-weight: 600;
            color: #667eea;
        }
        
        .badge-quantidade {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 25px;
            border-radius: 25px;
            font-size: 1.2em;
            font-weight: bold;
            min-width: 80px;
            text-align: center;
        }
        
        .servico-detalhes {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }
        
        .detalhe-item {
            background: white;
            padding: 12px;
            border-radius: 5px;
            border-left: 3px solid #667eea;
        }
        
        .detalhe-label {
            font-size: 0.9em;
            color: #666;
            margin-bottom: 5px;
        }
        
        .detalhe-valor {
            font-size: 1.1em;
            font-weight: 600;
            color: #333;
        }
        
        .periodo-info {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            text-align: center;
        }
        
        .periodo-info h2 {
            margin-bottom: 10px;
        }
        
        .resumo-geral {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .resumo-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .resumo-numero {
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
        }
        
        .resumo-label {
            color: #666;
            font-size: 0.9em;
        }
        
        .sem-agendamentos {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .sem-agendamentos h2 {
            color: #999;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
	<header class="main-header">
	  <div class="header-content">
	    <div class="logo">
	      <img src="../images/logo.png" class="logo-img" alt="VetCare Logo">
	      <span class="logo-text">VetCare</span>
	    </div>
	    <nav class="main-nav">
	      <a href="../index.jsp">Início</a>
	      <a href="menu.jsp">Gerente</a>
	    </nav>
	  </div>
	</header>
	
	<section class="page-hero">
	  <div class="page-hero-inner">
	    <h1>📊 Previsão de Agendamentos - Próxima Semana</h1>
	    <p>Previsão de Agendamentos para a próxima semana</p>
	  </div>
	</section>
    <div class="page-content">
    	<a href="menu.jsp" class="btn-voltar">← Voltar</a>
        
        <div class="content">
            <%
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            // Calcular datas da próxima semana
            LocalDate hoje = LocalDate.now();
            LocalDate inicioProximaSemana = hoje.plusDays(1);
            LocalDate fimProximaSemana = inicioProximaSemana.plusDays(7);
            
            java.sql.Date sqlInicio = java.sql.Date.valueOf(inicioProximaSemana);
            java.sql.Date sqlFim = java.sql.Date.valueOf(fimProximaSemana);
            %>
            
            <!-- Informação do Período -->
            <div class="periodo-info">
                <h2>📅 Período: Próximos 7 Dias</h2>
                <p style="font-size: 1.1em;">
                    De <strong><%= util.DataFormatter.LocalDateToString(inicioProximaSemana) %></strong>
                    até <strong><%= util.DataFormatter.LocalDateToString(fimProximaSemana) %></strong>
                </p>
            </div>
            
            <%
            try {
                Connection con = manipula.getLigacao();
                
                // Resumo Geral
                String sqlResumo = 
                    "SELECT " +
                    "    COUNT(DISTINCT a.idAgendamento) AS totalAgendamentos, " +
                    "    COUNT(DISTINCT sv.idServico) AS tiposServico, " +
                    "    COUNT(DISTINCT DATE(a.dataHrAgenda)) AS diasComAgendamento " +
                    "FROM agendamento a " +
                    "LEFT JOIN solicita s ON a.idAgendamento = s.idAgendamento " +
                    "LEFT JOIN servicoVet sv ON s.idServico = sv.idServico " +
                    "WHERE a.dataHrAgenda BETWEEN ? AND ? " +
                    "  AND a.statusAgendamento = 'marcado'";
                
                PreparedStatement psResumo = con.prepareStatement(sqlResumo);
                psResumo.setDate(1, sqlInicio);
                psResumo.setDate(2, sqlFim);
                ResultSet rsResumo = psResumo.executeQuery();
                
                int totalAgendamentos = 0;
                int tiposServico = 0;
                int diasComAgendamento = 0;
                
                if (rsResumo.next()) {
                    totalAgendamentos = rsResumo.getInt("totalAgendamentos");
                    tiposServico = rsResumo.getInt("tiposServico");
                    diasComAgendamento = rsResumo.getInt("diasComAgendamento");
                }
                
                rsResumo.close();
                psResumo.close();
                %>
                
                <!-- Resumo Geral -->
                <div class="resumo-geral">
                    <div class="resumo-card">
                        <div class="resumo-numero"><%= totalAgendamentos %></div>
                        <div class="resumo-label">Total de Agendamentos</div>
                    </div>
                    <div class="resumo-card">
                        <div class="resumo-numero"><%= tiposServico %></div>
                        <div class="resumo-label">Tipos de Serviço</div>
                    </div>
                    <div class="resumo-card">
                        <div class="resumo-numero"><%= diasComAgendamento %></div>
                        <div class="resumo-label">Dias com Agendamento</div>
                    </div>
                    <div class="resumo-card">
                        <div class="resumo-numero">
                            <%= totalAgendamentos > 0 ? String.format("%.1f", totalAgendamentos / 7.0) : "0" %>
                        </div>
                        <div class="resumo-label">Média por Dia</div>
                    </div>
                </div>
                
                <%
                if (totalAgendamentos == 0) {
                %>
                    <div class="sem-agendamentos">
                        <h2>📭 Nenhum Agendamento Previsto</h2>
                        <p>Não existem agendamentos marcados para a próxima semana.</p>
                    </div>
                <%
                } else {
                    // SQL Principal - Agendamentos por Tipo de Serviço
                    String sql = 
                        "SELECT " +
                        "    a.tipoServ, " +
                        "    COUNT(a.idAgendamento) AS quantidade, " +
                        "    MIN(a.dataHrAgenda) AS primeiroAgendamento, " +
                        "    MAX(a.dataHrAgenda) AS ultimoAgendamento, " +
                        "    AVG(a.custos) AS custoMedio, " +
                        "    SUM(a.custos) AS custoTotal " +
                        "FROM agendamento a " +
                        "WHERE a.dataHrAgenda BETWEEN ? AND ? " +
                        "  AND a.statusAgendamento = 'marcado' " +
                        "GROUP BY a.tipoServ " +
                        "ORDER BY quantidade DESC, a.tipoServ ASC";
                    
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setDate(1, sqlInicio);
                    ps.setDate(2, sqlFim);
                    
                    ResultSet rs = ps.executeQuery();
                    
                    while (rs.next()) {
                        String tipoServico = rs.getString("tipoServ");
                        int quantidade = rs.getInt("quantidade");
                        Timestamp primeiro = rs.getTimestamp("primeiroAgendamento");
                        Timestamp ultimo = rs.getTimestamp("ultimoAgendamento");
                        double custoMedio = rs.getDouble("custoMedio");
                        double custoTotal = rs.getDouble("custoTotal");
                        
                        // Ícone por tipo de serviço
                        String icone = "📋";
                        if (tipoServico != null) {
                            switch (tipoServico.toLowerCase()) {
                                case "consulta": icone = "🩺"; break;
                                case "exame": icone = "🔬"; break;
                                case "cirurgia": icone = "⚕️"; break;
                                case "vacina": icone = "💉"; break;
                                case "desparasitação": icone = "💊"; break;
                            }
                        }
                        %>
                        
                        <div class="servico-card">
                            <div class="servico-header">
                                <div class="servico-tipo">
                                    <%= icone %> <%= tipoServico != null ? tipoServico : "Não Especificado" %>
                                </div>
                                <div class="badge-quantidade">
                                    <%= quantidade %>
                                    <%= quantidade == 1 ? "agendamento" : "agendamentos" %>
                                </div>
                            </div>
                            
                            <div class="servico-detalhes">
                                <div class="detalhe-item">
                                    <div class="detalhe-label">🗓️ Primeiro Agendamento</div>
                                    <div class="detalhe-valor">
                                        <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(primeiro) %>
                                    </div>
                                </div>
                                
                                <div class="detalhe-item">
                                    <div class="detalhe-label">🗓️ Último Agendamento</div>
                                    <div class="detalhe-valor">
                                        <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(ultimo) %>
                                    </div>
                                </div>
                                
                                <div class="detalhe-item">
                                    <div class="detalhe-label">💰 Custo Médio</div>
                                    <div class="detalhe-valor">
                                        <%= String.format("%.2f €", custoMedio) %>
                                    </div>
                                </div>
                                
                                <div class="detalhe-item">
                                    <div class="detalhe-label">💵 Receita Prevista</div>
                                    <div class="detalhe-valor">
                                        <%= String.format("%.2f €", custoTotal) %>
                                    </div>
                                </div>
                            </div>
                            
                            <%
                            // Detalhes por dia da semana
                            String sqlPorDia = 
                                "SELECT " +
                                "    DATE(a.dataHrAgenda) AS dia, " +
                                "    DAYNAME(a.dataHrAgenda) AS diaSemana, " +
                                "    COUNT(*) AS qtd " +
                                "FROM agendamento a " +
                                "WHERE a.dataHrAgenda BETWEEN ? AND ? " +
                                "  AND a.statusAgendamento = 'marcado' " +
                                "  AND a.tipoServ = ? " +
                                "GROUP BY dia, diaSemana " +
                                "ORDER BY dia ASC";
                            
                            PreparedStatement psDia = con.prepareStatement(sqlPorDia);
                            psDia.setDate(1, sqlInicio);
                            psDia.setDate(2, sqlFim);
                            psDia.setString(3, tipoServico);
                            ResultSet rsDia = psDia.executeQuery();
                            
                            boolean temDetalhes = false;
                            StringBuilder detalhesHTML = new StringBuilder();
                            
                            while (rsDia.next()) {
                                temDetalhes = true;
                                java.sql.Date dia = rsDia.getDate("dia");
                                String diaSemana = rsDia.getString("diaSemana");
                                int qtdDia = rsDia.getInt("qtd");
                                
                                detalhesHTML.append("<div class='detalhe-item'>");
                                detalhesHTML.append("<div class='detalhe-label'>").append(diaSemana).append("</div>");
                                detalhesHTML.append("<div class='detalhe-valor'>")
                                           .append(util.DataFormatter.LocalDateToString(dia.toLocalDate()))
                                           .append(" - ").append(qtdDia)
                                           .append(qtdDia == 1 ? " agendamento" : " agendamentos")
                                           .append("</div>");
                                detalhesHTML.append("</div>");
                            }
                            
                            if (temDetalhes) {
                            %>
                                <div style="grid-column: 1 / -1; margin-top: 10px;">
                                    <strong style="color: #667eea;">📅 Distribuição por Dia:</strong>
                                    <div class="servico-detalhes" style="margin-top: 10px;">
                                        <%= detalhesHTML.toString() %>
                                    </div>
                                </div>
                            <%
                            }
                            
                            rsDia.close();
                            psDia.close();
                            %>
                        </div>
                        
                        <%
                    }
                    
                    rs.close();
                    ps.close();
                }
                
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
            
            <!-- Botões de Ação -->
            <div class="form-actions" style="margin-top: 30px; justify-content: center;">
                <button onclick="window.print()" class="btn btn-secondary">
                    🖨️ Imprimir Relatório
                </button>
            </div>
            
        </div>
    </div>
</body>
</html>
