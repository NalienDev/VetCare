<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="vetcare.*, java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospitais e Clínicas Veterinárias - VetCare</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .clinicas-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 8rem 2rem 4rem;
            color: white;
            text-align: center;
        }

        .clinicas-header h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
        }

        .search-section {
            background: white;
            padding: 3rem 2rem;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            position: relative;
            margin-top: -3rem;
            border-radius: 16px;
            max-width: 1200px;
            margin-left: auto;
            margin-right: auto;
        }

        .search-box {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .search-input {
            flex: 1;
            padding: 1rem;
            border: 2px solid #DFE4EA;
            border-radius: 12px;
            font-size: 1rem;
        }

        .search-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem 2rem;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .search-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }

        .search-actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
        }

        .btn-location {
            background: #E8F5E9;
            color: #27AE60;
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.3s ease;
        }

        .btn-location:hover {
            background: #C8E6C9;
            transform: translateY(-2px);
        }

        .btn-map {
            background: #2F3542;
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.3s ease;
        }

        .btn-map:hover {
            background: #1e252f;
            transform: translateY(-2px);
        }

        .filters {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
            flex-wrap: wrap;
        }

        .filter-select {
            padding: 0.75rem 1rem;
            border: 2px solid #DFE4EA;
            border-radius: 12px;
            background: white;
            cursor: pointer;
            font-size: 0.95rem;
        }

        .clinicas-container {
            max-width: 1400px;
            margin: 3rem auto;
            padding: 0 2rem;
        }

        .region-section {
            margin-bottom: 4rem;
        }

        .region-title {
            font-size: 2rem;
            color: #2F3542;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 3px solid #667eea;
        }

        .clinica-card {
            background: white;
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            border: 2px solid transparent;
            cursor: pointer;
        }

        .clinica-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
            border-color: #667eea;
        }

        .clinica-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 1.5rem;
        }

        .clinica-name {
            font-size: 1.5rem;
            color: #2F3542;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .clinica-name-link {
            color: #2F3542;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .clinica-name-link:hover {
            color: #667eea;
        }

        .clinica-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .info-item {
            display: flex;
            align-items: start;
            gap: 0.75rem;
        }

        .info-icon {
            width: 24px;
            height: 24px;
            color: #667eea;
            flex-shrink: 0;
        }

        .info-content {
            flex: 1;
        }

        .info-label {
            font-size: 0.85rem;
            color: #57606F;
            margin-bottom: 0.25rem;
        }

        .info-text {
            color: #2F3542;
            font-weight: 500;
        }

        .clinica-hours {
            display: flex;
            gap: 1rem;
            align-items: center;
        }

        .hours-badge {
            background: #E8F5E9;
            color: #27AE60;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .emergency-badge {
            background: #FFEBEE;
            color: #EB5757;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .clinica-contact {
            display: flex;
            gap: 1rem;
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid #DFE4EA;
        }

        .contact-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .contact-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }

        .view-map-btn {
            background: white;
            color: #2F3542;
            padding: 0.75rem 1.5rem;
            border: 2px solid #DFE4EA;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .view-map-btn:hover {
            border-color: #667eea;
            color: #667eea;
        }

        .no-results {
            text-align: center;
            padding: 4rem 2rem;
            color: #57606F;
        }

        .no-results h3 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }

        @media (max-width: 768px) {
            .clinicas-header h1 {
                font-size: 2rem;
            }

            .search-box {
                flex-direction: column;
            }

            .clinica-info {
                grid-template-columns: 1fr;
            }

            .clinica-contact {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <!-- Header com logo e navegação -->
    <header class="main-header">
        <div class="header-content">
            <div class="logo">
                <img src="images/logo.png" alt="VetCare Logo" class="logo-img">
                <span class="logo-text">VetCare</span>
            </div>
            <nav class="main-nav">
                <a href="index.jsp">Início</a>
                <a href="clinicas.jsp">Clínicas</a>
                <a href="#sobre">Sobre Nós</a>
                <a href="#contacto">Contacto</a>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <div class="clinicas-header">
        <h1>Hospitais e Clínicas Veterinárias</h1>
    </div>

    <!-- Search Section -->
    <div class="search-section">
        <form method="GET" action="clinicas.jsp">
            <div class="search-box">
                <input type="text" 
                       name="pesquisa" 
                       class="search-input" 
                       placeholder="Pesquisar clínica..."
                       value="<%= request.getParameter("pesquisa") != null ? request.getParameter("pesquisa") : "" %>">
                <button type="submit" class="search-btn">🔍 Pesquisar</button>
            </div>
        </form>

        <div class="search-actions">
            <a href="#" class="btn-location" onclick="getLocation()">
                📍 Clínicas mais próximas
            </a>
            <a href="#mapa" class="btn-map">
                🗺️ Exibir mapa
            </a>
        </div>

        <p style="text-align: center; color: #57606F; margin-top: 1.5rem;">
            <strong>Dica!</strong> Você pode pesquisar pelo nome da clínica, cidade ou usar a sua localização para encontrar clínicas perto de você. 
            <a href="#" style="color: #667eea;">Como habilitar.</a>
        </p>
    </div>

    <!-- Clínicas Container -->
    <div class="clinicas-container">
        <%
        String pesquisa = request.getParameter("pesquisa");
        
        Configura cfg = new Configura();
        Manipula manipula = new Manipula(cfg);
        
        try {
            String sql = "SELECT c.localidade, c.arteria, c.numero, c.andar, c.codPostal, " +
                        "c.morada, c.latitude, c.longitude, " +
                        "GROUP_CONCAT(DISTINCT CONCAT(h.diaUtil, ': ', h.horaInicio, '-', h.horaFim) SEPARATOR '|') as horarios " +
                        "FROM clinica c " +
                        "LEFT JOIN horario h ON c.localidade = h.localidade ";
            
            if (pesquisa != null && !pesquisa.trim().isEmpty()) {
                sql += "WHERE c.localidade LIKE ? OR c.arteria LIKE ? ";
            }
            
            sql += "GROUP BY c.localidade " +
                   "ORDER BY c.localidade";
            
            Connection con = manipula.getLigacao();
            PreparedStatement ps = con.prepareStatement(sql);
            
            if (pesquisa != null && !pesquisa.trim().isEmpty()) {
                String searchTerm = "%" + pesquisa + "%";
                ps.setString(1, searchTerm);
                ps.setString(2, searchTerm);
            }
            
            ResultSet rs = ps.executeQuery();
            
            boolean hasResults = false;
            String currentRegion = "";
            
            while (rs.next()) {
                hasResults = true;
                String localidade = rs.getString("localidade");
                
                // Nova seção de região
                if (!localidade.equals(currentRegion)) {
                    if (!currentRegion.isEmpty()) {
                        out.println("</div>"); // Fecha região anterior
                    }
                    currentRegion = localidade;
                    out.println("<div class='region-section'>");
                    out.println("<h2 class='region-title'>" + localidade + "</h2>");
                }
                
                String morada = rs.getString("morada");
                String codPostal = rs.getString("codPostal");
                float latitude = rs.getFloat("latitude");
                float longitude = rs.getFloat("longitude");
                String horarios = rs.getString("horarios");
        %>
                <div class="clinica-card">
                    <div class="clinica-header">
                        <div>
                            <h3 class="clinica-name">
                                <a href="#" class="clinica-name-link">
                                    Clínica Veterinária <%= localidade %> →
                                </a>
                            </h3>
                        </div>
                    </div>

                    <div class="clinica-info">
                        <div class="info-item">
                            <span class="info-icon">📍</span>
                            <div class="info-content">
                                <div class="info-label">Morada</div>
                                <div class="info-text"><%= morada %>, <%= codPostal %></div>
                            </div>
                        </div>

                        <div class="info-item">
                            <span class="info-icon">🕐</span>
                            <div class="info-content">
                                <div class="info-label">Horário</div>
                                <div class="clinica-hours">
                                    <% if (horarios != null && !horarios.isEmpty()) {
                                        String[] horariosArray = horarios.split("\\|");
                                        if (horariosArray.length > 0) {
                                            out.println("<span class='hours-badge'>⏰ " + horariosArray[0] + "</span>");
                                        }
                                    } else { %>
                                        <span class="hours-badge">⏰ Consultar horário</span>
                                    <% } %>
                                </div>
                            </div>
                        </div>

                        <div class="info-item">
                            <span class="info-icon">🌍</span>
                            <div class="info-content">
                                <div class="info-label">Coordenadas GPS</div>
                                <div class="info-text"><%= String.format("%.4f, %.4f", latitude, longitude) %></div>
                            </div>
                        </div>
                    </div>

                    <div class="clinica-contact">
                        <a href="tel:210000000" class="contact-btn">
                            📞 Contactar
                        </a>
                        <a href="https://www.google.com/maps?q=<%= latitude %>,<%= longitude %>" 
                           target="_blank" 
                           class="view-map-btn">
                            🗺️ Ver no mapa
                        </a>
                    </div>
                </div>
        <%
            }
            
            if (!currentRegion.isEmpty()) {
                out.println("</div>"); // Fecha última região
            }
            
            if (!hasResults) {
        %>
                <div class="no-results">
                    <h3>😔 Nenhuma clínica encontrada</h3>
                    <p>Tente ajustar os seus critérios de pesquisa ou navegue por todas as clínicas disponíveis.</p>
                </div>
        <%
            }
            
            rs.close();
            ps.close();
            
        } catch (Exception e) {
            out.println("<div class='mensagem erro'>❌ Erro ao carregar clínicas: " + e.getMessage() + "</div>");
            e.printStackTrace();
        } finally {
            manipula.desligar();
        }
        %>
    </div>

    <!-- Footer -->
    <footer class="main-footer">
        <div class="container">
            <div class="footer-content">
                <div class="footer-col">
                    <h4>VetCare</h4>
                    <p>Sistema de Gestão de Clínicas Veterinárias</p>
                    <p class="footer-small">ISEL - Sistemas de Bases de Dados - 2025/2026</p>
                </div>
                <div class="footer-col">
                    <h4>Contactos</h4>
                    <p>Email: info@vetcare.pt</p>
                    <p>Telefone: +351 210 000 000</p>
                </div>
                <div class="footer-col">
                    <h4>Desenvolvido por</h4>
                    <p>Sofia Salgado (51694)</p>
                    <p>Lucas Filipe (51793)</p>
                    <p>Daniel Coelho (51812)</p>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2025 VetCare - Todos os direitos reservados</p>
            </div>
        </div>
    </footer>

    <script>
        function getLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    function(position) {
                        alert("Funcionalidade de localização em desenvolvimento!\n" +
                              "Sua posição: " + position.coords.latitude + ", " + position.coords.longitude);
                    },
                    function(error) {
                        alert("Não foi possível obter a sua localização.\nPor favor, permita o acesso à localização nas configurações do navegador.");
                    }
                );
            } else {
                alert("Geolocalização não é suportada pelo seu navegador.");
            }
        }
    </script>
</body>
</html>