<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Agendar Serviço</title>
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
    <h1>Agendar Serviço</h1>
    <p>Marcar serviços para clientes existentes com distribuição automática.</p>
  </div>
</section>

<%
String mensagem = "";
String tipoMensagem = "";
String detalhesDistribuicao = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String nif = request.getParameter("nif");
    String localidade = request.getParameter("localidade");
    String dataHoraStr = request.getParameter("dataHora");
    String tipoServ = request.getParameter("tipoServ");
    String custosStr = request.getParameter("custos");
    
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        Connection con = manipula.getLigacao();
        con.setAutoCommit(false);
        
        java.sql.Timestamp dataHora = java.sql.Timestamp.valueOf(dataHoraStr.replace("T", " ") + ":00");
        java.math.BigDecimal custos = custosStr != null && !custosStr.isEmpty() ? new java.math.BigDecimal(custosStr) : null;
        
        Calendar cal = Calendar.getInstance();
        cal.setTime(dataHora);
        int diaSemana = cal.get(Calendar.DAY_OF_WEEK); 
        
        String diaUtil = null;
        if (diaSemana == 2) diaUtil = "Segunda";
        else if (diaSemana == 3) diaUtil = "Terça";
        else if (diaSemana == 4) diaUtil = "Quarta";
        else if (diaSemana == 5) diaUtil = "Quinta";
        else if (diaSemana == 6) diaUtil = "Sexta";
        
        if (diaUtil == null) {
            mensagem = "A clínica não funciona aos fins de semana!";
            tipoMensagem = "erro";
            con.rollback();
        } else {
            
            String sqlCheckHorario = 
                "SELECT horaInicio, horaFim FROM horario " +
                "WHERE localidade = ? AND diaUtil = ?";
            
            PreparedStatement psCheckHorario = con.prepareStatement(sqlCheckHorario);
            psCheckHorario.setString(1, localidade);
            psCheckHorario.setString(2, diaUtil);
            ResultSet rsCheckHorario = psCheckHorario.executeQuery();
            
            if (!rsCheckHorario.next()) {
                mensagem = "A clínica " + localidade + " não funciona às " + diaUtil + "-feiras!";
                tipoMensagem = "erro";
                rsCheckHorario.close();
                psCheckHorario.close();
                con.rollback();
            } else {
                Time horaInicio = rsCheckHorario.getTime("horaInicio");
                Time horaFim = rsCheckHorario.getTime("horaFim");
                rsCheckHorario.close();
                psCheckHorario.close();
                
                SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
                String horaConsulta = timeFormat.format(dataHora);
                
                if (horaConsulta.compareTo(horaInicio.toString()) < 0 || 
                    horaConsulta.compareTo(horaFim.toString()) >= 0) {
                    mensagem = "Hora fora do horário de funcionamento! " +
                              "A clínica funciona das " + horaInicio.toString().substring(0,5) + 
                              " às " + horaFim.toString().substring(0,5);
                    tipoMensagem = "erro";
                    con.rollback();
                } else {
                    
                    String sqlVets = 
                        "SELECT e.nLicenca, v.nome, " +
                        "  COUNT(a.idAgendamento) as numConsultas " +
                        "FROM escalado e " +
                        "JOIN veterinario v ON v.nLicenca = e.nLicenca " +
                        "LEFT JOIN agendamento a ON " +
                        "  DATE(a.dataHrAgenda) = DATE(?) " +
                        "  AND a.statusAgendamento != 'cancelado' " +
                        "  AND CASE DAYOFWEEK(a.dataHrAgenda) " +
                        "    WHEN 2 THEN 'Segunda' " +
                        "    WHEN 3 THEN 'Terça' " +
                        "    WHEN 4 THEN 'Quarta' " +
                        "    WHEN 5 THEN 'Quinta' " +
                        "    WHEN 6 THEN 'Sexta' " +
                        "  END = e.diaUtil " +
                        "WHERE e.localidade = ? AND e.diaUtil = ? " +
                        "GROUP BY e.nLicenca, v.nome " +
                        "ORDER BY numConsultas ASC, e.nLicenca ASC " +
                        "LIMIT 1";
                    
                    PreparedStatement psVets = con.prepareStatement(sqlVets);
                    psVets.setTimestamp(1, dataHora);
                    psVets.setString(2, localidade);
                    psVets.setString(3, diaUtil);
                    ResultSet rsVets = psVets.executeQuery();
                    
                    if (!rsVets.next()) {
                        mensagem = "Não há veterinários disponíveis neste horário!";
                        tipoMensagem = "erro";
                        rsVets.close();
                        psVets.close();
                        con.rollback();
                    } else {
                        String nLicencaVet = rsVets.getString("nLicenca");
                        String nomeVet = rsVets.getString("nome");
                        int numConsultasAtual = rsVets.getInt("numConsultas");
                        rsVets.close();
                        psVets.close();
                        
                        String sqlAgendamento = 
                            "INSERT INTO agendamento (dataHrAgenda, tipoServ, statusAgendamento, custos, primeiraVez) " +
                            "VALUES (?, ?, 'marcado', ?, FALSE)";
                        
                        PreparedStatement psAgend = con.prepareStatement(sqlAgendamento, Statement.RETURN_GENERATED_KEYS);
                        psAgend.setTimestamp(1, dataHora);
                        psAgend.setString(2, tipoServ);
                        psAgend.setBigDecimal(3, custos);
                        
                        if (psAgend.executeUpdate() > 0) {
                            ResultSet rsKeys = psAgend.getGeneratedKeys();
                            if (rsKeys.next()) {
                                int idAgendamento = rsKeys.getInt(1);
                                
                                String sqlAgenda = "INSERT INTO agenda (idAgendamento, NIF) VALUES (?, ?)";
                                PreparedStatement psAgenda = con.prepareStatement(sqlAgenda);
                                psAgenda.setInt(1, idAgendamento);
                                psAgenda.setString(2, nif);
                                psAgenda.executeUpdate();
                                psAgenda.close();
                                
                                con.commit();
                                
                                mensagem = "Serviço agendado com sucesso! ID: " + idAgendamento;
                                tipoMensagem = "sucesso";
                                
                                detalhesDistribuicao = 
                                    "<strong>Distribuição Automática:</strong><br>" +
                                    "<img src='../images/icon-vet.png' class='icon-inline' alt='Veterinário'> Veterinário atribuído: <strong>" + nomeVet + "</strong> (Licença: " + nLicencaVet + ")<br>" +
                                    "📊 Consultas já atribuídas hoje: " + numConsultasAtual + "<br>" +
                                    "<img src='../images/icon-home.png' class='icon-inline' alt='Clínica'> Clínica: " + localidade + "<br>" +
                                    "<img src='../images/icon-calendar.png' class='icon-inline' alt='Data'> Data: " + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(dataHora);
                            }
                            rsKeys.close();
                        } else {
                            con.rollback();
                            mensagem = "Erro ao criar agendamento";
                            tipoMensagem = "erro";
                        }
                        psAgend.close();
                    }
                }
            }
        }
        
        con.setAutoCommit(true);
        
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
  <a href="gestao_agendamentos_vet.jsp" class="btn-voltar">← Voltar</a>

  <% if (!mensagem.isEmpty()) { %>
      <div class="mensagem <%= tipoMensagem %>">
          <%= tipoMensagem.equals("sucesso") ? "✅" : "<img src='../images/icon-cancel.png' class='icon-inline' alt='Erro'>" %> <%= mensagem %>
          <% if (!detalhesDistribuicao.isEmpty()) { %>
              <div style="margin-top: 15px; padding-top: 15px; border-top: 2px solid #28A745;">
                  <%= detalhesDistribuicao %>
              </div>
          <% } %>
      </div>
  <% } %>

  <div style="margin:20px 0; padding:15px; background:#E8F4F8; border-left: 4px solid #4A90E2; border-radius:10px;">
    <strong>Distribuição Automática:</strong> O sistema atribui automaticamente a consulta ao veterinário 
    com menos consultas naquele dia, garantindo distribuição equilibrada da carga de trabalho.
  </div>

  <div class="formulario">
    <form method="POST">
      <div class="form-group">
        <label>Clínica (Localidade) *</label>
        <select name="localidade" required>
          <option value="">Selecione a clínica...</option>
          <%
          Configura cfg = new Configura();
          Manipula manipula = new Manipula(cfg);
          
          try {
              Connection con = manipula.getLigacao();
              String sql = "SELECT DISTINCT localidade FROM horario ORDER BY localidade";
              PreparedStatement ps = con.prepareStatement(sql);
              ResultSet rs = ps.executeQuery();
              
              while (rs.next()) {
                  String loc = rs.getString("localidade");
          %>
                  <option value="<%= loc %>"><%= loc %></option>
          <%
              }
              rs.close();
              ps.close();
          } catch (Exception e) {
              e.printStackTrace();
          } finally {
              manipula.desligar();
          }
          %>
        </select>
      </div>
      
      <div class="form-group">
        <label>NIF do Cliente *</label>
        <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9" required
               placeholder="Cliente que já tem ficha">
        <small style="color: #666; font-size: 12px; display: block; margin-top: 5px;">
          ℹ️ Apenas clientes existentes (retorno)
        </small>
      </div>
      
      <div class="form-group">
        <label>Data e Hora *</label>
        <input type="datetime-local" name="dataHora" required>
        <small style="color: #666; font-size: 12px; display: block; margin-top: 5px;">
          ⚠️ Apenas dias úteis (Segunda a Sexta) dentro do horário da clínica
        </small>
      </div>
      
      <div class="form-group">
        <label>Tipo de Serviço *</label>
        <select name="tipoServ" required>
          <option value="">Selecione...</option>
          <option value="Consulta Médica">Consulta Médica</option>
          <option value="Exame Físico">Exame Físico</option>
          <option value="Exame Diagnóstico">Exame Diagnóstico</option>
          <option value="Vacinação">Vacinação</option>
          <option value="Desparasitação">Desparasitação</option>
          <option value="Intervenção Cirúrgica">Intervenção Cirúrgica</option>
          <option value="Medicina Preventiva">Medicina Preventiva</option>
          <option value="Tratamento Terapêutico">Tratamento Terapêutico</option>
        </select>
      </div>
      
      <div class="form-group">
        <label>Custo (€)</label>
        <input type="number" name="custos" step="0.01" min="0" placeholder="Opcional">
      </div>
      
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">
          <img src="../images/icon-calendar.png" class="icon-inline" alt="Agendar"> Agendar com Distribuição Automática
        </button>
        <button type="reset" class="btn btn-secondary">
          <img src="../images/icon-reset.png" class="icon-inline" alt="Limpar"> Limpar
        </button>
      </div>
    </form>
  </div>
  
</div>

</body>
</html>