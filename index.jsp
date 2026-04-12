<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Proyectos de Grado | Inicio</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --bg-dark: #212529;
            --accent-color: #343a40; /* Gris oscuro profesional */
            --text-main: #dee2e6;
        }

        body {
            background-color: #1a1d20; /* Fondo oscuro profundo */
            color: var(--text-main);
            height: 100vh;
            display: flex;
            align-items: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .login-container {
            max-width: 450px;
            margin: auto;
            padding: 3rem 2rem;
            border-radius: 8px;
            background-color: #2b3035; /* Gris ligeramente más claro que el fondo */
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            border: 1px solid #3d4246;
        }

        .system-logo {
            font-size: 1.5rem;
            font-weight: 300;
            letter-spacing: 2px;
            border-bottom: 1px solid #495057;
            padding-bottom: 1rem;
        }

        /* Unificando el color de todos los botones */
        .btn-role {
            background-color: #495057;
            border: 1px solid #6c757d;
            color: #ffffff;
            padding: 0.8rem;
            font-weight: 500;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-size: 0.9rem;
        }

        .btn-role:hover {
            background-color: #343a40;
            border-color: #adb5bd;
            color: #ffffff;
            transform: translateY(-2px);
        }

        .footer-text {
            font-size: 0.75rem;
            color: #6c757d;
            margin-top: 2rem;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="login-container text-center">
        <header class="mb-4">
            <h1 class="system-logo text-uppercase">Plataforma de Proyectos</h1>
            <p class="small text-white-50 mt-3">Identifíquese para acceder al panel correspondiente</p>
        </header>
        
        <nav class="d-grid gap-3">
            <a href="admin_login.jsp" class="btn btn-role">Administrador</a>
            <a href="coordinador.jsp" class="btn btn-role">Coordinador</a>
            <a href="director.jsp" class="btn btn-role">Director</a>
            <a href="evaluador.jsp" class="btn btn-role">Evaluador</a>
            <a href="estudiante.jsp" class="btn btn-role">Estudiante</a>
        </nav>
        
        <footer class="footer-text">
            Módulo de Gestión Académica v1.0 <br>
            Tecnología: JSP & JSTL
        </footer>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>