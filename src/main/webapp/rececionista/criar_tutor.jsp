<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*, java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Criar/Atualizar Tutor</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📝 Criar/Atualizar Tutor</h1>
            <a href="menu.jsp" class="btn-voltar">← Voltar</a>
        </header>
        
        <%
        String mensagem = "";
        String tipoMensagem = "";
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String nif = request.getParameter("nif");
            String nomeCompleto = request.getParameter("nomeCompleto");
            String contactos = request.getParameter("contactos");
            String arteria = request.getParameter("arteria");
            String numero = request.getParameter("numero");
            String andar = request.getParameter("andar");
            String distrito = request.getParameter("distrito");
            String concelho = request.getParameter("concelho");
            String freguesia = request.getParameter("freguesia");
            String prefLinguisticas = request.getParameter("prefLinguisticas");
            String tipoCliente = request.getParameter("tipoCliente");
            String capitalSocial = request.getParameter("capitalSocial");
            
            Configura cfg = new Configura();
            Manipula manipula = new Manipula(cfg);
            
            try {
                Connection con = manipula.getLigacao();
                con.setAutoCommit(false);
                
                // Verificar se já existe
                String sqlVerifica = "SELECT NIF FROM cliente WHERE NIF = ?";
                List<Object> params = Arrays.asList(nif);
                boolean existe = false;
                
                PreparedStatement ps = con.prepareStatement(sqlVerifica);
                ps.setString(1, nif);
                ResultSet rs = ps.executeQuery();
                existe = rs.next();
                rs.close();
                ps.close();
                
                String sqlCliente;
                if (existe) {
                    sqlCliente = "UPDATE cliente SET nomeCompleto=?, contactos=?, arteria=?, numero=?, andar=?, distrito=?, concelho=?, freguesia=?, prefLinguisticas=? WHERE NIF=?";
                    params = Arrays.asList(nomeCompleto, contactos, arteria, Integer.parseInt(numero), 
                                         andar.isEmpty() ? null : andar, distrito, concelho, freguesia, 
                                         prefLinguisticas.isEmpty() ? null : prefLinguisticas, nif);
                } else {
                    sqlCliente = "INSERT INTO cliente (NIF, nomeCompleto, contactos, arteria, numero, andar, distrito, concelho, freguesia, prefLinguisticas) VALUES (?,?,?,?,?,?,?,?,?,?)";
                    params = Arrays.asList(nif, nomeCompleto, contactos, arteria, Integer.parseInt(numero), 
                                         andar.isEmpty() ? null : andar, distrito, concelho, freguesia, 
                                         prefLinguisticas.isEmpty() ? null : prefLinguisticas);
                }
                
                if (manipula.xDirectiva(sqlCliente, params)) {
                    // Inserir pessoa ou empresa
                    if ("pessoa".equals(tipoCliente)) {
                        String sqlPessoa = existe ? "UPDATE pessoa SET NIF=? WHERE NIF=?" : "INSERT INTO pessoa (NIF) VALUES (?)";
                        manipula.xDirectiva(sqlPessoa, Arrays.asList(nif, nif));
                    } else if ("empresa".equals(tipoCliente)) {
                        String sqlEmpresa;
                        if (existe) {
                            sqlEmpresa = "UPDATE empresa SET capitalSocial=? WHERE NIF=?";
                            manipula.xDirectiva(sqlEmpresa, Arrays.asList(new BigDecimal(capitalSocial), nif));
                        } else {
                            sqlEmpresa = "INSERT INTO empresa (NIF, capitalSocial) VALUES (?,?)";
                            manipula.xDirectiva(sqlEmpresa, Arrays.asList(nif, new BigDecimal(capitalSocial)));
                        }
                    }
                    
                    con.commit();
                    mensagem = existe ? "✅ Tutor atualizado com sucesso!" : "✅ Tutor criado com sucesso!";
                    tipoMensagem = "sucesso";
                } else {
                    con.rollback();
                    mensagem = "❌ Erro ao guardar dados";
                    tipoMensagem = "erro";
                }
                
            } catch (Exception e) {
                mensagem = "❌ Erro: " + e.getMessage();
                tipoMensagem = "erro";
            } finally {
                manipula.desligar();
            }
        }
        %>
        
        <div class="content">
            <% if (!mensagem.isEmpty()) { %>
                <div class="mensagem <%= tipoMensagem %>"><%= mensagem %></div>
            <% } %>
            
            <form method="POST" class="formulario">
                <div class="form-group">
                    <label>NIF *</label>
                    <input type="text" name="nif" pattern="[0-9]{9}" maxlength="9" required 
                           placeholder="Número de Identificação Fiscal">
                </div>
                
                <div class="form-group">
                    <label>Nome Completo *</label>
                    <input type="text" name="nomeCompleto" maxlength="150" required>
                </div>
                
                <div class="form-group">
                    <label>Contactos *</label>
                    <input type="text" name="contactos" maxlength="100" required 
                           placeholder="Telefone/Email">
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Arteria (Rua/Av) *</label>
                        <input type="text" name="arteria" maxlength="255" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Número *</label>
                        <input type="number" name="numero" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Andar</label>
                        <input type="text" name="andar" maxlength="10">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Distrito</label>
                        <input type="text" name="distrito" maxlength="50">
                    </div>
                    
                    <div class="form-group">
                        <label>Concelho</label>
                        <input type="text" name="concelho" maxlength="50">
                    </div>
                    
                    <div class="form-group">
                        <label>Freguesia</label>
                        <input type="text" name="freguesia" maxlength="50">
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Preferências Linguísticas</label>
                    <input type="text" name="prefLinguisticas" maxlength="50" placeholder="Ex: PT">
                </div>
                
                <div class="form-group">
                    <label>Tipo de Cliente *</label>
                    <select name="tipoCliente" id="tipoCliente" required onchange="mostrarCampoEmpresa()">
                        <option value="">Selecione...</option>
                        <option value="pessoa">Pessoa</option>
                        <option value="empresa">Empresa</option>
                    </select>
                </div>
                
                <div class="form-group" id="campoCapitalSocial" style="display: none;">
                    <label>Capital Social (€) *</label>
                    <input type="number" name="capitalSocial" step="0.01" min="0">
                </div>
                
                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">💾 Guardar</button>
                    <button type="reset" class="btn btn-secondary">🔄 Limpar</button>
                </div>
            </form>
        </div>
    </div>
    
    <script>
        function mostrarCampoEmpresa() {
            const tipo = document.getElementById('tipoCliente').value;
            const campoCapital = document.getElementById('campoCapitalSocial');
            const inputCapital = document.querySelector('input[name="capitalSocial"]');
            
            if (tipo === 'empresa') {
                campoCapital.style.display = 'block';
                inputCapital.required = true;
            } else {
                campoCapital.style.display = 'none';
                inputCapital.required = false;
            }
        }
    </script>
</body>
</html>
