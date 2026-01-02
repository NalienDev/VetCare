<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.time.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Selecionar Animal</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  
  <style>
    /* ✨ CARDS DE ANIMAIS MODERNOS */
    .animals-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
      gap: 24px;
      margin-top: 30px;
    }
    
    .animal-card {
      background: white;
      border: 2px solid #E7EEF4;
      border-radius: 24px 8px 24px 8px;
      padding: 24px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.06);
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      position: relative;
      overflow: hidden;
    }
    
    .animal-card:hover {
      transform: translateY(-6px);
      box-shadow: 0 12px 28px rgba(0,0,0,0.12);
      border-color: #0B2A42;
    }
    
    .animal-card.sem-peso {
      border-color: #FFA500;
      background: linear-gradient(135deg, #ffffff 0%, #FFF9F0 100%);
    }
    
    .animal-card.sem-peso::before {
      content: '⚠️';
      position: absolute;
      top: 16px;
      right: 16px;
      font-size: 24px;
      opacity: 0.7;
    }
    
    .animal-header {
      display: flex;
      gap: 16px;
      align-items: flex-start;
      margin-bottom: 20px;
      padding-bottom: 16px;
      border-bottom: 2px solid #F1F5F8;
    }
    
    .animal-photo {
      width: 80px;
      height: 80px;
      border-radius: 16px;
      object-fit: cover;
      border: 3px solid #E7EEF4;
      box-shadow: 0 4px 8px rgba(0,0,0,0.1);
      flex-shrink: 0;
      background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
    }
    
    .animal-info {
      flex: 1;
      min-width: 0;
    }
    
    .animal-name {
      font-size: 22px;
      font-weight: 900;
      color: #0B2A42;
      margin: 0 0 6px 0;
      word-break: break-word;
    }
    
    .animal-id {
      font-size: 13px;
      font-weight: 700;
      color: #57606F;
      background: #F1F5F8;
      padding: 4px 10px;
      border-radius: 8px;
      display: inline-block;
    }
    
    .animal-stats {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
      margin-bottom: 18px;
    }
    
    .stat-item {
      background: #F8FAFC;
      padding: 12px;
      border-radius: 12px;
      border: 1px solid #E7EEF4;
    }
    
    .stat-label {
      font-size: 11px;
      font-weight: 800;
      color: #57606F;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 4px;
    }
    
    .stat-value {
      font-size: 18px;
      font-weight: 900;
      color: #0B2A42;
    }
    
    .stat-value.missing {
      color: #FFA500;
      font-size: 14px;
      font-weight: 700;
    }
    
    .animal-details {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin-bottom: 16px;
    }
    
    .detail-tag {
      padding: 6px 12px;
      background: #EAF6FB;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 800;
      color: #0B2A42;
      display: flex;
      align-items: center;
      gap: 4px;
    }
    
    .warning-badge {
      background: #FFF3CD;
      color: #856404;
      padding: 10px 14px;
      border-radius: 12px;
      font-size: 13px;
      font-weight: 800;
      margin-bottom: 16px;
      border: 2px solid #FFC107;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .animal-actions {
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }
    
    .btn-atender {
      flex: 1;
      min-width: 140px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 14px 20px;
      border-radius: 16px 4px 16px 4px;
      background: #0B2A42;
      color: white;
      font-weight: 900;
      font-size: 14px;
      text-decoration: none;
      border: none;
      cursor: pointer;
      transition: all 0.2s;
    }
    
    .btn-atender:hover {
      background: #164164;
      transform: scale(1.02);
    }
    
    .btn-atualizar {
      flex: 1;
      min-width: 140px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 14px 20px;
      border-radius: 16px 4px 16px 4px;
      background: #FFA500;
      color: white;
      font-weight: 900;
      font-size: 14px;
      text-decoration: none;
      border: none;
      cursor: pointer;
      transition: all 0.2s;
    }
    
    .btn-atualizar:hover {
      background: #FF8C00;
      transform: scale(1.02);
    }
    
    .tutor-info {
      background: linear-gradient(135deg, #EAF6FB 0%, #D4EDFC 100%);
      border: 2px solid #B8D4E6;
      border-radius: 20px 6px 20px 6px;
      padding: 20px 24px;
      margin-bottom: 30px;
      display: flex;
      align-items: center;
      gap: 16px;
      flex-wrap: wrap;
    }
    
    .tutor-info strong {
      color: #0B2A42;
      font-weight: 900;
    }
    
    .empty-state {
      text-align: center;
      padding: 60px 20px;
      background: white;
      border-radius: 24px 8px 24px 8px;
      border: 2px dashed #DFE4EA;
    }
    
    .empty-state-icon {
      font-size: 64px;
      margin-bottom: 16px;
      opacity: 0.5;
    }
    
    .empty-state-text {
      font-size: 18px;
      font-weight: 700;
      color: #57606F;
    }
    
    @media (max-width: 768px) {
      .animals-grid {
        grid-template-columns: 1fr;
      }
      
      .animal-stats {
        grid-template-columns: 1fr;
      }
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
    <h1>Selecionar Animal para Atendimento</h1>
    <p>Escolha o animal que será atendido nesta consulta</p>
  </div>
</section>

<div class="page-content">
  <a href="lista_chamada.jsp" class="btn-voltar">← Voltar à Lista de Chamada</a>

<%
String idAgendamentoParam = request.getParameter("idAgendamento");

if(idAgendamentoParam == null){
%>
  <div class="mensagem erro">❌ Agendamento não encontrado.</div>
<%
  return;
}

Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

try {
    Connection con = manipula.getLigacao();

    // Buscar tutor do agendamento
    PreparedStatement psTutor = con.prepareStatement(
      "SELECT c.NIF, c.nomeCompleto FROM agenda ag " +
      "JOIN cliente c ON c.NIF = ag.NIF " +
      "WHERE ag.idAgendamento=?"
    );
    psTutor.setInt(1, Integer.parseInt(idAgendamentoParam));
    ResultSet rsTutor = psTutor.executeQuery();

    if(!rsTutor.next()){
%>
      <div class="mensagem erro">❌ Tutor não encontrado para este agendamento.</div>
<%
      rsTutor.close();
      psTutor.close();
      return;
    }

    String nifTutor = rsTutor.getString("NIF");
    String nomeTutor = rsTutor.getString("nomeCompleto");

    rsTutor.close();
    psTutor.close();
%>

  <div class="tutor-info">
    <span>👤 <strong>Tutor:</strong> <%= nomeTutor %></span>
    <span>📇 <strong>NIF:</strong> <%= nifTutor %></span>
    <span>📅 <strong>Agendamento:</strong> #<%= idAgendamentoParam %></span>
  </div>

<%
    // Buscar animais com informações completas incluindo PESO ATUAL
    PreparedStatement psA = con.prepareStatement(
      "SELECT f.idFichaClin, f.nome, f.sexo, f.dataNasc, " +
      "r.nomeRaca, e.nomeComum as especie, " +
      "cf.cores, cf.peso as pesoAtual " +
      "FROM fichaClinicaAnimal f " +
      "JOIN tutor t ON t.idFichaClin = f.idFichaClin " +
      "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
      "LEFT JOIN raca r ON r.nomeRaca = fr.nomeRaca " +
      "LEFT JOIN especie e ON e.nomeComum = r.nomeComum " +
      "LEFT JOIN caracteristicasFic cf ON cf.idFicha = f.idFichaClin " +
      "WHERE t.NIF=? ORDER BY f.nome"
    );
    psA.setString(1, nifTutor);
    ResultSet rsA = psA.executeQuery();

    boolean tem = false;
    java.util.List<java.util.Map<String, Object>> animais = new java.util.ArrayList<>();
    
    while(rsA.next()){
        tem = true;
        int idFicha = rsA.getInt("idFichaClin");
        
        // ✅ PESO ATUAL vem direto da fichaClinicaAnimal.pesoAtual
        Double pesoAtual = null;
        double pesoDb = rsA.getDouble("pesoAtual");
        if(!rsA.wasNull() && pesoDb > 0) {
            pesoAtual = pesoDb;
        }
        
        // Calcular idade
        java.sql.Date dataNasc = rsA.getDate("dataNasc");
        int idade = 0;
        if(dataNasc != null) {
            LocalDate nascimento = dataNasc.toLocalDate();
            LocalDate hoje = LocalDate.now();
            idade = Period.between(nascimento, hoje).getYears();
        }
        
        java.util.Map<String, Object> animal = new java.util.HashMap<>();
        animal.put("idFichaClin", idFicha);
        animal.put("nome", rsA.getString("nome"));
        animal.put("sexo", rsA.getString("sexo"));
        animal.put("raca", rsA.getString("nomeRaca"));
        animal.put("especie", rsA.getString("especie"));
        animal.put("cores", rsA.getString("cores"));
        animal.put("idade", idade);
        animal.put("pesoAtual", pesoAtual);
        
        animais.add(animal);
    }
    rsA.close();
    psA.close();

    if(!tem){
%>
      <div class="empty-state">
        <div class="empty-state-icon">🐾</div>
        <div class="empty-state-text">Este tutor não tem animais registados</div>
      </div>
<%
    } else {
%>

  <div class="animals-grid">
<%
        for(java.util.Map<String, Object> animal : animais) {
            int idFicha = (Integer) animal.get("idFichaClin");
            String nome = (String) animal.get("nome");
            String sexo = (String) animal.get("sexo");
            String raca = (String) animal.get("raca");
            String especie = (String) animal.get("especie");
            String cores = (String) animal.get("cores");
            int idade = (Integer) animal.get("idade");
            Double pesoAtual = (Double) animal.get("pesoAtual");
            
            boolean semPeso = (pesoAtual == null || pesoAtual <= 0);
            String sexoIcon = "M".equals(sexo) ? "♂️" : "♀️";
%>
    <div class="animal-card <%= semPeso ? "sem-peso" : "" %>">
      <div class="animal-header">
        <img src="../fotoAnimal?id=<%= idFicha %>" class="animal-photo" alt="<%= nome %>">
        <div class="animal-info">
          <h3 class="animal-name"><%= nome %></h3>
          <span class="animal-id">ID #<%= idFicha %></span>
        </div>
      </div>
      
      <div class="animal-stats">
        <div class="stat-item">
          <div class="stat-label">🎂 Idade</div>
          <div class="stat-value"><%= idade %> <%= idade == 1 ? "ano" : "anos" %></div>
        </div>
        
        <div class="stat-item">
          <div class="stat-label">⚖️ Peso Atual</div>
          <div class="stat-value <%= semPeso ? "missing" : "" %>">
            <%= semPeso ? "Não definido" : String.format("%.2f kg", pesoAtual) %>
          </div>
        </div>
      </div>
      
      <div class="animal-details">
        <span class="detail-tag"><%= sexoIcon %> <%= "M".equals(sexo) ? "Macho" : "Fêmea" %></span>
        <% if(especie != null) { %><span class="detail-tag">🐾 <%= especie %></span><% } %>
        <% if(raca != null) { %><span class="detail-tag">🧬 <%= raca %></span><% } %>
        <% if(cores != null && !cores.equals("N/A")) { %><span class="detail-tag">🎨 <%= cores %></span><% } %>
      </div>
      
      <% if(semPeso) { %>
      <div class="warning-badge">
        ⚠️ Este animal não tem peso atual registado
      </div>
      <% } %>
      
      <div class="animal-actions">
        <a class="btn-atender" 
           href="atualizar_historico.jsp?idAgendamento=<%= idAgendamentoParam %>&idFichaClin=<%= idFicha %>">
          ✅ Atender
        </a>
        
        <% if(semPeso) { %>
        <a class="btn-atualizar" 
           href="ficha_clinica.jsp?idFichaClin=<%= idFicha %>" 
           target="_blank"
           title="Atualizar dados do animal antes de atender">
          📝 Atualizar Peso
        </a>
        <% } %>
      </div>
    </div>
<%
        }
%>
  </div>

<%
    }

} catch(Exception e){
%>
  <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
<%
  e.printStackTrace();
} finally {
  manipula.desligar();
}
%>

</div>

</body>
</html>
