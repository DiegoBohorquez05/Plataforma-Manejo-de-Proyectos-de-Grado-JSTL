<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 
    CONSULTA RESUELTA: 
    Traemos todo de proyectos (p.*) y solo el nombre de estudiantes (e.nombre).
    El LEFT JOIN asegura que el proyecto aparezca aunque no tenga estudiante asignado.
--%>
<sql:query dataSource="${ds}" var="misProyectos">
    SELECT p.*, e.nombre 
    FROM proyectos p 
    LEFT JOIN estudiantes e ON p.estudiante_id = e.id 
    WHERE p.coordinador_id = ? 
    ORDER BY p.id DESC
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel de Coordinador</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { background-color: #0d0d0d; color: #e0e0e0; font-family: 'Segoe UI', sans-serif; }
        .card-dark { background-color: #161616; border: 1px solid #333; border-radius: 12px; margin-bottom: 20px; }
        .table { color: #fff; border-collapse: separate; border-spacing: 0 10px; }
        .table thead th { border: none; color: #888; text-transform: uppercase; font-size: 0.75rem; letter-spacing: 1px; }
        .table tbody tr { background-color: #1a1a1a; transition: transform 0.2s; }
        .table tbody td { border: none; padding: 20px; vertical-align: middle; }
        .text-warning { color: #ffc107 !important; }
        .badge-success { background-color: #28a745; color: #fff; }
        .badge-info { background-color: #17a2b8; color: #fff; }
    </style>
</head>
<body class="p-4">

<div class="container-fluid">
<div class="d-flex justify-content-between align-items-center mb-5">
        <h2 class="font-weight-bold">Gestión de <span class="text-warning">Proyectos</span></h2>
        <a href="../logout.jsp" class="btn btn-outline-danger btn-sm px-4">Cerrar Sesión</a>
    </div>
    <div class="row">
        <div class="col-md-3">
            <div class="card-dark p-4 shadow">
                <h6 class="text-warning mb-4 font-weight-bold">NUEVO PROYECTO</h6>
                <form action="../acciones_coordinador.jsp" method="POST">
                    <input type="hidden" name="accion" value="crear_proyecto">
                    <div class="form-group small">
                        <label>NOMBRE DEL PROYECTO</label>
                        <input type="text" name="txtNombre" class="form-control bg-dark text-white border-secondary" required>
                    </div>
                    <div class="form-group small">
                        <label>CÓDIGO</label>
                        <input type="text" name="txtCodigo" class="form-control bg-dark text-white border-secondary" required>
                    </div>
                    <div class="form-group small">
                        <label>FACULTAD</label>
                        <input type="text" name="txtFacultad" class="form-control bg-dark text-white border-secondary" required>
                    </div>
                    <div class="form-group small">
                        <label>DESCRIPCIÓN</label>
                        <textarea name="txtDesc" class="form-control bg-dark text-white border-secondary" rows="3" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-warning btn-block font-weight-bold">PUBLICAR PROYECTO</button>
                </form>
            </div>
        </div>

        <div class="col-md-9">
            <div class="card-dark p-4 shadow">
                <h6 class="text-muted mb-4 small font-weight-bold">ESTADO DE MIS PROYECTOS</h6>
                
                <table class="table">
                    <thead>
                        <tr>
                            <th>CÓDIGO</th>
                            <th>PROYECTO</th>
                            <th class="text-center">ESTADO</th>
                            <th>ESTUDIANTE ASIGNADO</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${misProyectos.rows}">
                            <tr>
                                <td class="text-warning font-weight-bold">${p.codigo_proyecto}</td>
                                <td style="max-width: 350px;">${p.nombre_proyecto}</td>
                                <td class="text-center">
                                    <span class="badge ${p.estado == 'Asignado' ? 'badge-success' : 'badge-info'}">
                                        ${p.estado}
                                    </span>
                                </td>
                                <td>
                                    <i class="fas fa-user-circle mr-2 text-muted"></i>
                                    <c:choose>
                                        <c:when test="${not empty p.nombre}">
                                            <span class="text-white font-weight-bold">${p.nombre}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">Disponible</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <c:if test="${misProyectos.rowCount == 0}">
                    <div class="text-center py-5">
                        <i class="fas fa-folder-open fa-3x text-secondary mb-3"></i>
                        <p class="text-muted">No has publicado ningún proyecto todavía.</p>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

</body>
</html>