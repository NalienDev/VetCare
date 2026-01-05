<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.*, java.time.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Meu Perfil</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  
  <style>
  
    /* Estilos para ícones inline */
    .icon-inline {
      width: 18px;
      height: 18px;
      vertical-align: middle;
      margin: -2px 4px 0 0;
      display: inline-block;
    }
    
    /* Ícones em botões */
    .btn .icon-inline {
      width: 16px;
      height: 16px;
      margin-right: 6px;
    }
    
    /* Ícones em títulos */
    h1 .icon-inline, h2 .icon-inline, h3 .icon-inline {
      width: 24px;
      height: 24px;
      margin-right: 8px;
    }
    
    /* Ícones em tabelas */
    .tabela .icon-inline {
      width: 16px;
      height: 16px;
    }

    .profile-header {
      background: white;
      border: 2px solid #E7EEF4;
      border-radius: 12px;
      padding: 30px;
      margin-bottom: 30px;
    }
    .profile-info h2 {
      margin: 0 0 10px 0;
      font-size: 24px;
      color: #0B2A42;
    }
    .profile-info p {
      margin: 5px 0;
      color: #666;
    }
    
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 15px;
      margin-bottom: 30px;
    }
    .stat-card {
      background: white;
      border: 2px solid #E7EEF4;
      border-radius: 12px;
      padding: 20px;
      text-align: center;
    }
    .stat-value {
      font-size: 32px;
      font-weight: 700;
      color: #4A90E2;
      margin: 10px 0;
    }
    .stat-label {
      color: #666;
      font-size: 14px;
    }
    
    .horarios-trabalho {
      background: white;
      border: 2px solid #E7EEF4;
      border-radius: 12px;
      padding: 20px;
      margin-bottom: 30px;
    }
    .horarios-trabalho h3 {
      margin: 0 0 20px 0;
      color: #0B2A42;
      font-size: 18px;
    }
    .horario-item {
      background: #F8F9FA;
      border-left: 4px solid #4A90E2;
      padding: 15px;
      margin-bottom: 10px;
      border-radius: 6px;
    }
    .horario-dia {
      font-weight: 700;
      color: #0B2A42;
      font-size: 16px;
      margin-bottom: 5px;
    }
    .horario-detalhes {
      color: #666;
      font-size: 14px;
    }
    .horario-clinica {
      color: #4A90E2;
      font-weight: 600;
      margin-top: 5px;
    }
    
    .calendario {
      background: white;
      border: 2px solid #E7EEF4;
      border-radius: 12px;
      padding: 20px;
      margin-bottom: 30px;
    }
    .calendario-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }
    .calendario-mes {
      font-size: 20px;
      font-weight: 700;
      color: #0B2A42;
    }
    .calendario-nav {
      display: flex;
      gap: 10px;
      align-items: center;
    }
    .calendario-nav button {
      background: #4A90E2;
      color: white;
      border: none;
      padding: 8px 16px;
      border-radius: 6px;
      cursor: pointer;
      font-weight: 600;
      transition: background 0.3s;
    }
    .calendario-nav button:hover {
      background: #357ABD;
    }
    .calendario-nav select {
      padding: 8px 12px;
      border: 2px solid #E7EEF4;
      border-radius: 6px;
      font-weight: 600;
      color: #0B2A42;
      background: white;
    }
    
    .calendario-grid {
      display: grid;
      grid-template-columns: repeat(7, 1fr);
      gap: 8px;
    }
    .calendario-dia-header {
      text-align: center;
      font-weight: 700;
      color: #666;
      padding: 10px;
      font-size: 12px;
    }
    .calendario-dia {
      aspect-ratio: 1;
      border: 2px solid #E7EEF4;
      border-radius: 8px;
      padding: 8px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s;
      position: relative;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
    }
    .calendario-dia:hover {
      border-color: #4A90E2;
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
    .calendario-dia-numero {
      font-weight: 700;
      color: #0B2A42;
      font-size: 16px;
      margin-bottom: 4px;
    }
    .calendario-dia-info {
      font-size: 10px;
      color: #666;
      line-height: 1.2;
    }
    .calendario-dia-vazio {
      border: none;
      cursor: default;
    }
    .calendario-dia-vazio:hover {
      transform: none;
      box-shadow: none;
    }
    .calendario-dia-trabalho {
      background: #E8F4F8;
      border-color: #4A90E2;
    }
    .calendario-dia-consultas {
      background: #D4EDDA;
      border-color: #28A745;
    }
    .calendario-dia-hoje {
      background: #FFF3CD;
      border-color: #FFC107;
    }
    .calendario-consultas-count {
      font-size: 11px;
      font-weight: 700;
      color: #28A745;
      margin-top: 2px;
    }
    
    .consultas-dia {
      background: white;
      border: 2px solid #E7EEF4;
      border-radius: 12px;
      padding: 20px;
      margin-top: 20px;
      display: none;
    }
    .consultas-dia.active {
      display: block;
    }
    .consultas-dia h3 {
      margin: 0 0 15px 0;
      color: #0B2A42;
    }
    .consulta-item {
      background: #F8F9FA;
      border-left: 4px solid #4A90E2;
      padding: 15px;
      margin-bottom: 10px;
      border-radius: 6px;
    }
    .consulta-item.realizada {
      border-left-color: #28A745;
      opacity: 0.7;
    }
    .consulta-hora {
      font-weight: 700;
      color: #0B2A42;
      font-size: 16px;
      margin-bottom: 5px;
    }
    .consulta-tipo {
      color: #4A90E2;
      font-weight: 600;
      margin-bottom: 5px;
    }
    .consulta-cliente {
      color: #666;
      font-size: 14px;
    }
    .consulta-clinica {
      color: #28A745;
      font-weight: 600;
      margin-top: 5px;
    }
    
    .legenda {
      display: flex;
      gap: 20px;
      margin-top: 20px;
      flex-wrap: wrap;
    }
    .legenda-item {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 13px;
    }
    .legenda-cor {
      width: 20px;
      height: 20px;
      border-radius: 4px;
      border: 2px solid;
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
      <a href="menu.jsp">Veterinário</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>O Meu Perfil</h1>
    <p>Horários, estatísticas e calendário de consultas.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar ao Menu</a>

  <div class="formulario">
    <form method="GET">
      <div class="form-group">
        <label>Número de Licença</label>
        <input type="text" name="nLicenca" required 
               value="<%= request.getParameter("nLicenca") != null ? request.getParameter("nLicenca") : "" %>"
               placeholder="Digite sua licença profissional">
      </div>
      <button type="submit" class="btn btn-primary">Ver Meu Perfil</button>
    </form>
  </div>

  <%
  String nLicenca = request.getParameter("nLicenca");
  if (nLicenca != null && !nLicenca.isEmpty()) {
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
          Connection con = manipula.getLigacao();
          
          // BUSCAR DADOS DO VETERINÁRIO
          String sqlVet = 
              "SELECT nome, contacto " +
              "FROM veterinario WHERE nLicenca = ?";
          PreparedStatement psVet = con.prepareStatement(sqlVet);
          psVet.setString(1, nLicenca);
          ResultSet rsVet = psVet.executeQuery();
          
          if (!rsVet.next()) {
  %>
              <div class="mensagem erro">
                  Veterinário com licença <%= nLicenca %> não encontrado.
              </div>
  <%
          } else {
              String nome = rsVet.getString("nome");
              String contacto = rsVet.getString("contacto");
              String email = nLicenca + "@vetcare.pt";
              rsVet.close();
              psVet.close();
  %>
  
  <!-- HEADER DO PERFIL -->
  <div class="profile-header">
    <div class="profile-info">
      <h2><%= nome %></h2>
      <p><strong>Licença:</strong> <%= nLicenca %></p>
      <p><strong>Email:</strong> <%= email %> | <strong>Contacto:</strong> <%= contacto %></p>
    </div>
  </div>
  
  <%
              // ESTATÍSTICAS
              String sqlStats = 
                  "SELECT " +
                  "  COUNT(DISTINCT CASE WHEN a.dataHrAgenda >= CURDATE() THEN a.idAgendamento END) as consultasFuturas, " +
                  "  COUNT(DISTINCT CASE WHEN a.statusAgendamento = 'realizado' THEN a.idAgendamento END) as consultasRealizadas, " +
                  "  COUNT(DISTINCT e.localidade) as clinicas " +
                  "FROM escalado e " +
                  "LEFT JOIN horario h ON h.localidade = e.localidade AND h.diaUtil = e.diaUtil " +
                  "LEFT JOIN agendamento a ON " +
                  "  CASE DAYOFWEEK(a.dataHrAgenda) " +
                  "    WHEN 2 THEN 'Segunda' " +
                  "    WHEN 3 THEN 'Terça' " +
                  "    WHEN 4 THEN 'Quarta' " +
                  "    WHEN 5 THEN 'Quinta' " +
                  "    WHEN 6 THEN 'Sexta' " +
                  "  END = e.diaUtil " +
                  "  AND TIME(a.dataHrAgenda) >= h.horaInicio " +
                  "  AND TIME(a.dataHrAgenda) < h.horaFim " +
                  "WHERE e.nLicenca = ?";
              
              PreparedStatement psStats = con.prepareStatement(sqlStats);
              psStats.setString(1, nLicenca);
              ResultSet rsStats = psStats.executeQuery();
              
              int consultasFuturas = 0;
              int consultasRealizadas = 0;
              int clinicas = 0;
              
              if (rsStats.next()) {
                  consultasFuturas = rsStats.getInt("consultasFuturas");
                  consultasRealizadas = rsStats.getInt("consultasRealizadas");
                  clinicas = rsStats.getInt("clinicas");
              }
              rsStats.close();
              psStats.close();
  %>
  
  <!-- ESTATÍSTICAS -->
  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-label">Consultas Futuras</div>
      <div class="stat-value"><%= consultasFuturas %></div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Consultas Realizadas</div>
      <div class="stat-value"><%= consultasRealizadas %></div>
    </div>
    <div class="stat-card">
      <div class="stat-label">Clínicas</div>
      <div class="stat-value"><%= clinicas %></div>
    </div>
  </div>
  
  <%
              // BUSCAR HORÁRIOS DE TRABALHO
              String sqlHorarios = 
                  "SELECT e.diaUtil, e.localidade, h.horaInicio, h.horaFim " +
                  "FROM escalado e " +
                  "JOIN horario h ON h.localidade = e.localidade AND h.diaUtil = e.diaUtil " +
                  "WHERE e.nLicenca = ? " +
                  "ORDER BY " +
                  "  CASE e.diaUtil " +
                  "    WHEN 'Segunda' THEN 1 " +
                  "    WHEN 'Terça' THEN 2 " +
                  "    WHEN 'Quarta' THEN 3 " +
                  "    WHEN 'Quinta' THEN 4 " +
                  "    WHEN 'Sexta' THEN 5 " +
                  "  END, e.localidade";
              
              PreparedStatement psHorarios = con.prepareStatement(sqlHorarios);
              psHorarios.setString(1, nLicenca);
              ResultSet rsHorarios = psHorarios.executeQuery();
  %>
  
  <!-- HORÁRIOS DE TRABALHO -->
  <div class="horarios-trabalho">
    <h3><img src="../images/icon-calendar.png" class="icon-inline" alt="Calendário"> Os Meus Horários de Trabalho</h3>
    <%
              boolean temHorarios = false;
              while (rsHorarios.next()) {
                  temHorarios = true;
                  String diaUtil = rsHorarios.getString("diaUtil");
                  String localidade = rsHorarios.getString("localidade");
                  Time horaInicio = rsHorarios.getTime("horaInicio");
                  Time horaFim = rsHorarios.getTime("horaFim");
    %>
    <div class="horario-item">
      <div class="horario-dia"><%= diaUtil %>-feira</div>
      <div class="horario-detalhes">🕒 <%= horaInicio.toString().substring(0,5) %> às <%= horaFim.toString().substring(0,5) %></div>
      <div class="horario-clinica"><img src="../images/icon-pin.png" class="icon-inline" alt="Clínica"> <%= localidade %></div>
    </div>
    <%
              }
              
              if (!temHorarios) {
    %>
    <div style="text-align: center; color: #666; padding: 20px;">
      Nenhum horário de trabalho definido.
    </div>
    <%
              }
              rsHorarios.close();
              psHorarios.close();
    %>
  </div>
  
  <%
              // PARÂMETROS DO CALENDÁRIO
              String mesParam = request.getParameter("mes");
              String anoParam = request.getParameter("ano");
              
              Calendar cal = Calendar.getInstance();
              int mesAtual = (mesParam != null) ? Integer.parseInt(mesParam) : cal.get(Calendar.MONTH);
              int anoAtual = (anoParam != null) ? Integer.parseInt(anoParam) : cal.get(Calendar.YEAR);
              int diaHoje = cal.get(Calendar.DAY_OF_MONTH);
              int mesHoje = cal.get(Calendar.MONTH);
              int anoHoje = cal.get(Calendar.YEAR);
              
              // Configurar calendário para o mês selecionado
              cal.set(Calendar.YEAR, anoAtual);
              cal.set(Calendar.MONTH, mesAtual);
              cal.set(Calendar.DAY_OF_MONTH, 1);
              
              int primeiroDiaSemana = cal.get(Calendar.DAY_OF_WEEK);
              int diasNoMes = cal.getActualMaximum(Calendar.DAY_OF_MONTH);
              
              String[] nomesMeses = {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", 
                                     "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"};
              
              // BUSCAR CONSULTAS DO MÊS
              String sqlConsultas = 
                  "SELECT " +
                  "  a.idAgendamento, " +
                  "  a.dataHrAgenda, " +
                  "  a.tipoServ, " +
                  "  a.statusAgendamento, " +
                  "  c.nomeCompleto as cliente, " +
                  "  e.localidade, " +
                  "  DAY(a.dataHrAgenda) as dia " +
                  "FROM agendamento a " +
                  "JOIN agenda ag ON ag.idAgendamento = a.idAgendamento " +
                  "JOIN cliente c ON c.NIF = ag.NIF " +
                  "JOIN escalado e ON e.nLicenca = ? " +
                  "JOIN horario h ON h.localidade = e.localidade AND h.diaUtil = e.diaUtil " +
                  "WHERE MONTH(a.dataHrAgenda) = ? " +
                  "  AND YEAR(a.dataHrAgenda) = ? " +
                  "  AND CASE DAYOFWEEK(a.dataHrAgenda) " +
                  "    WHEN 2 THEN 'Segunda' " +
                  "    WHEN 3 THEN 'Terça' " +
                  "    WHEN 4 THEN 'Quarta' " +
                  "    WHEN 5 THEN 'Quinta' " +
                  "    WHEN 6 THEN 'Sexta' " +
                  "  END = e.diaUtil " +
                  "  AND TIME(a.dataHrAgenda) >= h.horaInicio " +
                  "  AND TIME(a.dataHrAgenda) < h.horaFim " +
                  "ORDER BY a.dataHrAgenda";
              
              PreparedStatement psCons = con.prepareStatement(sqlConsultas);
              psCons.setString(1, nLicenca);
              psCons.setInt(2, mesAtual + 1);
              psCons.setInt(3, anoAtual);
              ResultSet rsCons = psCons.executeQuery();
              
              Map<Integer, List<Map<String, Object>>> consultasPorDia = new HashMap<>();
              SimpleDateFormat sdfHora = new SimpleDateFormat("HH:mm");
              
              while (rsCons.next()) {
                  int dia = rsCons.getInt("dia");
                  Map<String, Object> consulta = new HashMap<>();
                  consulta.put("id", rsCons.getInt("idAgendamento"));
                  consulta.put("dataHora", rsCons.getTimestamp("dataHrAgenda"));
                  consulta.put("tipo", rsCons.getString("tipoServ"));
                  consulta.put("status", rsCons.getString("statusAgendamento"));
                  consulta.put("cliente", rsCons.getString("cliente"));
                  consulta.put("localidade", rsCons.getString("localidade"));
                  
                  if (!consultasPorDia.containsKey(dia)) {
                      consultasPorDia.put(dia, new ArrayList<>());
                  }
                  consultasPorDia.get(dia).add(consulta);
              }
              rsCons.close();
              psCons.close();
              
              // BUSCAR DIAS DE TRABALHO
              String sqlDiasTrabalho = 
                  "SELECT DISTINCT e.diaUtil FROM escalado e WHERE e.nLicenca = ?";
              PreparedStatement psDias = con.prepareStatement(sqlDiasTrabalho);
              psDias.setString(1, nLicenca);
              ResultSet rsDias = psDias.executeQuery();
              
              Set<String> diasTrabalho = new HashSet<>();
              while (rsDias.next()) {
                  diasTrabalho.add(rsDias.getString("diaUtil"));
              }
              rsDias.close();
              psDias.close();
  %>
  
  <!-- CALENDÁRIO -->
  <div class="calendario">
    <div class="calendario-header">
      <div class="calendario-mes"><%= nomesMeses[mesAtual] %> <%= anoAtual %></div>
      <div class="calendario-nav">
        <select id="mesSelect" onchange="mudarMes()">
          <% for (int i = 0; i < 12; i++) { %>
            <option value="<%= i %>" <%= i == mesAtual ? "selected" : "" %>><%= nomesMeses[i] %></option>
          <% } %>
        </select>
        <select id="anoSelect" onchange="mudarMes()">
          <% for (int ano = anoAtual - 2; ano <= anoAtual + 2; ano++) { %>
            <option value="<%= ano %>" <%= ano == anoAtual ? "selected" : "" %>><%= ano %></option>
          <% } %>
        </select>
        <button onclick="irParaHoje()">Hoje</button>
      </div>
    </div>
    
    <div class="calendario-grid">
      <!-- Headers dos dias -->
      <div class="calendario-dia-header">Dom</div>
      <div class="calendario-dia-header">Seg</div>
      <div class="calendario-dia-header">Ter</div>
      <div class="calendario-dia-header">Qua</div>
      <div class="calendario-dia-header">Qui</div>
      <div class="calendario-dia-header">Sex</div>
      <div class="calendario-dia-header">Sáb</div>
      
      <%
              // Dias vazios antes do primeiro dia
              for (int i = 1; i < primeiroDiaSemana; i++) {
      %>
        <div class="calendario-dia calendario-dia-vazio"></div>
      <%
              }
              
              // Dias do mês
              for (int dia = 1; dia <= diasNoMes; dia++) {
                  cal.set(Calendar.DAY_OF_MONTH, dia);
                  int diaSemana = cal.get(Calendar.DAY_OF_WEEK);
                  
                  String diaSemanaTexto = "";
                  boolean ehDiaTrabalho = false;
                  
                  if (diaSemana == 2 && diasTrabalho.contains("Segunda")) {
                      diaSemanaTexto = "Segunda";
                      ehDiaTrabalho = true;
                  } else if (diaSemana == 3 && diasTrabalho.contains("Terça")) {
                      diaSemanaTexto = "Terça";
                      ehDiaTrabalho = true;
                  } else if (diaSemana == 4 && diasTrabalho.contains("Quarta")) {
                      diaSemanaTexto = "Quarta";
                      ehDiaTrabalho = true;
                  } else if (diaSemana == 5 && diasTrabalho.contains("Quinta")) {
                      diaSemanaTexto = "Quinta";
                      ehDiaTrabalho = true;
                  } else if (diaSemana == 6 && diasTrabalho.contains("Sexta")) {
                      diaSemanaTexto = "Sexta";
                      ehDiaTrabalho = true;
                  }
                  
                  List<Map<String, Object>> consultasDia = consultasPorDia.get(dia);
                  int numConsultas = (consultasDia != null) ? consultasDia.size() : 0;
                  
                  String classes = "calendario-dia";
                  if (dia == diaHoje && mesAtual == mesHoje && anoAtual == anoHoje) {
                      classes += " calendario-dia-hoje";
                  } else if (numConsultas > 0) {
                      classes += " calendario-dia-consultas";
                  } else if (ehDiaTrabalho) {
                      classes += " calendario-dia-trabalho";
                  }
                  
                  String onclick = (numConsultas > 0) ? "onclick=\"mostrarConsultas(" + dia + ")\"" : "";
      %>
        <div class="<%= classes %>" <%= onclick %> title="<%= ehDiaTrabalho ? "Dia de trabalho" : "Não trabalha" %>">
          <div class="calendario-dia-numero"><%= dia %></div>
          <% if (numConsultas > 0) { %>
            <div class="calendario-consultas-count"><%= numConsultas %> consulta<%= numConsultas > 1 ? "s" : "" %></div>
          <% } %>
        </div>
      <%
              }
      %>
    </div>
    
    <div class="legenda">
      <div class="legenda-item">
        <div class="legenda-cor" style="background: #FFF3CD; border-color: #FFC107;"></div>
        <span>Hoje</span>
      </div>
      <div class="legenda-item">
        <div class="legenda-cor" style="background: #E8F4F8; border-color: #4A90E2;"></div>
        <span>Dia de trabalho</span>
      </div>
      <div class="legenda-item">
        <div class="legenda-cor" style="background: #D4EDDA; border-color: #28A745;"></div>
        <span>Com consultas</span>
      </div>
      <div class="legenda-item">
        <div class="legenda-cor" style="background: white; border-color: #E7EEF4;"></div>
        <span>Folga</span>
      </div>
    </div>
  </div>
  
  <!-- CONSULTAS POR DIA -->
  <%
              for (Map.Entry<Integer, List<Map<String, Object>>> entry : consultasPorDia.entrySet()) {
                  int dia = entry.getKey();
                  List<Map<String, Object>> consultas = entry.getValue();
  %>
  <div class="consultas-dia" id="consultas-dia-<%= dia %>">
    <h3>Consultas de <%= dia %> de <%= nomesMeses[mesAtual] %></h3>
    <%
                  for (Map<String, Object> consulta : consultas) {
                      Timestamp dataHora = (Timestamp) consulta.get("dataHora");
                      String tipo = (String) consulta.get("tipo");
                      String status = (String) consulta.get("status");
                      String cliente = (String) consulta.get("cliente");
                      String localidade = (String) consulta.get("localidade");
                      
                      String classItem = "consulta-item";
                      if ("realizado".equals(status)) {
                          classItem += " realizada";
                      }
    %>
    <div class="<%= classItem %>">
      <div class="consulta-hora"><%= sdfHora.format(dataHora) %></div>
      <div class="consulta-tipo"><%= tipo %></div>
      <div class="consulta-cliente">Cliente: <%= cliente %></div>
      <div class="consulta-clinica"><img src="../images/icon-pin.png" class="icon-inline" alt="Clínica"> Clínica: <%= localidade %></div>
      <div class="consulta-cliente">Status: <%= status %></div>
    </div>
    <%
                  }
    %>
  </div>
  <%
              }
  %>
  
  <%
          }
          
      } catch (Exception e) {
  %>
          <div class="mensagem erro">Erro: <%= e.getMessage() %></div>
  <%
          e.printStackTrace();
      } finally {
          manipula.desligar();
      }
  }
  %>
</div>

<script>
function mudarMes() {
  var mes = document.getElementById('mesSelect').value;
  var ano = document.getElementById('anoSelect').value;
  var nLicenca = '<%= request.getParameter("nLicenca") != null ? request.getParameter("nLicenca") : "" %>';
  window.location.href = 'perfil_veterinario.jsp?nLicenca=' + nLicenca + '&mes=' + mes + '&ano=' + ano;
}

function irParaHoje() {
  var nLicenca = '<%= request.getParameter("nLicenca") != null ? request.getParameter("nLicenca") : "" %>';
  window.location.href = 'perfil_veterinario.jsp?nLicenca=' + nLicenca;
}

function mostrarConsultas(dia) {
  var todasConsultas = document.querySelectorAll('.consultas-dia');
  todasConsultas.forEach(function(el) {
    el.classList.remove('active');
  });
  
  var consultasDia = document.getElementById('consultas-dia-' + dia);
  if (consultasDia) {
    consultasDia.classList.add('active');
	consultasDia.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
	}
}
</script>
</body>
</html>