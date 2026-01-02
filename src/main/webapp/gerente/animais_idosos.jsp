<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Animais Idosos</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>👴 Animais Idosos</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <h3>📋 Animais que atingiram ou ultrapassaram 75% da expectativa de vida</h3>
            
            <table class="tabela">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nome</th>
                        <th>Raça</th>
                        <th>Idade (anos)</th>
                        <th>Expectativa (anos)</th>
                        <th>% Vida</th>
                        <th>Tutor</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Configura cfg = new Configura();
                    Manipula manipula = new Manipula(cfg);
                    
                    try {
                        String sql = 
                            "SELECT f.idFichaClin, f.nome, f.dataNasc, " +
                            "       r.nomeRaca, r.expectativaVida, " +
                            "       c.nomeCompleto AS tutor, " +
                            "       TIMESTAMPDIFF(YEAR, f.dataNasc, CURDATE()) AS idade, " +
                            "       ROUND((TIMESTAMPDIFF(YEAR, f.dataNasc, CURDATE()) / r.expectativaVida) * 100, 1) AS percentVida " +
                            "FROM fichaClinicaAnimal f " +
                            "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
                            "LEFT JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
                            "LEFT JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
                            "LEFT JOIN cliente c ON t.NIF = c.NIF " +
                            "WHERE r.expectativaVida IS NOT NULL " +
                            "HAVING percentVida >= 75 " +
                            "ORDER BY percentVida DESC";
                        
                        Connection con = manipula.getLigacao();
                        PreparedStatement ps = con.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        
                        boolean temDados = false;
                        
                        while (rs.next()) {
                            temDados = true;
                            double percentVida = rs.getDouble("percentVida");
                            String corAlerta = percentVida >= 90 ? "red" : percentVida >= 80 ? "orange" : "#666";
                            %>
                            <tr>
                                <td><%= rs.getInt("idFichaClin") %></td>
                                <td><%= rs.getString("nome") %></td>
                                <td><%= rs.getString("nomeRaca") %></td>
                                <td><%= rs.getInt("idade") %></td>
                                <td><%= rs.getInt("expectativaVida") %></td>
                                <td style="color: <%= corAlerta %>; font-weight: bold;">
                                    <%= String.format("%.1f", percentVida) %>%
                                </td>
                                <td><%= rs.getString("tutor") %></td>
                            </tr>
                            <%
                        }
                        
                        if (!temDados) {
                            %>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 2rem;">
                                    📭 Nenhum animal idoso encontrado
                                </td>
                            </tr>
                            <%
                        }
                        
                        rs.close();
                        ps.close();
                        
                    } catch (Exception e) {
                        %>
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 2rem; color: red;">
                                ❌ Erro ao carregar dados: <%= e.getMessage() %>
                            </td>
                        </tr>
                        <%
                        e.printStackTrace();
                    } finally {
                        manipula.desligar();
                    }
                    %>
                </tbody>
            </table>
            
            <div class="info-card" style="margin-top: 2rem;">
                <h4>ℹ️ Legenda:</h4>
                <ul>
                    <li><span style="color: #666;">75-79%</span> - Idoso (cuidados preventivos)</li>
                    <li><span style="color: orange;">80-89%</span> - Idoso avançado (monitorização)</li>
                    <li><span style="color: red;">90%+</span> - Muito idoso (atenção redobrada)</li>
                </ul>
            </div>
        </div>
    </div>
    
    <style>
        .info-card {
            background: #f8f9fa;
            padding: 1.5rem;
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }
        
        .info-card ul {
            margin: 0.5rem 0 0 1.5rem;
        }
        
        .info-card li {
            margin: 0.5rem 0;
        }
    </style>
</body>
</html>
