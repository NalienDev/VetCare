<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Árvore Genealógica</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .arvore {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }
        
        .nivel {
            display: flex;
            justify-content: center;
            gap: 40px;
            margin-bottom: 30px;
        }
        
        .animal-box {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            text-align: center;
            min-width: 150px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }
        
        .animal-box.pai {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        
        .animal-box.mae {
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
        }
        
        .animal-nome {
            font-weight: bold;
            font-size: 1.1em;
            margin-bottom: 5px;
        }
        
        .animal-info {
            font-size: 0.9em;
            opacity: 0.9;
        }
        
        .conexao {
            width: 2px;
            height: 30px;
            background: #667eea;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🌳 Árvore Genealógica</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <div class="content">
            <div class="formulario">
                <form method="GET">
                    <div class="form-group">
                        <label>ID do Animal</label>
                        <input type="number" name="id" required 
                               value="<%= request.getParameter("id") != null ? request.getParameter("id") : "" %>">
                    </div>
                    <button type="submit" class="btn btn-primary">🔍 Ver Genealogia</button>
                </form>
            </div>
            
            <%
            String idParam = request.getParameter("id");
            if (idParam != null && !idParam.isEmpty()) {
                int idFicha = Integer.parseInt(idParam);
                Configura cfg = new Configura();
                Manipula manipula = new Manipula(cfg);
                
                try {
                    // Buscar dados do animal
                    String sql = "SELECT nome, filiacao FROM fichaClinicaAnimal WHERE idFichaClin = ?";
                    Connection con = manipula.getLigacao();
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setInt(1, idFicha);
                    ResultSet rs = ps.executeQuery();
                    
                    if (rs.next()) {
                        String nome = rs.getString("nome");
                        String filiacao = rs.getString("filiacao");
                        %>
                        
                        <div class="arvore">
                            <!-- Avós (se houver informação) -->
                            <% if (filiacao != null && !filiacao.isEmpty() && filiacao.contains("descendente")) { %>
                                <div class="nivel">
                                    <div class="animal-box">
                                        <div class="animal-nome">Avô Paterno</div>
                                        <div class="animal-info">Informação não disponível</div>
                                    </div>
                                    <div class="animal-box">
                                        <div class="animal-nome">Avó Paterna</div>
                                        <div class="animal-info">Informação não disponível</div>
                                    </div>
                                    <div class="animal-box">
                                        <div class="animal-nome">Avô Materno</div>
                                        <div class="animal-info">Informação não disponível</div>
                                    </div>
                                    <div class="animal-box">
                                        <div class="animal-nome">Avó Materna</div>
                                        <div class="animal-info">Informação não disponível</div>
                                    </div>
                                </div>
                                <div class="conexao"></div>
                            <% } %>
                            
                            <!-- Pais -->
                            <div class="nivel">
                                <div class="animal-box pai">
                                    <div class="animal-nome">👨 Pai</div>
                                    <div class="animal-info">
                                        <%= filiacao != null && filiacao.contains("pai") ? filiacao : "Desconhecido" %>
                                    </div>
                                </div>
                                <div class="animal-box mae">
                                    <div class="animal-nome">👩 Mãe</div>
                                    <div class="animal-info">
                                        <%= filiacao != null && filiacao.contains("mãe") ? filiacao : "Desconhecida" %>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="conexao"></div>
                            
                            <!-- Animal atual -->
                            <div class="nivel">
                                <div class="animal-box" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                                    <div class="animal-nome">🐾 <%= nome %></div>
                                    <div class="animal-info">ID: <%= idFicha %></div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="info-card" style="margin-top: 30px;">
                            <h3>ℹ️ Informação sobre Filiação</h3>
                            <p><strong>Filiação registada:</strong> <%= filiacao != null ? filiacao : "Não especificada" %></p>
                            <p style="color: #666; margin-top: 10px;">
                                <em>Nota: Para uma árvore genealógica completa, é necessário registar 
                                a filiação detalhada de cada animal no sistema.</em>
                            </p>
                        </div>
                        
                        <%
                    } else {
                        %>
                        <div class="mensagem erro">Animal não encontrado</div>
                        <%
                    }
                    
                    rs.close();
                    ps.close();
                    
                } catch (Exception e) {
                    %>
                    <div class="mensagem erro">❌ Erro: <%= e.getMessage() %></div>
                    <%
                    e.printStackTrace();
                } finally {
                    manipula.desligar();
                }
            }
            %>
        </div>
    </div>
</body>
</html>
