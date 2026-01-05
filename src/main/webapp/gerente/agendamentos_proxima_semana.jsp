<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.time.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VetCare - Previsão Próxima Semana</title>
    <link rel="stylesheet" href="../css/vetcare-ui.css">
    <style>
        .resumo-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border: 2px solid #E7EEF4;
            border-radius: 12px;
            padding: 25px;
            text-align: center;
        }
        
        .stat-numero {
            font-size: 42px;
            font-weight: 700;
            color: #4A90E2;
            margin-bottom: 8px;
        }
        
        .stat-label {
            color: #57606F;
            font-size: 14px;
            font-weight: 600;
        }
        
        .calendario-semana {
            background: white;
            border: 2px solid #E7EEF4;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
        }
        
        .calendario-semana h3 {
            margin: 0 0 20px 0;
            color: #0B2A42;
            font-size: 18px;
            font-weight: 700;
        }
        
        .dias-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 12px;
        }
        
        .dia-card {
            background: white;
            border: 2px solid #E7EEF4;
            border-radius: 10px;
            padding: 15px;
            text-align: center;
            transition: all 0.3s;
        }
        
        .dia-card.util {
            background: #E8F4F8;
            border-color: #4A90E2;
        }
        
        .dia-card.util:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(74, 144, 226, 0.2);
        }
        
        .dia-card.bloqueado {
            background: #F1F3F5;
            border-color: #DEE2E6;
            opacity: 0.6;
        }
        
        .dia-semana {
            font-size: 12px;
            font-weight: 600;
            color: #57606F;
            margin-bottom: 5px;
            text-transform: uppercase;
        }
        
        .dia-numero {
            font-size: 24px;
            font-weight: 700;
            color: #0B2A42;
            margin-bottom: 8px;
        }
        
        .dia-mes {
            font-size: 11px;
            color: #57606F;
            margin-bottom: 10px;
        }
        
        .dia-agendamentos {
            font-size: 13px;
            font-weight: 700;
            color: #4A90E2;
            padding: 5px;
            background: white;
            border-radius: 5px;
        }
        
        .dia-card.bloqueado .dia-agendamentos {
            color: #ADB5BD;
        }
        
        .servicos-lista {
            background: white;
            border: 2px solid #E7EEF4;
            border-radius: 12px;
            padding: 25px;
        }
        
        .servicos-lista h3 {
            margin: 0 0 20px 0;
            color: #0B2A42;
            font-size: 18px;
            font-weight: 700;
        }
        
        .servico-item {
            background: #F8F9FA;
            border-left: 4px solid #4A90E2;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.3s;
            cursor: pointer;
        }
        
        .servico-item:hover {
            transform: translateX(5px);
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .servico-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .servico-info h4 {
            margin: 0 0 8px 0;
            color: #0B2A42;
            font-size: 16px;
            font-weight: 700;
        }
        
        .servico-detalhes {
            display: flex;
            gap: 20px;
            font-size: 13px;
            color: #57606F;
        }
        
        .servico-quantidade {
            background: #4A90E2;
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 20px;
            font-weight: 700;
            min-width: 60px;
            text-align: center;
        }
        
        .servico-expandido {
            display: none;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 2px solid #E7EEF4;
        }
        
        .servico-expandido.ativo {
            display: block;
        }
        
        .agendamento-detalhe {
            background: white;
            border: 2px solid #E7EEF4;
            border-radius: 8px;
            padding: 18px;
            margin-bottom: 12px;
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
        }
        
        .agendamento-campo {
            display: flex;
            flex-direction: column;
        }
        
        .agendamento-label {
            color: #57606F;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            margin-bottom: 4px;
        }
        
        .agendamento-valor {
            color: #0B2A42;
            font-size: 14px;
            font-weight: 700;
        }
        
        .agendamento-campo.full-width {
            grid-column: 1 / -1;
        }
        
        .expandir-icon {
            margin-left: 10px;
            font-size: 12px;
            color: #4A90E2;
        }
        
        .periodo-info {
            background: linear-gradient(135deg, #4A90E2 0%, #357ABD 100%);
            color: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            text-align: center;
        }
        
        .periodo-info h2 {
            margin: 0 0 10px 0;
            font-size: 22px;
        }
        
        .periodo-info p {
            margin: 0;
            font-size: 16px;
            opacity: 0.95;
        }
        
        .sem-dados {
            text-align: center;
            padding: 60px 20px;
            color: #57606F;
        }
        
        .sem-dados h3 {
            color: #ADB5BD;
            margin-bottom: 10px;
        }
        
        .btn-voltar {
            margin-bottom: 25px;
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
    <h1>Previsão de Agendamentos</h1>
    <p>Próxima semana útil</p>
  </div>
</section>

<div class="page-content">
    <a href="menu.jsp" class="btn-voltar">← Voltar</a>
    
    <%
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    LocalDate hoje = LocalDate.now();
    LocalDate inicioSemana = hoje.plusDays(1);
    LocalDate fimSemana = inicioSemana.plusDays(6);
    
    java.sql.Date sqlInicio = java.sql.Date.valueOf(inicioSemana);
    java.sql.Date sqlFim = java.sql.Date.valueOf(fimSemana);
    
    java.text.SimpleDateFormat sdfCompleto = new java.text.SimpleDateFormat("dd/MM/yyyy");
    %>
    
    <div class="periodo-info">
        <h2>Período: Próximos 7 Dias</h2>
        <p>De <strong><%= sdfCompleto.format(sqlInicio) %></strong> até <strong><%= sdfCompleto.format(sqlFim) %></strong></p>
    </div>
    
    <%
    try {
        Connection con = manipula.getLigacao();
        
        // RESUMO GERAL
        String sqlResumo = 
            "SELECT " +
            "  COUNT(DISTINCT a.idAgendamento) AS totalAgendamentos, " +
            "  COUNT(DISTINCT a.tipoServ) AS tiposServico, " +
            "  COUNT(DISTINCT DATE(a.dataHrAgenda)) AS diasComAgendamento, " +
            "  AVG(a.custos) AS custoMedio, " +
            "  SUM(a.custos) AS receitaPrevista " +
            "FROM agendamento a " +
            "WHERE a.dataHrAgenda BETWEEN ? AND ? " +
            "  AND a.statusAgendamento = 'marcado'";
        
        PreparedStatement psResumo = con.prepareStatement(sqlResumo);
        psResumo.setDate(1, sqlInicio);
        psResumo.setDate(2, sqlFim);
        ResultSet rsResumo = psResumo.executeQuery();
        
        int totalAgendamentos = 0;
        int tiposServico = 0;
        int diasComAgendamento = 0;
        double custoMedio = 0;
        double receitaPrevista = 0;
        
        if (rsResumo.next()) {
            totalAgendamentos = rsResumo.getInt("totalAgendamentos");
            tiposServico = rsResumo.getInt("tiposServico");
            diasComAgendamento = rsResumo.getInt("diasComAgendamento");
            custoMedio = rsResumo.getDouble("custoMedio");
            receitaPrevista = rsResumo.getDouble("receitaPrevista");
        }
        
        rsResumo.close();
        psResumo.close();
    %>
    
    <div class="resumo-cards">
        <div class="stat-card">
            <div class="stat-numero"><%= totalAgendamentos %></div>
            <div class="stat-label">Total Agendamentos</div>
        </div>
        <div class="stat-card">
            <div class="stat-numero"><%= diasComAgendamento %></div>
            <div class="stat-label">Dias com Agendamento</div>
        </div>
        <div class="stat-card">
            <div class="stat-numero"><%= tiposServico %></div>
            <div class="stat-label">Tipos de Serviço</div>
        </div>
        <div class="stat-card">
            <div class="stat-numero"><%= String.format("%.2f €", custoMedio) %></div>
            <div class="stat-label">Custo Médio</div>
        </div>
        <div class="stat-card">
            <div class="stat-numero"><%= String.format("%.2f €", receitaPrevista) %></div>
            <div class="stat-label">Receita Prevista</div>
        </div>
    </div>
    
    <%
        
        String sqlPorDia = 
            "SELECT " +
            "  DATE(a.dataHrAgenda) AS dia, " +
            "  COUNT(*) AS quantidade " +
            "FROM agendamento a " +
            "WHERE a.dataHrAgenda BETWEEN ? AND ? " +
            "  AND a.statusAgendamento = 'marcado' " +
            "GROUP BY dia " +
            "ORDER BY dia ASC";
        
        PreparedStatement psDia = con.prepareStatement(sqlPorDia);
        psDia.setDate(1, sqlInicio);
        psDia.setDate(2, sqlFim);
        ResultSet rsDia = psDia.executeQuery();
        
        Map<LocalDate, Integer> agendamentosPorDia = new HashMap<>();
        while (rsDia.next()) {
            LocalDate dia = rsDia.getDate("dia").toLocalDate();
            int qtd = rsDia.getInt("quantidade");
            agendamentosPorDia.put(dia, qtd);
        }
        rsDia.close();
        psDia.close();
        
        String[] diasSemana = {"Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"};
        String[] meses = {"Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"};
    %>
    
    <div class="calendario-semana">
        <h3>Calendário Semanal</h3>
        <div class="dias-grid">
            <%
            for (int i = 0; i < 7; i++) {
                LocalDate dia = inicioSemana.plusDays(i);
                int diaSemanaNum = dia.getDayOfWeek().getValue();
                boolean ehFimSemana = diaSemanaNum == 6 || diaSemanaNum == 7;
                String classeDia = ehFimSemana ? "dia-card bloqueado" : "dia-card util";
                
                int qtdAgendamentos = agendamentosPorDia.getOrDefault(dia, 0);
            %>
            <div class="<%= classeDia %>">
                <div class="dia-semana"><%= diasSemana[diaSemanaNum % 7] %></div>
                <div class="dia-numero"><%= dia.getDayOfMonth() %></div>
                <div class="dia-mes"><%= meses[dia.getMonthValue() - 1] %></div>
                <% if (!ehFimSemana) { %>
                    <div class="dia-agendamentos">
                        <%= qtdAgendamentos %> <%= qtdAgendamentos == 1 ? "consulta" : "consultas" %>
                    </div>
                <% } else { %>
                    <div class="dia-agendamentos">Fechado</div>
                <% } %>
            </div>
            <%
            }
            %>
        </div>
    </div>
    
    <div class="servicos-lista">
        <h3>Agendamentos por Tipo de Serviço</h3>
        
        <%
        if (totalAgendamentos == 0) {
        %>
            <div class="sem-dados">
                <h3>Sem Agendamentos</h3>
                <p>Não existem agendamentos marcados para a próxima semana.</p>
            </div>
        <%
        } else {
            String sqlServicos = 
                "SELECT " +
                "  a.tipoServ, " +
                "  COUNT(*) AS quantidade, " +
                "  MIN(a.dataHrAgenda) AS primeiro, " +
                "  MAX(a.dataHrAgenda) AS ultimo, " +
                "  AVG(a.custos) AS custoMedio " +
                "FROM agendamento a " +
                "WHERE a.dataHrAgenda BETWEEN ? AND ? " +
                "  AND a.statusAgendamento = 'marcado' " +
                "GROUP BY a.tipoServ " +
                "ORDER BY quantidade DESC, a.tipoServ ASC";
            
            PreparedStatement psServicos = con.prepareStatement(sqlServicos);
            psServicos.setDate(1, sqlInicio);
            psServicos.setDate(2, sqlFim);
            ResultSet rsServicos = psServicos.executeQuery();
            
            java.text.SimpleDateFormat sdfHora = new java.text.SimpleDateFormat("dd/MM HH:mm");
            
            int servicoIndex = 0;
            while (rsServicos.next()) {
                String tipoServ = rsServicos.getString("tipoServ");
                int quantidade = rsServicos.getInt("quantidade");
                Timestamp primeiro = rsServicos.getTimestamp("primeiro");
                Timestamp ultimo = rsServicos.getTimestamp("ultimo");
                double custoMedioServ = rsServicos.getDouble("custoMedio");
                
                String servicoId = "servico-" + servicoIndex;
        %>
        <div class="servico-item" onclick="toggleServico('<%= servicoId %>')">
            <div style="flex: 1;">
                <div class="servico-header">
                    <div class="servico-info">
                        <h4>
                            <%= tipoServ != null ? tipoServ : "Não Especificado" %>
                            <span class="expandir-icon" id="icon-<%= servicoId %>">▼</span>
                        </h4>
                        <div class="servico-detalhes">
                            <span><strong>Primeiro:</strong> <%= sdfHora.format(primeiro) %></span>
                            <span><strong>Último:</strong> <%= sdfHora.format(ultimo) %></span>
                            <span><strong>Custo Médio:</strong> <%= String.format("%.2f €", custoMedioServ) %></span>
                        </div>
                    </div>
                    <div class="servico-quantidade">
                        <%= quantidade %>
                    </div>
                </div>
                
                <div class="servico-expandido" id="<%= servicoId %>">
                    <%
                    
                    String sqlDetalhes = 
                        "SELECT DISTINCT " +
                        "  a.idAgendamento, " +
                        "  a.dataHrAgenda, " +
                        "  a.custos, " +
                        "  c.nomeCompleto AS cliente, " +
                        "  c.NIF, " +
                        "  (SELECT e2.localidade " +
                        "   FROM escalado e2 " +
                        "   JOIN horario h2 ON h2.localidade = e2.localidade AND h2.diaUtil = e2.diaUtil " +
                        "   WHERE CASE DAYOFWEEK(a.dataHrAgenda) " +
                        "     WHEN 2 THEN 'Segunda' " +
                        "     WHEN 3 THEN 'Terça' " +
                        "     WHEN 4 THEN 'Quarta' " +
                        "     WHEN 5 THEN 'Quinta' " +
                        "     WHEN 6 THEN 'Sexta' " +
                        "   END = e2.diaUtil " +
                        "   AND TIME(a.dataHrAgenda) >= h2.horaInicio " +
                        "   AND TIME(a.dataHrAgenda) < h2.horaFim " +
                        "   LIMIT 1) AS localidade " +
                        "FROM agendamento a " +
                        "JOIN agenda ag ON ag.idAgendamento = a.idAgendamento " +
                        "JOIN cliente c ON c.NIF = ag.NIF " +
                        "WHERE a.dataHrAgenda BETWEEN ? AND ? " +
                        "  AND a.statusAgendamento = 'marcado' " +
                        "  AND a.tipoServ = ? " +
                        "ORDER BY a.dataHrAgenda ASC";
                    
                    PreparedStatement psDetalhes = con.prepareStatement(sqlDetalhes);
                    psDetalhes.setDate(1, sqlInicio);
                    psDetalhes.setDate(2, sqlFim);
                    psDetalhes.setString(3, tipoServ);
                    ResultSet rsDetalhes = psDetalhes.executeQuery();
                    
                    while (rsDetalhes.next()) {
                        int idAgend = rsDetalhes.getInt("idAgendamento");
                        Timestamp dataHora = rsDetalhes.getTimestamp("dataHrAgenda");
                        double custo = rsDetalhes.getDouble("custos");
                        String cliente = rsDetalhes.getString("cliente");
                        String nif = rsDetalhes.getString("NIF");
                        String localidade = rsDetalhes.getString("localidade");
                    %>
                    <div class="agendamento-detalhe">
                        <div class="agendamento-campo">
                            <span class="agendamento-label">ID</span>
                            <span class="agendamento-valor"><%= idAgend %></span>
                        </div>
                        <div class="agendamento-campo">
                            <span class="agendamento-label">Data/Hora</span>
                            <span class="agendamento-valor"><%= sdfHora.format(dataHora) %></span>
                        </div>
                        <div class="agendamento-campo full-width">
                            <span class="agendamento-label">Cliente</span>
                            <span class="agendamento-valor"><%= cliente %></span>
                        </div>
                        <div class="agendamento-campo">
                            <span class="agendamento-label">NIF</span>
                            <span class="agendamento-valor"><%= nif %></span>
                        </div>
                        <% if (localidade != null) { %>
                        <div class="agendamento-campo">
                            <span class="agendamento-label">Clínica</span>
                            <span class="agendamento-valor"><%= localidade %></span>
                        </div>
                        <% } %>
                        <div class="agendamento-campo">
                            <span class="agendamento-label">Custo</span>
                            <span class="agendamento-valor"><%= String.format("%.2f €", custo) %></span>
                        </div>
                    </div>
                    <%
                    }
                    rsDetalhes.close();
                    psDetalhes.close();
                    %>
                </div>
            </div>
        </div>
        <%
                servicoIndex++;
            }
            rsServicos.close();
            psServicos.close();
        }
        %>
    </div>
    
    <div class="form-actions" style="margin-top: 30px; justify-content: center;">
        <button onclick="window.print()" class="btn btn-secondary">Imprimir Relatório</button>
    </div>
    
    <%
    } catch (Exception e) {
    %>
        <div class="mensagem erro">Erro: <%= e.getMessage() %></div>
    <%
        e.printStackTrace();
    } finally {
        manipula.desligar();
    }
    %>
</div>

<script>
function toggleServico(id) {
    var expandido = document.getElementById(id);
    var icon = document.getElementById('icon-' + id);
    
    if (expandido.classList.contains('ativo')) {
        expandido.classList.remove('ativo');
        icon.textContent = '▼';
    } else {
        
        var todosExpandidos = document.querySelectorAll('.servico-expandido');
        var todosIcons = document.querySelectorAll('.expandir-icon');
        todosExpandidos.forEach(function(el) {
            el.classList.remove('ativo');
        });
        todosIcons.forEach(function(el) {
            el.textContent = '▼';
        });
        
        
        expandido.classList.add('ativo');
        icon.textContent = '▲';
    }
}
</script>

</body>
</html>