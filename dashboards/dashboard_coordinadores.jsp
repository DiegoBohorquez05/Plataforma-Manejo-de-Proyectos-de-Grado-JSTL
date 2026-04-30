<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. CONSULTA DE PROYECTOS GENERALES --%>
<sql:query dataSource="${ds}" var="misProyectos">
    SELECT p.*, e.nombre_estudiante 
    FROM proyectos p 
    LEFT JOIN estudiantes e ON p.estudiante_id = e.id 
    WHERE p.coordinador_id = ? 
    ORDER BY p.id DESC
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 2. CONSULTA DE SEGUIMIENTO --%>
<sql:query dataSource="${ds}" var="seguimientoProyectos">
    SELECT 
        p.id AS proyecto_id,
        p.nombre_proyecto,
        p.estado AS estado_proyecto,
        d.nombre_director,
        ev.nombre_evaluador,
        (SELECT id FROM documentos_proyecto WHERE proyecto_id = p.id ORDER BY fecha_subida DESC LIMIT 1) AS id_documento,
        dp.estado_director,
        dp.estado_evaluador,
        dp.estado_coordinador
    FROM proyectos p
    LEFT JOIN directores d ON p.director_id = d.id
    LEFT JOIN evaluadores ev ON p.evaluador_id = ev.id
    LEFT JOIN documentos_proyecto dp ON dp.id = (
        SELECT id FROM documentos_proyecto 
        WHERE proyecto_id = p.id 
        ORDER BY fecha_subida DESC LIMIT 1
    )
    WHERE p.coordinador_id = ? AND p.estado IN ('Asignado', 'Finalizado')
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 3. CONSULTA DE SOLICITUDES PENDIENTES --%>
<sql:query dataSource="${ds}" var="solicitudes">
    SELECT s.*, e.nombre_estudiante, p.nombre_proyecto 
    FROM solicitudes_proyectos s
    JOIN estudiantes e ON s.estudiante_id = e.id
    JOIN proyectos p ON s.proyecto_id = p.id
    WHERE s.estado = 'Pendiente' AND p.coordinador_id = ?
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 4. CONSULTAS PARA LISTAS --%>
<sql:query dataSource="${ds}" var="listaDirectores">
    SELECT id, nombre_director FROM directores ORDER BY nombre_director ASC
</sql:query>
<sql:query dataSource="${ds}" var="listaEvaluadores">
    SELECT id, nombre_evaluador FROM evaluadores ORDER BY nombre_evaluador ASC
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Coordinador | Gestión de Proyectos</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        :root { --accent: #ffc107; --bg-dark: #0d0d0d; --card-bg: #161616; --row-bg: #1a1a1a; --border: #333; --text-muted: #888; }
        body { background-color: var(--bg-dark); color: #e0e0e0; font-family: 'Segoe UI', sans-serif; }
        .header-section { background-color: var(--card-bg); border-bottom: 1px solid var(--border); padding: 1.5rem; margin-bottom: 2rem; }
        .card-dark { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.3); }
        .form-control { background-color: #0d0d0d !important; border: 1px solid #444 !important; color: white !important; border-radius: 8px; }
        label { font-size: 0.7rem; letter-spacing: 1px; font-weight: 700; color: var(--text-muted); margin-bottom: 8px; }
        .table { color: #fff; border-collapse: separate; border-spacing: 0 12px; }
        .table thead th { border: none; color: var(--text-muted); text-transform: uppercase; font-size: 0.7rem; padding-left: 20px; }
        .table tbody tr { background-color: var(--row-bg); transition: 0.3s; border-radius: 10px; }
        .table tbody td { border: none; padding: 20px; vertical-align: middle; }
        .btn-warning { background-color: var(--accent); border: none; font-weight: 700; border-radius: 10px; text-transform: uppercase; font-size: 0.85rem; }
        .badge-status { padding: 6px 12px; border-radius: 6px; font-size: 0.7rem; font-weight: 800; }
    </style>
</head>
<body>

<div class="header-section">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h2 class="mb-0 font-weight-bold">Gestión de <span class="text-warning">Proyectos</span></h2>
        <div class="d-flex align-items-center">
            <span class="mr-3 text-muted small"><i class="fas fa-user-tie mr-1"></i> ${sessionScope.usuarioLogueado.nombre_coordinador}</span>
            <a href="../logout.jsp" class="btn btn-outline-danger btn-sm px-4">Cerrar Sesión</a>
        </div>
    </div>
</div>

<div class="container-fluid px-4">
    <div class="row">
        <div class="col-md-3 mb-4">
            <div class="card-dark p-4">
                <h6 class="text-warning mb-4 font-weight-bold"><i class="fas fa-plus-circle mr-2"></i> NUEVO PROYECTO</h6>
                <form action="../acciones_coordinador.jsp" method="POST">
                    <input type="hidden" name="accion" value="crear_proyecto">
                    <div class="form-group"><label>NOMBRE</label><input type="text" name="txtNombre" class="form-control" required></div>
                    <div class="form-group"><label>CÓDIGO</label><input type="text" name="txtCodigo" class="form-control" required></div>
                    <div class="form-group"><label>FACULTAD</label><input type="text" name="txtFacultad" class="form-control" required></div>
                    <div class="form-group"><label>DESCRIPCIÓN</label><textarea name="txtDesc" class="form-control" rows="3" required></textarea></div>
                    <button type="submit" class="btn btn-warning btn-block">Publicar Proyecto</button>
                </form>
            </div>
        </div>

        <div class="col-md-9">
            <c:if test="${solicitudes.rowCount > 0}">
                <div class="card-dark p-4 mb-4" style="border-left: 5px solid var(--accent);">
                    <h6 class="text-warning small font-weight-bold mb-3">SOLICITUDES POR APROBAR</h6>
                    <c:forEach var="sol" items="${solicitudes.rows}">
                        <div class="d-flex justify-content-between align-items-center bg-dark p-3 rounded mb-2">
                            <div>
                                <span class="text-white font-weight-bold">${sol.nombre_estudiante}</span> 
                                <span class="text-muted mx-2">pide</span> 
                                <span class="text-warning font-weight-bold">${sol.nombre_proyecto}</span>
                                <a href="${sol.link_drive}" target="_blank" class="badge badge-info ml-2 px-2 py-1"><i class="fab fa-google-drive mr-1"></i> VER DRIVE</a>
                            </div>
                            <form action="../acciones_coordinador.jsp" method="POST">
                                <input type="hidden" name="accion" value="aprobar_estudiante">
                                <input type="hidden" name="id_solicitud" value="${sol.id}">
                                <input type="hidden" name="id_estudiante" value="${sol.estudiante_id}">
                                <input type="hidden" name="id_proyecto" value="${sol.proyecto_id}">
                                <button type="submit" class="btn btn-success btn-sm px-4">Aceptar</button>
                            </form>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <div class="card-dark p-4 mb-4">
                <h6 class="text-info small font-weight-bold mb-4"><i class="fas fa-stream mr-2"></i> SEGUIMIENTO Y AVAL FINAL</h6>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>PROYECTO</th>
                                <th>AVALES</th>
                                <th class="text-right">ACCIÓN</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="seg" items="${seguimientoProyectos.rows}">
                                <tr>
                                    <td>
                                        <div class="text-white font-weight-bold small">${seg.nombre_proyecto}</div>
                                        <div class="text-muted" style="font-size: 0.65rem;">${seg.nombre_director} / ${seg.nombre_evaluador}</div>
                                    </td>
                                    <td>
    <%-- AVAL DIRECTOR --%>
    <c:choose>
        <c:when test="${seg.estado_director == 'Aprobado'}">
            <span class="badge badge-success">DIR: Aprobado</span>
        </c:when>
        <c:when test="${seg.estado_director == 'Corregir'}">
            <span class="badge badge-danger">DIR: Corregir</span>
        </c:when>
        <c:otherwise>
            <span class="badge badge-warning">DIR: PENDIENTE</span>
        </c:otherwise>
    </c:choose>
    
    <%-- AVAL EVALUADOR --%>
    <c:choose>
        <c:when test="${seg.estado_evaluador == 'Aprobado'}">
            <span class="badge badge-success">EVA: Aprobado</span>
        </c:when>
        <c:when test="${seg.estado_evaluador == 'Corregir'}">
            <span class="badge badge-danger">EVA: Corregir</span>
        </c:when>
        <c:otherwise>
            <span class="badge badge-warning">EVA: PENDIENTE</span>
        </c:otherwise>
    </c:choose>
</td>
                                    <td class="text-right">
                                        <c:choose>
                                            <c:when test="${seg.estado_coordinador == 'Aprobado'}">
                                                <span class="badge badge-success px-3 py-2"><i class="fas fa-check-double mr-1"></i> FINALIZADO</span>
                                            </c:when>
                                            <c:when test="${seg.estado_director == 'Aprobado' && seg.estado_evaluador == 'Aprobado'}">
                                                <form action="../acciones_coordinador.jsp" method="POST">
                                                    <input type="hidden" name="accion" value="finalizar_proyecto">
                                                    <input type="hidden" name="id_proyecto" value="${seg.proyecto_id}">
                                                    <input type="hidden" name="id_documento" value="${seg.id_documento}"> 
                                                    <button type="submit" class="btn btn-warning btn-sm font-weight-bold">FINALIZAR</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn btn-dark btn-sm text-muted" disabled style="font-size: 0.7rem;">PENDIENTE AVALES</button>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card-dark p-4">
                <h6 class="text-muted small font-weight-bold mb-4">TODOS LOS PROYECTOS</h6>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>CÓDIGO</th>
                                <th>PROYECTO</th>
                                <th class="text-center">ESTADO</th>
                                <th>ASIGNACIONES</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${misProyectos.rows}">
                                <tr>
                                    <td class="text-warning font-weight-bold">${p.codigo_proyecto}</td>
                                    <td>
                                        <div class="text-white small font-weight-bold">${p.nombre_proyecto}</div>
                                        <div class="text-muted small">${p.facultad}</div>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge-status ${p.estado == 'Finalizado' ? 'badge-success' : 'badge-info'}">${p.estado}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.director_id > 0 && p.evaluador_id > 0}">
                                                <div class="bg-dark p-2 rounded border border-secondary" style="font-size: 0.7rem;">
                                                    <div class="text-warning mb-1"><i class="fas fa-user-graduate mr-1"></i> ${p.nombre_estudiante}</div>
                                                    <div class="text-white mb-1"><i class="fas fa-user-tie mr-1"></i> Dir: 
                                                        <c:forEach var="d" items="${listaDirectores.rows}"><c:if test="${p.director_id == d.id}">${d.nombre_director}</c:if></c:forEach>
                                                    </div>
                                                    <div class="text-white"><i class="fas fa-search mr-1"></i> Eva: 
                                                        <c:forEach var="ev" items="${listaEvaluadores.rows}"><c:if test="${p.evaluador_id == ev.id}">${ev.nombre_evaluador}</c:if></c:forEach>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:when test="${not empty p.nombre_estudiante}">
                                                <form action="../acciones_coordinador.jsp" method="POST" class="bg-dark p-2 rounded border border-warning">
                                                    <input type="hidden" name="accion" value="asignar_personal">
                                                    <input type="hidden" name="id_proyecto" value="${p.id}">
                                                    <div class="form-row align-items-end">
                                                        <div class="col">
                                                            <select name="id_director" class="form-control form-control-sm" required>
                                                                <option value="">Director...</option>
                                                                <c:forEach var="d" items="${listaDirectores.rows}"><option value="${d.id}">${d.nombre_director}</option></c:forEach>
                                                            </select>
                                                        </div>
                                                        <div class="col">
                                                            <select name="id_evaluador" class="form-control form-control-sm" required>
                                                                <option value="">Evaluador...</option>
                                                                <c:forEach var="ev" items="${listaEvaluadores.rows}"><option value="${ev.id}">${ev.nombre_evaluador}</option></c:forEach>
                                                            </select>
                                                        </div>
                                                        <div class="col-auto"><button type="submit" class="btn btn-warning btn-sm"><i class="fas fa-save"></i></button></div>
                                                    </div>
                                                </form>
                                            </c:when>
                                            <c:otherwise><span class="text-muted small"><i>Esperando solicitud...</i></span></c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>