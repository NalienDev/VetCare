<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Histórico Clínico</title>
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

<%
String idParam = request.getParameter("idFichaClin");
if (idParam == null) {
    response.sendRedirect("pesquisar_animal.jsp");
    return;
}

int idFicha = Integer.parseInt(idParam);
Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

try {
    Connection con = manipula.getLigacao();
    
    String sqlAnimal = 
        "SELECT f.nome, c.nomeCompleto AS tutor " +
        "FROM fichaClinicaAnimal f " +
        "LEFT JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
        "LEFT JOIN cliente c ON t.NIF = c.NIF " +
        "WHERE f.idFichaClin = ?";
    
    PreparedStatement psAnimal = con.prepareStatement(sqlAnimal);
    psAnimal.setInt(1, idFicha);
    ResultSet rsAnimal = psAnimal.executeQuery();
    
    if (rsAnimal.next()) {
        String nome = rsAnimal.getString("nome");
        String tutor = rsAnimal.getString("tutor");
%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Histórico Clínico: <%= nome %></h1>
    <p>Tutor: <%= tutor %> | ID: <%= idFicha %></p>
  </div>
</section>

<div class="page-content">
  <a href="ficha_clinica.jsp?idFichaClin=<%= idFicha %>" class="btn-voltar">← Voltar à Ficha</a>
  
  <%
        rsAnimal.close();
        psAnimal.close();
        
        String sqlHistorico = "SELECT idHistorico FROM historicoClinico WHERE idFichaClin = ?";
        PreparedStatement psHist = con.prepareStatement(sqlHistorico);
        psHist.setInt(1, idFicha);
        ResultSet rsHist = psHist.executeQuery();
        
        if (rsHist.next()) {
            int idHistorico = rsHist.getInt("idHistorico");
            rsHist.close();
            psHist.close();
            
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

            String sqlConsultas = 
                "SELECT dataConsulta, motivo, sintomas, diagnostico, medicacao " +
                "FROM consultaHist WHERE idHistorico = ? ORDER BY dataConsulta DESC";
            
            PreparedStatement psConsultas = con.prepareStatement(sqlConsultas);
            psConsultas.setInt(1, idHistorico);
            ResultSet rsConsultas = psConsultas.executeQuery();
            boolean temConsultas = false;
  %>
            <div class="table-card">
              <h3>🩺 Consultas</h3>
              <table class="tabela">
                <thead>
                  <tr>
                    <th>Data/Hora</th>
                    <th>Motivo</th>
                    <th>Sintomas</th>
                    <th>Medicação</th>
                    <th>Diagnóstico</th>
                  </tr>
                </thead>
                <tbody>
  <%
            while (rsConsultas.next()) {
                temConsultas = true;
                Timestamp dataConsulta = rsConsultas.getTimestamp("dataConsulta");
  %>
                  <tr>
                    <td><%= dataConsulta != null ? sdf.format(dataConsulta) : "-" %></td>
                    <td><%= rsConsultas.getString("motivo") != null ? rsConsultas.getString("motivo") : "-" %></td>
                    <td><%= rsConsultas.getString("sintomas") != null ? rsConsultas.getString("sintomas") : "-" %></td>
                    <td><%= rsConsultas.getString("medicacao") != null ? rsConsultas.getString("medicacao") : "-" %></td>
                    <td><%= rsConsultas.getString("diagnostico") != null ? rsConsultas.getString("diagnostico") : "-" %></td>
                  </tr>
  <%
            }
            if (!temConsultas) {
  %>
                  <tr>
                    <td colspan="5" style="text-align:center; padding:2rem; color:#57606F;">
                      🔭 Sem consultas registadas
                    </td>
                  </tr>
  <%
            }
            rsConsultas.close();
            psConsultas.close();
  %>
                </tbody>
              </table>
            </div>

  <%
            String sqlVacinas = 
                "SELECT dataVacina, tipoVacina, fabricante " +
                "FROM vacinacao WHERE idHistorico = ? ORDER BY dataVacina DESC";
            
            PreparedStatement psVacinas = con.prepareStatement(sqlVacinas);
            psVacinas.setInt(1, idHistorico);
            ResultSet rsVacinas = psVacinas.executeQuery();
            boolean temVacinas = false;
  %>
            <div class="table-card">
              <h3>💉 Vacinações</h3>
              <table class="tabela">
                <thead>
                  <tr>
                    <th>Data e Hora</th>
                    <th>Tipo</th>
                    <th>Fabricante</th>
                  </tr>
                </thead>
                <tbody>
  <%
            while (rsVacinas.next()) {
                temVacinas = true;
                Timestamp dataVacina = rsVacinas.getTimestamp("dataVacina");
  %>
                  <tr>
                    <td><%= dataVacina != null ? sdf.format(dataVacina) : "-" %></td>
                    <td><%= rsVacinas.getString("tipoVacina") != null ? rsVacinas.getString("tipoVacina") : "-" %></td>
                    <td><%= rsVacinas.getString("fabricante") != null ? rsVacinas.getString("fabricante") : "-" %></td>
                  </tr>
  <%
            }
            if (!temVacinas) {
  %>
                  <tr>
                    <td colspan="3" style="text-align:center; padding:2rem; color:#57606F;">
                      🔭 Sem vacinações registadas
                    </td>
                  </tr>
  <%
            }
            rsVacinas.close();
            psVacinas.close();
  %>
                </tbody>
              </table>
            </div>

  <%
            String sqlDes = 
                "SELECT dataDesparasitacao, tipoDesparasitacao, produtosUtilizados " +
                "FROM desparasitacao WHERE idHistorico = ? ORDER BY dataDesparasitacao DESC";
            
            PreparedStatement psDes = con.prepareStatement(sqlDes);
            psDes.setInt(1, idHistorico);
            ResultSet rsDes = psDes.executeQuery();
            boolean temDes = false;
  %>
            <div class="table-card">
              <h3>🪱 Desparasitação</h3>
              <table class="tabela">
                <thead>
                  <tr>
                    <th>Data e Hora</th>
                    <th>Tipo</th>
                    <th>Produtos Utilizados</th>
                  </tr>
                </thead>
                <tbody>
  <%
            while (rsDes.next()) {
                temDes = true;
                Timestamp dataDes = rsDes.getTimestamp("dataDesparasitacao");
  %>
                  <tr>
                    <td><%= dataDes != null ? sdf.format(dataDes) : "-" %></td>
                    <td><%= rsDes.getString("tipoDesparasitacao") != null ? rsDes.getString("tipoDesparasitacao") : "-" %></td>
                    <td><%= rsDes.getString("produtosUtilizados") != null ? rsDes.getString("produtosUtilizados") : "-" %></td>
                  </tr>
  <%
            }
            if (!temDes) {
  %>
                  <tr>
                    <td colspan="3" style="text-align:center; padding:2rem; color:#57606F;">
                      🔭 Sem desparasitações registadas
                    </td>
                  </tr>
  <%
            }
            rsDes.close();
            psDes.close();
  %>
                </tbody>
              </table>
            </div>

  <%
            String sqlExames = 
                "SELECT dataHora, temperatura, peso, freqCard, freqResp " +
                "FROM exameFis WHERE idHistorico = ? ORDER BY dataHora DESC LIMIT 20";
            
            PreparedStatement psExames = con.prepareStatement(sqlExames);
            psExames.setInt(1, idHistorico);
            ResultSet rsExames = psExames.executeQuery();
            boolean temExames = false;
  %>
            <div class="table-card">
              <h3>🔬 Exames Físicos</h3>
              <table class="tabela">
                <thead>
                  <tr>
                    <th>Data/Hora</th>
                    <th>Peso</th>
                    <th>Temperatura</th>
                    <th>Freq. Cardíaca</th>
                    <th>Freq. Respiratória</th>
                  </tr>
                </thead>
                <tbody>
  <%
            while (rsExames.next()) {
                temExames = true;
                Timestamp dataExame = rsExames.getTimestamp("dataHora");
                double peso = rsExames.getDouble("peso");
                double temp = rsExames.getDouble("temperatura");
                int freqCard = rsExames.getInt("freqCard");
                int freqResp = rsExames.getInt("freqResp");
  %>
                  <tr>
                    <td><%= dataExame != null ? sdf.format(dataExame) : "-" %></td>
                    <td><%= String.format("%.2f kg", peso) %></td>
                    <td><%= String.format("%.1f °C", temp) %></td>
                    <td><%= freqCard %> bpm</td>
                    <td><%= freqResp %> rpm</td>
                  </tr>
  <%
            }
            if (!temExames) {
  %>
                  <tr>
                    <td colspan="5" style="text-align:center; padding:2rem; color:#57606F;">
                      🔭 Sem exames físicos registados
                    </td>
                  </tr>
  <%
            }
            rsExames.close();
            psExames.close();
  %>
                </tbody>
              </table>
            </div>

  <%
            String sqlResEx = 
                "SELECT dataHora, tipoExame, resultadosEx " +
                "FROM resultadoEx WHERE idHistorico = ? ORDER BY dataHora DESC LIMIT 20";
            
            PreparedStatement psRes = con.prepareStatement(sqlResEx);
            psRes.setInt(1, idHistorico);
            ResultSet rsRes = psRes.executeQuery();
            boolean temRes = false;
  %>
            <div class="table-card">
              <h3>📄 Resultados de Exames</h3>
              <table class="tabela">
                <thead>
                  <tr>
                    <th>Data/Hora</th>
                    <th>Tipo</th>
                    <th>Resultados</th>
                  </tr>
                </thead>
                <tbody>
  <%
            while (rsRes.next()) {
                temRes = true;
                Timestamp dataRes = rsRes.getTimestamp("dataHora");
  %>
                  <tr>
                    <td><%= dataRes != null ? sdf.format(dataRes) : "-" %></td>
                    <td><%= rsRes.getString("tipoExame") != null ? rsRes.getString("tipoExame") : "-" %></td>
                    <td><%= rsRes.getString("resultadosEx") != null ? rsRes.getString("resultadosEx") : "-" %></td>
                  </tr>
  <%
            }
            if (!temRes) {
  %>
                  <tr>
                    <td colspan="3" style="text-align:center; padding:2rem; color:#57606F;">
                      🔭 Sem resultados de exames registados
                    </td>
                  </tr>
  <%
            }
            rsRes.close();
            psRes.close();
  %>
                </tbody>
              </table>
            </div>

  <%
            String sqlCir = 
                "SELECT dataCirurgia, tipoCirurgia, notasPosOp " +
                "FROM cirurgiaHist WHERE idHistorico = ? ORDER BY dataCirurgia DESC";
            
            PreparedStatement psCir = con.prepareStatement(sqlCir);
            psCir.setInt(1, idHistorico);
            ResultSet rsCir = psCir.executeQuery();
            boolean temCir = false;
  %>
            <div class="table-card">
              <h3>🏥 Cirurgias</h3>
              <table class="tabela">
                <thead>
                  <tr>
                    <th>Data e Hora</th>
                    <th>Tipo</th>
                    <th>Notas</th>
                  </tr>
                </thead>
                <tbody>
  <%
            while (rsCir.next()) {
                temCir = true;
                Timestamp dataCir = rsCir.getTimestamp("dataCirurgia");
  %>
                  <tr>
                    <td><%= dataCir != null ? sdf.format(dataCir) : "-" %></td>
                    <td><%= rsCir.getString("tipoCirurgia") != null ? rsCir.getString("tipoCirurgia") : "-" %></td>
                    <td><%= rsCir.getString("notasPosOp") != null ? rsCir.getString("notasPosOp") : "-" %></td>
                  </tr>
  <%
            }
            if (!temCir) {
  %>
                  <tr>
                    <td colspan="3" style="text-align:center; padding:2rem; color:#57606F;">
                      🔭 Sem cirurgias registadas
                    </td>
                  </tr>
  <%
            }
            rsCir.close();
            psCir.close();
  %>
                </tbody>
              </table>
            </div>

  <%
            String sqlTrat = 
                "SELECT dataTrat, tipoTratamento, descricao " +
                "FROM TratTerapHist WHERE idHistorico = ? ORDER BY dataTrat DESC";
            
            PreparedStatement psTrat = con.prepareStatement(sqlTrat);
            psTrat.setInt(1, idHistorico);
            ResultSet rsTrat = psTrat.executeQuery();
            boolean temTrat = false;
  %>
            <div class="table-card">
              <h3>🧾 Tratamentos Terapêuticos</h3>
              <table class="tabela">
                <thead>
                  <tr>
                    <th>Data e Hora</th>
                    <th>Tipo</th>
                    <th>Descrição</th>
                  </tr>
                </thead>
                <tbody>
  <%
            while (rsTrat.next()) {
                temTrat = true;
                Timestamp dataTrat = rsTrat.getTimestamp("dataTrat");
  %>
                  <tr>
                    <td><%= dataTrat != null ? sdf.format(dataTrat) : "-" %></td>
                    <td><%= rsTrat.getString("tipoTratamento") != null ? rsTrat.getString("tipoTratamento") : "-" %></td>
                    <td><%= rsTrat.getString("descricao") != null ? rsTrat.getString("descricao") : "-" %></td>
                  </tr>
  <%
            }
            if (!temTrat) {
  %>
                  <tr>
                    <td colspan="3" style="text-align:center; padding:2rem; color:#57606F;">
                      🔭 Sem tratamentos terapêuticos registados
                    </td>
                  </tr>
  <%
            }
            rsTrat.close();
            psTrat.close();
  %>
                </tbody>
              </table>
            </div>

  <%
        } else {
            rsHist.close();
            psHist.close();
  %>
            <div class="mensagem">
              🔭 Histórico clínico não encontrado para este animal
            </div>
  <%
        }
    } else {
        rsAnimal.close();
        psAnimal.close();
%>
<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Erro</h1>
    <p>Animal não encontrado</p>
  </div>
</section>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
%>
  <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
<%
} finally {
    manipula.desligar();
}
%>
</div>

</body>
</html>