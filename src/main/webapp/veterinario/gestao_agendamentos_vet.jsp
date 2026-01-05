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
    <h1>Gestão de Agendamentos</h1>
    <p>Agendar ou cancelar serviços pendentes.</p>
  </div>
</section>

<%
String mensagem = "";
String tipoMensagem = "";
String acao = request.getParameter("acao");

if (acao != null && "POST".equalsIgnoreCase(request.getMethod())) {
    String idAgendamento = request.getParameter("idAgendamento");
    
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        Connection con = manipula.getLigacao();
        
        if ("cancelar".equals(acao)) {
            String sql = "UPDATE agendamento SET statusAgendamento = 'cancelado' WHERE idAgendamento = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(idAgendamento));
            
            if (ps.executeUpdate() > 0) {
                mensagem = "✅ Agendamento cancelado com sucesso!";
                tipoMensagem = "sucesso";
            } else {
                mensagem = "Erro ao cancelar agendamento";
                tipoMensagem = "erro";
            }
            ps.close();
        }
    } catch (Exception e) {
        mensagem = "Erro: " + e.getMessage();
        tipoMensagem = "erro";
        e.printStackTrace();
    } finally {
        manipula.desligar();
    }
}
%>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar ao Menu</a>

  <% if (!mensagem.isEmpty()) { %>
      <div class="mensagem <%= tipoMensagem %>">
          <% if (tipoMensagem.equals("erro")) { %>
              <img src="../images/icon-cancel.png" class="icon-inline" alt="Erro">
          <% } %>
          <%= mensagem %>
      </div>
  <% } %>

  <div style="margin:20px 0;">
    <a href="agendar_servico_vet.jsp" class="btn btn-primary">
      <img src="../images/icon-add.png" class="icon-inline" alt="Adicionar"> Agendar Novo Serviço
    </a>
  </div>

  <div class="table-card">
    <h3>Agendamentos Pendentes</h3>
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
        Configura cfg = new Configura();
        Manipula manipula = new Manipula(cfg);
        
        try {
            String sql = 
                "SELECT a.idAgendamento, a.dataHrAgenda, a.tipoServ, a.statusAgendamento, " +
                "       c.nomeCompleto " +
                "FROM agendamento a " +
                "INNER JOIN agenda ag ON a.idAgendamento = ag.idAgendamento " +
                "INNER JOIN cliente c ON ag.NIF = c.NIF " +
                "WHERE a.statusAgendamento = 'marcado' " +
                "ORDER BY a.dataHrAgenda ASC " +
                "LIMIT 50";
            
            Connection con = manipula.getLigacao();
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
                        <span class="badge badge-success">
                            <%= status %>
                        </span>
                    </td>
                    <td>
                        <form method="POST" style="display: inline;">
                            <input type="hidden" name="idAgendamento" value="<%= idAgend %>">
                            <input type="hidden" name="acao" value="cancelar">
                            <button type="submit" class="btn btn-danger" 
                                    onclick="return confirm('Tem a certeza que deseja cancelar este agendamento?')">
                                <img src="../images/icon-cancel.png" class="icon-inline" alt="Cancelar"> Cancelar
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
                <td colspan="6" style="text-align: center; padding: 2rem; color: red;">
                    <img src="../images/icon-cancel.png" class="icon-inline" alt="Erro"> Erro ao carregar dados: <%= e.getMessage() %>
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