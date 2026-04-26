<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. CONSULTA DE PROYECTOS: Usando la nueva columna nombre_estudiante --%>
<sql:query dataSource="${ds}" var="misProyectos">
    SELECT p.*, e.nombre_estudiante 
    FROM proyectos p 
    LEFT JOIN estudiantes e ON p.estudiante_id = e.id 
    WHERE p.coordinador_id = ? 
    ORDER BY p.id DESC
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 2. CONSULTA DE SOLICITUDES: Estudiantes que enviaron link de Drive --%>
<sql:query dataSource="${ds}" var="solicitudes">
    SELECT s.*, e.nombre_estudiante, p.nombre_proyecto 
    FROM solicitudes_proyectos s
    JOIN estudiantes e ON s.estudiante_id = e.id
    JOIN proyectos p ON s.proyecto_id = p.id
    WHERE s.estado = 'Pendiente' AND p.coordinador_id = ?
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 3. CONSULTAS PARA COMBOS: Directores y Evaluadores --%>
<sql:query dataSource="${ds}" var="listaDirectores">
    SELECT id, nombre FROM directores ORDER BY nombre ASC
</sql:query>
<sql:query dataSource="${ds}" var="listaEvaluadores">
    SELECT id, nombre FROM evaluadores ORDER BY nombre ASC
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Proyectos | Coordinador</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        :root { --accent: #ffc107; --bg-dark: #0d0d0d; --card-bg: #161616; --row-bg: #1a1a1a; --border: #333; }
        body { background-color: var(--bg-dark); color: #e0e0e0; font-family: 'Segoe UI', sans-serif; }
        .card-dark { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 12px; }
        .form-control { background-color: #0d0d0d !important; border: 1px solid #444 !important; color: white !important; }
        .table { color: #fff; border-collapse: separate; border-spacing: 0 10px; }
        .table tbody tr { background-color: var(--row-bg); }
        .table td { vertical-align: middle; border: none; padding: 15px; }
        .badge-status { padding: 5px 10px; border-radius: 4px; font-size: 0.75rem; font-weight: bold; }
    </style>
</head>
<body>

<nav class="navbar navbar-dark bg-dark mb-4 border-bottom border-secondary">
    <span class="navbar-brand font-weight-bold">Gestión de <span class="text-warning">Proyectos</span></span>
    <div class="ml-auto text-muted small">
        <i class="fas fa-user-tie mr-1"></i> ${sessionScope.usuarioLogueado.nombre} 
        <a href="../logout.jsp" class="btn btn-outline-danger btn-sm ml-3">Cerrar Sesión</a>
    </div>
</nav>

<div class="container-fluid px-4">
    <div class="row">
        <div class="col-md-3">
            <div class="card-dark p-4 shadow">
                <h6 class="text-warning mb-4"><i class="fas fa-plus mr-2"></i>NUEVO PROYECTO</h6>
                <form action="../acciones_coordinador.jsp" method="POST">
                    <input type="hidden" name="accion" value="crear_proyecto">
                    <div class="form-group"><label class="small text-muted">NOMBRE</label><input type="text" name="txtNombre" class="form-control" required></div>
                    <div class="form-group"><label class="small text-muted">CÓDIGO</label><input type="text" name="txtCodigo" class="form-control" required></div>
                    <div class="form-group"><label class="small text-muted">FACULTAD</label><input type="text" name="txtFacultad" class="form-control" required></div>
                    <div class="form-group"><label class="small text-muted">DESCRIPCIÓN</label><textarea name="txtDesc" class="form-control" rows="2"></textarea></div>
                    <button type="submit" class="btn btn-warning btn-block font-weight-bold">PUBLICAR</button>
                </form>
            </div>
        </div>

        <div class="col-md-9">
            
            <%-- SECCIÓN DE SOLICITUDES (Solo aparece si hay pendientes) --%>
            <c:if test="${solicitudes.rowCount > 0}">
                <div class="card-dark p-4 mb-4 border-warning">
                    <h6 class="text-warning mb-3">SOLICITUDES PENDIENTES</h6>
                    <c:forEach var="sol" items="${solicitudes.rows}">
                        <div class="d-flex justify-content-between align-items-center bg-dark p-3 rounded mb-2">
                            <div>
                                <strong class="text-white">${sol.nombre_estudiante}</strong> solicita <span class="text-warning">${sol.nombre_proyecto}</span>
                                <a href="${sol.link_drive}" target="_blank" class="ml-3 badge badge-info p-2"><i class="fab fa-google-drive"></i> DRIVE</a>
                            </div>
                            <form action="../acciones_coordinador.jsp" method="POST">
                                <input type="hidden" name="accion" value="aprobar_estudiante">
                                <input type="hidden" name="id_solicitud" value="${sol.id}">
                                <input type="hidden" name="id_estudiante" value="${sol.estudiante_id}">
                                <input type="hidden" name="id_proyecto" value="${sol.proyecto_id}">
                                <button type="submit" class="btn btn-success btn-sm px-4">Aprobar</button>
                            </form>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <div class="card-dark p-4">
                <h6 class="text-muted mb-4">TODOS LOS PROYECTOS</h6>
                <table class="table">
                    <thead>
                        <tr class="text-muted small">
                            <th>CÓDIGO</th>
                            <th>PROYECTO</th>
                            <th>ESTADO</th>
                            <th>ASIGNACIÓN ESTUDIANTE</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${misProyectos.rows}">
                            <tr>
                                <td class="text-warning font-weight-bold">${p.codigo_proyecto}</td>
                                <td class="small font-weight-bold" style="max-width: 200px;">${p.nombre_proyecto}</td>
                                <td>
                                    <span class="badge-status ${p.estado == 'Asignado' ? 'bg-success' : 'bg-info'} text-white">
                                        ${p.estado}
                                    </span>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <i class="fas fa-user-graduate mr-2 text-muted"></i>
                                        <c:choose>
                                            <c:when test="${not empty p.nombre_estudiante}">
                                                <span class="text-white font-weight-bold">${p.nombre_estudiante}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted small font-italic">Esperando aprobación...</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    
                                    <%-- Formulario de personal si ya hay estudiante --%>
                                    <c:if test="${not empty p.nombre_estudiante}">
                                        <form action="../acciones_coordinador.jsp" method="POST" class="mt-2 row no-gutters">
                                            <input type="hidden" name="accion" value="asignar_personal">
                                            <input type="hidden" name="id_proyecto" value="${p.id}">
                                            <div class="col mr-1">
                                                <select name="id_director" class="form-control form-control-sm">
                                                    <option value="">Director...</option>
                                                    <c:forEach var="d" items="${listaDirectores.rows}">
                                                        <option value="${d.id}" ${p.director_id == d.id ? 'selected' : ''}>${d.nombre}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col mr-1">
                                                <select name="id_evaluador" class="form-control form-control-sm">
                                                    <option value="">Evaluador...</option>
                                                    <c:forEach var="e" items="${listaEvaluadores.rows}">
                                                        <option value="${e.id}" ${p.evaluador_id == e.id ? 'selected' : ''}>${e.nombre}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <button type="submit" class="btn btn-warning btn-sm"><i class="fas fa-save"></i></button>
                                        </form>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>