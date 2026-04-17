<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:if test="${empty sessionScope.usuarioLogueado || sessionScope.tipoUsuario != 'directores'}">
    <c:redirect url="login_usuarios.jsp?rol=directores" />
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard | Director</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
</head>
<body style="background: #121212; color: #fff;">
    <div class="container p-5 text-center">
        <i class="fas fa-user-edit fa-4x text-success mb-4"></i>
        <h2>Panel de Dirección de Proyectos</h2>
        <p>Hola, Director ${sessionScope.usuarioLogueado.nombre}</p>
        <div class="alert alert-secondary mt-4">No tienes solicitudes de aval pendientes.</div>
        <a href="../logout.jsp" class="btn btn-success mt-3">Finalizar Sesión</a>
    </div>
</body>
</html>