<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:if test="${empty sessionScope.usuarioLogueado || sessionScope.tipoUsuario != 'evaluadores'}">
    <c:redirect url="login_usuarios.jsp?rol=evaluadores" />
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Dashboard | Evaluador</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
</head>
<body class="bg-dark text-white">
    <div class="container p-5">
        <div class="border border-info p-4 rounded text-center">
            <h3>Panel de Calificación</h3>
            <p>Evaluador: <strong>${sessionScope.usuarioLogueado.nombre}</strong></p>
            <hr class="bg-info">
            <p>Proyectos pendientes por calificar: 0</p>
            <a href="../logout.jsp" class="btn btn-outline-info">Salir</a>
        </div>
    </div>
</body>
</html>