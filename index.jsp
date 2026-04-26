<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ProjectHub | Universidad de Santander</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        :root { --accent: #ffc107; --bg-dark: #0a0a0a; --card-bg: #121212; --text-muted: #888; }
        body { background-color: var(--bg-dark); color: #ffffff; font-family: 'Inter', sans-serif; }
        
        /* Hero */
        .hero-section { padding: 100px 0 60px 0; background: radial-gradient(circle at 50% -20%, #222 0%, var(--bg-dark) 70%); }
        .hero-title { font-size: 3.5rem; font-weight: 800; letter-spacing: -2px; }

        /* Tarjetas de Acceso (Roles) */
        .role-card {
            background: var(--card-bg); border: 1px solid #222; border-radius: 20px; padding: 40px 20px;
            transition: all 0.3s ease; text-decoration: none !important; display: block; height: 100%;
        }
        .role-card:hover { border-color: var(--accent); transform: translateY(-10px); background: #1a1a1a; }
        .role-icon { font-size: 2.5rem; color: var(--accent); margin-bottom: 20px; display: block; }
        .role-name { font-size: 1.1rem; font-weight: 600; color: #fff; text-transform: uppercase; letter-spacing: 1px; }

        /* SECCIÓN RECURSOS (Tarjetas de Documentos) */
        .section-title { font-weight: 800; letter-spacing: 1px; margin-bottom: 40px; }
        .resource-card {
            background: rgba(255, 255, 255, 0.02); border: 1px dashed #333; border-radius: 15px;
            padding: 30px; transition: 0.3s; text-decoration: none !important; display: block; height: 100%;
        }
        .resource-card:hover { border-style: solid; border-color: var(--accent); background: rgba(255, 193, 7, 0.03); }
        .resource-card i { font-size: 2rem; color: var(--accent); margin-bottom: 15px; display: block; }
        .resource-card h6 { color: #fff; font-weight: 700; margin-bottom: 10px; }
        .resource-card p { font-size: 0.8rem; color: var(--text-muted); margin-bottom: 0; line-height: 1.4; }

        footer { padding: 60px 0; border-top: 1px solid #111; }
        .btn-admin { color: #333; font-size: 0.7rem; font-weight: 700; letter-spacing: 2px; text-decoration: none; transition: 0.3s; }
        .btn-admin:hover { color: var(--accent); }
    </style>
</head>
<body>

<div class="hero-section text-center">
    <div class="container">
        <h1 class="hero-title mb-3">PROJECT<span class="text-warning">HUB</span></h1>
        <p class="text-muted mx-auto mb-5" style="max-width: 650px;">
            Gestión integral de proyectos de grado. Una herramienta diseñada para centralizar la comunicación entre estudiantes y directores.
        </p>

        <div class="row">
            <%-- ENLACES CORREGIDOS A login_usuarios.jsp --%>
            <div class="col-md-3 mb-4">
                <a href="login_usuarios.jsp?rol=estudiante" class="role-card">
                    <i class="fas fa-user-graduate role-icon"></i>
                    <span class="role-name">Estudiante</span>
                </a>
            </div>
            <div class="col-md-3 mb-4">
                <a href="login_usuarios.jsp?rol=directores" class="role-card">
                    <i class="fas fa-user-tie role-icon"></i>
                    <span class="role-name">Director</span>
                </a>
            </div>
            <div class="col-md-3 mb-4">
                <a href="login_usuarios.jsp?rol=evaluadores" class="role-card">
                    <i class="fas fa-clipboard-check role-icon"></i>
                    <span class="role-name">Evaluador</span>
                </a>
            </div>
            <div class="col-md-3 mb-4">
                <a href="login_usuarios.jsp?rol=coordinadores" class="role-card">
                    <i class="fas fa-user-shield role-icon"></i>
                    <span class="role-name">Coordinador</span>
                </a>
            </div>
        </div>
    </div>
</div>

<section class="py-5" style="background-color: #080808;">
    <div class="container">
        <h4 class="text-center section-title">RECURSOS <span class="text-warning">ACADÉMICOS</span></h4>
        
        <div class="row">
            <div class="col-md-3 mb-4">
                <a href="#" class="resource-card text-center">
                    <i class="fas fa-file-pdf"></i>
                    <h6>Reglamento General</h6>
                    <p>Consulta las normas y requisitos legales para el desarrollo de tu proyecto.</p>
                </a>
            </div>
            <div class="col-md-3 mb-4">
                <a href="#" class="resource-card text-center">
                    <i class="fas fa-file-word"></i>
                    <h6>Plantilla de Entrega</h6>
                    <p>Descarga el formato oficial para la redacción de informes y avances.</p>
                </a>
            </div>
            <div class="col-md-3 mb-4">
                <a href="#" class="resource-card text-center">
                    <i class="fas fa-calendar-alt"></i>
                    <h6>Cronograma 2026</h6>
                    <p>Fechas estipuladas para sustentaciones y cierres de actas académicas.</p>
                </a>
            </div>
            <div class="col-md-3 mb-4">
                <a href="#" class="resource-card text-center">
                    <i class="fas fa-video"></i>
                    <h6>Tutorial de Uso</h6>
                    <p>Video guía sobre cómo navegar y subir documentos correctamente.</p>
                </a>
            </div>
        </div>
    </div>
</section>

<footer class="text-center">
    <div class="container">
        <a href="admin_login.jsp" class="btn-admin">ACCESO PARA ADMINISTRADORES</a>
        <a href="./credenciales/ver_credenciales.jsp" class="btn-admin">
            <i class="fas fa-key mr-1"></i> VER CREDENCIALES (Pruebas)
        </a>
        <p class="text-muted mt-4 small mb-0">&copy; 2026 Universidad de Santander | Facultad de Ingeniería</p>
    </div>
</footer>

</body>
</html>