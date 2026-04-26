<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. NORMALIZACIÓN DE ROL Y TABLA --%>
<c:set var="rolRecibido" value="${not empty param.rol ? param.rol : 'estudiante'}" />

<c:choose>
    <c:when test="${rolRecibido == 'estudiante'}">
        <c:set var="tabla" value="estudiantes" />
        <c:set var="pagina" value="dashboard_estudiante.jsp" />
    </c:when>
    <c:when test="${rolRecibido == 'directores'}">
        <c:set var="tabla" value="directores" />
        <c:set var="pagina" value="dashboard_directores.jsp" />
    </c:when>
    <c:when test="${rolRecibido == 'evaluadores'}">
        <c:set var="tabla" value="evaluadores" />
        <c:set var="pagina" value="dashboard_evaluadores.jsp" />
    </c:when>
    <c:when test="${rolRecibido == 'coordinadores'}">
        <c:set var="tabla" value="coordinadores" />
        <c:set var="pagina" value="dashboard_coordinadores.jsp" />
    </c:when>
</c:choose>

<c:if test="${pageContext.request.method == 'POST'}">
    <sql:query dataSource="${ds}" var="res">
        SELECT * FROM ${tabla} WHERE gmail = ? AND password = ?
        <sql:param value="${param.txtGmail}" />
        <sql:param value="${param.txtPass}" />
    </sql:query>

    <c:choose>
        <c:when test="${res.rowCount > 0}">
            <c:set var="usuarioLogueado" value="${res.rows[0]}" scope="session" />
            <c:set var="tipoUsuario" value="${rolRecibido}" scope="session" />
            <%-- Redireccionamos a la carpeta dashboards --%>
            <c:redirect url="dashboards/${pagina}" />
        </c:when>
        <c:otherwise>
            <c:set var="error" value="true" />
        </c:otherwise>
    </c:choose>
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Acceso | <c:out value="${rolRecibido}" /></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { background: #0a0a0a; color: white; height: 100vh; display: flex; align-items: center; justify-content: center; font-family: 'Inter', sans-serif; }
        .login-box { background: #121212; border: 1px solid #222; padding: 40px; border-radius: 20px; width: 100%; max-width: 400px; }
        .form-control { background: #000; border: 1px solid #333; color: white; height: 45px; }
        .form-control:focus { background: #000; color: white; border-color: #ffc107; box-shadow: none; }
        .btn-primary { background: #ffc107; border: none; color: black; font-weight: bold; height: 45px; }
        .text-warning { text-transform: capitalize; }
    </style>
</head>
<body>
<div class="login-box shadow-lg text-center">
    <%-- Volver con ruta absoluta --%>
    <a href="${pageContext.request.contextPath}/index.jsp" class="text-muted small d-block mb-3 text-decoration-none">
        <i class="fas fa-arrow-left"></i> Volver al inicio
    </a>
    <h3 class="mb-4">Acceso <span class="text-warning">${rolRecibido}</span></h3>
    <c:if test="${error}">
        <div class="alert alert-danger small py-2">Datos incorrectos para ${rolRecibido}</div>
    </c:if>
    <form method="POST">
        <div class="form-group text-left">
            <label class="small text-muted">GMAIL</label>
            <input type="email" name="txtGmail" class="form-control" required>
        </div>
        <div class="form-group text-left">
            <label class="small text-muted">CONTRASEÑA</label>
            <input type="password" name="txtPass" class="form-control" required>
        </div>
        <button type="submit" class="btn btn-primary btn-block py-2 mt-4">INGRESAR</button>
    </form>
</div>
</body>
</html>