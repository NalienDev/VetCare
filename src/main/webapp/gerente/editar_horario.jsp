<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Atualizar Horário</title>
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
    .info-box p {
      margin: 5px 0;
      color: #555;
      font-size: 14px;
    }
    .readonly-field {
      background: #F5F5F5;
      cursor: not-allowed;
    }
    .time-inputs {
      display: flex;
      gap: 15px;
      align-items: center;
    }
    .time-inputs .form-group {
      flex: 1;
      margin: 0;
    }
    .delete-section {
      background: #FFF3CD;
      border-left: 4px solid #FFC107;
      padding: 15px;
      margin-top: 30px;
      border-radius: 8px;
    }
    .delete-section h3 {
      margin: 0 0 10px 0;
      color: #856404;
      font-size: 16px;
    }
    .btn-danger {
      background: #DC3545;
      color: white;
      border: none;
      padding: 10px 20px;
      border-radius: 8px;
      cursor: pointer;
      font-weight: 600;
      transition: all 0.3s;
    }
    .btn-danger:hover {
      background: #C82333;
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(220, 53, 69, 0.3);
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

// Dados atuais
java.sql.Time horaInicio = null;
java.sql.Time horaFim = null;

try {
    Connection con = manipula.getLigacao();

    // =============================================
    // ELIMINAR HORÁRIO
    // =============================================
    if ("DELETE".equalsIgnoreCase(request.getParameter("action"))) {
        con.setAutoCommit(false);
        
        PreparedStatement psDel = con.prepareStatement(
            "DELETE FROM horario WHERE localidade=? AND diaUtil=?"
        );
        psDel.setString(1, localidade);
        psDel.setString(2, diaUtil);
        
        int linhas = psDel.executeUpdate();
        psDel.close();

        if (linhas > 0) {
            con.commit();
            response.sendRedirect("gestao_horarios.jsp?msg=deleted");
            return;
        } else {
            con.rollback();
            mensagem = "❌ Erro ao eliminar horário";
            tipoMensagem = "erro";
        }
    }

    // =============================================
    // GUARDAR ALTERAÇÕES
    // =============================================
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String horaInicioStr = request.getParameter("horaInicio");
        String horaFimStr = request.getParameter("horaFim");

        con.setAutoCommit(false);

        // Validar horários
        java.sql.Time inicio = java.sql.Time.valueOf(horaInicioStr + ":00");
        java.sql.Time fim = java.sql.Time.valueOf(horaFimStr + ":00");

        if (inicio.compareTo(fim) >= 0) {
            mensagem = "❌ A hora de início deve ser anterior à hora de fim.";
            tipoMensagem = "erro";
            con.rollback();
        } else {
            // Update horário
            PreparedStatement psUp = con.prepareStatement(
                "UPDATE horario SET horaInicio=?, horaFim=? WHERE localidade=? AND diaUtil=?"
            );
            psUp.setTime(1, inicio);
            psUp.setTime(2, fim);
            psUp.setString(3, localidade);
            psUp.setString(4, diaUtil);
            
            int linhas = psUp.executeUpdate();
            psUp.close();

            if (linhas > 0) {
                con.commit();
                mensagem = "✅ Horário atualizado com sucesso!";
                tipoMensagem = "sucesso";
                horaInicio = inicio;
                horaFim = fim;
            } else {
                con.rollback();
                mensagem = "❌ Erro ao atualizar horário";
                tipoMensagem = "erro";
            }
        }
    }

    // =============================================
    // CARREGAR DADOS ATUAIS PARA O FORM
    // =============================================
    if (horaInicio == null) {
        PreparedStatement ps = con.prepareStatement(
            "SELECT horaInicio, horaFim FROM horario WHERE localidade=? AND diaUtil=?"
        );
        ps.setString(1, localidade);
        ps.setString(2, diaUtil);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            horaInicio = rs.getTime("horaInicio");
            horaFim = rs.getTime("horaFim");
        } else {
            response.sendRedirect("criar_horarios.jsp");
            return;
        }

        rs.close();
        ps.close();
    }
%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Atualizar Horário</h1>
    <p><%= localidade %> - <%= diaUtil %>-feira</p>
  </div>
</section>

<div class="page-content">
  <a href="gestao_horarios.jsp" class="btn-voltar">← Voltar aos Horários</a>

  <% if (!mensagem.isEmpty()) { %>
    <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <div class="info-box">
    <h3>ℹ️ Informação</h3>
    <p>A <strong>localidade</strong> e o <strong>dia da semana</strong> não podem ser alterados.</p>
    <p>Para criar um horário diferente, use a opção "Criar Horário".</p>
  </div>

  <form method="POST" class="formulario">
    <div class="form-group">
      <label>Localidade (Clínica)</label>
      <input 
        type="text" 
        value="<%= localidade %>" 
        class="readonly-field"
        readonly>
    </div>

    <div class="form-group">
      <label>Dia Útil</label>
      <input 
        type="text" 
        value="<%= diaUtil %>-feira" 
        class="readonly-field"
        readonly>
      <small style="color: #666; font-size: 12px; display: block; margin-top: 5px;">
        ℹ️ Estes campos não podem ser alterados
      </small>
    </div>

    <div class="time-inputs">
      <div class="form-group">
        <label>Hora de Início *</label>
        <input 
          type="time" 
          name="horaInicio" 
          value="<%= horaInicio != null ? horaInicio.toString().substring(0, 5) : "" %>"
          required>
      </div>

      <div class="form-group">
        <label>Hora de Fim *</label>
        <input 
          type="time" 
          name="horaFim" 
          value="<%= horaFim != null ? horaFim.toString().substring(0, 5) : "" %>"
          required>
      </div>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">💾 Guardar Alterações</button>
      <a href="gestao_horarios.jsp" class="btn btn-secondary">❌ Cancelar</a>
    </div>
  </form>

  <div class="delete-section">
    <h3>⚠️ Zona de Perigo</h3>
    <p>Eliminar este horário irá <strong>remover permanentemente</strong> o registo da base de dados.</p>
    <p>Esta ação não pode ser revertida!</p>
    <form method="POST" onsubmit="return confirm('⚠️ Tem a certeza que deseja ELIMINAR este horário?\\n\\nLocalidade: <%= localidade %>\\nDia: <%= diaUtil %>-feira\\n\\nEsta ação é IRREVERSÍVEL!');" style="margin-top: 15px;">
      <input type="hidden" name="action" value="DELETE">
      <button type="submit" class="btn-danger">🗑️ Eliminar Horário</button>
    </form>
  </div>
</div>

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