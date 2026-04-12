<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- SEGURIDAD: Si la sesión no existe, redirigir al login --%>
<c:if test="${empty sessionScope.adminLogueado}">
    <c:redirect url="admin_login.jsp" />
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Administrativo | Proyectos de Grado</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { 
            background-color: #1a1d20; 
            color: #dee2e6; 
            font-family: 'Segoe UI', sans-serif;
        }
        .navbar-custom {
            background-color: #2b3035;
            border-bottom: 1px solid #3d4246;
        }
        .main-card {
            background-color: #2b3035;
            border: 1px solid #3d4246;
            border-radius: 8px;
            padding: 2rem;
        }
        .status-badge {
            background-color: #198754; /* Verde éxito sutil */
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.8rem;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-dark navbar-custom mb-5">
    <div class="container">
        <span class="navbar-brand text-uppercase fw-bold" style="letter-spacing: 1px;">
            Sistema de Proyectos
        </span>
        <div class="d-flex align-items-center">
            <span class="me-3 small text-white-50">Admin: ${sessionScope.adminLogueado.nombre}</span>
            <a href="logout.jsp" class="btn btn-outline-danger btn-sm">Cerrar Sesión</a>
        </div>
    </div>
</nav>

<div class="container">
    <div class="main-card shadow-lg">
        <div class="row align-items-center">
            <div class="col-md-8">
                <h2 class="fw-light">Bienvenido al Panel de Control</h2>
                <p class="text-white-50">Has validado tus credenciales correctamente contra la base de datos en Clever Cloud.</p>
            </div>
            <div class="col-md-4 text-end">
                <span class="status-badge">Sesión Activa</span>
            </div>
        </div>
        
        <hr class="my-4" style="border-color: #495057;">
        
        <div class="alert alert-info bg-dark border-secondary text-info small">
            <strong>Nota de prueba:</strong> Este es el dashboard básico. En la siguiente fase, aquí listaremos los proyectos de grado, coordinadores y estudiantes registrados.
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>