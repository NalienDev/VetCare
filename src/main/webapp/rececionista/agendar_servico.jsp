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
    .alerta-aviso {
      background: #FFF3CD;
      border: 2px solid #FFC107;
      border-radius: 16px;
      padding: 16px 20px;
      margin-bottom: 20px;
      font-weight: 700;
      color: #856404;
    }
    .alerta-info {
      background: #E8F4F8;
      border-left: 4px solid #4A90E2;
      padding: 15px;
      margin: 20px 0;
      border-radius: 8px;
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
    <h1>📅 Agendar Serviço</h1>
    <p>Marcar serviços com distribuição automática de veterinários.</p>
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
    String primeiraVezStr = request.getParameter("primeiraVez");
    
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        Connection con = manipula.getLigacao();
        boolean primeiraVez = "sim".equals(primeiraVezStr);
        
        // ✅ VALIDAÇÃO: Se primeira vez, verificar se tem animais
        if(primeiraVez) {
            PreparedStatement psCheck = con.prepareStatement(
                "SELECT COUNT(*) as total FROM tutor WHERE NIF = ?"
            );
            psCheck.setString(1, nif);
            ResultSet rsCheck = psCheck.executeQuery();
            
            int totalAnimais = 0;
            if(rsCheck.next()) {
                totalAnimais = rsCheck.getInt("total");
            }
            rsCheck.close();
            psCheck.close();
            
            if(totalAnimais == 0) {
                mensagem = "⚠️ Este cliente não tem animais registados. Por favor, registe um animal antes de agendar a primeira consulta.";
                tipoMensagem = "erro";
            } else {
                // Continua para criar agendamento
                primeiraVez = true;
            }
        }
        
        // ✅ SE PASSOU VALIDAÇÃO, CRIAR AGENDAMENTO COM DISTRIBUIÇÃO AUTOMÁTICA
        if (mensagem.isEmpty()) {
            con.setAutoCommit(false);
            
            // Parse data/hora
            java.sql.Timestamp dataHora = java.sql.Timestamp.valueOf(dataHoraStr.replace("T", " ") + ":00");
            java.math.BigDecimal custos = custosStr != null && !custosStr.isEmpty() ? new java.math.BigDecimal(custosStr) : null;
            
            // Extrair informações da data
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
                
                // ✅ VALIDAR HORÁRIO DA CLÍNICA
                String sqlCheckHorario = 
                    "SELECT horaInicio, horaFim FROM horario " +
                    "WHERE localidade = ? AND diaUtil = ?";
                
                PreparedStatement psCheckHorario = con.prepareStatement(sqlCheckHorario);
                psCheckHorario.setString(1, localidade);
                psCheckHorario.setString(2, diaUtil);
                ResultSet rsCheckHorario = psCheckHorario.executeQuery();
                
                if (!rsCheckHorario.next()) {
                    mensagem = "❌ A clínica " + localidade + " não funciona às " + diaUtil + "-feiras!";
                    tipoMensagem = "erro";
                    rsCheckHorario.close();
                    psCheckHorario.close();
                    con.rollback();
                } else {
                    Time horaInicio = rsCheckHorario.getTime("horaInicio");
                    Time horaFim = rsCheckHorario.getTime("horaFim");
                    rsCheckHorario.close();
                    psCheckHorario.close();
                    
                    // Validar se hora está dentro do horário
                    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");
                    String horaConsulta = timeFormat.format(dataHora);
                    
                    if (horaConsulta.compareTo(horaInicio.toString()) < 0 || 
                        horaConsulta.compareTo(horaFim.toString()) >= 0) {
                        mensagem = "❌ Hora fora do horário de funcionamento! " +
                                  "A clínica funciona das " + horaInicio.toString().substring(0,5) + 
                                  " às " + horaFim.toString().substring(0,5);
                        tipoMensagem = "erro";
                        con.rollback();
                    } else {
                        
                        // ✅ BUSCAR VETERINÁRIOS E DISTRIBUIR AUTOMATICAMENTE
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
                            mensagem = "❌ Não há veterinários disponíveis neste horário! Por favor, escalem veterinários primeiro.";
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
                            
                            // ✅ CRIAR AGENDAMENTO
                            String sqlAgendamento = 
                                "INSERT INTO agendamento (dataHrAgenda, tipoServ, statusAgendamento, custos, primeiraVez) " +
                                "VALUES (?, ?, 'marcado', ?, ?)";
                            
                            PreparedStatement psAgend = con.prepareStatement(sqlAgendamento, Statement.RETURN_GENERATED_KEYS);
                            psAgend.setTimestamp(1, dataHora);
                            psAgend.setString(2, tipoServ);
                            psAgend.setBigDecimal(3, custos);
                            psAgend.setBoolean(4, primeiraVez);
                            
                            if (psAgend.executeUpdate() > 0) {
                                ResultSet rsKeys = psAgend.getGeneratedKeys();
                                if (rsKeys.next()) {
                                    int idAgendamento = rsKeys.getInt(1);
                                    
                                    // Ligar ao cliente
                                    String sqlAgenda = "INSERT INTO agenda (idAgendamento, NIF) VALUES (?, ?)";
                                    PreparedStatement psAgenda = con.prepareStatement(sqlAgenda);
                                    psAgenda.setInt(1, idAgendamento);
                                    psAgenda.setString(2, nif);
                                    psAgenda.executeUpdate();
                                    psAgenda.close();
                                    
                                    con.commit();
                                    
                                    mensagem = "✅ Serviço agendado com sucesso! ID: " + idAgendamento;
                                    tipoMensagem = "sucesso";
                                    
                                    detalhesDistribuicao = 
                                        "<strong>Distribuição Automática:</strong><br>" +
                                        "👨‍⚕️ Veterinário atribuído: <strong>" + nomeVet + "</strong> (Licença: " + nLicencaVet + ")<br>" +
                                        "📊 Consultas já atribuídas hoje: " + numConsultasAtual + "<br>" +
                                        "📍 Clínica: " + localidade + "<br>" +
                                        "📅 Data: " + new SimpleDateFormat("dd/MM/yyyy HH:mm").format(dataHora) + "<br>" +
                                        "🔵 Primeira vez? " + (primeiraVez ? "Sim" : "Não");
                                }
                                rsKeys.close();
                            } else {
                                con.rollback();
                                mensagem = "❌ Erro ao criar agendamento";
                                tipoMensagem = "erro";
                            }
                            psAgend.close();
                        }
                    }
                }
            }
            
            con.setAutoCommit(true);
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
      <div class="mensagem <%= tipoMensagem %>">
          <%= mensagem %>
          <% if (!detalhesDistribuicao.isEmpty()) { %>
              <div style="margin-top: 15px; padding-top: 15px; border-top: 2px solid #28A745;">
                  <%= detalhesDistribuicao %>
              </div>
          <% } %>
      </div>
  <% } %>
  
  <div class="alerta-info">
    <strong>Sistema de Distribuição Automática:</strong><br>
    O sistema atribui automaticamente a consulta ao veterinário com menos consultas naquele dia, 
    garantindo distribuição equilibrada da carga de trabalho.
  </div>
  
  <div class="alerta-aviso">
    ⚠️ <strong>Atenção:</strong> Se marcar "Primeira Vez", certifique-se de que o cliente já tem pelo menos um animal registado na base de dados.
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
               placeholder="Digite o NIF do cliente">
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
        <input type="number" name="custos" step="0.01" min="0"
               placeholder="Deixe vazio se não souber">
      </div>
      
      <div class="form-group">
        <label>Primeira Vez? *</label>
        <select name="primeiraVez" required>
          <option value="nao" selected>Não (cliente já veio antes)</option>
          <option value="sim">Sim (primeira consulta do cliente)</option>
        </select>
        <small style="color: #57606F; font-weight: 600; margin-top: 6px; display: block;">
            Se for "Sim", o cliente deve ter pelo menos um animal registado
        </small>
      </div>
      
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">📅 Agendar com Distribuição Automática</button>
        <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
      </div>
    </form>
  </div>
  
  <div style="margin-top: 30px; padding: 20px; background: #E8F4F8; border-left: 4px solid #4A90E2; border-radius: 10px;">
    <h3 style="margin: 0 0 10px 0; color: #0B2A42;">ℹ️ Como Funciona</h3>
    <ul style="margin: 0; padding-left: 20px; color: #0B2A42;">
      <li><strong>Passo 1:</strong> Sistema identifica veterinários escalados na clínica/dia</li>
      <li><strong>Passo 2:</strong> Conta consultas de cada veterinário naquele dia</li>
      <li><strong>Passo 3:</strong> Atribui ao veterinário com MENOS consultas</li>
      <li><strong>Resultado:</strong> Carga de trabalho equilibrada! 🎯</li>
    </ul>
  </div>
</div>

</body>
</html>
