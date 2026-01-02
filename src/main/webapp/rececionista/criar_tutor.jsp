<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Criar Tutor</title>
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
      <a href="menu.jsp">Rececionista</a>
    </nav>
  </div>
</header>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Criar Tutor</h1>
    <p>Registar novos clientes.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <%
    String mensagem = "";
    String tipoMensagem = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {

      String nif = request.getParameter("nif");
      String nomeCompleto = request.getParameter("nomeCompleto");
      String contactos = request.getParameter("contactos");
      String arteria = request.getParameter("arteria");
      String numero = request.getParameter("numero");
      String andar = request.getParameter("andar");
      String distrito = request.getParameter("distrito");
      String concelho = request.getParameter("concelho");
      String freguesia = request.getParameter("freguesia");
      String prefLinguisticas = request.getParameter("prefLinguisticas");
      String tipoCliente = request.getParameter("tipoCliente");
      String capitalSocial = request.getParameter("capitalSocial");

      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);

      try {
        Connection con = manipula.getLigacao();
        con.setAutoCommit(false);

        String sqlVerifica = "SELECT NIF FROM cliente WHERE NIF = ?";
        PreparedStatement psVerifica = con.prepareStatement(sqlVerifica);
        psVerifica.setString(1, nif);
        ResultSet rsVerifica = psVerifica.executeQuery();
        boolean existe = rsVerifica.next();
        rsVerifica.close();
        psVerifica.close();

        boolean sucesso = false;

        if (existe) {
          String sqlCliente = "UPDATE cliente SET nomeCompleto=?, contactos=?, arteria=?, numero=?, andar=?, distrito=?, concelho=?, freguesia=?, prefLinguisticas=? WHERE NIF=?";
          PreparedStatement psCliente = con.prepareStatement(sqlCliente);
          psCliente.setString(1, nomeCompleto);
          psCliente.setString(2, contactos);
          psCliente.setString(3, arteria);
          psCliente.setInt(4, Integer.parseInt(numero));
          psCliente.setString(5, andar.isEmpty() ? null : andar);
          psCliente.setString(6, distrito.isEmpty() ? null : distrito);
          psCliente.setString(7, concelho.isEmpty() ? null : concelho);
          psCliente.setString(8, freguesia.isEmpty() ? null : freguesia);
          psCliente.setString(9, prefLinguisticas.isEmpty() ? null : prefLinguisticas);
          psCliente.setString(10, nif);
          sucesso = psCliente.executeUpdate() > 0;
          psCliente.close();
        } else {
          String sqlCliente = "INSERT INTO cliente (NIF, nomeCompleto, contactos, arteria, numero, andar, distrito, concelho, freguesia, prefLinguisticas) VALUES (?,?,?,?,?,?,?,?,?,?)";
          PreparedStatement psCliente = con.prepareStatement(sqlCliente);
          psCliente.setString(1, nif);
          psCliente.setString(2, nomeCompleto);
          psCliente.setString(3, contactos);
          psCliente.setString(4, arteria);
          psCliente.setInt(5, Integer.parseInt(numero));
          psCliente.setString(6, andar.isEmpty() ? null : andar);
          psCliente.setString(7, distrito.isEmpty() ? null : distrito);
          psCliente.setString(8, concelho.isEmpty() ? null : concelho);
          psCliente.setString(9, freguesia.isEmpty() ? null : freguesia);
          psCliente.setString(10, prefLinguisticas.isEmpty() ? null : prefLinguisticas);
          sucesso = psCliente.executeUpdate() > 0;
          psCliente.close();
        }

        if (sucesso) {
          if ("pessoa".equals(tipoCliente)) {
            if (!existe) {
              PreparedStatement psPessoa = con.prepareStatement("INSERT INTO pessoa (NIF) VALUES (?)");
              psPessoa.setString(1, nif);
              psPessoa.executeUpdate();
              psPessoa.close();
            }
          } else if ("empresa".equals(tipoCliente)) {
            if (existe) {
              PreparedStatement psEmpresa = con.prepareStatement("UPDATE empresa SET capitalSocial=? WHERE NIF=?");
              psEmpresa.setBigDecimal(1, new BigDecimal(capitalSocial));
              psEmpresa.setString(2, nif);
              psEmpresa.executeUpdate();
              psEmpresa.close();
            } else {
              PreparedStatement psEmpresa = con.prepareStatement("INSERT INTO empresa (NIF, capitalSocial) VALUES (?,?)");
              psEmpresa.setString(1, nif);
              psEmpresa.setBigDecimal(2, new BigDecimal(capitalSocial));
              psEmpresa.executeUpdate();
              psEmpresa.close();
            }
          }

          con.commit();
          mensagem = existe ? "✅ Tutor atualizado com sucesso!" : "✅ Tutor criado com sucesso!";
          tipoMensagem = "sucesso";
        } else {
          con.rollback();
          mensagem = "❌ Erro ao guardar dados";
          tipoMensagem = "erro";
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

  <% if (!mensagem.isEmpty()) { %>
    <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <form method="POST" class="formulario">

    <div class="form-group">
      <label>NIF *</label>
      <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9" required placeholder="Número de Identificação Fiscal">
    </div>

    <div class="form-group">
      <label>Nome Completo *</label>
      <input type="text" name="nomeCompleto" maxlength="150" required>
    </div>

    <div class="form-group">
      <label>Contactos *</label>
      <input type="text" name="contactos" maxlength="100" required placeholder="Telefone/Email">
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Arteria *</label>
        <input type="text" name="arteria" maxlength="255" required>
      </div>

      <div class="form-group">
        <label>Número *</label>
        <input type="number" name="numero" required>
      </div>

      <div class="form-group">
        <label>Andar</label>
        <input type="text" name="andar" maxlength="10">
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Distrito</label>
        <input type="text" name="distrito" maxlength="50">
      </div>

      <div class="form-group">
        <label>Concelho</label>
        <input type="text" name="concelho" maxlength="50">
      </div>

      <div class="form-group">
        <label>Freguesia</label>
        <input type="text" name="freguesia" maxlength="50">
      </div>
    </div>

    <div class="form-group">
      <label>Preferências Linguísticas</label>
      <input type="text" name="prefLinguisticas" maxlength="50" placeholder="Ex: PT">
    </div>

    <div class="form-group">
      <label>Tipo de Cliente *</label>
      <select name="tipoCliente" id="tipoCliente" required onchange="mostrarCampoEmpresa()">
        <option value="">Selecione...</option>
        <option value="pessoa">Pessoa</option>
        <option value="empresa">Empresa</option>
      </select>
    </div>

    <div class="form-group" id="campoCapitalSocial" style="display:none;">
      <label>Capital Social (€) *</label>
      <input type="number" name="capitalSocial" step="0.01" min="0">
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">Guardar</button>
      <button type="reset" class="btn btn-secondary">Limpar</button>
    </div>

  </form>

</div>

<script>
  function mostrarCampoEmpresa(){
    const tipo = document.getElementById('tipoCliente').value;
    const campo = document.getElementById('campoCapitalSocial');
    const input = document.querySelector('input[name="capitalSocial"]');

    if(tipo === "empresa"){
      campo.style.display = "block";
      input.required = true;
    }else{
      campo.style.display = "none";
      input.required = false;
    }
  }
</script>

</body>
</html>
