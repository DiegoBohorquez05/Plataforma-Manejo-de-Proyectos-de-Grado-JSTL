<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. CONSULTA DE PROYECTOS: Trae el nombre del estudiante asignado --%>
<sql:query dataSource="${ds}" var="misProyectos">
    SELECT p.*, e.nombre_estudiante 
    FROM proyectos p 
    LEFT JOIN estudiantes e ON p.estudiante_id = e.id 
    WHERE p.coordinador_id = ? 
    ORDER BY p.id DESC
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- NUEVA CONSULTA: Seguimiento de avances y avales --%>
<sql:query dataSource="${ds}" var="seguimientoProyectos">
    SELECT 
        p.id AS proyecto_id,
        p.nombre_proyecto,
        p.estado AS estado_proyecto,
        dp.nombre_documento AS ultimo_avance,
        dp.estado_director,
        dp.estado_evaluador,
        d.nombre_director,
        ev.nombre_evaluador
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

<%-- 2. CONSULTA DE SOLICITUDES PENDIENTES --%>
<sql:query dataSource="${ds}" var="solicitudes">
    SELECT s.*, e.nombre_estudiante, p.nombre_proyecto 
    FROM solicitudes_proyectos s
    JOIN estudiantes e ON s.estudiante_id = e.id
    JOIN proyectos p ON s.proyecto_id = p.id
    WHERE s.estado = 'Pendiente' AND p.coordinador_id = ?
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<sql:query dataSource="${ds}" var="proyectos">
    SELECT 
        id, 
        nombre_proyecto, 
        descripcion, 
        facultad, 
        codigo_proyecto, 
        estado 
    FROM proyectos 
    WHERE coordinador_id = ?
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 3. CONSULTAS PARA LISTAS DESPLEGABLES --%>
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
        .table tbody td:first-child { border-radius: 10px 0 0 10px; }
        .table tbody td:last-child { border-radius: 0 10px 10px 0; }
        .btn-warning { background-color: var(--accent); border: none; font-weight: 700; border-radius: 10px; text-transform: uppercase; font-size: 0.85rem; }
        .badge-status { padding: 6px 12px; border-radius: 6px; font-size: 0.7rem; font-weight: 800; }
        .badge-success { background-color: #28a745; color: white; }
        .badge-info { background-color: #17a2b8; color: white; }
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
            <%-- SECCIÓN DE SOLICITUDES --%>
            <c:if test="${solicitudes.rowCount > 0}">
                <div class="card-dark p-4 mb-4" style="border-left: 5px solid var(--accent);">
                    <h6 class="text-warning small font-weight-bold mb-3">SOLICITUDES POR APROBAR</h6>
                    <c:forEach var="sol" items="${solicitudes.rows}">
                        <div class="d-flex justify-content-between align-items-center bg-dark p-3 rounded mb-2" style="border: 1px solid #333;">
                            <div>
                                <span class="text-white font-weight-bold">${sol.nombre_estudiante}</span> 
                                <span class="text-muted mx-2">solicita</span> 
                                <span class="text-warning font-weight-bold">${sol.nombre_proyecto}</span>
                                <br>
                                <a href="${sol.link_drive}" target="_blank" class="badge badge-info mt-2 px-3 py-1">
                                    <i class="fab fa-google-drive mr-1"></i> VER LINK DE DRIVE
                                </a>
                            </div>
                            <div class="d-flex">
                                <form action="../acciones_coordinador.jsp" method="POST" class="mr-2">
                                    <input type="hidden" name="accion" value="aprobar_estudiante">
                                    <input type="hidden" name="id_solicitud" value="${sol.id}">
                                    <input type="hidden" name="id_estudiante" value="${sol.estudiante_id}">
                                    <input type="hidden" name="id_proyecto" value="${sol.proyecto_id}">
                                    <button type="submit" class="btn btn-success btn-sm px-3">Aceptar</button>
                                </form>
                                <form action="../acciones_coordinador.jsp" method="POST">
                                    <input type="hidden" name="accion" value="rechazar_estudiante">
                                    <input type="hidden" name="id_solicitud" value="${sol.id}">
                                    <button type="submit" class="btn btn-outline-danger btn-sm px-3">Rechazar</button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <%-- NUEVA TABLA: SEGUIMIENTO DE PASOS Y AVAL FINAL --%>
            <div class="card-dark p-4 mb-4" style="border-top: 3px solid #17a2b8;">
                <h6 class="text-info small font-weight-bold mb-4"><i class="fas fa-stream mr-2"></i> SEGUIMIENTO Y AVAL FINAL</h6>
                <div class="table-responsive">
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>PROYECTO EN CURSO</th>
                                <th>ESTADO AVALES (DIR/EVA)</th>
                                <th>PASO / ÚLTIMO AVANCE</th>
                                <th class="text-right">ACCIÓN COORDINADOR</th>
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
                                        <span class="badge ${seg.estado_director == 'Aprobado' ? 'badge-success' : 'badge-warning'}" style="font-size: 0.6rem;">${seg.estado_director}</span>
                                        <span class="badge ${seg.estado_evaluador == 'Aprobado' ? 'badge-success' : 'badge-warning'}" style="font-size: 0.6rem;">${seg.estado_evaluador}</span>
                                    </td>
                                    <td class="text-muted small">
                                        <c:choose>
                                            <c:when test="${empty seg.ultimo_avance}">Esperando entregas...</c:when>
                                            <c:otherwise>
                                                ${seg.ultimo_avance}
                                                <c:if test="${seg.estado_director == 'Corregir' || seg.estado_evaluador == 'Corregir'}">
                                                    <i class="fas fa-exclamation-triangle text-danger ml-1" title="Requiere corrección"></i>
                                                </c:if>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-right">
                                        <c:choose>
                                            <c:when test="${seg.estado_proyecto == 'Finalizado'}">
                                                <span class="badge badge-success px-3 py-2"><i class="fas fa-check-double mr-1"></i> FINALIZADO</span>
                                            </c:when>
                                            <c:when test="${seg.estado_director == 'Aprobado' && seg.estado_evaluador == 'Aprobado'}">
                                                <form action="../acciones_coordinador.jsp" method="POST">
                                                    <input type="hidden" name="accion" value="finalizar_proyecto">
                                                    <input type="hidden" name="id_proyecto" value="${seg.proyecto_id}">
                                                    <button type="submit" class="btn btn-warning btn-sm font-weight-bold">DAR AVAL FINAL</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn btn-dark btn-sm text-muted" disabled style="font-size: 0.7rem; border: 1px solid #333;">PENDIENTE AVALES</button>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <%-- TABLA GENERAL DE PROYECTOS --%>
            <div class="card-dark p-4">
                <h6 class="text-muted small font-weight-bold mb-4">TODOS LOS PROYECTOS</h6>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>CÓDIGO</th>
                                <th>PROYECTO</th> <th>DESCRIPCION</th>
                                <th>FACULTAD</th> <th>ESTADO</th>
                                <th>ASIGNACIONES</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${misProyectos.rows}">
                                <tr>
                                    <td class="text-warning font-weight-bold">${p.codigo_proyecto}</td>
                                    <td class="text-white font-weight-bold small">${p.nombre_proyecto}</td>
                                    <td class="text-white font-weight-bold">${p.descripcion}</td>
                                    <td class="text-white font-weight-bold small">${p.facultad}</td>
                                    <td style="text-align: center;">
                                        <span class="badge-status ${p.estado == 'Asignado' || p.estado == 'Finalizado' ? 'badge-success' : 'badge-info'}">${p.estado}</span>
                                    </td>
                                    <td>
                                        <c:if test="${not empty p.nombre_estudiante}">
                                            <c:choose>
                                                <c:when test="${p.director_id > 0 && p.evaluador_id > 0}">
                                                    <div class="bg-dark p-2 rounded mt-2 border border-secondary" style="opacity: 0.85;">
                                                        <div class="form-row">
                                                            <div class="col">
                                                                <label class="mb-0" style="font-size: 0.6rem; color: #28a745;">DIRECTOR <i class="fas fa-lock small"></i></label>
                                                                <c:forEach var="d" items="${listaDirectores.rows}">
                                                                    <c:if test="${p.director_id == d.id}"><div class="text-white small">${d.nombre_director}</div></c:if>
                                                                </c:forEach>
                                                            </div>
                                                            <div class="col">
                                                                <label class="mb-0" style="font-size: 0.6rem; color: #28a745;">EVALUADOR <i class="fas fa-lock small"></i></label>
                                                                <c:forEach var="ev" items="${listaEvaluadores.rows}">
                                                                    <c:if test="${p.evaluador_id == ev.id}"><div class="text-white small">${ev.nombre_evaluador}</div></c:if>
                                                                </c:forEach>
                                                            </div>
                                                            <div class="col">
                                                                <label class="mb-0" style="font-size: 0.6rem; color: #28a745;">ESTUDIANTE <i class="fas fa-lock small"></i></label>
                                                                <div class="text-white small">${p.nombre_estudiante}</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="../acciones_coordinador.jsp" method="POST" class="bg-dark p-2 rounded mt-2">
                                                        <input type="hidden" name="accion" value="asignar_personal">
                                                        <input type="hidden" name="id_proyecto" value="${p.id}">
                                                        <div class="form-row align-items-end">
                                                            <div class="col">
                                                                <label class="mb-1" style="font-size: 0.6rem;">DIRECTOR</label>
                                                                <select name="id_director" class="form-control form-control-sm border-secondary" required>
                                                                    <option value="">--</option>
                                                                    <c:forEach var="d" items="${listaDirectores.rows}"><option value="${d.id}">${d.nombre_director}</option></c:forEach>
                                                                </select>
                                                            </div>
                                                            <div class="col">
                                                                <label class="mb-1" style="font-size: 0.6rem;">EVALUADOR</label>
                                                                <select name="id_evaluador" class="form-control form-control-sm border-secondary" required>
                                                                    <option value="">--</option>
                                                                    <c:forEach var="ev" items="${listaEvaluadores.rows}"><option value="${ev.id}">${ev.nombre_evaluador}</option></c:forEach>
                                                                </select>
                                                            </div>
                                                            <div class="col-auto">
                                                                <button type="submit" class="btn btn-warning btn-sm" style="height:31px;"><i class="fas fa-save"></i></button>
                                                            </div>
                                                        </div>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
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
</div>
</body>
</html>