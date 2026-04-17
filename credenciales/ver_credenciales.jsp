<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%-- 1. Conexión --%>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 2. Consultas --%>
<sql:query dataSource="${ds}" var="est">SELECT 'Estudiante' as rol, gmail, password FROM estudiantes</sql:query>
<sql:query dataSource="${ds}" var="coo">SELECT 'Coordinador' as rol, gmail, password FROM coordinadores</sql:query>
<sql:query dataSource="${ds}" var="eva">SELECT 'Evaluador' as rol, gmail, password FROM evaluadores</sql:query>
<sql:query dataSource="${ds}" var="dir">SELECT 'Director' as rol, gmail, password FROM directores</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Credenciales de Prueba | Debug</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <style>
        body { background: #0b0c0d; color: #fff; font-family: 'Inter', sans-serif; padding: 50px; }
        .table-debug { background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.1); border-radius: 15px; overflow: hidden; }
        .badge-est { background: #007bff; }
        .badge-coo { background: #6f42c1; }
        .badge-eva { background: #fd7e14; }
        .badge-dir { background: #28a745; }
        .table { color: #ccc; }
    </style>
</head>
<body>
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2>🔑 Credenciales de Prueba</h2>
            <a href="../index.jsp" class="btn btn-outline-light btn-sm">Volver al Portal</a>
        </div>

        <div class="table-debug p-4 shadow-lg">
            <table class="table table-hover">
                <thead>
                    <tr class="text-warning">
                        <th>ROL</th>
                        <th>GMAIL (USUARIO)</th>
                        <th>CONTRASEÑA</th>
                    </tr>
                </thead>
                <tbody>
                    <%-- Listar Estudiantes --%>
                    <c:forEach var="u" items="${est.rows}">
                        <tr>
                            <td><span class="badge badge-est">Estudiante</span></td>
                            <td>${u.gmail}</td>
                            <td><code>${u.password}</code></td>
                        </tr>
                    </c:forEach>
                    <%-- Listar Coordinadores --%>
                    <c:forEach var="u" items="${coo.rows}">
                        <tr>
                            <td><span class="badge badge-coo">Coordinador</span></td>
                            <td>${u.gmail}</td>
                            <td><code>${u.password}</code></td>
                        </tr>
                    </c:forEach>
                    <%-- Listar Evaluadores --%>
                    <c:forEach var="u" items="${eva.rows}">
                        <tr>
                            <td><span class="badge badge-eva">Evaluador</span></td>
                            <td>${u.gmail}</td>
                            <td><code>${u.password}</code></td>
                        </tr>
                    </c:forEach>
                    <%-- Listar Directores --%>
                    <c:forEach var="u" items="${dir.rows}">
                        <tr>
                            <td><span class="badge badge-dir">Director</span></td>
                            <td>${u.gmail}</td>
                            <td><code>${u.password}</code></td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>