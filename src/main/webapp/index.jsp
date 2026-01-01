<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VetCare - Sistema de Gestão Veterinária</title>
    <link rel="stylesheet" href="css/style.css">
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
                <a href="clinicas.jsp">Clínicas</a>
                <a href="#sobre">Sobre Nós</a>
                <a href="#contacto">Contacto</a>
            </nav>
        </div>
    </header>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-overlay"></div>
        <div class="hero-content">
            <h1 class="hero-title">Porque o seu animal de estimação merece a melhor atenção</h1>
            
            <!-- Menu de busca de clínicas -->
            <div class="clinic-search-box">
                <div class="search-header">
                    <h2>Encontre uma clínica</h2>
                    <a href="clinicas.jsp" class="btn-todas-clinicas">Todas as clínicas</a>
                </div>
                
                <div class="search-input-wrapper">
                    <input type="text" placeholder="Pesquisar clínica..." class="search-clinic-input">
                    <button class="btn-search-clinic">
                        <img src="images/search-icon.png" alt="Pesquisar">
                    </button>
                </div>
                
                <div class="search-info">
                    <p><strong>Dica!</strong> Você pode pesquisar pelo nome da clínica, cidade ou usar sua localização para encontrar clínicas perto de você.</p>
                    <p class="how-enable">Como habilitar:</p>
                </div>
                
                <div class="search-actions">
                    <button class="btn-clinicas-proximas">
                        <img src="images/location-icon.png" alt="Localização">
                        Clínicas mais próximas
                    </button>
                    <button class="btn-urgencias">
                        <img src="images/emergency-icon.png" alt="Urgências">
                        Urgências
                    </button>
                </div>
            </div>
        </div>
        <!-- Adicione sua imagem de animal aqui -->
        <img src="images/hero-cat.jpeg" alt="Gato" class="hero-image">
    </section>

    <!-- Secção de Acesso Rápido -->
    <section class="quick-access">
        <div class="container">
            <h2 class="section-title">Acesso ao Sistema</h2>
            <div class="access-grid">
                <!-- Rececionista -->
                <a href="rececionista/menu.jsp" class="access-card">
                    <div class="card-icon">
                        <img src="images/receptionist-icon.png" alt="Rececionista">
                    </div>
                    <h3>Rececionista</h3>
                    <p>Gestão de tutores, animais e agendamentos</p>
                    <ul class="card-features">
                        <li>Criar e atualizar fichas</li>
                        <li>Agendar serviços</li>
                    </ul>
                </a>

                <!-- Veterinário -->
                <a href="veterinario/menu.jsp" class="access-card">
                    <div class="card-icon">
                        <img src="images/vet-icon.png" alt="Veterinário">
                    </div>
                    <h3>Veterinário</h3>
                    <p>Consulta e atualização de registos clínicos</p>
                    <ul class="card-features">
                        <li>Histórico clínico</li>
                        <li>Lista de chamada</li>
                    </ul>
                </a>

                <!-- Tutor -->
                <a href="tutor/menu.jsp" class="access-card">
                    <div class="card-icon">
                        <img src="images/owner-icon.png" alt="Tutor">
                    </div>
                    <h3>Tutor</h3>
                    <p>Acesso aos dados dos seus animais</p>
                    <ul class="card-features">
                        <li>Consultar fichas</li>
                        <li>Gerir consultas</li>
                    </ul>
                </a>

                <!-- Gerente -->
                <a href="gerente/menu.jsp" class="access-card">
                    <div class="card-icon">
                        <img src="images/manager-icon.png" alt="Gerente">
                    </div>
                    <h3>Gerente</h3>
                    <p>Administração completa do sistema</p>
                    <ul class="card-features">
                        <li>Gestão de recursos</li>
                        <li>Relatórios</li>
                    </ul>
                </a>
            </div>
        </div>
    </section>

    <!-- Secção Sobre -->
    <section id="sobre" class="about-section">
        <div class="container">
            <div class="about-content">
                <div class="about-text">
                    <h2>Cuidados veterinários de excelência</h2>
                    <p>O VetCare é um sistema completo de gestão para clínicas veterinárias, desenvolvido para facilitar o dia-a-dia dos profissionais e melhorar a experiência dos tutores.</p>
                    <p>Com tecnologia moderna e interface intuitiva, garantimos eficiência e qualidade no atendimento aos seus animais de estimação.</p>
                </div>
                <div class="about-image">
                    <img src="images/about-dog.png" alt="Cão">
                </div>
            </div>
        </div>
    </section>

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
</body>
</html>
