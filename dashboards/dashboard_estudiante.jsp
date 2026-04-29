<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. CONSULTA: Proyecto Asignado --%>
<sql:query dataSource="${ds}" var="proyectoAsignado">
    SELECT 
        p.*, 
        d.nombre_director, 
        ev.nombre_evaluador,
        e.nombre_estudiante AS nombre_principal,
        c1.nombre_estudiante AS nombre_comp1,
        c2.nombre_estudiante AS nombre_comp2
    FROM proyectos p
    LEFT JOIN directores d ON p.director_id = d.id
    LEFT JOIN evaluadores ev ON p.evaluador_id = ev.id
    LEFT JOIN estudiantes e ON p.estudiante_id = e.id
    LEFT JOIN estudiantes c1 ON p.companero1_id = c1.id
    LEFT JOIN estudiantes c2 ON p.companero2_id = c2.id
    WHERE p.estudiante_id = ? OR p.companero1_id = ? OR p.companero2_id = ?
    LIMIT 1
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- CONSULTA: Historial de documentos --%>
<c:if test="${proyectoAsignado.rowCount > 0}">
    <sql:query dataSource="${ds}" var="historialDocs">
        SELECT 
            dp.id AS doc_id,
            dp.nombre_documento,
            dp.link_drive,
            dp.fecha_subida,
            dp.estado_director,
            dp.estado_evaluador
        FROM documentos_proyecto dp
        WHERE dp.proyecto_id = ? 
        ORDER BY dp.fecha_subida DESC
        <sql:param value="${proyectoAsignado.rows[0].id}" />
    </sql:query>
</c:if>

<%-- CONSULTA: Solicitudes enviadas (Para el marcador de seguimiento) --%>
<sql:query dataSource="${ds}" var="miSolicitud">
    SELECT s.*, p.nombre_proyecto FROM solicitudes_proyectos s
    JOIN proyectos p ON s.proyecto_id = p.id
    WHERE s.estudiante_id = ? AND s.estado = 'Pendiente'
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<sql:query dataSource="${ds}" var="proyectosDisponibles">
    SELECT * FROM proyectos WHERE estado = 'Disponible' ORDER BY id DESC
</sql:query>

<%-- FILTRO DE ESTUDIANTES: Solo muestra los que están libres (Sin proyecto y sin solicitud activa) --%>
<sql:query dataSource="${ds}" var="listaEstudiantes">
    SELECT id, nombre_estudiante 
    FROM estudiantes 
    WHERE id != ? 
    AND id NOT IN (SELECT IFNULL(estudiante_id, 0) FROM proyectos)
    AND id NOT IN (SELECT IFNULL(companero1_id, 0) FROM proyectos)
    AND id NOT IN (SELECT IFNULL(companero2_id, 0) FROM proyectos)
    AND id NOT IN (SELECT IFNULL(estudiante_id, 0) FROM solicitudes_proyectos WHERE estado IN ('Pendiente', 'Aprobada'))
    AND id NOT IN (SELECT IFNULL(companero1_id, 0) FROM solicitudes_proyectos WHERE estado IN ('Pendiente', 'Aprobada'))
    AND id NOT IN (SELECT IFNULL(companero2_id, 0) FROM solicitudes_proyectos WHERE estado IN ('Pendiente', 'Aprobada'))
    ORDER BY nombre_estudiante ASC
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Estudiante | Proyectos</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        :root { --accent: #ffc107; --bg-dark: #0d0d0d; --card-bg: #161616; --border: #333; }
        body { background-color: var(--bg-dark); color: #e0e0e0; font-family: 'Segoe UI', sans-serif; }
        .navbar-custom { background-color: var(--card-bg); border-bottom: 1px solid var(--border); padding: 1rem 2rem; }
        .card-proyecto { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 12px; padding: 20px; transition: 0.3s; height: 100%; }
        .card-proyecto:hover { border-color: var(--accent); transform: translateY(-5px); }
        .badge-facultad { background-color: #333; color: #ddd; font-size: 0.7rem; padding: 4px 10px; border-radius: 4px; text-transform: uppercase; }
        .btn-tomar { background-color: var(--accent); color: #000; font-weight: 700; border-radius: 8px; border: none; padding: 10px; }
        .input-drive { background-color: #0d0d0d !important; border: 1px solid #444 !important; color: white !important; font-size: 0.8rem; }
        .info-label { font-size: 0.65rem; color: var(--accent); font-weight: 800; letter-spacing: 1px; text-transform: uppercase; display: block; margin-bottom: 2px; }
        .table-docs { background-color: #111; border-radius: 8px; overflow: hidden; }
        .table-docs th { border-top: none; color: var(--accent); font-size: 0.7rem; text-transform: uppercase; }
        .table-docs td { vertical-align: middle; border-color: #222; font-size: 0.85rem; }
    </style>
</head>
<body>

<nav class="navbar-custom d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0 font-weight-bold">Panel <span class="text-warning">Estudiante</span></h4>
    <div class="d-flex align-items-center">
        <span class="text-muted small mr-3">Bienvenido, ${sessionScope.usuarioLogueado.nombre_estudiante}</span>
        <a href="../logout.jsp" class="btn btn-outline-danger btn-sm px-4">Cerrar Sesión</a>
    </div>
</nav>

<div class="container-fluid px-5">
    
    <%-- SECCIÓN: MARCADOR DE SEGUIMIENTO --%>
    <c:if test="${proyectoAsignado.rowCount == 0 && miSolicitud.rowCount > 0}">
        <div class="card-proyecto mb-5" style="border: 1px solid var(--accent); background: linear-gradient(45deg, #161616, #1a1a10);">
            <h6 class="info-label">ESTADO DE TU SOLICITUD ENVIADA</h6>
            <div class="d-flex align-items-center justify-content-between mt-3">
                <div>
                    <h4 class="text-white">${miSolicitud.rows[0].nombre_proyecto}</h4>
                    <p class="text-muted small">Enviada el: ${miSolicitud.rows[0].fecha_solicitud}</p>
                </div>
                <div class="text-center">
                    <div class="spinner-border text-warning spinner-border-sm mb-2"></div>
                    <span class="d-block badge badge-warning px-3 py-2">PENDIENTE DE REVISIÓN</span>
                    <small class="text-muted d-block mt-1">El coordinador está evaluando tu propuesta</small>
                </div>
            </div>
        </div>
    </c:if>

    <h6 class="text-muted small font-weight-bold mb-3">MI PROYECTO ASIGNADO</h6>
    <div class="row mb-5">
        <div class="col-12">
            <c:choose>
                <c:when test="${proyectoAsignado.rowCount > 0}">
                    <c:set var="miP" value="${proyectoAsignado.rows[0]}" />
                    <div class="card-proyecto" style="border-left: 5px solid #28a745;">
                        <div class="d-flex justify-content-between">
                            <div class="flex-grow-1">
                                <h4 class="text-white mb-1">${miP.nombre_proyecto}</h4>
                                <span class="badge-facultad">${miP.facultad}</span>
                                <p class="text-muted mt-3">${miP.descripcion}</p>
                                
                                <div class="mt-4 row">
                                    <div class="col-md-3">
                                        <label class="info-label">DIRECTOR</label>
                                        <span class="text-white small"><i class="fas fa-user-tie mr-2 text-muted"></i>${not empty miP.nombre_director ? miP.nombre_director : 'Pendiente'}</span>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="info-label">EVALUADOR</label>
                                        <span class="text-white small"><i class="fas fa-search mr-2 text-muted"></i>${not empty miP.nombre_evaluador ? miP.nombre_evaluador : 'Pendiente'}</span>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="info-label">INTEGRANTES DEL GRUPO</label>
                                        <div class="text-white small">
                                            <i class="fas fa-users mr-2 text-muted"></i>
                                            ${miP.nombre_principal}${not empty miP.nombre_comp1 ? ', '.concat(miP.nombre_comp1) : ''}${not empty miP.nombre_comp2 ? ', '.concat(miP.nombre_comp2) : ''}
                                        </div>
                                    </div>
                                </div>

                                <div class="mt-5 pt-4" style="border-top: 1px solid #333;">
                                    <h6 class="text-white font-weight-bold mb-3 small"><i class="fas fa-file-upload mr-2 text-warning"></i> ENTREGAR AVANCE</h6>
                                    <form action="../acciones_estudiante.jsp" method="POST" class="row no-gutters mb-4">
                                        <input type="hidden" name="accion" value="subir_documento">
                                        <input type="hidden" name="id_proyecto" value="${miP.id}">
                                        <div class="col-md-4 pr-2">
                                            <input type="text" name="txtNombreDoc" class="form-control input-drive" placeholder="Nombre de la entrega" required>
                                        </div>
                                        <div class="col-md-6 pr-2">
                                            <input type="url" name="txtLinkDrive" class="form-control input-drive" placeholder="URL de Google Drive" required>
                                        </div>
                                        <div class="col-md-2">
                                            <button type="submit" class="btn btn-warning btn-block btn-sm font-weight-bold" style="height: 35px;">ENTREGAR</button>
                                        </div>
                                    </form>

                                    <div class="table-responsive">
                                        <table class="table table-dark table-docs mb-0">
                                            <thead>
                                                <tr>
                                                    <th>Fecha</th>
                                                    <th>Documento</th>
                                                    <th>Aval Director</th>
                                                    <th>Aval Evaluador</th>
                                                    <th class="text-right">Link</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="doc" items="${historialDocs.rows}">
                                                    <tr>
                                                        <td class="text-muted small">${doc.fecha_subida}</td>
                                                        <td class="font-weight-bold">${doc.nombre_documento}</td>
                                                        <td><span class="badge ${doc.estado_director == 'Aprobado' ? 'badge-success' : 'badge-warning'}">${doc.estado_director}</span></td>
                                                        <td><span class="badge ${doc.estado_evaluador == 'Aprobado' ? 'badge-success' : 'badge-warning'}">${doc.estado_evaluador}</span></td>
                                                        <td class="text-right"><a href="${doc.link_drive}" target="_blank" class="btn btn-outline-warning btn-sm"><i class="fas fa-external-link-alt"></i></a></td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card-proyecto bg-dark text-center py-5" style="border: 1px dashed #444;">
                        <i class="fas fa-folder-open fa-3x text-muted mb-3"></i>
                        <p class="mb-0 text-muted">No tienes proyectos asignados actualmente.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <h6 class="text-muted small font-weight-bold mb-3">PROYECTOS DISPONIBLES</h6>
    <div class="row">
        <c:forEach var="p" items="${proyectosDisponibles.rows}">
            <div class="col-md-4 mb-4">
                <div class="card-proyecto">
                    <h5 class="text-white font-weight-bold mb-2">${p.nombre_proyecto}</h5>
                    <span class="badge-facultad">${p.facultad}</span>
                    <p class="text-muted small mt-3" style="height: 50px; overflow: hidden;">${p.descripcion}</p>
                    <hr style="border-color: #333;">
                    <c:choose>
                        <c:when test="${proyectoAsignado.rowCount == 0 && miSolicitud.rowCount == 0}">
                            <form action="../acciones_estudiante.jsp" method="POST">
                                <input type="hidden" name="accion" value="enviar_solicitud">
                                <input type="hidden" name="id_proyecto" value="${p.id}">
                                <input type="url" name="txtLink" class="form-control input-drive mb-2" placeholder="Link Propuesta" required>
                                <div class="row mb-2">
                                    <div class="col-6">
                                        <select name="id_companero1" class="form-control input-drive py-0 small" style="height: 30px;">
                                            <option value="">Compañero 1</option>
                                            <c:forEach var="est" items="${listaEstudiantes.rows}"><option value="${est.id}">${est.nombre_estudiante}</option></c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-6">
                                        <select name="id_companero2" class="form-control input-drive py-0 small" style="height: 30px;">
                                            <option value="">Compañero 2</option>
                                            <c:forEach var="est" items="${listaEstudiantes.rows}"><option value="${est.id}">${est.nombre_estudiante}</option></c:forEach>
                                        </select>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-tomar btn-block">SOLICITAR PROYECTO</button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <button class="btn btn-secondary btn-block disabled" disabled>OPCIÓN BLOQUEADA</button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:forEach>
    </div>
</div>
</body>
</html>