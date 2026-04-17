<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<%-- Seguridad: Validar sesión y tipo de usuario --%>
<c:if test="${empty sessionScope.usuarioLogueado || sessionScope.tipoUsuario != 'estudiantes'}">
    <c:redirect url="login_usuarios.jsp?rol=estudiantes" />
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard | Estudiante</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { background: #0f0f0f; color: white; font-family: 'Inter', sans-serif; }
        .nav-side { background: rgba(255,255,255,0.03); height: 100vh; border-right: 1px solid rgba(255,255,255,0.1); }
        .card-stat { background: linear-gradient(45deg, #2c3e50, #000000); border: 1px solid #ffc107; border-radius: 15px; }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-md-2 nav-side p-4">
                <h4 class="text-warning">InmoHome</h4>
                <hr class="bg-secondary">
                <p class="small text-muted">Bienvenido,</p>
                <h6>${sessionScope.usuarioLogueado.nombre}</h6>
                <div class="mt-4">
                    <a href="#" class="d-block text-white mb-2"><i class="fas fa-file-upload mr-2"></i> Mi Proyecto</a>
                    <a href="../logout.jsp" class="d-block text-danger mt-5"><i class="fas fa-sign-out-alt mr-2"></i> Salir</a>
                </div>
            </div>
            <div class="col-md-10 p-5">
                <h2 class="font-weight-light">Panel del Estudiante</h2>
                <div class="row mt-4">
                    <div class="col-md-4">
                        <div class="card-stat p-4 text-center">
                            <h5 class="text-warning">Estado del Proyecto</h5>
                            <p class="display-4">Enviado</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>