<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.time.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Animais Idosos - Acima da Expectativa</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .animal-card {
            background: linear-gradient(135deg, #fff9e6 0%, #ffeaa7 100%);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            border-left: 5px solid #fdcb6e;
            display: flex;
            gap: 20px;
            align-items: center;
        }
        
        .animal-ranking {
            font-size: 2em;
            font-weight: bold;
            color: #fdcb6e;
            min-width: 60px;
            text-align: center;
        }
        
        .animal-foto {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #fdcb6e;
        }
        
        .animal-info {
            flex: 1;
        }
        
        .animal-nome {
            font-size: 1.3em;
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }
        
        .animal-detalhes {
            color: #666;
            line-height: 1.6;
        }
        
        .badge-idade {
            background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
            text-align: center;
            min-width: 150px;
        }
        
        .expectativa-info {
            display: flex;
            gap: 10px;
            margin-top: 10px;
            font-size: 0.9em;
        }
        
        .expectativa-item {
            background: white;
            padding: 8px 12px;
            border-radius: 5px;
            border-left: 3px solid #fdcb6e;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>👴 Animais Idosos - Acima da Expectativa de Vida</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <div class="info-card">
                <h3>📊 Sobre este Relatório</h3>
                <p>Esta lista apresenta os animais que já ultrapassaram a expectativa média de vida da sua raça, ordenados por idade (do mais velho para o mais novo).</p>
            </div>
            
            <%
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                Connection con = manipula.getLigacao();
                
                // SQL para encontrar animais acima da expectativa
                String sql = 
                    "SELECT " +
                    "    f.idFichaClin, " +
                    "    f.nome AS nomeAnimal, " +
                    "    f.sexo, " +
                    "    f.dataNasc, " +
                    "    TIMESTAMPDIFF(YEAR, f.dataNasc, CURDATE()) AS idadeAnos, " +
                    "    TIMESTAMPDIFF(MONTH, f.dataNasc, CURDATE()) % 12 AS idadeMeses, " +
                    "    r.nomeRaca, " +
                    "    r.expectativaVida, " +
                    "    e.nomeComum AS especie, " +
                    "    c.nomeCompleto AS tutor, " +
                    "    c.contactos, " +
                    "    (TIMESTAMPDIFF(YEAR, f.dataNasc, CURDATE()) - r.expectativaVida) AS anosAlem " +
                    "FROM fichaClinicaAnimal f " +
                    "INNER JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
                    "INNER JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
                    "INNER JOIN pertence p ON r.nomeRaca = p.nomeRaca " +
                    "INNER JOIN especie e ON p.nomeComum = e.nomeComum " +
                    "INNER JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
                    "INNER JOIN cliente c ON t.NIF = c.NIF " +
                    "WHERE TIMESTAMPDIFF(YEAR, f.dataNasc, CURDATE()) > r.expectativaVida " +
                    "ORDER BY idadeAnos DESC, idadeMeses DESC, f.nome ASC";
                
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery();
                
                int contador = 0;
                boolean temDados = false;
                
                while (rs.next()) {
                    temDados = true;
                    contador++;
                    
                    int idFicha = rs.getInt("idFichaClin");
                    String nomeAnimal = rs.getString("nomeAnimal");
                    String sexo = rs.getString("sexo");
                    java.sql.Date dataNasc = rs.getDate("dataNasc");
                    int idadeAnos = rs.getInt("idadeAnos");
                    int idadeMeses = rs.getInt("idadeMeses");
                    String raca = rs.getString("nomeRaca");
                    int expectativa = rs.getInt("expectativaVida");
                    String especie = rs.getString("especie");
                    String tutor = rs.getString("tutor");
                    String contactos = rs.getString("contactos");
                    int anosAlem = rs.getInt("anosAlem");
                    
                    String genero = util.DataFormatter.obterGenero(sexo);
                    
                    // Buscar foto (se existir)
                    String fotoBase64 = null;
                    String sqlFoto = "SELECT fotografia FROM caracteristicasFis WHERE idFicha = ?";
                    PreparedStatement psFoto = con.prepareStatement(sqlFoto);
                    psFoto.setInt(1, idFicha);
                    ResultSet rsFoto = psFoto.executeQuery();
                    if (rsFoto.next()) {
                        java.sql.Blob blob = rsFoto.getBlob("fotografia");
                        if (blob != null) {
                            byte[] bytes = blob.getBytes(1, (int) blob.length());
                            fotoBase64 = Base64.getEncoder().encodeToString(bytes);
                        }
                    }
                    rsFoto.close();
                    psFoto.close();
                    %>
                    
                    <div class="animal-card">
                        <div class="animal-ranking">
                            <%= contador %>º
                        </div>
                        
                        <% if (fotoBase64 != null) { %>
                            <img src="data:image/jpeg;base64,<%= fotoBase64 %>" 
                                 alt="<%= nomeAnimal %>" 
                                 class="animal-foto">
                        <% } else { %>
                            <div class="animal-foto" style="background: #ddd; display: flex; align-items: center; justify-content: center; font-size: 2em;">
                                <%= especie.toLowerCase().contains("cão") ? "🐕" : 
                                    especie.toLowerCase().contains("gato") ? "🐈" : "🐾" %>
                            </div>
                        <% } %>
                        
                        <div class="animal-info">
                            <div class="animal-nome">
                                <%= nomeAnimal %> 
                                <span style="font-size: 0.8em; color: #666;">
                                    (<%= genero %>)
                                </span>
                            </div>
                            
                            <div class="animal-detalhes">
                                <strong>Raça:</strong> <%= raca %> (<%= especie %>)<br>
                                <strong>Tutor:</strong> <%= tutor %> | <%= contactos %><br>
                                <strong>Data Nascimento:</strong> <%= util.DataFormatter.LocalDateToString(dataNasc.toLocalDate()) %>
                            </div>
                            
                            <div class="expectativa-info">
                                <div class="expectativa-item">
                                    <strong>Expectativa de Vida:</strong> <%= expectativa %> anos
                                </div>
                                <div class="expectativa-item">
                                    <strong>Excesso:</strong> +<%= anosAlem %> 
                                    <%= anosAlem == 1 ? "ano" : "anos" %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="badge-idade">
                            🎂 <%= idadeAnos %> 
                            <%= idadeAnos == 1 ? "ano" : "anos" %>
                            <% if (idadeMeses > 0) { %>
                                e <%= idadeMeses %> 
                                <%= idadeMeses == 1 ? "mês" : "meses" %>
                            <% } %>
                        </div>
                    </div>
                    
                    <%
                }
                
                if (!temDados) {
                %>
                    <div class="sem-dados" style="text-align: center; padding: 60px 20px;">
                        <h2 style="color: #28a745;">✅ Nenhum Animal Acima da Expectativa</h2>
                        <p>Todos os animais registados estão dentro ou abaixo da expectativa de vida da sua raça.</p>
                        <p style="margin-top: 20px; color: #666;">Isso é um excelente sinal de saúde! 🎉</p>
                    </div>
                <%
                } else {
                %>
                    <div class="info-card" style="margin-top: 30px; background: #d4edda; border-color: #c3e6cb; color: #155724;">
                        <h3 style="color: #155724;">🎉 Parabéns!</h3>
                        <p>Foram encontrados <strong><%= contador %></strong> 
                           <%= contador == 1 ? "animal" : "animais" %> 
                           que ultrapassaram a expectativa média de vida. 
                           Isso demonstra excelentes cuidados veterinários!</p>
                    </div>
                <%
                }
                
                rs.close();
                ps.close();
                
            } catch (SQLException e) {
                %>
                <div class="mensagem erro">
                    ❌ Erro ao carregar dados: <%= e.getMessage() %>
                </div>
                <%
                e.printStackTrace();
            } finally {
                manipula.desligar();
            }
            %>
            
            <div class="form-actions" style="margin-top: 30px; justify-content: center;">
                <button onclick="window.print()" class="btn btn-primary">
                    🖨️ Imprimir Lista
                </button>
            </div>
        </div>
    </div>
</body>
</html>
