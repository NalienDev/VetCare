<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.math.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Tutores - Animais com Excesso de Peso</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .tutor-card {
            background: #fff3cd;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 20px;
            border-left: 5px solid #ffc107;
        }
        
        .tutor-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 2px solid #ffe69c;
        }
        
        .tutor-nome {
            font-size: 1.3em;
            font-weight: 600;
            color: #333;
        }
        
        .badge-animais {
            background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: bold;
        }
        
        .animais-lista {
            margin-top: 15px;
        }
        
        .animal-item {
            background: white;
            padding: 15px;
            margin-bottom: 10px;
            border-radius: 5px;
            border-left: 3px solid #ffc107;
        }
        
        .animal-nome {
            font-weight: 600;
            color: #856404;
            margin-bottom: 5px;
        }
        
        .peso-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 10px;
            margin-top: 10px;
            font-size: 0.9em;
        }
        
        .peso-item {
            background: #fff;
            padding: 8px;
            border-radius: 3px;
        }
        
        .peso-item strong {
            color: #856404;
        }
        
        .excesso-badge {
            display: inline-block;
            background: #dc3545;
            color: white;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 0.85em;
            font-weight: bold;
            margin-left: 10px;
        }
        
        .alerta-obesidade {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 10px;
            border-radius: 5px;
            margin-top: 10px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>⚖️ Tutores com Animais em Excesso de Peso</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <div class="info-card">
                <h3>📊 Critério de Excesso de Peso</h3>
                <p>São considerados com excesso de peso os animais cujo peso atual ultrapassa em <strong>mais de 10%</strong> o peso adulto ideal da raça.</p>
                <p><strong>Fórmula:</strong> Peso Atual > (Peso Ideal da Raça × 1.10)</p>
            </div>
            
            <%
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                Connection con = manipula.getLigacao();
                
                // SQL para encontrar tutores com animais acima do peso
                // Considera 10% acima do peso ideal da raça como excesso
                String sql = 
                    "SELECT " +
                    "    c.NIF, " +
                    "    c.nomeCompleto AS tutorNome, " +
                    "    c.contactos, " +
                    "    COUNT(DISTINCT f.idFichaClin) AS totalAnimaisExcesso " +
                    "FROM cliente c " +
                    "INNER JOIN tutor t ON c.NIF = t.NIF " +
                    "INNER JOIN fichaClinicaAnimal f ON t.idFichaClin = f.idFichaClin " +
                    "INNER JOIN caracteristicasFis cf ON f.idFichaClin = cf.idFicha " +
                    "INNER JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
                    "INNER JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
                    "WHERE cf.peso > (r.pesoAdlt * 1.10) " +  // 10% acima do peso ideal
                    "GROUP BY c.NIF, c.nomeCompleto, c.contactos " +
                    "ORDER BY totalAnimaisExcesso DESC, c.nomeCompleto ASC";
                
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery();
                
                boolean temDados = false;
                int totalTutores = 0;
                
                while (rs.next()) {
                    temDados = true;
                    totalTutores++;
                    
                    String nif = rs.getString("NIF");
                    String tutorNome = rs.getString("tutorNome");
                    String contactos = rs.getString("contactos");
                    int totalAnimaisExcesso = rs.getInt("totalAnimaisExcesso");
                    %>
                    
                    <div class="tutor-card">
                        <div class="tutor-header">
                            <div>
                                <div class="tutor-nome"><%= tutorNome %></div>
                                <div style="color: #666; font-size: 0.9em;">
                                    <strong>NIF:</strong> <%= nif %> | 
                                    <strong>Contacto:</strong> <%= contactos %>
                                </div>
                            </div>
                            <div class="badge-animais">
                                ⚠️ <%= totalAnimaisExcesso %> 
                                <%= totalAnimaisExcesso == 1 ? "animal" : "animais" %>
                            </div>
                        </div>
                        
                        <div class="animais-lista">
                            <strong style="color: #856404;">📋 Animais com Excesso de Peso:</strong>
                            
                            <%
                            // Buscar detalhes dos animais deste tutor
                            String sqlAnimais = 
                                "SELECT " +
                                "    f.idFichaClin, " +
                                "    f.nome AS nomeAnimal, " +
                                "    f.sexo, " +
                                "    r.nomeRaca, " +
                                "    e.nomeComum AS especie, " +
                                "    cf.peso AS pesoAtual, " +
                                "    r.pesoAdlt AS pesoIdeal, " +
                                "    ((cf.peso - r.pesoAdlt) / r.pesoAdlt * 100) AS percentualExcesso " +
                                "FROM fichaClinicaAnimal f " +
                                "INNER JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
                                "INNER JOIN caracteristicasFis cf ON f.idFichaClin = cf.idFicha " +
                                "INNER JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
                                "INNER JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
                                "INNER JOIN pertence p ON r.nomeRaca = p.nomeRaca " +
                                "INNER JOIN especie e ON p.nomeComum = e.nomeComum " +
                                "WHERE t.NIF = ? " +
                                "  AND cf.peso > (r.pesoAdlt * 1.10) " +
                                "ORDER BY percentualExcesso DESC";
                            
                            PreparedStatement psAnimais = con.prepareStatement(sqlAnimais);
                            psAnimais.setString(1, nif);
                            ResultSet rsAnimais = psAnimais.executeQuery();
                            
                            while (rsAnimais.next()) {
                                String nomeAnimal = rsAnimais.getString("nomeAnimal");
                                String sexo = rsAnimais.getString("sexo");
                                String raca = rsAnimais.getString("nomeRaca");
                                String especie = rsAnimais.getString("especie");
                                BigDecimal pesoAtual = rsAnimais.getBigDecimal("pesoAtual");
                                BigDecimal pesoIdeal = rsAnimais.getBigDecimal("pesoIdeal");
                                double percentualExcesso = rsAnimais.getDouble("percentualExcesso");
                                
                                String genero = util.DataFormatter.obterGenero(sexo);
                                
                                // Calcular diferença
                                BigDecimal diferenca = pesoAtual.subtract(pesoIdeal);
                                
                                // Nível de obesidade
                                String nivelObesidade = "";
                                String corAlerta = "#ffc107";
                                
                                if (percentualExcesso > 30) {
                                    nivelObesidade = "🔴 OBESIDADE GRAVE";
                                    corAlerta = "#dc3545";
                                } else if (percentualExcesso > 20) {
                                    nivelObesidade = "🟠 OBESIDADE MODERADA";
                                    corAlerta = "#ff6b6b";
                                } else {
                                    nivelObesidade = "🟡 SOBREPESO";
                                    corAlerta = "#ffc107";
                                }
                                %>
                                
                                <div class="animal-item">
                                    <div class="animal-nome">
                                        🐾 <%= nomeAnimal %> (<%= genero %>)
                                        <span class="excesso-badge" style="background: <%= corAlerta %>;">
                                            +<%= String.format("%.1f", percentualExcesso) %>%
                                        </span>
                                    </div>
                                    
                                    <div style="color: #666; font-size: 0.9em; margin-bottom: 10px;">
                                        <%= raca %> - <%= especie %>
                                    </div>
                                    
                                    <div class="peso-info">
                                        <div class="peso-item">
                                            <strong>Peso Atual:</strong> 
                                            <%= String.format("%.2f", pesoAtual) %> kg
                                        </div>
                                        <div class="peso-item">
                                            <strong>Peso Ideal:</strong> 
                                            <%= String.format("%.2f", pesoIdeal) %> kg
                                        </div>
                                        <div class="peso-item">
                                            <strong>Excesso:</strong> 
                                            +<%= String.format("%.2f", diferenca) %> kg
                                        </div>
                                        <div class="peso-item">
                                            <strong>Nível:</strong> <%= nivelObesidade %>
                                        </div>
                                    </div>
                                    
                                    <% if (percentualExcesso > 20) { %>
                                        <div class="alerta-obesidade">
                                            <strong>⚠️ ATENÇÃO:</strong> 
                                            Este animal apresenta sinais de obesidade. 
                                            Recomenda-se consulta veterinária para avaliação e plano de emagrecimento.
                                        </div>
                                    <% } %>
                                </div>
                                
                                <%
                            }
                            
                            rsAnimais.close();
                            psAnimais.close();
                            %>
                        </div>
                    </div>
                    
                    <%
                }
                
                if (!temDados) {
                %>
                    <div class="sem-dados" style="text-align: center; padding: 60px 20px;">
                        <h2 style="color: #28a745;">✅ Peso Adequado!</h2>
                        <p>Nenhum animal registado apresenta excesso de peso superior a 10% do ideal.</p>
                        <p style="margin-top: 20px; color: #666;">
                            Todos os animais estão dentro ou próximos do peso ideal da raça. Parabéns! 🎉
                        </p>
                    </div>
                <%
                } else {
                %>
                    <div class="info-card" style="margin-top: 30px; background: #fff3cd; border-color: #ffeeba; color: #856404;">
                        <h3 style="color: #856404;">📊 Resumo</h3>
                        <p>
                            Foram encontrados <strong><%= totalTutores %></strong> 
                            <%= totalTutores == 1 ? "tutor" : "tutores" %> 
                            com animais apresentando excesso de peso.
                        </p>
                        <p style="margin-top: 10px;">
                            <strong>Recomendação:</strong> Contactar os tutores para agendar consultas 
                            de avaliação nutricional e estabelecer planos de controle de peso.
                        </p>
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
                    🖨️ Imprimir Relatório
                </button>
            </div>
        </div>
    </div>
</body>
</html>
