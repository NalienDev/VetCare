<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.io.*, java.nio.file.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
  <meta charset="UTF-8">
  <title>Criar Animal</title>
  <link rel="stylesheet" href="../css/vetcare-ui.css">
  <style>
    .color-palette {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(50px, 1fr));
      gap: 10px;
      margin-top: 10px;
    }
    .color-option {
      position: relative;
      cursor: pointer;
    }
    .color-option input[type="checkbox"] {
      position: absolute;
      opacity: 0;
    }
    .color-box {
      width: 50px;
      height: 50px;
      border-radius: 8px;
      border: 3px solid transparent;
      transition: all 0.2s;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .color-option input:checked + .color-box {
      border-color: #0B2A42;
      box-shadow: 0 0 0 2px #4A90E2;
    }
    .color-option input:checked + .color-box::after {
      content: '✓';
      color: white;
      font-weight: bold;
      font-size: 24px;
      text-shadow: 0 0 3px rgba(0,0,0,0.5);
    }
    .foto-preview {
      max-width: 200px;
      max-height: 200px;
      margin-top: 10px;
      border-radius: 12px;
      display: none;
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
    <h1>Criar Animal</h1>
    <p>Registar um novo animal na clínica.</p>
  </div>
</section>

<div class="page-content">
  <a href="menu.jsp" class="btn-voltar">← Voltar</a>

  <%
    String mensagem = "";
    String tipoMensagem = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
      String nifTutor = request.getParameter("nifTutor");
      String nome = request.getParameter("nome");
      String sexo = request.getParameter("sexo");
      String dataNasc = request.getParameter("dataNasc");
      String filiacao = request.getParameter("filiacao");
      String estadoReprod = request.getParameter("estadoReprod");
      String alergias = request.getParameter("alergias");
      String nomeRaca = request.getParameter("nomeRaca");
      String nomeEspecie = request.getParameter("nomeEspecie");
      String[] coresSelecionadas = request.getParameterValues("cores");
      String outrasDistint = request.getParameter("outrasDistint");

      Configura cfg = new Configura();
      Manipula manipula = new Manipula(cfg);

      try {
        Connection con = manipula.getLigacao();
        con.setAutoCommit(false);

        // Próximo ID
        String sqlMaxId = "SELECT COALESCE(MAX(idFichaClin),0)+1 AS proximoId FROM fichaClinicaAnimal";
        PreparedStatement psMax = con.prepareStatement(sqlMaxId);
        ResultSet rsMax = psMax.executeQuery();
        int idFicha = 1;
        if(rsMax.next()) idFicha = rsMax.getInt("proximoId");
        rsMax.close(); psMax.close();

        // Verificar se espécie existe, senão criar
        String sqlEsp = "SELECT nomeComum FROM especie WHERE nomeComum = ?";
        PreparedStatement psEsp = con.prepareStatement(sqlEsp);
        psEsp.setString(1, nomeEspecie);
        ResultSet rsEsp = psEsp.executeQuery();
        
        if (!rsEsp.next()) {
          // Criar espécie
          String sqlInsEsp = "INSERT INTO especie (nomeComum, nomeCientifico, regimeAlimentar, padraoAtividade, vocalizacao) VALUES (?,?,?,?,?)";
          PreparedStatement psInsEsp = con.prepareStatement(sqlInsEsp);
          psInsEsp.setString(1, nomeEspecie);
          psInsEsp.setString(2, nomeEspecie + " sp.");
          psInsEsp.setString(3, "Variado");
          psInsEsp.setString(4, "Variado");
          psInsEsp.setString(5, "Variado");
          psInsEsp.executeUpdate();
          psInsEsp.close();
        }
        rsEsp.close();
        psEsp.close();

        // Verificar se raça existe, senão criar
        String sqlRaca = "SELECT nomeRaca FROM raca WHERE nomeRaca = ?";
        PreparedStatement psRaca = con.prepareStatement(sqlRaca);
        psRaca.setString(1, nomeRaca);
        ResultSet rsRaca = psRaca.executeQuery();
        
        if (!rsRaca.next()) {
          // Criar raça
          String sqlInsRaca = "INSERT INTO raca (nomeRaca, nomeComum, expectativaVida, pesoAdlt, comprimentoAdlt, porte, predisposicoesGen, cuidadosEsp) VALUES (?,?,?,?,?,?,?,?)";
          PreparedStatement psInsRaca = con.prepareStatement(sqlInsRaca);
          psInsRaca.setString(1, nomeRaca);
          psInsRaca.setString(2, nomeEspecie);
          psInsRaca.setInt(3, 12);
          psInsRaca.setDouble(4, 5.0);
          psInsRaca.setDouble(5, 30.0);
          psInsRaca.setString(6, "Médio");
          psInsRaca.setString(7, "N/A");
          psInsRaca.setString(8, "N/A");
          psInsRaca.executeUpdate();
          psInsRaca.close();
        }
        rsRaca.close();
        psRaca.close();

        // Inserir ficha animal
        String sqlFicha = "INSERT INTO fichaClinicaAnimal (idFichaClin,nome,sexo,dataNasc,filiacao,estadoReprod,alergias) VALUES (?,?,?,?,?,?,?)";
        PreparedStatement psFicha = con.prepareStatement(sqlFicha);
        psFicha.setInt(1, idFicha);
        psFicha.setString(2, nome);
        psFicha.setString(3, sexo);
        
        java.sql.Date dn = null;
        if (dataNasc == null || dataNasc.trim().isEmpty()) {
          throw new Exception("Data de nascimento é obrigatória.");
        }
        
        try {
          if (dataNasc.contains("-")) {
            dn = java.sql.Date.valueOf(dataNasc);
          } else {
            java.util.Date utilDate = new java.text.SimpleDateFormat("dd/MM/yyyy").parse(dataNasc);
            dn = new java.sql.Date(utilDate.getTime());
          }
        } catch (Exception ex) {
          throw new Exception("Data inválida. Use dd/mm/aaaa ou yyyy-mm-dd.");
        }
        
        psFicha.setDate(4, dn);
        psFicha.setString(5, (filiacao != null && !filiacao.trim().isEmpty()) ? filiacao : "Desconhecido");
        psFicha.setString(6, estadoReprod);
        psFicha.setString(7, (alergias != null && !alergias.trim().isEmpty()) ? alergias : null);
        
        int linhas = psFicha.executeUpdate();
        psFicha.close();

        if (linhas > 0) {

          // Raça
          PreparedStatement psR = con.prepareStatement("INSERT INTO fichaRaca (idFichaClin,nomeRaca) VALUES (?,?)");
          psR.setInt(1, idFicha);
          psR.setString(2, nomeRaca);
          psR.executeUpdate();
          psR.close();

          // Tutor
          PreparedStatement psT = con.prepareStatement("INSERT INTO tutor (NIF,idFichaClin) VALUES (?,?)");
          psT.setString(1, nifTutor);
          psT.setInt(2, idFicha);
          psT.executeUpdate();
          psT.close();

          // Histórico
          PreparedStatement psH = con.prepareStatement("INSERT INTO historicoClinico (idFichaClin) VALUES (?)");
          psH.setInt(1, idFicha);
          psH.executeUpdate();
          psH.close();

          // FOTO + CARACTERÍSTICAS FÍSICAS
          Part filePart = request.getPart("fotoPerfil");
          String cores = (coresSelecionadas != null) ? String.join(", ", coresSelecionadas) : "N/A";

          // ✅ CORREÇÃO: guardar foto NA BASE DE DADOS (BLOB) e não no filesystem
          byte[] fotoBytes = new byte[0];
          if (filePart != null && filePart.getSize() > 0) {
            try (InputStream input = filePart.getInputStream()) {
              fotoBytes = input.readAllBytes();
            }
          }

          // Guardar características na BD
          String sqlFoto = "INSERT INTO caracteristicasFic (idFicha, cores, fotografia, peso, outrasDistint) VALUES (?,?,?,?,?)";
          PreparedStatement psFoto = con.prepareStatement(sqlFoto);
          psFoto.setInt(1, idFicha);
          psFoto.setString(2, cores);
          psFoto.setBytes(3, fotoBytes); // ✅ agora guarda a foto real em BLOB

          // ✅ CORREÇÃO: peso aqui é peso atual, NÃO é tamanho do ficheiro
          // Como o veterinário altera o peso na ficha, aqui fica NULL
          psFoto.setNull(4, java.sql.Types.DECIMAL);

          psFoto.setString(5, (outrasDistint != null && !outrasDistint.trim().isEmpty()) ? outrasDistint : "N/A");
          psFoto.executeUpdate();
          psFoto.close();

          PreparedStatement psC = con.prepareStatement("INSERT INTO contem (idFichaClin) VALUES (?)");
          psC.setInt(1, idFicha);
          psC.executeUpdate();
          psC.close();

          con.commit();
          mensagem = "✅ Animal registado com sucesso! ID: " + idFicha;
          tipoMensagem = "sucesso";

        } else {
          con.rollback();
          mensagem = "❌ Erro ao registar animal";
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

  <form method="POST" class="formulario" enctype="multipart/form-data">
    <div class="form-group">
      <label>NIF do Tutor *</label>
      <input type="text" name="nifTutor" pattern="[0-9]{9}" maxlength="9" required>
    </div>

    <div class="form-group">
      <label>Nome do Animal *</label>
      <input type="text" name="nome" maxlength="100" required>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Sexo *</label>
        <select name="sexo" required>
          <option value="">Selecione...</option>
          <option value="M">🐕 Macho</option>
          <option value="F">🐕 Fêmea</option>
        </select>
      </div>

      <div class="form-group">
        <label>Data de Nascimento *</label>
        <input type="date" name="dataNasc" required max="<%= java.time.LocalDate.now() %>">
      </div>
    </div>

    <div class="form-group">
      <label>Espécie *</label>
      <select name="nomeEspecie" id="especieSelect" required onchange="carregarRacas()">
        <option value="">Selecione...</option>
        <option value="Cão">🐕 Cão</option>
        <option value="Gato">🐈 Gato</option>
        <option value="Coelho">🐰 Coelho</option>
        <option value="Porquinho da Índia">🐹 Porquinho da Índia</option>
        <option value="Hamster">🐹 Hamster</option>
        <option value="Cavalo">🐴 Cavalo</option>
        <option value="Pássaro">🦜 Pássaro</option>
        <option value="Tartaruga">🐢 Tartaruga</option>
        <option value="Furão">🦦 Furão</option>
        <option value="Chinchila">🐭 Chinchila</option>
      </select>
    </div>

    <div class="form-group" id="racaGroup" style="display:none;">
      <label>Raça *</label>
      <input type="text" name="nomeRaca" id="racaInput" list="racasList" maxlength="100">
      <datalist id="racasList"></datalist>
    </div>

    <div class="form-group">
      <label>Foto de Perfil</label>
      <input type="file" name="fotoPerfil" id="fotoPerfil" accept="image/*" onchange="previewFoto(this)">
      <img id="fotoPreview" class="foto-preview" alt="Preview">
    </div>

    <div class="form-group">
      <label>Cores do Animal</label>
      <div class="color-palette">
        <label class="color-option">
          <input type="checkbox" name="cores" value="Preto">
          <div class="color-box" style="background:#000000"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Branco">
          <div class="color-box" style="background:#FFFFFF; border:1px solid #ddd"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Castanho">
          <div class="color-box" style="background:#8B4513"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Dourado">
          <div class="color-box" style="background:#FFD700"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Cinzento">
          <div class="color-box" style="background:#808080"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Laranja">
          <div class="color-box" style="background:#FFA500"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Azul">
          <div class="color-box" style="background:#4169E1"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Verde">
          <div class="color-box" style="background:#228B22"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Vermelho">
          <div class="color-box" style="background:#DC143C"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Amarelo">
          <div class="color-box" style="background:#FFD700"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Rosa">
          <div class="color-box" style="background:#FFB6C1"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Roxo">
          <div class="color-box" style="background:#9370DB"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Bege">
          <div class="color-box" style="background:#F5F5DC"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Creme">
          <div class="color-box" style="background:#FFFACD"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Tigrado">
          <div class="color-box" style="background:repeating-linear-gradient(45deg,#8B4513,#8B4513 10px,#D2691E 10px,#D2691E 20px)"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Malhado">
          <div class="color-box" style="background:radial-gradient(circle, #000 30%, #fff 30%)"></div>
        </label>
        <label class="color-option">
          <input type="checkbox" name="cores" value="Tricolor">
          <div class="color-box" style="background:linear-gradient(120deg,#000 33%,#fff 33% 66%,#8B4513 66%)"></div>
        </label>
      </div>
    </div>

    <div class="form-group">
      <label>Outras Características Distintivas</label>
      <textarea name="outrasDistint" rows="2" placeholder="Ex: dedo extra, mancha específica, cicatriz..."></textarea>
    </div>

    <div class="form-group">
      <label>Filiação</label>
      <input type="text" name="filiacao" maxlength="255" placeholder="Criador, pais conhecidos...">
    </div>

    <div class="form-group">
      <label>Estado Reprodutivo *</label>
      <select name="estadoReprod" required>
        <option value="Inteiro">Inteiro</option>
        <option value="Castrado">Castrado</option>
        <option value="Esterilizada">Esterilizada</option>
      </select>
    </div>

    <div class="form-group">
      <label>Alergias</label>
      <textarea name="alergias" rows="3" placeholder="Alergias alimentares, medicamentosas..."></textarea>
    </div>

    <div class="form-actions">
      <button type="submit" class="btn btn-primary">💾 Guardar</button>
      <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
    </div>
  </form>
</div>

<script>
const racasPorEspecie = {
  "Cão": ["Labrador Retriever","Golden Retriever","Pastor Alemão","Bulldog Francês","Bulldog Inglês","Beagle","Poodle","Rottweiler","Yorkshire Terrier","Boxer","Dachshund (Salsicha)","Husky Siberiano","Doberman","Shih Tzu","Pug","Chihuahua","Border Collie","Cocker Spaniel","Springer Spaniel","Dálmata","Schnauzer","Bernese Mountain Dog","Akita","Chow Chow","Mastim","São Bernardo","Bull Terrier","Staffordshire","Jack Russell Terrier","Bichon Frisé","Maltês","West Highland Terrier","Lhasa Apso","Basenji","Pointer","Setter Irlandês","Setter Inglês","Weimaraner","Vizsla","Basset Hound","Bloodhound","Galgo","Whippet","Greyhound","Border Terrier","Cairn Terrier","Scottish Terrier","Shar Pei","Cão de Água Português","Rafeiro Alentejano","Perdigueiro Português","Podengo Português","Castro Laboreiro","Serra da Estrela","Mestiço","SRD (Sem Raça Definida)"],
  "Gato": ["Persa","Siamês","Maine Coon","Ragdoll","Bengal","British Shorthair","Abissínio","Sphynx","Scottish Fold","Birmanês","Norueguês da Floresta","Angorá","Russian Blue","Exótico","Oriental","Manx","Devon Rex","Cornish Rex","Burmês","Tonkinês","Chartreux","Balinês","Somali","Bombaim","Havana Brown","Singapura","Korat","LaPerm","Selkirk Rex","American Shorthair","American Curl","Munchkin","Savannah","Toyger","Europeu Comum","Mestiço","SRD (Sem Raça Definida)"],
  "Coelho": ["Coelho Anão","Mini Lop","Holland Lop","Lionhead","Rex","Angorá","Gigante Flamengo","Nova Zelândia","Californiano","Netherland Dwarf","Jersey Wooly","Fuzzy Lop","English Lop","French Lop","Himalaia","Hotot","Mini Rex","Polish","Mestiço"],
  "Porquinho da Índia": ["Americano","Abissínio","Peruano","Silkie","Texel","Coronet","Teddy","Rex","Skinny Pig","Baldwin","Alpaca","Lunkarya","Mestiço"],
  "Hamster": ["Sírio (Dourado)","Anão Russo","Roborovski","Chinês","Anão de Campbell","Anão Winter White","Mestiço"],
  "Cavalo": ["Puro Sangue Inglês","Quarto de Milha","Árabe","Appaloosa","Paint Horse","Andaluz","Lusitano","Frisão","Hannoveriano","Holsteiner","Oldenburg","Westfalen","Sela Francesa","Puro Sangue Árabe","Morgan","Tennessee Walker","Mustang","Clydesdale","Shire","Percheron","Haflinger","Islandês","Fjord","Connemara","Welsh Pony","Shetland","Alter Real","Garrano","Sorraia","Mestiço"],
  "Pássaro": ["Periquito Australiano","Calopsita","Agapornis","Canário","Papagaio Cinzento","Papagaio Amazona","Cacatua","Arara","Diamante Mandarim","Diamante de Gould","Manon","Periquito Inglês","Ring Neck","Rosela","Eclectus","Pionus","Louro","Jandaia","Mestiço"],
  "Tartaruga": ["Tartaruga de Orelha Vermelha","Tartaruga de Caixa","Tartaruga Pintada","Tartaruga Musk","Tartaruga Cumberland","Jabuti Piranga","Jabuti Tinga","Tartaruga Leopardo","Tartaruga Grega","Tartaruga Hermann","Tartaruga Russa","Mestiço"],
  "Furão": ["Furão Standard","Furão Angora","Furão Albino","Furão Sable","Furão Panda","Mestiço"],
  "Chinchila": ["Chinchila Standard","Chinchila Branca","Chinchila Velvet","Chinchila Violet","Chinchila Beige","Mestiço"]
};

function carregarRacas() {
  const especie = document.getElementById('especieSelect').value;
  const racaGroup = document.getElementById('racaGroup');
  const racaInput = document.getElementById('racaInput');
  const datalist = document.getElementById('racasList');
  
  datalist.innerHTML = '';
  
  if (especie && racasPorEspecie[especie]) {
    racaGroup.style.display = 'block';
    racaInput.required = true;
    
    racasPorEspecie[especie].forEach(raca => {
      const option = document.createElement('option');
      option.value = raca;
      datalist.appendChild(option);
    });
  } else {
    racaGroup.style.display = 'none';
    racaInput.required = false;
  }
}

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

</body>
</html>
