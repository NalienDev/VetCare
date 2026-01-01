<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, org.json.*, java.io.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Importar Dados</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📥 Importar Dados</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <%
        String mensagem = "";
        String tipoMensagem = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String dadosJSON = request.getParameter("dadosJSON");
            
            if (dadosJSON != null && !dadosJSON.isEmpty()) {
                Configura cfg = new Configura();
                Manipula manipula = new Manipula(cfg);
                
                try {
                    JSONObject json = new JSONObject(dadosJSON);
                    
                    String nome = json.getString("nome");
                    String sexo = json.getString("sexo");
                    String dataNasc = json.getString("dataNasc");
                    String estadoReprod = json.getString("estadoReprod");
                    String raca = json.getString("raca");
                    
                    Connection con = manipula.getLigacao();
                    con.setAutoCommit(false);
                    
                    // Inserir ficha
                    String sqlFicha = "INSERT INTO fichaClinicaAnimal (nome, sexo, dataNasc, estadoReprod) VALUES (?,?,?,?)";
                    if (manipula.xDirectiva(sqlFicha, Arrays.asList(
                        nome, sexo, java.sql.Date.valueOf(dataNasc), estadoReprod
                    ))) {
                        ResultSet rs = manipula.getResultado("SELECT LAST_INSERT_ID() AS id");
                        if (rs.next()) {
                            int idFicha = rs.getInt("id");
                            
                            // Associar raça
                            String sqlRaca = "INSERT INTO fichaRaca (idFichaClin, nomeRaca) VALUES (?,?)";
                            manipula.xDirectiva(sqlRaca, Arrays.asList(idFicha, raca));
                            
                            con.commit();
                            mensagem = "✅ Dados importados com sucesso! ID da nova ficha: " + idFicha;
                            tipoMensagem = "sucesso";
                        }
                    }
                    
                } catch (Exception e) {
                    mensagem = "❌ Erro ao importar: " + e.getMessage();
                    tipoMensagem = "erro";
                    e.printStackTrace();
                } finally {
                    manipula.desligar();
                }
            }
        }
        %>
        
        <div class="content">
            <% if (!mensagem.isEmpty()) { %>
                <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
            <% } %>
            
            <div class="info-card">
                <h3>📋 Importar Ficha Clínica</h3>
                <p>Cole o conteúdo JSON exportado para importar uma ficha clínica.</p>
            </div>
            
            <form method="POST" class="formulario">
                <div class="form-group">
                    <label>Dados JSON *</label>
                    <textarea name="dadosJSON" rows="15" required 
                              placeholder='{"idFichaClin": 1, "nome": "Rex", "sexo": "M", ...}'></textarea>
                </div>
                
                <button type="submit" class="btn btn-primary">📥 Importar</button>
            </form>
            
            <div class="info-card" style="margin-top: 30px; background: #fff3cd;">
                <h4>💡 Exemplo de JSON</h4>
                <pre style="background: white; padding: 15px; border-radius: 5px; overflow-x: auto;">
{
  "idFichaClin": 999,
  "nome": "Rex",
  "sexo": "M",
  "dataNasc": "2020-01-15",
  "raca": "Labrador",
  "estadoReprod": "Inteiro"
}</pre>
            </div>
        </div>
    </div>
</body>
</html>
