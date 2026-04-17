<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:if test="${empty sessionScope.usuarioLogueado || sessionScope.tipoUsuario != 'coordinadores'}">
    <c:redirect url="login_usuarios.jsp?rol=coordinadores" />
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard | Coordinador</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <style>
        body { background: #0f0f0f; color: white; }
        .top-bar { background: rgba(255,193,7,0.1); border-bottom: 1px solid #ffc107; padding: 15px; }
    </style>
</head>
<body>
    <div class="top-bar d-flex justify-content-between">
        <span class="font-weight-bold">COORDINACIÓN ACADÉMICA</span>
        <a href="../logout.jsp" class="text-warning">Cerrar Sesión</a>
    </div>
    <div class="container mt-5 text-center">
        <h1 class="display-4">Bienvenido, ${sessionScope.usuarioLogueado.nombre}</h1>
        <p class="lead text-muted">Aquí podrás supervisar todos los procesos de grado.</p>
    </div>
</body>
</html>