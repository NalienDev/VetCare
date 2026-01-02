<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Animais com Excesso de Peso</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>⚖️ Animais com Excesso de Peso</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <h3>📋 Animais que excedem o peso adulto da raça</h3>
            
            <table class="tabela">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nome</th>
                        <th>Raça</th>
                        <th>Peso Atual (kg)</th>
                        <th>Peso Ideal (kg)</th>
                        <th>Excesso (%)</th>
                        <th>Tutor</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Configura cfg = new Configura();
                    Manipula manipula = new Manipula(cfg);
                    
                    try {
                        // Query sem tabela pertence e sem caracteristicasfis
                        // Usando exameFis para obter o peso mais recente
                        String sql = 
                            "SELECT f.idFichaClin, f.nome, r.nomeRaca, r.pesoAdlt, " +
                            "       ef.peso AS pesoAtual, " +
                            "       c.nomeCompleto AS tutor, " +
                            "       ROUND(((ef.peso - r.pesoAdlt) / r.pesoAdlt) * 100, 2) AS excesso " +
                            "FROM fichaClinicaAnimal f " +
                            "LEFT JOIN fichaRaca fr ON f.idFichaClin = fr.idFichaClin " +
                            "LEFT JOIN raca r ON fr.nomeRaca = r.nomeRaca " +
                            "LEFT JOIN tutor t ON f.idFichaClin = t.idFichaClin " +
                            "LEFT JOIN cliente c ON t.NIF = c.NIF " +
                            "LEFT JOIN historicoClinico h ON f.idFichaClin = h.idFichaClin " +
                            "LEFT JOIN ( " +
                            "    SELECT idHistorico, peso, dataHora " +
                            "    FROM exameFis ef1 " +
                            "    WHERE dataHora = ( " +
                            "        SELECT MAX(dataHora) " +
                            "        FROM exameFis ef2 " +
                            "        WHERE ef2.idHistorico = ef1.idHistorico " +
                            "    ) " +
                            ") ef ON h.idHistorico = ef.idHistorico " +
                            "WHERE r.pesoAdlt IS NOT NULL " +
                            "  AND ef.peso IS NOT NULL " +
                            "  AND ef.peso > r.pesoAdlt " +
                            "ORDER BY excesso DESC";
                        
                        Connection con = manipula.getLigacao();
                        PreparedStatement ps = con.prepareStatement(sql);
                        ResultSet rs = ps.executeQuery();
                        
                        boolean temDados = false;
                        
                        while (rs.next()) {
                            temDados = true;
                            %>
                            <tr>
                                <td><%= rs.getInt("idFichaClin") %></td>
                                <td><%= rs.getString("nome") %></td>
                                <td><%= rs.getString("nomeRaca") %></td>
                                <td><%= String.format("%.2f", rs.getDouble("pesoAtual")) %></td>
                                <td><%= String.format("%.2f", rs.getDouble("pesoAdlt")) %></td>
                                <td style="color: red; font-weight: bold;">
                                    +<%= String.format("%.1f", rs.getDouble("excesso")) %>%
                                </td>
                                <td><%= rs.getString("tutor") %></td>
                            </tr>
                            <%
                        }
                        
                        if (!temDados) {
                            %>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 2rem;">
                                    📭 Nenhum animal com excesso de peso encontrado ou sem dados de peso registados
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
        </div>
    </div>
</body>
</html>
