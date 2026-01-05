<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Agendar Consulta</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  
  <style>
    .alerta-info {
      background: #EAF6FB;
      border: 2px solid #B8D4E6;
      border-radius: 16px;
      padding: 16px 20px;
      margin-bottom: 24px;
      display: flex;
      align-items: flex-start;
      gap: 12px;
      font-weight: 700;
      color: #0B2A42;
      line-height: 1.5;
    }
    
    .alerta-aviso {
      background: #FFF3CD;
      border: 2px solid #FFC107;
      border-radius: 16px;
      padding: 16px 20px;
      margin-bottom: 24px;
      display: flex;
      align-items: flex-start;
      gap: 12px;
      font-weight: 700;
      color: #856404;
      line-height: 1.5;
    }
    
    .alerta-sucesso {
      background: #D4EDDA;
      border: 2px solid #28A745;
      border-radius: 16px;
      padding: 16px 20px;
      margin-bottom: 24px;
      font-weight: 700;
      color: #155724;
    }
    
    .btn-voltar {
      margin-bottom: 30px;
    }
    
    .icon-inline {
      width: 18px;
      height: 18px;
      vertical-align: middle;
      margin-right: 5px;
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
      <a href="menu.jsp">Tutor</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Agendar Consulta</h1>
    <p>Marque uma consulta veterinária para o seu animal</p>
  </div>
</section>

<%
String mensagem = "";
String tipoMensagem = "";
String detalhesDistribuicao = "";
String nif = request.getParameter("nif");

if ("POST".equalsIgnoreCase(request.getMethod()) && nif != null) {
    String localidade = request.getParameter("localidade");
    String dataHoraStr = request.getParameter("dataHora");
    String tipoServ = request.getParameter("tipoServ");
    
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        Connection con = manipula.getLigacao();
        
        PreparedStatement psCheck = con.prepareStatement(
            "SELECT COUNT(*) as total FROM agenda ag " +
            "JOIN agendamento a ON a.idAgendamento = ag.idAgendamento " +
            "WHERE ag.NIF = ?"
        );
        psCheck.setString(1, nif);
        ResultSet rsCheck = psCheck.executeQuery();
        
        boolean primeiraVez = true;
        if(rsCheck.next()) {
            primeiraVez = (rsCheck.getInt("total") == 0);
        }
        rsCheck.close();
        psCheck.close();
        
        if(primeiraVez) {
            mensagem = "❌ Primeira consulta deve ser agendada pela rececionista. Por favor, contacte a clínica.";
            tipoMensagem = "erro";
        } else {
           
            PreparedStatement psAnimais = con.prepareStatement(
                "SELECT COUNT(*) as total FROM tutor WHERE NIF = ?"
            );
            psAnimais.setString(1, nif);
            ResultSet rsAnimais = psAnimais.executeQuery();
            
            int totalAnimais = 0;
            if(rsAnimais.next()) {
                totalAnimais = rsAnimais.getInt("total");
            }
            rsAnimais.close();
            psAnimais.close();
            
            if(totalAnimais == 0) {
                mensagem = "❌ Não tem animais registados. Contacte a rececionista.";
                tipoMensagem = "erro";
            } else {
                
                con.setAutoCommit(false);
                
                java.sql.Timestamp dataHora = java.sql.Timestamp.valueOf(dataHoraStr.replace("T", " ") + ":00");
                
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
                    mensagem = "❌ A clínica não funciona aos fins de semana!";
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
                        mensagem = "❌ A clínica não funciona neste dia!";
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
                            mensagem = "❌ Hora fora do horário! Funciona das " + 
                                      horaInicio.toString().substring(0,5) + " às " + 
                                      horaFim.toString().substring(0,5);
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
                                mensagem = "❌ Sem veterinários disponíveis neste horário!";
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
                                    "VALUES (?, ?, 'marcado', NULL, FALSE)";
                                
                                PreparedStatement psAgend = con.prepareStatement(sqlAgendamento, Statement.RETURN_GENERATED_KEYS);
                                psAgend.setTimestamp(1, dataHora);
                                psAgend.setString(2, tipoServ);
                                
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
                                        mensagem = "✅ Consulta agendada com sucesso! ID: " + idAgendamento;
                                        tipoMensagem = "sucesso";
                                        
                                        detalhesDistribuicao = 
                                            "👨‍⚕️ Veterinário: <strong>" + nomeVet + "</strong><br>" +
                                            "📍 Clínica: " + localidade + "<br>" +
                                            "📅 Data: " + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(dataHora);
                                    }
                                    rsKeys.close();
                                } else {
                                    con.rollback();
                                    mensagem = "❌ Erro ao criar consulta";
                                    tipoMensagem = "erro";
                                }
                                psAgend.close();
                            }
                        }
                    }
                }
                
                con.setAutoCommit(true);
            }
        }
        
    } catch (Exception e) {
        mensagem = "❌ Erro: " + e.getMessage();
        tipoMensagem = "erro";
        e.printStackTrace();
    } finally {
        manipula.desligar();
    }
}
%>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <% if (!mensagem.isEmpty()) { %>
      <div class="<%= "sucesso".equals(tipoMensagem) ? "alerta-sucesso" : "mensagem " + tipoMensagem %>">
          <%= mensagem %>
          <% if (!detalhesDistribuicao.isEmpty()) { %>
              <div style="margin-top: 10px; padding-top: 10px; border-top: 2px solid rgba(0,0,0,0.1);">
                  <%= detalhesDistribuicao %>
              </div>
          <% } %>
      </div>
  <% } %>
  
  <div class="alerta-info">
    ℹ️ <div>
      <strong>Atenção:</strong> Se for a sua primeira vez na clínica, contacte a rececionista para fazer o agendamento inicial. 
      Após a primeira consulta, poderá agendar diretamente pelo site.<br>
      <strong>Telefone:</strong> 210 123 456
    </div>
  </div>

  <% if (nif == null || nif.trim().isEmpty()) { %>
  
  <div class="formulario">
    <h3 style="margin: 0 0 20px 0; font-size: 20px; font-weight: 900; color: #0B2A42;">
        Passo 1: Identificação
    </h3>
    <form method="GET">
      <div class="form-group">
        <label>Seu NIF *</label>
        <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9" required
               placeholder="Digite o seu NIF para continuar">
      </div>
      <button type="submit" class="btn btn-primary">
        <img src="../images/icon-arrow-right.png" alt="Continuar" class="icon-inline">Continuar
      </button>
    </form>
  </div>
  
  <% } else { 
     
      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);
      
      try {
          Connection con = manipula.getLigacao();
          
          PreparedStatement psCheck = con.prepareStatement(
              "SELECT COUNT(*) as total FROM agenda ag WHERE ag.NIF = ?"
          );
          psCheck.setString(1, nif);
          ResultSet rsCheck = psCheck.executeQuery();
          
          boolean primeiraVez = true;
          if(rsCheck.next()) {
              primeiraVez = (rsCheck.getInt("total") == 0);
          }
          rsCheck.close();
          psCheck.close();
          
          PreparedStatement psAnimais = con.prepareStatement(
              "SELECT COUNT(*) as total FROM tutor WHERE NIF = ?"
          );
          psAnimais.setString(1, nif);
          ResultSet rsAnimais = psAnimais.executeQuery();
          
          int totalAnimais = 0;
          if(rsAnimais.next()) {
              totalAnimais = rsAnimais.getInt("total");
          }
          rsAnimais.close();
          psAnimais.close();
          
          if(primeiraVez) {
  %>
  
  <div class="alerta-aviso">
    ⚠️ <div>
      <strong>Primeira vez na clínica</strong><br>
      Como é a sua primeira consulta, por favor contacte a nossa rececionista para fazer o agendamento inicial.<br>
      <strong>Telefone:</strong> 210 123 456
    </div>
  </div>
  
  <div style="text-align: center; margin-top: 30px;">
    <a href="?nif=" class="btn btn-secondary">← Tentar outro NIF</a>
  </div>
  
  <% 
          } else if(totalAnimais == 0) {
  %>
  
  <div class="alerta-aviso">
    ⚠️ <div>
      <strong>Sem animais registados</strong><br>
      Não encontrámos animais registados com o seu NIF. Contacte a rececionista.<br>
      <strong>Telefone:</strong> 210 123 456
    </div>
  </div>
  
  <div style="text-align: center; margin-top: 30px;">
    <a href="?nif=" class="btn btn-secondary">← Tentar outro NIF</a>
  </div>
  
  <% 
          } else {
              
  %>
  
  <div class="alerta-info">
    <div>
      <strong>Bem-vindo de volta!</strong><br>
      NIF: <strong><%= nif %></strong> | Animais registados: <strong><%= totalAnimais %></strong><br>
      Preencha o formulário abaixo para agendar a sua consulta.
    </div>
  </div>

  <div class="formulario">
    <h3 style="margin: 0 0 20px 0; font-size: 20px; font-weight: 900; color: #0B2A42;">
         Passo 2: Detalhes da Consulta
    </h3>
    <form method="POST">
      <input type="hidden" name="nif" value="<%= nif %>">
      
      <div class="form-group">
        <label>Clínica *</label>
        <select name="localidade" required>
          <option value="">Selecione...</option>
          <%
          String sqlClin = "SELECT DISTINCT localidade FROM horario ORDER BY localidade";
          PreparedStatement psClin = con.prepareStatement(sqlClin);
          ResultSet rsClin = psClin.executeQuery();
          
          while (rsClin.next()) {
              String loc = rsClin.getString("localidade");
          %>
              <option value="<%= loc %>"><%= loc %></option>
          <%
          }
          rsClin.close();
          psClin.close();
          %>
        </select>
      </div>
      
      <div class="form-group">
        <label>Data e Hora *</label>
        <input type="datetime-local" name="dataHora" required
               min="<%= java.time.LocalDateTime.now().toString().substring(0,16) %>">
        <small style="color: #57606F; font-weight: 600; margin-top: 6px; display: block;">
          💡 Segunda a Sexta, dentro do horário da clínica
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
      
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">
          <img src="../images/icon-calendar.png" alt="Agendar" class="icon-inline">Confirmar Agendamento
        </button>
        <a href="?nif=" class="btn btn-secondary">← Voltar</a>
      </div>
    </form>
  </div>
  
  <% 
          }
      } catch(Exception e) {
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
