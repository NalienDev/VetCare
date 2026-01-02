<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Lista de Chamada</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
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
    <p>Agendamentos de hoje e futuros por data-hora.</p>
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
      <button type="submit" class="btn btn-primary">📋 Ver Lista de Chamada</button>
    </form>
  </div>

  <%
  String nLicenca = request.getParameter("nLicenca");
  if (nLicenca != null && !nLicenca.isEmpty()) {
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
          String sql = 
              "SELECT a.idAgendamento, a.dataHrAgenda, a.tipoServ, a.statusAgendamento, " +
              "       c.nomeCompleto AS cliente, c.NIF " +
              "FROM agendamento a " +
              "INNER JOIN agenda ag ON a.idAgendamento = ag.idAgendamento " +
              "INNER JOIN cliente c ON ag.NIF = c.NIF " +
              "WHERE a.dataHrAgenda >= CURDATE() " +
              "ORDER BY a.dataHrAgenda ASC " +
              "LIMIT 50";
          
          Connection con = manipula.getLigacao();
          PreparedStatement ps = con.prepareStatement(sql);
          ResultSet rs = ps.executeQuery();
          
          SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
          boolean temAgendamentos = false;
  %>
          
          <div class="table-card">
            <h3>📅 Seus Agendamentos</h3>
            <table class="tabela">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Data/Hora</th>
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

              // ✅ Definir badge conforme status real
              String badgeClass = "badge badge-success"; // default
              String statusTexto = status;

              if ("marcado".equalsIgnoreCase(status)) {
                  badgeClass = "badge badge-success";
                  statusTexto = "Marcado";
              } else if ("cancelado".equalsIgnoreCase(status)) {
                  badgeClass = "badge badge-danger";
                  statusTexto = "Cancelado";
              } else if ("concluido".equalsIgnoreCase(status)) {
                  badgeClass = "badge badge-primary";
                  statusTexto = "Concluído";
              } else {
                  badgeClass = "badge";
              }
          %>
              <tr>
                  <td><strong><%= idAgend %></strong></td>
                  <td><%= sdf.format(dataHora) %></td>
                  <td><%= rs.getString("cliente") %></td>
                  <td><%= rs.getString("NIF") %></td>
                  <td><%= tipoServ %></td>

                  <!-- ✅ STATUS REAL DA BD -->
                  <td>
                      <span class="<%= badgeClass %>">
                          <%= statusTexto %>
                      </span>
                  </td>

                  <td>
                      <% if ("marcado".equalsIgnoreCase(status)) { %>
                          <!-- ✅ só deixa atender se estiver marcado -->
                          <a href="selecionar_animal_atender.jsp?idAgendamento=<%= idAgend %>&nif=<%= rs.getString("NIF") %>" 
                             class="btn btn-primary">
                              📝 Atender
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
                  <td colspan="7" style="text-align: center; padding: 2rem;">
                      📭 Não há agendamentos futuros
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
          
      } catch (Exception e) {
  %>
          <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
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
