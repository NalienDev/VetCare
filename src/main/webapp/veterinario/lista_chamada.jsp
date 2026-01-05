<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Lista de Chamada</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  <style>
    .icon-inline {
      width: 18px;
      height: 18px;
      vertical-align: middle;
      margin: -2px 4px 0 0;
      display: inline-block;
    }
    
    .btn .icon-inline {
      width: 16px;
      height: 16px;
      margin-right: 6px;
    }
    
    h1 .icon-inline, h2 .icon-inline, h3 .icon-inline {
      width: 24px;
      height: 24px;
      margin-right: 8px;
    }
    
    .tabela .icon-inline {
      width: 16px;
      height: 16px;
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
    <h1>Lista de Chamada</h1>
    <p>Suas consultas agendadas nos dias em que trabalha.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar ao Menu</a>

  <div class="formulario">
    <form method="GET">
      <div class="form-group">
        <label>Número de Licença do Veterinário</label>
        <input type="text" name="nLicenca" required 
               value="<%= request.getParameter("nLicenca") != null ? request.getParameter("nLicenca") : "" %>"
               placeholder="Digite sua licença profissional">
      </div>
      <button type="submit" class="btn btn-primary">Ver as Minhas Consultas</button>
    </form>
  </div>

  <%
  String nLicenca = request.getParameter("nLicenca");
  String mostrarTodas = request.getParameter("mostrarTodas");
  boolean exibirHistorico = "true".equals(mostrarTodas);
  
  if (nLicenca != null && !nLicenca.isEmpty()) {
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
          Connection con = manipula.getLigacao();
          
          String sqlCheckVet = "SELECT nome FROM veterinario WHERE nLicenca = ?";
          PreparedStatement psCheckVet = con.prepareStatement(sqlCheckVet);
          psCheckVet.setString(1, nLicenca);
          ResultSet rsCheckVet = psCheckVet.executeQuery();
          
          if (!rsCheckVet.next()) {
              rsCheckVet.close();
              psCheckVet.close();
  %>
              <div class="mensagem erro">
                  <img src="../images/icons/icon-cancel.png" class="icon-inline" alt="Erro"> Veterinário com licença <%= nLicenca %> não encontrado.
              </div>
  <%
          } else {
              String nomeVet = rsCheckVet.getString("nome");
              rsCheckVet.close();
              psCheckVet.close();
  %>
              <div class="mensagem" style="background: #E8F4F8; border-left: 4px solid #4A90E2;">
                    <strong><%= nomeVet %></strong> (Licença: <%= nLicenca %>)
              </div>

              <div style="margin: 20px 0; text-align: center;">
                  <% if (!exibirHistorico) { %>
                      <a href="?nLicenca=<%= nLicenca %>&mostrarTodas=true" 
                         class="btn btn-secondary" 
                         style="background: #6C757D; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; display: inline-block; font-weight: 700;">
                            Ver Histórico Completo (Incluir Consultas Anteriores)
                      </a>
                  <% } else { %>
                      <a href="?nLicenca=<%= nLicenca %>" 
                         class="btn btn-primary" 
                         style="padding: 12px 24px; border-radius: 8px; text-decoration: none; display: inline-block; font-weight: 700;">
                            Ver Apenas Próximas Consultas
                      </a>
                  <% } %>
              </div>
  <%
              String condicaoData = exibirHistorico ? "" : "AND a.dataHrAgenda >= CURDATE() ";
              
              String sql = 
                  "SELECT DISTINCT " +
                  "  a.idAgendamento, " +
                  "  a.dataHrAgenda, " +
                  "  a.tipoServ, " +
                  "  a.statusAgendamento, " +
                  "  c.nomeCompleto AS cliente, " +
                  "  c.NIF, " +
                  "  e.localidade " +
                  "FROM agendamento a " +
                  "INNER JOIN agenda ag ON a.idAgendamento = ag.idAgendamento " +
                  "INNER JOIN cliente c ON ag.NIF = c.NIF " +
                  "INNER JOIN escalado e ON e.nLicenca = ? " +
                  "INNER JOIN horario h ON h.localidade = e.localidade AND h.diaUtil = e.diaUtil " +
                  "WHERE DAYOFWEEK(a.dataHrAgenda) BETWEEN 2 AND 6 " + // Segunda a Sexta
                  condicaoData +
                  "  AND e.diaUtil = CASE DAYOFWEEK(a.dataHrAgenda) " +
                  "      WHEN 2 THEN 'Segunda' " +
                  "      WHEN 3 THEN 'Terça' " +
                  "      WHEN 4 THEN 'Quarta' " +
                  "      WHEN 5 THEN 'Quinta' " +
                  "      WHEN 6 THEN 'Sexta' " +
                  "    END " +
                  "  AND TIME(a.dataHrAgenda) >= h.horaInicio " +
                  "  AND TIME(a.dataHrAgenda) < h.horaFim " +
                  "ORDER BY a.dataHrAgenda " + (exibirHistorico ? "DESC" : "ASC") + " " +
                  "LIMIT 500";
              
              PreparedStatement ps = con.prepareStatement(sql);
              ps.setString(1, nLicenca);
              ResultSet rs = ps.executeQuery();
              
              SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
              SimpleDateFormat sdfDia = new SimpleDateFormat("EEEE", new Locale("pt", "PT"));
              boolean temAgendamentos = false;
  %>
              
              <div class="table-card">
                <h3><%= exibirHistorico ? "Histórico Completo de Consultas" : "As Suas Próximas Consultas" %></h3>
                <table class="tabela">
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Data/Hora</th>
                      <th>Dia da Semana</th>
                      <th>Clínica</th>
                      <th>Cliente</th>
                      <th>NIF</th>
                      <th>Tipo Serviço</th>
                      <th>Status</th>
                      <th>Ações</th>
                    </tr>
                  </thead>
                  <tbody>
              <%
              
              while (rs.next()) {
                  temAgendamentos = true;

                  int idAgend = rs.getInt("idAgendamento");
                  Timestamp dataHora = rs.getTimestamp("dataHrAgenda");
                  String status = rs.getString("statusAgendamento");
                  String tipoServ = rs.getString("tipoServ");
                  String localidade = rs.getString("localidade");

                  boolean isPassada = dataHora.getTime() < System.currentTimeMillis();
                  String rowStyle = isPassada && exibirHistorico ? "background-color: #f8f9fa; opacity: 0.8;" : "";

                  String badgeClass = "badge badge-success";
                  String statusTexto = status;

                  if ("marcado".equalsIgnoreCase(status)) {
                      badgeClass = "badge badge-success";
                      statusTexto = "Marcado";
                  } else if ("cancelado".equalsIgnoreCase(status)) {
                      badgeClass = "badge badge-danger";
                      statusTexto = "Cancelado";
                  } else if ("realizado".equalsIgnoreCase(status)) {
                      badgeClass = "badge badge-primary";
                      statusTexto = "Realizado";
                  } else if ("confirmado".equalsIgnoreCase(status)) {
                      badgeClass = "badge badge-info";
                      statusTexto = "Confirmado";
                  }
              %>
                  <tr style="<%= rowStyle %>">
                      <td><strong><%= idAgend %></strong></td>
                      <td><%= sdf.format(dataHora) %></td>
                      <td><%= sdfDia.format(dataHora) %></td>
                      <td><strong><%= localidade %></strong></td>
                      <td><%= rs.getString("cliente") %></td>
                      <td><%= rs.getString("NIF") %></td>
                      <td><%= tipoServ %></td>
                      <td>
                          <span class="<%= badgeClass %>">
                              <%= statusTexto %>
                          </span>
                      </td>
                      <td>
                          <% if ("marcado".equalsIgnoreCase(status)) { %>
                              <a href="selecionar_animal_atender.jsp?idAgendamento=<%= idAgend %>&nif=<%= rs.getString("NIF") %>" 
                                 class="btn btn-primary">
                                  <img src="../images/icon-clipboard2.png" class="icon-inline" alt="Atender"> Atender
                              </a>
                          <% } else { %>
                              <span style="color:#57606F; font-weight:700;">
                                  —
                              </span>
                          <% } %>
                      </td>
                  </tr>
              <%
              }
              
              if (!temAgendamentos) {
              %>
                  <tr>
                      <td colspan="9" style="text-align: center; padding: 2rem;">
                          <div style="color:#57606F; font-weight:700; margin-bottom: 16px;">
                              🔭 <%= exibirHistorico ? "Não há consultas registradas" : "Não há consultas agendadas para você" %>
                          </div>
                          <div style="background: #FFF3CD; border: 2px solid #FFC107; border-radius: 12px; padding: 16px; max-width: 600px; margin: 0 auto; font-weight: 700; color: #856404;">
                              ℹ️ As consultas aparecem aqui quando são agendadas nos dias e horários em que você está escalado.<br>
                              <strong style="display: block; margin-top: 8px;">
                                  Para ver seu horário de trabalho, acesse "Meu Perfil".
                              </strong>
                          </div>
                      </td>
                  </tr>
              <%
              }
              %>
                  </tbody>
                </table>
              </div>
  <%
              
              rs.close();
              ps.close();
          }
          
      } catch (Exception e) {
  %>
          <div class="mensagem erro"><img src="../images/icon-cancel.png" class="icon-inline" alt="Erro"> Erro: <%= e.getMessage() %></div>
  <%
          e.printStackTrace();
      } finally {
          manipula.desligar();
      }
  }
  %>
</div>

</body>
</html>