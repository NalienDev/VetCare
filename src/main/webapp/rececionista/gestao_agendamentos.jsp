<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Gestão de Agendamentos</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">

  <style>
    .reagendar-box{
      display:flex;
      align-items:center;
      gap:8px;
      flex-wrap:wrap;
      margin-bottom:10px;
    }
    .reagendar-box input[type="datetime-local"]{
      padding:10px;
      border-radius:10px;
      border:1px solid #DDE6EE;
      font-weight:700;
      background:#F8FAFC;
      max-width:220px;
    }

    /* ícones inline (consistência com outros JSPs) */
    .icon-inline {
      width: 16px;
      height: 16px;
      vertical-align: middle;
      margin: -2px 6px 0 0;
      display: inline-block;
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
      <a href="menu.jsp">Rececionista</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Gestão de Agendamentos</h1>
    <p>Reagendar ou cancelar serviços pendentes.</p>
  </div>
</section>

<%
String mensagem = "";
String tipoMensagem = "";
String acao = request.getParameter("acao");

Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

if (acao != null && "POST".equalsIgnoreCase(request.getMethod())) {
    String idAgendamento = request.getParameter("idAgendamento");

    try {
        Connection con = manipula.getLigacao();

        // CANCELAR
        if ("cancelar".equals(acao)) {
            String sql = "UPDATE agendamento SET statusAgendamento='cancelado' WHERE idAgendamento=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(idAgendamento));

            if (ps.executeUpdate() > 0) {
                mensagem = "✅ Agendamento cancelado com sucesso!";
                tipoMensagem = "sucesso";
            } else {
                mensagem = "❌ Erro ao cancelar agendamento";
                tipoMensagem = "erro";
            }
            ps.close();
        }

        // REAGENDAR
        if ("reagendar".equals(acao)) {
            String novaData = request.getParameter("novaData");

            if (novaData != null && !novaData.trim().isEmpty()) {
                try {
                    novaData = novaData.replace("T"," ") + ":00";

                    String sql = "UPDATE agendamento SET dataHrAgenda=?, statusAgendamento='marcado' WHERE idAgendamento=?";
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setTimestamp(1, java.sql.Timestamp.valueOf(novaData));
                    ps.setInt(2, Integer.parseInt(idAgendamento));

                    ps.executeUpdate();
                    ps.close();

                    mensagem = "✅ Agendamento reagendado com sucesso!";
                    tipoMensagem = "sucesso";

                } catch (Exception ex) {
                    mensagem = "❌ Data inválida ou já existe agendamento nessa hora.";
                    tipoMensagem = "erro";
                }
            } else {
                mensagem = "❌ Escolha uma nova data/hora.";
                tipoMensagem = "erro";
            }
        }

    } catch (Exception e) {
        mensagem = "❌ Erro: " + e.getMessage();
        tipoMensagem = "erro";
        e.printStackTrace();
    }
}
%>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar ao Menu</a>

  <% if (!mensagem.isEmpty()) { %>
      <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <div style="margin:20px 0;">
    <a href="agendar_servico.jsp" class="btn btn-primary">
      <img src="../images/icon-add.png" class="icon-inline" alt="Agendar">
      Agendar Novo Serviço
    </a>
  </div>

  <div class="table-card">
    <h3>Agendamentos Marcados</h3>
    <table class="tabela">
      <thead>
        <tr>
          <th>ID</th>
          <th>Cliente</th>
          <th>Data/Hora</th>
          <th>Tipo</th>
          <th>Status</th>
          <th>Ações</th>
        </tr>
      </thead>
      <tbody>

        <%
        try {
            Connection con = manipula.getLigacao();

            String sql =
                "SELECT a.idAgendamento, a.dataHrAgenda, a.tipoServ, a.statusAgendamento, c.nomeCompleto " +
                "FROM agendamento a " +
                "INNER JOIN agenda ag ON a.idAgendamento = ag.idAgendamento " +
                "INNER JOIN cliente c ON ag.NIF = c.NIF " +
                "WHERE a.statusAgendamento = 'marcado' " +
                "ORDER BY a.dataHrAgenda ASC " +
                "LIMIT 50";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            boolean temDados = false;

            while (rs.next()) {
                temDados = true;
                int idAgend = rs.getInt("idAgendamento");
                Timestamp dataHora = rs.getTimestamp("dataHrAgenda");
                String tipo = rs.getString("tipoServ");
                String status = rs.getString("statusAgendamento");
                String nomeCliente = rs.getString("nomeCompleto");
        %>

            <tr>
                <td><strong><%= idAgend %></strong></td>
                <td><%= nomeCliente %></td>
                <td><%= sdf.format(dataHora) %></td>
                <td><%= tipo %></td>
                <td>
                    <span class="badge badge-success"><%= status %></span>
                </td>
                <td>

                    <!-- ✅ REAGENDAR -->
                    <form method="POST" class="reagendar-box">
                        <input type="hidden" name="idAgendamento" value="<%= idAgend %>">
                        <input type="hidden" name="acao" value="reagendar">
                        <input type="datetime-local" name="novaData" required>
                        <button type="submit" class="btn btn-primary">
                          <img src="../images/icon-calendar.png" class="icon-inline" alt="Reagendar">
                          Reagendar
                        </button>
                    </form>

                    <!-- ✅ CANCELAR -->
                    <form method="POST" style="display:inline;">
                        <input type="hidden" name="idAgendamento" value="<%= idAgend %>">
                        <input type="hidden" name="acao" value="cancelar">
                        <button type="submit" class="btn btn-danger"
                                onclick="return confirm('Tem a certeza que deseja cancelar este agendamento?')">
                            <img src="../images/icon-cancel.png" class="icon-inline" alt="Cancelar">
                            Cancelar
                        </button>
                    </form>

                </td>
            </tr>

        <%
            }

            if (!temDados) {
        %>
            <tr>
                <td colspan="6" style="text-align: center; padding: 2rem;">
                    📭 Não existem agendamentos pendentes
                </td>
            </tr>
        <%
            }

            rs.close();
            ps.close();

        } catch (Exception e) {
        %>
            <tr>
                <td colspan="6" style="text-align:center; padding:2rem; color:red;">
                    ❌ Erro ao carregar dados: <%= e.getMessage() %>
                </td>
            </tr>
        <%
            e.printStackTrace();
        } finally {
            manipula.desligar();
        }
        %>

      </tbody>
    </table>
  </div>
</div>

</body>
</html>
