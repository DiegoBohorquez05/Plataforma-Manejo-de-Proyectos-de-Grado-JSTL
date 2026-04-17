<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%-- 1. Conexión (Usa la ruta directa porque está en la raíz) --%>
<%@ include file="WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 2. Identificar Rol --%>
<c:set var="rol" value="${not empty param.rol ? param.rol : 'estudiantes'}" />

<%-- 3. Validación de Login --%>
<c:if test="${pageContext.request.method == 'POST'}">
    <sql:query dataSource="${ds}" var="res">
        SELECT * FROM ${rol} WHERE gmail = ? AND password = ?
        <sql:param value="${param.txtGmail}" />
        <sql:param value="${param.txtPass}" />
    </sql:query>

    <c:choose>
        <c:when test="${res.rowCount > 0}">
            <%-- Guardamos datos en sesión --%>
            <c:set var="usuarioLogueado" value="${res.rows[0]}" scope="session" />
            <c:set var="tipoUsuario" value="${rol}" scope="session" />
            
            <%-- REDIRECCIÓN ACTUALIZADA A LA CARPETA DASHBOARDS --%>
            <c:choose>
                <c:when test="${rol == 'estudiantes'}">
                    <c:redirect url="dashboards/dashboard_estudiante.jsp" />
                </c:when>
                <c:otherwise>
                    <c:redirect url="dashboards/dashboard_${rol}.jsp" />
                </c:otherwise>
            </c:choose>
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
    <title>Acceso | <c:out value="${rol}" /></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { background: #0f0f0f; color: white; height: 100vh; display: flex; align-items: center; justify-content: center; font-family: 'Inter', sans-serif; }
        .login-box { background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.1); padding: 40px; border-radius: 20px; width: 100%; max-width: 400px; backdrop-filter: blur(10px); }
        .form-control { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: white; }
        .form-control:focus { background: rgba(255,255,255,0.1); color: white; border-color: #ffc107; box-shadow: none; }
        .btn-primary { background: #ffc107; border: none; color: black; font-weight: bold; }
        .btn-primary:hover { background: #e0a800; }
        .text-warning { text-transform: capitalize; }
    </style>
</head>
<body>

<div class="login-box shadow-lg text-center">
    <a href="index.jsp" class="text-muted small d-block mb-3 text-decoration-none">
        <i class="fas fa-arrow-left"></i> Volver al inicio
    </a>
    <h3 class="mb-4">Acceso <span class="text-warning">${rol}</span></h3>
    
    <c:if test="${error}">
        <div class="alert alert-danger small py-2">Credenciales incorrectas</div>
    </c:if>

    <form method="POST">
        <div class="form-group text-left">
            <label class="small text-muted">GMAIL INSTITUCIONAL</label>
            <input type="email" name="txtGmail" class="form-control" placeholder="usuario@gmail.com" required>
        </div>
        <div class="form-group text-left">
            <label class="small text-muted">CONTRASEÑA</label>
            <input type="password" name="txtPass" class="form-control" placeholder="••••••••" required>
        </div>
        <button type="submit" class="btn btn-primary btn-block py-2 mt-4">INGRESAR</button>
    </form>
</div>

</body>
</html>