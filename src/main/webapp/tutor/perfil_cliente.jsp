<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.time.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Meu Perfil</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  <style>
    .btn-voltar {
      margin-bottom: 30px;
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

<%
String nif = request.getParameter("nif");

if (nif == null || nif.trim().isEmpty()) {
%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>O Meu Perfil</h1>
    <p>Visualize as suas informações e animais</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>
  
  <div class="formulario">
    <form method="GET">
      <div class="form-group">
        <label>Seu NIF</label>
        <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9"
               placeholder="Digite seu NIF para ver o perfil" required>
      </div>
      <button type="submit" class="btn btn-primary">Ver Perfil</button>
    </form>
  </div>
</div>

<%
} else {
    Configura cfg = new Configura();
    Manipula manipula = new Manipula(cfg);
    
    try {
        Connection con = manipula.getLigacao();
        
        PreparedStatement psCliente = con.prepareStatement(
            "SELECT c.*, p.NIF as isPessoa " +
            "FROM cliente c " +
            "LEFT JOIN pessoa p ON p.NIF = c.NIF " +
            "WHERE c.NIF = ?"
        );
        psCliente.setString(1, nif);
        ResultSet rsCliente = psCliente.executeQuery();
        
        if (!rsCliente.next()) {
%>
<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Erro</h1>
    <p>Cliente não encontrado</p>
  </div>
</section>

<div class="page-content">
  <a href="?nif=" class="btn-voltar">← Tentar outro NIF</a>
  <div class="mensagem erro">❌ Não foi encontrado nenhum cliente com o NIF <%= nif %></div>
</div>

<%
        } else {
            String nomeCompleto = rsCliente.getString("nomeCompleto");
            String contactos = rsCliente.getString("contactos");
            String arteria = rsCliente.getString("arteria");
            int numero = rsCliente.getInt("numero");
            String andar = rsCliente.getString("andar");
            String distrito = rsCliente.getString("distrito");
            String concelho = rsCliente.getString("concelho");
            String freguesia = rsCliente.getString("freguesia");
            String prefLinguisticas = rsCliente.getString("prefLinguisticas");
            boolean isPessoa = rsCliente.getString("isPessoa") != null;
            
            String moradaCompleta = arteria + ", nº " + numero;
            if (andar != null && !andar.trim().isEmpty()) {
                moradaCompleta += ", " + andar;
            }
            
            rsCliente.close();
            psCliente.close();
            
            PreparedStatement psCountAnimais = con.prepareStatement(
                "SELECT COUNT(*) as total FROM tutor WHERE NIF = ?"
            );
            psCountAnimais.setString(1, nif);
            ResultSet rsCount = psCountAnimais.executeQuery();
            int totalAnimais = 0;
            if (rsCount.next()) {
                totalAnimais = rsCount.getInt("total");
            }
            rsCount.close();
            psCountAnimais.close();
            
            PreparedStatement psCountAgend = con.prepareStatement(
                "SELECT COUNT(*) as total FROM agenda WHERE NIF = ?"
            );
            psCountAgend.setString(1, nif);
            ResultSet rsCountAgend = psCountAgend.executeQuery();
            int totalAgendamentos = 0;
            if (rsCountAgend.next()) {
                totalAgendamentos = rsCountAgend.getInt("total");
            }
            rsCountAgend.close();
            psCountAgend.close();
            
            PreparedStatement psAnimais = con.prepareStatement(
                "SELECT f.idFichaClin, f.nome, f.dataNasc, r.nomeRaca, e.nomeComum as especie " +
                "FROM fichaClinicaAnimal f " +
                "JOIN tutor t ON t.idFichaClin = f.idFichaClin " +
                "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
                "LEFT JOIN raca r ON r.nomeRaca = fr.nomeRaca " +
                "LEFT JOIN especie e ON e.nomeComum = r.nomeComum " +
                "WHERE t.NIF = ? " +
                "ORDER BY f.nome"
            );
            psAnimais.setString(1, nif);
            ResultSet rsAnimais = psAnimais.executeQuery();
%>

<section class="page-hero" style="background: #EAF6FB;">
  <div class="page-hero-inner">
    <h1><%= nomeCompleto %></h1>
    <p>NIF: <%= nif %> | <%= isPessoa ? "Pessoa Física" : "Empresa" %></p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar ao Menu</a>
  
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 30px;">
    <div class="table-card" style="text-align: center; padding: 28px; background: white; border: 1px solid #E7EEF4; border-radius: 24px 6px 24px 6px;">
      <div style="font-size: 48px; font-weight: 900; color: #0B2A42; margin-bottom: 8px;"><%= totalAnimais %></div>
      <div style="font-size: 14px; font-weight: 800; color: #57606F; text-transform: uppercase;"><img src="../images/icon-paw.png" alt="Animais" style="width: 16px; height: 16px; vertical-align: middle; margin-right: 4px;"><%= totalAnimais == 1 ? "Animal" : "Animais" %></div>
    </div>
    
    <div class="table-card" style="text-align: center; padding: 28px; background: white; border: 1px solid #E7EEF4; border-radius: 24px 6px 24px 6px;">
      <div style="font-size: 48px; font-weight: 900; color: #0B2A42; margin-bottom: 8px;"><%= totalAgendamentos %></div>
      <div style="font-size: 14px; font-weight: 800; color: #57606F; text-transform: uppercase;"><img src="../images/icon-calendar-small.png" alt="Agendamentos" style="width: 16px; height: 16px; vertical-align: middle; margin-right: 4px;"><%= totalAgendamentos == 1 ? "Agendamento" : "Agendamentos" %></div>
    </div>
  </div>
  
  <div class="table-card" style="margin-top: 20px; background: white; border: 1px solid #E7EEF4; border-radius: 24px 6px 24px 6px; padding: 22px;">
    <h3 style="margin: 0 0 20px 0; font-size: 18px; font-weight: 900; color: #0B2A42;"><img src="../images/icon-clipboard.png" alt="Informações" style="width: 20px; height: 20px; vertical-align: middle; margin-right: 8px;">Informações Pessoais</h3>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 16px;">
      <div style="background: #F8FAFC; padding: 16px; border-radius: 12px;">
        <div style="font-size: 11px; font-weight: 800; color: #57606F; text-transform: uppercase; margin-bottom: 8px;">Nome Completo</div>
        <div style="font-size: 15px; font-weight: 900; color: #0B2A42;"><%= nomeCompleto %></div>
      </div>
      
      <div style="background: #F8FAFC; padding: 16px; border-radius: 12px;">
        <div style="font-size: 11px; font-weight: 800; color: #57606F; text-transform: uppercase; margin-bottom: 8px;">NIF</div>
        <div style="font-size: 15px; font-weight: 900; color: #0B2A42;"><%= nif %></div>
      </div>
      
      <div style="background: #F8FAFC; padding: 16px; border-radius: 12px;">
        <div style="font-size: 11px; font-weight: 800; color: #57606F; text-transform: uppercase; margin-bottom: 8px;">Contactos</div>
        <div style="font-size: 15px; font-weight: 900; color: #0B2A42;"><%= contactos %></div>
      </div>
      
      <div style="background: #F8FAFC; padding: 16px; border-radius: 12px;">
        <div style="font-size: 11px; font-weight: 800; color: #57606F; text-transform: uppercase; margin-bottom: 8px;">Tipo de Cliente</div>
        <div style="font-size: 15px; font-weight: 900; color: #0B2A42;"><%= isPessoa ? "Pessoa Física" : "Empresa" %></div>
      </div>
      
      <% if (prefLinguisticas != null && !prefLinguisticas.trim().isEmpty()) { %>
      <div style="background: #F8FAFC; padding: 16px; border-radius: 12px;">
        <div style="font-size: 11px; font-weight: 800; color: #57606F; text-transform: uppercase; margin-bottom: 8px;">Preferências Linguísticas</div>
        <div style="font-size: 15px; font-weight: 900; color: #0B2A42;"><%= prefLinguisticas %></div>
      </div>
      <% } %>
    </div>
  </div>
  
  <div class="table-card" style="margin-top: 20px; background: white; border: 1px solid #E7EEF4; border-radius: 24px 6px 24px 6px; padding: 22px;">
    <h3 style="margin: 0 0 20px 0; font-size: 18px; font-weight: 900; color: #0B2A42;"><img src="../images/icon-home.png" alt="Morada" style="width: 20px; height: 20px; vertical-align: middle; margin-right: 8px;">Morada</h3>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 16px;">
      <div style="background: #F8FAFC; padding: 16px; border-radius: 12px;">
        <div style="font-size: 11px; font-weight: 800; color: #57606F; text-transform: uppercase; margin-bottom: 8px;">Morada Completa</div>
        <div style="font-size: 15px; font-weight: 900; color: #0B2A42;"><%= moradaCompleta %></div>
      </div>
      
      <% if (freguesia != null && !freguesia.trim().isEmpty()) { %>
      <div style="background: #F8FAFC; padding: 16px; border-radius: 12px;">
        <div style="font-size: 11px; font-weight: 800; color: #57606F; text-transform: uppercase; margin-bottom: 8px;">Freguesia</div>
        <div style="font-size: 15px; font-weight: 900; color: #0B2A42;"><%= freguesia %></div>
      </div>
      <% } %>
      
      <% if (concelho != null && !concelho.trim().isEmpty()) { %>
      <div style="background: #F8FAFC; padding: 16px; border-radius: 12px;">
        <div style="font-size: 11px; font-weight: 800; color: #57606F; text-transform: uppercase; margin-bottom: 8px;">Concelho</div>
        <div style="font-size: 15px; font-weight: 900; color: #0B2A42;"><%= concelho %></div>
      </div>
      <% } %>
      
      <% if (distrito != null && !distrito.trim().isEmpty()) { %>
      <div style="background: #F8FAFC; padding: 16px; border-radius: 12px;">
        <div style="font-size: 11px; font-weight: 800; color: #57606F; text-transform: uppercase; margin-bottom: 8px;">Distrito</div>
        <div style="font-size: 15px; font-weight: 900; color: #0B2A42;"><%= distrito %></div>
      </div>
      <% } %>
    </div>
  </div>
  
  <div class="table-card" style="margin-top: 20px; background: white; border: 1px solid #E7EEF4; border-radius: 24px 6px 24px 6px; padding: 22px;">
    <h3 style="margin: 0 0 20px 0; font-size: 18px; font-weight: 900; color: #0B2A42;"><img src="../images/icon-paw.png" alt="Animais" style="width: 20px; height: 20px; vertical-align: middle; margin-right: 8px;">Os Meus Animais</h3>
    
    <%
    boolean temAnimais = false;
    %>
    
    <div class="menu-grid">
    <%
        while (rsAnimais.next()) {
            temAnimais = true;
            int idAnimal = rsAnimais.getInt("idFichaClin");
            String nomeAnimal = rsAnimais.getString("nome");
            String raca = rsAnimais.getString("nomeRaca");
            String especie = rsAnimais.getString("especie");
            java.sql.Date dataNasc = rsAnimais.getDate("dataNasc");
            
            int idade = 0;
            if (dataNasc != null) {
                LocalDate nascimento = dataNasc.toLocalDate();
                idade = Period.between(nascimento, LocalDate.now()).getYears();
            }
    %>
      <a href="consultar_fichas.jsp?nif=<%= nif %>&idFichaClin=<%= idAnimal %>" class="menu-card">
        <div style="display: flex; gap: 16px; align-items: center;">
          <img src="../fotoAnimal?id=<%= idAnimal %>" style="width: 60px; height: 60px; border-radius: 12px; object-fit: cover; border: 2px solid #E7EEF4;">
          <div style="flex: 1;">
            <h2 style="margin: 0 0 4px 0;"><%= nomeAnimal %></h2>
            <p style="margin: 0;"><%= especie != null ? especie : "Animal" %> | <%= idade %> <%= idade == 1 ? "ano" : "anos" %></p>
          </div>
        </div>
      </a>
    <%
        }
        
        if (!temAnimais) {
    %>
      <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #57606F;">
        <div style="font-size: 48px; margin-bottom: 12px; opacity: 0.5;">🐾</div>
        <div style="font-weight: 700;">Ainda não tem animais registados</div>
      </div>
    <%
        }
    %>
    </div>
    
    <%
            rsAnimais.close();
            psAnimais.close();
    %>
  </div>
</div>

<%
        }
        
    } catch (Exception e) {
%>
<div class="page-content">
  <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
</div>
<%
        e.printStackTrace();
    } finally {
        manipula.desligar();
    }
}
%>

</body>
</html>
