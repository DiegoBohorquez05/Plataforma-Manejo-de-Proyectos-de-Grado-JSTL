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

<%-- CONSULTA: Historial y Verificación de Aval de Coordinador --%>
<c:if test="${proyectoAsignado.rowCount > 0}">
    <sql:query dataSource="${ds}" var="historialDocs">
        SELECT * FROM documentos_proyecto 
        WHERE proyecto_id = ? 
        ORDER BY fecha_subida DESC
        <sql:param value="${proyectoAsignado.rows[0].id}" />
    </sql:query>
    
    <%-- Variable para saber si ya existe un aval del coordinador en cualquier documento --%>
    <c:set var="proyectoFinalizadoPorCoordinador" value="false" />
    <c:forEach var="check" items="${historialDocs.rows}">
        <c:if test="${check.estado_coordinador == 'Aprobado'}">
            <c:set var="proyectoFinalizadoPorCoordinador" value="true" />
        </c:if>
    </c:forEach>
</c:if>

<%-- CONSULTA: Solicitudes y Disponibles (Sin cambios) --%>
<sql:query dataSource="${ds}" var="miSolicitud">
    SELECT s.*, p.nombre_proyecto FROM solicitudes_proyectos s
    JOIN proyectos p ON s.proyecto_id = p.id
    WHERE s.estudiante_id = ? AND s.estado = 'Pendiente'
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<sql:query dataSource="${ds}" var="proyectosDisponibles">
    SELECT * FROM proyectos WHERE estado = 'Disponible' ORDER BY id DESC
</sql:query>

<sql:query dataSource="${ds}" var="listaEstudiantes">
    SELECT id, nombre_estudiante FROM estudiantes WHERE id != ? 
    AND id NOT IN (SELECT IFNULL(estudiante_id, 0) FROM proyectos)
    AND id NOT IN (SELECT IFNULL(companero1_id, 0) FROM proyectos)
    AND id NOT IN (SELECT IFNULL(companero2_id, 0) FROM proyectos)
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Estudiante | Proyectos</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        :root { --accent: #ffc107; --bg-dark: #0d0d0d; --card-bg: #161616; --border: #333; }
        body { background-color: var(--bg-dark); color: #e0e0e0; font-family: 'Segoe UI', sans-serif; }
        .navbar-custom { background-color: var(--card-bg); border-bottom: 1px solid var(--border); padding: 1rem 2rem; }
        .card-proyecto { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 12px; padding: 20px; transition: 0.3s; height: 100%; }
        .badge-facultad { background-color: #333; color: #ddd; font-size: 0.7rem; padding: 4px 10px; border-radius: 4px; text-transform: uppercase; }
        .input-drive { background-color: #0d0d0d !important; border: 1px solid #444 !important; color: white !important; font-size: 0.8rem; }
        .info-label { font-size: 0.65rem; color: var(--accent); font-weight: 800; letter-spacing: 1px; text-transform: uppercase; display: block; margin-bottom: 2px; }
        .table-docs { background-color: #111; border-radius: 8px; overflow: hidden; }
        .table-docs th { border-top: none; color: var(--accent); font-size: 0.7rem; text-transform: uppercase; }
        .cartel-exito {
            background: linear-gradient(45deg, #1e7e34, #28a745);
            border: 2px solid #fff; color: white; padding: 30px;
            border-radius: 15px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.5); margin: 20px 0;
        }
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
    <h6 class="text-muted small font-weight-bold mb-3">MI PROYECTO ASIGNADO</h6>
    <div class="row mb-5">
        <div class="col-12">
            <c:choose>
                <c:when test="${proyectoAsignado.rowCount > 0}">
                    <c:set var="miP" value="${proyectoAsignado.rows[0]}" />
                    <div class="card-proyecto" style="border-left: 5px solid ${proyectoFinalizadoPorCoordinador ? '#28a745' : '#ffc107'};">
                        
                        <h4 class="text-white mb-1">
                            ${miP.nombre_proyecto} 
                            <c:if test="${proyectoFinalizadoPorCoordinador}">
                                <span class="badge badge-success ml-2 small"><i class="fas fa-check-double mr-1"></i> AVALADO POR COORDINACIÓN</span>
                            </c:if>
                        </h4>
                        <span class="badge-facultad">${miP.facultad}</span>
                        
                        <div class="mt-4 row">
                            <div class="col-md-3">
                                <label class="info-label">DIRECTOR</label>
                                <span class="text-white small">${not empty miP.nombre_director ? miP.nombre_director : 'Pendiente'}</span>
                            </div>
                            <div class="col-md-3">
                                <label class="info-label">EVALUADOR</label>
                                <span class="text-white small">${not empty miP.nombre_evaluador ? miP.nombre_evaluador : 'Pendiente'}</span>
                            </div>
                        </div>

                        <div class="mt-5 pt-4" style="border-top: 1px solid #333;">
                            <c:choose>
                                <%-- BLOQUEO BASADO EN EL AVAL DEL COORDINADOR --%>
                                <c:when test="${proyectoFinalizadoPorCoordinador}">
                                    <div class="cartel-exito">
                                        <i class="fas fa-trophy fa-3x mb-3 text-warning"></i>
                                        <h2 class="font-weight-bold">PROYECTO APROBADO POR COORDINACIÓN</h2>
                                        <h4 class="mt-2">RECEPCIÓN DE ARCHIVOS CERRADA</h4>
                                    </div>
                                </c:when>
                                <c:otherwise>
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
                                </c:otherwise>
                            </c:choose>

                            <div class="table-responsive mt-3">
                                <table class="table table-dark table-docs mb-0">
                                    <thead>
                                        <tr>
                                            <th>Fecha</th>
                                            <th>Documento</th>
                                            <th>Aval Director</th>
                                            <th>Aval Evaluador</th>
                                            <th>Aval Coordinador</th>
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
                                                <td><span class="badge ${doc.estado_coordinator == 'Aprobado' ? 'badge-success' : 'badge-danger'}">${doc.estado_coordinador}</span></td>
                                                <td class="text-right"><a href="${doc.link_drive}" target="_blank" class="btn btn-outline-warning btn-sm"><i class="fas fa-external-link-alt"></i></a></td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card-proyecto bg-dark text-center py-5">
                        <p class="text-muted">No tienes proyectos asignados.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
</body>
</html>