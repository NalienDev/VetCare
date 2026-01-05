<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Atribuir Veterinário a Horário</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  
  <style>
    .info-box {
      background: #E8F4F8;
      border-left: 4px solid #4A90E2;
      padding: 15px;
      margin: 20px 0;
      border-radius: 8px;
    }
    .info-box h3 {
      margin: 0 0 10px 0;
      color: #0B2A42;
      font-size: 16px;
    }
    .info-box ul {
      margin: 10px 0 0 20px;
      color: #555;
    }
    .warning-box {
      background: #FFF3CD;
      border-left: 4px solid #FFC107;
      padding: 15px;
      margin: 20px 0;
      border-radius: 8px;
    }
    .veterinarios-atribuidos {
      background: #F8F9FA;
      border: 2px solid #DEE2E6;
      border-radius: 8px;
      padding: 15px;
      margin: 20px 0;
    }
    .vet-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 10px;
      background: white;
      border-radius: 6px;
      margin-bottom: 8px;
      border: 1px solid #DEE2E6;
    }
    .vet-info {
      flex: 1;
    }
    .btn-remover {
      background: #DC3545;
      color: white;
      border: none;
      padding: 6px 12px;
      border-radius: 6px;
      cursor: pointer;
      font-size: 12px;
      font-weight: 600;
    }
    .btn-remover:hover {
      background: #C82333;
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

<%
String localidadeParam = request.getParameter("localidade");
String diaUtilParam = request.getParameter("diaUtil");

if (localidadeParam == null || diaUtilParam == null) {
    response.sendRedirect("gestao_horarios.jsp");
    return;
}

String localidade = localidadeParam;
String diaUtil = diaUtilParam;
Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

String mensagem = "";
String tipoMensagem = "";

java.sql.Time horaInicio = null;
java.sql.Time horaFim = null;

try {
    Connection con = manipula.getLigacao();

    // =============================================
    // PROCESSAR AÇÕES
    // =============================================
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String acao = request.getParameter("acao");
        
        con.setAutoCommit(false);
        
        // ADICIONAR VETERINÁRIO
        if ("adicionar".equals(acao)) {
            String nLicenca = request.getParameter("nLicenca");
            
            if (nLicenca != null && !nLicenca.trim().isEmpty()) {
                
                // ✅ VALIDAÇÃO 1: Verificar se veterinário existe
                String sqlCheckVet = "SELECT nome FROM veterinario WHERE nLicenca = ?";
                PreparedStatement psCheckVet = con.prepareStatement(sqlCheckVet);
                psCheckVet.setString(1, nLicenca);
                ResultSet rsCheckVet = psCheckVet.executeQuery();
                
                if (!rsCheckVet.next()) {
                    mensagem = "❌ Veterinário com licença " + nLicenca + " não encontrado.";
                    tipoMensagem = "erro";
                    rsCheckVet.close();
                    psCheckVet.close();
                } else {
                    String nomeVet = rsCheckVet.getString("nome");
                    rsCheckVet.close();
                    psCheckVet.close();
                    
                    // ✅ VALIDAÇÃO 2: Verificar se já está atribuído a este horário
                    String sqlCheckExiste = 
                        "SELECT COUNT(*) as total FROM escalado " +
                        "WHERE nLicenca = ? AND localidade = ? AND diaUtil = ?";
                    
                    PreparedStatement psCheckExiste = con.prepareStatement(sqlCheckExiste);
                    psCheckExiste.setString(1, nLicenca);
                    psCheckExiste.setString(2, localidade);
                    psCheckExiste.setString(3, diaUtil);
                    ResultSet rsCheckExiste = psCheckExiste.executeQuery();
                    
                    boolean jaAtribuido = false;
                    if (rsCheckExiste.next()) {
                        jaAtribuido = rsCheckExiste.getInt("total") > 0;
                    }
                    rsCheckExiste.close();
                    psCheckExiste.close();
                    
                    if (jaAtribuido) {
                        mensagem = "⚠️ " + nomeVet + " já está atribuído a este horário.";
                        tipoMensagem = "erro";
                    } else {
                        
                        // ✅ VALIDAÇÃO 3: Verificar sobreposição de horários no mesmo dia
                        String sqlCheckSobreposicao = 
                            "SELECT h2.localidade, h2.horaInicio, h2.horaFim " +
                            "FROM escalado e " +
                            "JOIN horario h1 ON h1.localidade = ? AND h1.diaUtil = ? " +
                            "JOIN horario h2 ON h2.localidade = e.localidade AND h2.diaUtil = e.diaUtil " +
                            "WHERE e.nLicenca = ? AND e.diaUtil = ? " +
                            "AND ( " +
                            "  (h1.horaInicio < h2.horaFim AND h1.horaFim > h2.horaInicio) " +
                            ")";
                        
                        PreparedStatement psCheckSobreposicao = con.prepareStatement(sqlCheckSobreposicao);
                        psCheckSobreposicao.setString(1, localidade);
                        psCheckSobreposicao.setString(2, diaUtil);
                        psCheckSobreposicao.setString(3, nLicenca);
                        psCheckSobreposicao.setString(4, diaUtil);
                        ResultSet rsCheckSobreposicao = psCheckSobreposicao.executeQuery();
                        
                        if (rsCheckSobreposicao.next()) {
                            String localidadeConflito = rsCheckSobreposicao.getString("localidade");
                            java.sql.Time inicioConflito = rsCheckSobreposicao.getTime("horaInicio");
                            java.sql.Time fimConflito = rsCheckSobreposicao.getTime("horaFim");
                            
                            mensagem = "❌ CONFLITO DE HORÁRIO: " + nomeVet + " já está escalado em " + 
                                      localidadeConflito + " no mesmo dia das " + 
                                      inicioConflito.toString().substring(0, 5) + " às " + 
                                      fimConflito.toString().substring(0, 5) + ". " +
                                      "Um veterinário não pode supervisionar períodos sobrepostos.";
                            tipoMensagem = "erro";
                            rsCheckSobreposicao.close();
                            psCheckSobreposicao.close();
                        } else {
                            rsCheckSobreposicao.close();
                            psCheckSobreposicao.close();
                            
                            // ✅ TUDO OK: Inserir atribuição
                            String sqlInsert = 
                                "INSERT INTO escalado (nLicenca, localidade, diaUtil) VALUES (?, ?, ?)";
                            
                            PreparedStatement psInsert = con.prepareStatement(sqlInsert);
                            psInsert.setString(1, nLicenca);
                            psInsert.setString(2, localidade);
                            psInsert.setString(3, diaUtil);
                            
                            int linhas = psInsert.executeUpdate();
                            psInsert.close();
                            
                            if (linhas > 0) {
                                con.commit();
                                mensagem = "✅ " + nomeVet + " atribuído com sucesso ao horário!";
                                tipoMensagem = "sucesso";
                            } else {
                                con.rollback();
                                mensagem = "❌ Erro ao atribuir veterinário.";
                                tipoMensagem = "erro";
                            }
                        }
                    }
                }
            } else {
                mensagem = "❌ Por favor, selecione um veterinário.";
                tipoMensagem = "erro";
            }
        }
        
        // REMOVER VETERINÁRIO
        else if ("remover".equals(acao)) {
            String nLicenca = request.getParameter("nLicenca");
            
            String sqlDelete = 
                "DELETE FROM escalado WHERE nLicenca = ? AND localidade = ? AND diaUtil = ?";
            
            PreparedStatement psDelete = con.prepareStatement(sqlDelete);
            psDelete.setString(1, nLicenca);
            psDelete.setString(2, localidade);
            psDelete.setString(3, diaUtil);
            
            int linhas = psDelete.executeUpdate();
            psDelete.close();
            
            if (linhas > 0) {
                con.commit();
                mensagem = "✅ Veterinário removido do horário com sucesso!";
                tipoMensagem = "sucesso";
            } else {
                con.rollback();
                mensagem = "❌ Erro ao remover veterinário.";
                tipoMensagem = "erro";
            }
        }
        
        con.setAutoCommit(true);
    }

    // =============================================
    // CARREGAR DADOS DO HORÁRIO
    // =============================================
    PreparedStatement psHorario = con.prepareStatement(
        "SELECT horaInicio, horaFim FROM horario WHERE localidade=? AND diaUtil=?"
    );
    psHorario.setString(1, localidade);
    psHorario.setString(2, diaUtil);
    ResultSet rsHorario = psHorario.executeQuery();

    if (rsHorario.next()) {
        horaInicio = rsHorario.getTime("horaInicio");
        horaFim = rsHorario.getTime("horaFim");
    } else {
        response.sendRedirect("gestao_horarios.jsp");
        return;
    }
    rsHorario.close();
    psHorario.close();
%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>👨‍⚕️ Atribuir Veterinário a Horário</h1>
    <p><%= localidade %> - <%= diaUtil %>-feira (<%= horaInicio.toString().substring(0, 5) %> às <%= horaFim.toString().substring(0, 5) %>)</p>
  </div>
</section>

<div class="page-content">
  <a href="gestao_horarios.jsp" class="btn-voltar">← Voltar aos Horários</a>

  <% if (!mensagem.isEmpty()) { %>
    <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <div class="info-box">
    <h3>ℹ️ Regras de Atribuição</h3>
    <ul>
      <li><strong>Sem sobreposição:</strong> Um veterinário não pode ser escalado em períodos que se sobrepõem no mesmo dia</li>
      <li><strong>Dias úteis apenas:</strong> Segunda a Sexta-feira (clínica fechada aos fins de semana e feriados)</li>
      <li><strong>Múltiplas clínicas:</strong> Um veterinário pode trabalhar em várias clínicas desde que os horários não se sobreponham</li>
    </ul>
  </div>

  <!-- ✅ VETERINÁRIOS JÁ ATRIBUÍDOS -->
  <div class="veterinarios-atribuidos">
    <h3 style="margin: 0 0 15px 0; color: #0B2A42;">👨‍⚕️ Veterinários Escalados</h3>
    <%
    String sqlAtribuidos = 
        "SELECT e.nLicenca, v.nome, v.contacto " +
        "FROM escalado e " +
        "JOIN veterinario v ON v.nLicenca = e.nLicenca " +
        "WHERE e.localidade = ? AND e.diaUtil = ? " +
        "ORDER BY v.nome";
    
    PreparedStatement psAtribuidos = con.prepareStatement(sqlAtribuidos);
    psAtribuidos.setString(1, localidade);
    psAtribuidos.setString(2, diaUtil);
    ResultSet rsAtribuidos = psAtribuidos.executeQuery();
    
    boolean temAtribuidos = false;
    while (rsAtribuidos.next()) {
        temAtribuidos = true;
        String nLicencaAtrib = rsAtribuidos.getString("nLicenca");
        String nomeAtrib = rsAtribuidos.getString("nome");
        String contactoAtrib = rsAtribuidos.getString("contacto");
    %>
        <div class="vet-item">
          <div class="vet-info">
            <strong style="color: #0B2A42;"><%= nomeAtrib %></strong><br>
            <small style="color: #666;">Licença: <%= nLicencaAtrib %> | Contacto: <%= contactoAtrib %></small>
          </div>
          <form method="POST" style="margin: 0;" onsubmit="return confirm('Remover <%= nomeAtrib %> deste horário?');">
            <input type="hidden" name="acao" value="remover">
            <input type="hidden" name="nLicenca" value="<%= nLicencaAtrib %>">
            <button type="submit" class="btn-remover">🗑️ Remover</button>
          </form>
        </div>
    <%
    }
    
    if (!temAtribuidos) {
    %>
        <div style="text-align: center; color: #999; padding: 20px;">
          📭 Nenhum veterinário atribuído a este horário
        </div>
    <%
    }
    
    rsAtribuidos.close();
    psAtribuidos.close();
    %>
  </div>

  <!-- ✅ ADICIONAR VETERINÁRIO -->
  <form method="POST" class="formulario">
    <input type="hidden" name="acao" value="adicionar">
    
    <h3 style="margin: 20px 0 10px 0; color: #0B2A42;">➕ Adicionar Veterinário</h3>
    
    <div class="form-group">
      <label>Selecionar Veterinário *</label>
      <select name="nLicenca" required>
        <option value="">-- Selecione --</option>
        <%
        // Listar veterinários disponíveis (excluir os já atribuídos)
        String sqlVets = 
            "SELECT v.nLicenca, v.nome, v.contacto " +
            "FROM veterinario v " +
            "WHERE v.nLicenca NOT IN ( " +
            "  SELECT e.nLicenca FROM escalado e " +
            "  WHERE e.localidade = ? AND e.diaUtil = ? " +
            ") " +
            "ORDER BY v.nome";
        
        PreparedStatement psVets = con.prepareStatement(sqlVets);
        psVets.setString(1, localidade);
        psVets.setString(2, diaUtil);
        ResultSet rsVets = psVets.executeQuery();
        
        while (rsVets.next()) {
            String nLicencaVet = rsVets.getString("nLicenca");
            String nomeVet = rsVets.getString("nome");
            String contactoVet = rsVets.getString("contacto");
        %>
            <option value="<%= nLicencaVet %>">
              <%= nomeVet %> (Licença: <%= nLicencaVet %> | <%= contactoVet %>)
            </option>
        <%
        }
        rsVets.close();
        psVets.close();
        %>
      </select>
      <small style="color: #666; font-size: 12px; display: block; margin-top: 5px;">
        ⚠️ O sistema irá verificar conflitos de horário automaticamente
      </small>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">➕ Adicionar ao Horário</button>
      <a href="gestao_horarios.jsp" class="btn btn-secondary">❌ Cancelar</a>
    </div>
  </form>

  <!-- ✅ TABELA DE OUTROS HORÁRIOS DO VETERINÁRIO SELECIONADO (via JavaScript) -->
  <div id="outrosHorarios" style="display: none; margin-top: 30px;">
    <div class="warning-box">
      <h3>⚠️ Outros Horários deste Veterinário</h3>
      <div id="listaOutrosHorarios"></div>
    </div>
  </div>
</div>

<script>
// Mostrar outros horários quando selecionar veterinário
document.querySelector('select[name="nLicenca"]').addEventListener('change', function() {
    var nLicenca = this.value;
    var divOutros = document.getElementById('outrosHorarios');
    var listaDiv = document.getElementById('listaOutrosHorarios');
    
    if (!nLicenca) {
        divOutros.style.display = 'none';
        return;
    }
    
    // Fazer request para obter horários
    fetch('get_horarios_veterinario.jsp?nLicenca=' + encodeURIComponent(nLicenca))
        .then(response => response.text())
        .then(html => {
            if (html.trim()) {
                listaDiv.innerHTML = html;
                divOutros.style.display = 'block';
            } else {
                divOutros.style.display = 'none';
            }
        })
        .catch(error => {
            console.error('Erro:', error);
            divOutros.style.display = 'none';
        });
});
</script>

<%
} catch (Exception e) {
    e.printStackTrace();
%>
  <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
<%
} finally {
    manipula.desligar();
}
%>

</body>
</html>
