<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>InmoHome - Portal de Proyectos de Grado</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        body { 
            background: #0f0f0f; 
            color: white; 
            font-family: 'Inter', sans-serif; 
            min-height: 100vh;
        }
        .hero-section {
            padding: 100px 0;
            background: radial-gradient(circle at top right, #1a1c1e, #000000);
        }
        .role-card {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 30px;
            transition: 0.4s;
            text-align: center;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .role-card:hover {
            transform: translateY(-10px);
            background: rgba(255, 255, 255, 0.05);
            border-color: #ffc107;
        }
        .role-icon {
            font-size: 3rem;
            margin-bottom: 20px;
            color: #ffc107;
        }
        .btn-access {
            background: transparent;
            border: 1px solid #ffc107;
            color: #ffc107;
            font-weight: 600;
            border-radius: 10px;
            margin-top: 15px;
            transition: 0.3s;
        }
        .btn-access:hover {
            background: #ffc107;
            color: #000;
            text-decoration: none;
        }
        /* Contenedor de enlaces inferiores */
        .bottom-links {
            position: fixed;
            bottom: 20px;
            right: 20px;
            display: flex;
            gap: 20px;
            align-items: center;
        }
        .admin-link {
            color: rgba(255,255,255,0.3);
            font-size: 0.8rem;
            text-decoration: none;
            transition: 0.3s;
        }
        .admin-link:hover { color: #fff; text-decoration: none; }
        
        .debug-link {
            color: #ffc107;
            font-size: 0.8rem;
            text-decoration: none;
            font-weight: 600;
            transition: 0.3s;
        }
        .debug-link:hover { opacity: 0.8; text-decoration: none; }
    </style>
</head>
<body>

    <section class="hero-section text-center">
        <div class="container">
            <h1 class="display-4 font-weight-bold mb-3">Portal de Gestión de Grados</h1>
            <p class="lead text-muted mb-5">Seleccione su rol institucional para ingresar al sistema</p>
            
            <div class="row">
                <div class="col-md-3 mb-4">
                    <div class="role-card">
                        <i class="fas fa-user-graduate role-icon"></i>
                        <h4>Estudiantes</h4>
                        <p class="small text-muted">Gestione su proyecto y suba entregables.</p>
                        <a href="login_usuarios.jsp?rol=estudiantes" class="btn btn-access">Ingresar</a>
                    </div>
                </div>

                <div class="col-md-3 mb-4">
                    <div class="role-card">
                        <i class="fas fa-user-tie role-icon"></i>
                        <h4>Coordinadores</h4>
                        <p class="small text-muted">Supervise procesos y asigne evaluadores.</p>
                        <a href="login_usuarios.jsp?rol=coordinadores" class="btn btn-access">Ingresar</a>
                    </div>
                </div>

                <div class="col-md-3 mb-4">
                    <div class="role-card">
                        <i class="fas fa-chalkboard-teacher role-icon"></i>
                        <h4>Evaluadores</h4>
                        <p class="small text-muted">Califique y de feedback a los proyectos.</p>
                        <a href="login_usuarios.jsp?rol=evaluadores" class="btn btn-access">Ingresar</a>
                    </div>
                </div>

                <div class="col-md-3 mb-4">
                    <div class="role-card">
                        <i class="fas fa-user-edit role-icon"></i>
                        <h4>Directores</h4>
                        <p class="small text-muted">Acompañamiento y aval de propuestas.</p>
                        <a href="login_usuarios.jsp?rol=directores" class="btn btn-access">Ingresar</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <div class="bottom-links">
        <a href="./credenciales/ver_credenciales.jsp" class="debug-link">
            <i class="fas fa-key mr-1"></i> Ver Credenciales (Pruebas)
        </a>
        <a href="admin_login.jsp" class="admin-link">
            <i class="fas fa-lock mr-1"></i> Acceso Administrativo
        </a>
    </div>

</body>
</html>