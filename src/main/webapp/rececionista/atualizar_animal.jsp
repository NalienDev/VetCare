<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.io.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VetCare - Atualizar Animal</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  
  <style>
    /* ✨ CORES MELHORADAS - Sistema visual bonito */
    .color-palette {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(60px, 1fr));
      gap: 12px;
      margin-top: 12px;
      padding: 16px;
      background: #F8FAFC;
      border-radius: 16px;
      border: 1px solid #E7EEF4;
    }
    
    .color-option {
      position: relative;
      cursor: pointer;
      transition: transform 0.2s ease;
    }
    
    .color-option:hover {
      transform: translateY(-3px);
    }
    
    .color-option input[type="checkbox"] {
      position: absolute;
      opacity: 0;
      width: 100%;
      height: 100%;
      cursor: pointer;
    }
    
    .color-box {
      width: 60px;
      height: 60px;
      border-radius: 12px;
      border: 3px solid #DFE4EA;
      transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
      display: flex;
      align-items: center;
      justify-content: center;
      position: relative;
      box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    
    .color-option:hover .color-box {
      border-color: #0B2A42;
      box-shadow: 0 4px 12px rgba(11,42,66,0.15);
    }
    
    .color-option input:checked + .color-box {
      border-color: #0B2A42;
      border-width: 4px;
      box-shadow: 0 6px 20px rgba(11,42,66,0.25), 0 0 0 4px rgba(74,144,226,0.2);
      transform: scale(1.05);
    }
    
    .color-option input:checked + .color-box::after {
      content: '✓';
      color: white;
      font-weight: 900;
      font-size: 28px;
      text-shadow: 0 2px 8px rgba(0,0,0,0.6), 0 0 2px rgba(0,0,0,0.8);
      position: absolute;
      animation: checkmark-pop 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
    }
    
    @keyframes checkmark-pop {
      0% {
        transform: scale(0) rotate(-45deg);
        opacity: 0;
      }
      50% {
        transform: scale(1.2) rotate(10deg);
      }
      100% {
        transform: scale(1) rotate(0deg);
        opacity: 1;
      }
    }
    
    .color-label {
      text-align: center;
      font-size: 11px;
      font-weight: 800;
      color: #57606F;
      margin-top: 6px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }
    
    .foto-preview {
      max-width: 220px;
      max-height: 220px;
      margin-top: 12px;
      border-radius: 16px;
      display: none;
      border: 3px solid #E7EEF4;
      box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    }
    
    .color-section {
      background: white;
      padding: 24px;
      border-radius: 20px;
      border: 1px solid #E7EEF4;
      margin-bottom: 20px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04);
    }
    
    .color-section h3 {
      margin: 0 0 16px 0;
      font-size: 16px;
      font-weight: 900;
      color: #0B2A42;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .selected-colors {
      margin-top: 16px;
      padding: 12px;
      background: #EAF6FB;
      border-radius: 12px;
      min-height: 40px;
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      align-items: center;
    }
    
    .selected-color-tag {
      padding: 6px 12px;
      background: white;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 800;
      color: #0B2A42;
      box-shadow: 0 2px 4px rgba(0,0,0,0.06);
    }
    
    .color-info {
      color: #57606F;
      font-size: 13px;
      font-weight: 600;
      margin-top: 8px;
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

<%
String idParam = request.getParameter("idFichaClin");
if (idParam == null) {
    response.sendRedirect("listar_animais.jsp");
    return;
}

int idFicha = Integer.parseInt(idParam);
Configura cfg = new Configura();
Manipula manipula = new Manipula(cfg);

String mensagem = "";
String tipoMensagem = "";

// Dados atuais
String nome = "";
String sexo = "";
String filiacao = "";
String alergias = "";
String estadoReprod = "";
java.sql.Date dataNasc = null;
String nomeRaca = "";
String coresStr = "";
String outrasDistint = "";

try {
    Connection con = manipula.getLigacao();

    // =============================================
    // GUARDAR ALTERAÇÕES
    // =============================================
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        nome = request.getParameter("nome");
        sexo = request.getParameter("sexo");
        filiacao = request.getParameter("filiacao");
        alergias = request.getParameter("alergias");
        estadoReprod = request.getParameter("estadoReprod");
        nomeRaca = request.getParameter("nomeRaca");
        outrasDistint = request.getParameter("outrasDistint");
        
        // ✅ Processar cores selecionadas (múltiplas checkboxes)
        String[] coresSelecionadas = request.getParameterValues("cores");
        if (coresSelecionadas != null && coresSelecionadas.length > 0) {
            coresStr = String.join(", ", coresSelecionadas);
        } else {
            coresStr = "N/A";
        }

        String dataStr = request.getParameter("dataNasc");
        if (dataStr != null && !dataStr.trim().isEmpty()) {
            dataNasc = java.sql.Date.valueOf(dataStr);
        }

        con.setAutoCommit(false);

        // Update ficha
        PreparedStatement psUp = con.prepareStatement(
            "UPDATE fichaClinicaAnimal SET nome=?, sexo=?, dataNasc=?, filiacao=?, alergias=?, estadoReprod=? WHERE idFichaClin=?"
        );
        psUp.setString(1, nome);
        psUp.setString(2, sexo);
        psUp.setDate(3, dataNasc);
        psUp.setString(4, (filiacao != null && !filiacao.trim().isEmpty()) ? filiacao : "Desconhecido");
        psUp.setString(5, (alergias != null && !alergias.trim().isEmpty()) ? alergias : null);
        psUp.setString(6, estadoReprod);
        psUp.setInt(7, idFicha);
        psUp.executeUpdate();
        psUp.close();

        // Update raça
        PreparedStatement psR = con.prepareStatement(
            "UPDATE fichaRaca SET nomeRaca=? WHERE idFichaClin=?"
        );
        psR.setString(1, nomeRaca);
        psR.setInt(2, idFicha);
        psR.executeUpdate();
        psR.close();

        // Foto (se vier nova)
        Part filePart = request.getPart("fotoPerfil");
        boolean temNovaFoto = (filePart != null && filePart.getSize() > 0);
        byte[] fotoBytes = null;

        if (temNovaFoto) {
            try (InputStream input = filePart.getInputStream()) {
                fotoBytes = input.readAllBytes();
            }
        }

        // Update características (cores + outrasDistint + foto se existir)
        if (temNovaFoto) {
            PreparedStatement psCar = con.prepareStatement(
                "UPDATE caracteristicasFic SET cores=?, outrasDistint=?, fotografia=? WHERE idFicha=?"
            );
            psCar.setString(1, coresStr);
            psCar.setString(2, (outrasDistint != null && !outrasDistint.trim().isEmpty()) ? outrasDistint : "N/A");
            psCar.setBytes(3, fotoBytes);
            psCar.setInt(4, idFicha);
            psCar.executeUpdate();
            psCar.close();
        } else {
            PreparedStatement psCar = con.prepareStatement(
                "UPDATE caracteristicasFic SET cores=?, outrasDistint=? WHERE idFicha=?"
            );
            psCar.setString(1, coresStr);
            psCar.setString(2, (outrasDistint != null && !outrasDistint.trim().isEmpty()) ? outrasDistint : "N/A");
            psCar.setInt(3, idFicha);
            psCar.executeUpdate();
            psCar.close();
        }

        con.commit();
        mensagem = "✅ Dados do animal atualizados com sucesso!";
        tipoMensagem = "sucesso";
    }

    // =============================================
    // CARREGAR DADOS ATUAIS PARA O FORM
    // =============================================
    PreparedStatement ps = con.prepareStatement(
        "SELECT f.*, fr.nomeRaca, cf.cores, cf.outrasDistint " +
        "FROM fichaClinicaAnimal f " +
        "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
        "LEFT JOIN caracteristicasFic cf ON f.idFichaClin = cf.idFicha " +
        "WHERE f.idFichaClin=?"
    );
    ps.setInt(1, idFicha);
    ResultSet rs = ps.executeQuery();

    if (rs.next()) {
        nome = rs.getString("nome");
        sexo = rs.getString("sexo");
        dataNasc = rs.getDate("dataNasc");
        filiacao = rs.getString("filiacao");
        alergias = rs.getString("alergias");
        estadoReprod = rs.getString("estadoReprod");
        nomeRaca = rs.getString("nomeRaca");
        coresStr = rs.getString("cores");
        outrasDistint = rs.getString("outrasDistint");
    }

    rs.close();
    ps.close();
    
    // ✅ Preparar array de cores selecionadas para JavaScript
    List<String> coresSelecionadas = new ArrayList<>();
    if (coresStr != null && !coresStr.trim().isEmpty() && !coresStr.equals("N/A")) {
        String[] coresArray = coresStr.split(",");
        for (String cor : coresArray) {
            coresSelecionadas.add(cor.trim());
        }
    }
%>

<section class="page-hero">
  <div class="page-hero-inner">
    <h1>Atualizar Animal: <%= nome %></h1>
    <p>ID: <%= idFicha %> | Edite os dados do animal</p>
  </div>
</section>

<div class="page-content">
  <a href="ficha_clinica_rececionista.jsp?idFichaClin=<%= idFicha %>" class="btn-voltar">← Voltar à Ficha</a>

  <% if (!mensagem.isEmpty()) { %>
    <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
  <% } %>

  <form method="POST" class="formulario" enctype="multipart/form-data">
    <div class="form-group">
      <label>Nome *</label>
      <input type="text" name="nome" value="<%= nome != null ? nome : "" %>" required>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Sexo *</label>
        <select name="sexo" required>
          <option value="M" <%= "M".equals(sexo) ? "selected" : "" %>>🐕 Macho</option>
          <option value="F" <%= "F".equals(sexo) ? "selected" : "" %>>🐕 Fêmea</option>
          <option value="N" <%= "N".equals(sexo) ? "selected" : "" %>>Não aplicável</option>
        </select>
      </div>

      <div class="form-group">
        <label>Data de Nascimento *</label>
        <input type="date" name="dataNasc" value="<%= dataNasc != null ? dataNasc.toString() : "" %>" required max="<%= java.time.LocalDate.now() %>">
      </div>
    </div>

    <div class="form-group">
      <label>Raça *</label>
      <input type="text" name="nomeRaca" value="<%= nomeRaca != null ? nomeRaca : "" %>" required>
    </div>

    <div class="form-group">
      <label>Foto de Perfil</label>
      <input type="file" name="fotoPerfil" id="fotoPerfil" accept="image/*" onchange="previewFoto(this)">
      <img id="fotoPreview" class="foto-preview" alt="Preview">
      <p class="color-info">
        💡 Deixe em branco para manter a foto atual
      </p>
    </div>

    <!-- ✨ SISTEMA DE CORES VISUAL MELHORADO -->
    <div class="color-palette">
        <label class="color-option">
          <input type="checkbox" name="cores" value="Preto" id="cor-preto">
          <div class="color-box" style="background:#000000"></div>
          <div class="color-label">Preto</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Branco" id="cor-branco">
          <div class="color-box" style="background:#FFFFFF; border-color:#CCCCCC"></div>
          <div class="color-label">Branco</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Castanho" id="cor-castanho">
          <div class="color-box" style="background:#8B4513"></div>
          <div class="color-label">Castanho</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Dourado" id="cor-dourado">
          <div class="color-box" style="background:#FFD700"></div>
          <div class="color-label">Dourado</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Cinzento" id="cor-cinzento">
          <div class="color-box" style="background:#808080"></div>
          <div class="color-label">Cinzento</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Laranja" id="cor-laranja">
          <div class="color-box" style="background:#FFA500"></div>
          <div class="color-label">Laranja</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Azul" id="cor-azul">
          <div class="color-box" style="background:#4169E1"></div>
          <div class="color-label">Azul</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Verde" id="cor-verde">
          <div class="color-box" style="background:#228B22"></div>
          <div class="color-label">Verde</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Vermelho" id="cor-vermelho">
          <div class="color-box" style="background:#DC143C"></div>
          <div class="color-label">Vermelho</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Amarelo" id="cor-amarelo">
          <div class="color-box" style="background:#FFD700"></div>
          <div class="color-label">Amarelo</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Rosa" id="cor-rosa">
          <div class="color-box" style="background:#FFB6C1"></div>
          <div class="color-label">Rosa</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Roxo" id="cor-roxo">
          <div class="color-box" style="background:#9370DB"></div>
          <div class="color-label">Roxo</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Bege" id="cor-bege">
          <div class="color-box" style="background:#F5F5DC; border-color:#D4CFC0"></div>
          <div class="color-label">Bege</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Creme" id="cor-creme">
          <div class="color-box" style="background:#FFFACD; border-color:#E6E1B8"></div>
          <div class="color-label">Creme</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Tigrado" id="cor-tigrado">
          <div class="color-box" style="background:repeating-linear-gradient(45deg,#8B4513,#8B4513 10px,#D2691E 10px,#D2691E 20px)"></div>
          <div class="color-label">Tigrado</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Malhado" id="cor-malhado">
          <div class="color-box" style="background:radial-gradient(circle at 25% 25%, #000 15%, #fff 15% 35%, #000 35% 50%, #fff 50%)"></div>
          <div class="color-label">Malhado</div>
        </label>
        
        <label class="color-option">
          <input type="checkbox" name="cores" value="Tricolor" id="cor-tricolor">
          <div class="color-box" style="background:linear-gradient(120deg,#000 33%,#fff 33% 66%,#8B4513 66%)"></div>
          <div class="color-label">Tricolor</div>
        </label>
      </div>
      
      <div class="selected-colors" id="selectedColors">
        <span class="color-info" id="noColorText">Nenhuma cor selecionada</span>
      </div>
    </div>

    <div class="form-group">
      <label>Outras Características Distintivas</label>
      <textarea name="outrasDistint" rows="3" placeholder="Ex: mancha específica, cicatriz, dedo extra..."><%= outrasDistint != null ? outrasDistint : "" %></textarea>
    </div>

    <div class="form-group">
      <label>Filiação</label>
      <input type="text" name="filiacao" value="<%= filiacao != null ? filiacao : "" %>" placeholder="Criador, pais conhecidos...">
    </div>

    <div class="form-group">
      <label>Estado Reprodutivo *</label>
      <select name="estadoReprod" required>
        <option value="Inteiro" <%= "Inteiro".equals(estadoReprod) ? "selected" : "" %>>Inteiro</option>
        <option value="Castrado" <%= "Castrado".equals(estadoReprod) ? "selected" : "" %>>Castrado</option>
        <option value="Esterilizada" <%= "Esterilizada".equals(estadoReprod) ? "selected" : "" %>>Esterilizada</option>
      </select>
    </div>

    <div class="form-group">
      <label>Alergias</label>
      <textarea name="alergias" rows="3" placeholder="Alergias alimentares, medicamentosas..."><%= alergias != null ? alergias : "" %></textarea>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">💾 Guardar Alterações</button>
      <a href="ficha_clinica_rececionista.jsp?idFichaClin=<%= idFicha %>" class="btn btn-secondary">❌ Cancelar</a>
    </div>
  </form>
</div>

<script>
// ✅ Cores já selecionadas (vindas do servidor)
const coresAtuais = [
<%
    for (int i = 0; i < coresSelecionadas.size(); i++) {
        out.print("\"" + coresSelecionadas.get(i).replace("\"", "\\\"") + "\"");
        if (i < coresSelecionadas.size() - 1) out.print(",");
    }
%>
];
// ✅ Marcar checkboxes com cores já guardadas
window.addEventListener('DOMContentLoaded', function() {
  coresAtuais.forEach(function(cor) {
    const checkbox = document.querySelector('input[name="cores"][value="' + cor + '"]');
    if (checkbox) {
      checkbox.checked = true;
    }
  });
  updateSelectedColors();
});

// ✅ Atualizar display de cores selecionadas
function updateSelectedColors() {
  const checkboxes = document.querySelectorAll('input[name="cores"]:checked');
  const container = document.getElementById('selectedColors');
  const noColorText = document.getElementById('noColorText');
  
  container.innerHTML = '';
  
  if (checkboxes.length === 0) {
    container.innerHTML = '<span class="color-info" id="noColorText">Nenhuma cor selecionada</span>';
  } else {
    checkboxes.forEach(function(cb) {
      const tag = document.createElement('span');
      tag.className = 'selected-color-tag';
      tag.textContent = cb.value;
      container.appendChild(tag);
    });
  }
}

// ✅ Listener para atualizar quando selecionam cores
document.querySelectorAll('input[name="cores"]').forEach(function(checkbox) {
  checkbox.addEventListener('change', updateSelectedColors);
});

// ✅ Preview da foto
function previewFoto(input) {
  const preview = document.getElementById('fotoPreview');
  if (input.files && input.files[0]) {
    const reader = new FileReader();
    reader.onload = function(e) {
      preview.src = e.target.result;
      preview.style.display = 'block';
    };
    reader.readAsDataURL(input.files[0]);
  }
}
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
