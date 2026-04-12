<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%-- 1. Incluimos el fragmento --%>
<%@ include file="WEB-INF/conexion.jspf" %>

<%-- 2. Configuramos el DataSource usando las variables que guardamos en application --%>
<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 3. Lógica de Validación --%>
<c:if test="${pageContext.request.method == 'POST'}">
    <sql:query dataSource="${ds}" var="resultado">
        SELECT * FROM administradores 
        WHERE usuario = ? AND password = ?
        <sql:param value="${param.adminUser}" />
        <sql:param value="${param.adminPass}" />
    </sql:query>

    <c:choose>
        <c:when test="${resultado.rowCount > 0}">
            <c:set var="adminLogueado" value="${resultado.rows[0]}" scope="session" />
            <c:redirect url="dashboard_admin.jsp" />
        </c:when>
        <c:otherwise>
            <c:set var="errorLogin" value="true" />
        </c:otherwise>
    </c:choose>
</c:if>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Administración | Proyectos de Grado</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { 
            background: radial-gradient(circle at top right, #1a1c1e, #000000); 
            display: flex; align-items: center; justify-content: center; 
            height: 100vh; margin: 0; color: white;
        }
        .login-card { 
            width: 100%; max-width: 420px; background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(15px); border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px; padding: 40px; box-shadow: 0 25px 50px rgba(0,0,0,0.5);
        }
        .form-control { 
            background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: #fff; 
        }
        .btn-login { background: #495057; color: white; font-weight: bold; border: none; }
        .btn-login:hover { background: #343a40; }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="text-center mb-4">
            <i class="fas fa-user-shield fa-3x text-secondary mb-3"></i>
            <h3>Administración</h3>
        </div>
        
        <c:if test="${not empty errorLogin}">
            <div class="alert alert-danger py-2 small">Credenciales incorrectas</div>
        </c:if>

        <form method="POST">
            <div class="form-group">
                <label class="small text-muted">USUARIO MAESTRO</label>
                <input type="text" name="adminUser" class="form-control" required>
            </div>
            <div class="form-group">
                <label class="small text-muted">CLAVE DE ACCESO</label>
                <input type="password" name="adminPass" class="form-control" required>
            </div>
            <button type="submit" class="btn btn-login btn-block py-3 mt-3">ENTRAR</button>
            <div class="text-center mt-3">
                <a href="index.jsp" class="text-white-50 small text-decoration-none">Volver al inicio</a>
            </div>
        </form>
    </div>
</body>
</html>