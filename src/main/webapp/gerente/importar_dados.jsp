<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, org.json.*" %>
<!DOCTYPE html>
<html lang="pt" style="height: 100%;">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Importar Dados - VetCare</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  <style>
    html, body {
      height: 100%;
      margin: 0;
      padding: 0;
    }
    body {
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    .page-content {
      flex: 1;
    }
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
    pre {
      background: white;
      padding: 15px;
      border-radius: 8px;
      overflow-x: auto;
      border: 1px solid #E7EEF4;
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
      <a href="menu.jsp">Gerente</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Importar Dados</h1>
    <p>Importar fichas clínicas a partir de ficheiros JSON.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <%
  String mensagem = "";
  String tipoMensagem = "";
  
  if ("POST".equalsIgnoreCase(request.getMethod())) {
      String dadosJSON = request.getParameter("dadosJSON");
      
      if (dadosJSON != null && !dadosJSON.trim().isEmpty()) {
          Configura cfg = new Configura();
          Manipula manipula = new Manipula(cfg);
          
          try {
              JSONObject json = new JSONObject(dadosJSON);
              
              String nome = json.getString("nome");
              String sexo = json.getString("sexo");
              String dataNasc = json.getString("dataNasc");
              String estadoReprod = json.getString("estadoReprod");
              String raca = json.getString("raca");
              String filiacao = json.optString("filiacao", "Desconhecido");
              String alergias = json.optString("alergias", null);
              
              Connection con = manipula.getLigacao();
              con.setAutoCommit(false);
              
              // Próximo ID
              String sqlMaxId = "SELECT COALESCE(MAX(idFichaClin),0)+1 AS proximoId FROM fichaClinicaAnimal";
              PreparedStatement psMax = con.prepareStatement(sqlMaxId);
              ResultSet rsMax = psMax.executeQuery();
              int idFicha = 1;
              if(rsMax.next()) idFicha = rsMax.getInt("proximoId");
              rsMax.close(); psMax.close();
              
              // Inserir ficha
              String sqlFicha = "INSERT INTO fichaClinicaAnimal (idFichaClin, nome, sexo, dataNasc, filiacao, estadoReprod, alergias) VALUES (?,?,?,?,?,?,?)";
              PreparedStatement psFicha = con.prepareStatement(sqlFicha);
              psFicha.setInt(1, idFicha);
              psFicha.setString(2, nome);
              psFicha.setString(3, sexo);
              psFicha.setDate(4, java.sql.Date.valueOf(dataNasc));
              psFicha.setString(5, filiacao);
              psFicha.setString(6, estadoReprod);
              psFicha.setString(7, alergias);
              psFicha.executeUpdate();
              psFicha.close();
              
              // Associar raça
              String sqlRaca = "INSERT INTO fichaRaca (idFichaClin, nomeRaca) VALUES (?,?)";
              PreparedStatement psRaca = con.prepareStatement(sqlRaca);
              psRaca.setInt(1, idFicha);
              psRaca.setString(2, raca);
              psRaca.executeUpdate();
              psRaca.close();
              
              // Histórico
              String sqlHist = "INSERT INTO historicoClinico (idFichaClin) VALUES (?)";
              PreparedStatement psHist = con.prepareStatement(sqlHist);
              psHist.setInt(1, idFicha);
              psHist.executeUpdate();
              psHist.close();
              
              con.commit();
              mensagem = "✅ Dados importados com sucesso! ID da nova ficha: " + idFicha;
              tipoMensagem = "sucesso";
              
          } catch (JSONException e) {
              mensagem = "❌ Erro ao processar JSON: " + e.getMessage();
              tipoMensagem = "erro";
          } catch (Exception e) {
              mensagem = "❌ Erro ao importar: " + e.getMessage();
              tipoMensagem = "erro";
              e.printStackTrace();
          } finally {
              manipula.desligar();
          }
      } else {
          mensagem = "❌ Por favor, cole o conteúdo JSON para importar.";
          tipoMensagem = "erro";
      }
  }
  %>

  <% if (!mensagem.isEmpty()) { %>
    <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <div class="info-box">
    <h3><img src="../images/icon-upload-b.png" alt="Clipboard" class="icon-inline">Importar Ficha Clínica</h3>
    <p>Cole o conteúdo JSON exportado para importar uma ficha clínica no sistema.</p>
  </div>

  <form method="POST" class="formulario">
    <div class="form-group">
      <label>Dados JSON *</label>
      <textarea 
        name="dadosJSON" 
        rows="15" 
        required 
        placeholder='Cole aqui o JSON exportado...'
        style="font-family: monospace; font-size: 13px;"></textarea>
    </div>
    
    <div class="form-actions">
      <button type="submit" class="btn btn-primary">
        <img src="../images/icon-upload.png" alt="Importar" class="icon-inline">Importar Dados
      </button>
      <button type="reset" class="btn btn-secondary">
        <img src="../images/icon-reset.png" alt="Limpar" class="icon-inline">Limpar
      </button>
    </div>
  </form>

  <div class="info-box" style="margin-top: 30px; background: #FFF3CD; border-left-color: #FFC107;">
    <h3><img src="../images/icon-lightbulb.png" alt="Ideia" class="icon-inline">Exemplo de JSON</h3>
    <pre>{
  "nome": "Rex",
  "sexo": "M",
  "dataNasc": "2020-01-15",
  "raca": "Labrador Retriever",
  "estadoReprod": "Inteiro",
  "filiacao": "Desconhecido",
  "alergias": null
}</pre>
    <p style="margin-top: 10px;"><strong>Nota:</strong> O campo "idFichaClin" será gerado automaticamente e pode ser omitido.</p>
  </div>
</div>

</body>
</html>
