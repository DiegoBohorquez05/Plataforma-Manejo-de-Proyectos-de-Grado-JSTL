<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- CONSULTA: Traemos el ID principal de documentos_proyecto --%>
<sql:query dataSource="${ds}" var="docsAsignados">
    SELECT 
        dp.id, 
        dp.nombre_documento, 
        dp.link_drive,
        dp.estado_director, 
        p.nombre_proyecto, 
        e.nombre_estudiante 
    FROM documentos_proyecto dp
    JOIN proyectos p ON dp.proyecto_id = p.id
    JOIN estudiantes e ON p.estudiante_id = e.id
    WHERE p.director_id = ?
    ORDER BY dp.fecha_subida DESC
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Director | Gestión de Proyectos</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        :root { --accent: #ffc107; --bg-dark: #0d0d0d; --card-bg: #161616; --border: #333; }
        body { background-color: var(--bg-dark); color: #e0e0e0; font-family: 'Segoe UI', sans-serif; }
        
        .navbar-custom { background-color: var(--card-bg); border-bottom: 1px solid var(--border); padding: 1rem 2rem; }
        
        .table-custom { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 12px; overflow: hidden; }
        .table-custom thead { background-color: #1a1a1a; }
        .table-custom th { border: none; color: var(--accent); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 1px; padding: 20px; }
        .table-custom td { border-top: 1px solid #222; vertical-align: middle; padding: 20px; font-size: 0.9rem; }
        
        .btn-review { background-color: var(--accent); color: #000; font-weight: 700; border: none; border-radius: 6px; padding: 8px 15px; transition: 0.3s; cursor: pointer; }
        .btn-review:hover { background-color: #e0a800; transform: scale(1.05); text-decoration: none; color: #000; }
        
        .project-name { font-weight: 700; color: #fff; display: block; }
        .student-name { font-size: 0.8rem; color: #888; }
        .doc-badge { background: #333; color: #fff; padding: 4px 10px; border-radius: 4px; font-size: 0.75rem; }
        
        .bg-black { background-color: #000 !important; }
        .modal-content { border-radius: 15px; }
        
        .badge-aprobado { background-color: #28a745; color: white; padding: 5px 10px; }
        .badge-corregir { background-color: #dc3545; color: white; padding: 5px 10px; }
        .badge-pendiente { background-color: #6c757d; color: white; padding: 5px 10px; }
    </style>
</head>
<body>

<nav class="navbar-custom d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0 font-weight-bold">Panel <span class="text-warning">Director</span></h4>
    <div class="d-flex align-items-center">
        <span class="text-muted small mr-3"><i class="fas fa-user-tie mr-1"></i> ${sessionScope.usuarioLogueado.nombre_director}</span>
        <a href="../logout.jsp" class="btn btn-outline-danger btn-sm px-4 font-weight-bold">SALIR</a>
    </div>
</nav>

<div class="container-fluid px-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h5 class="mb-1 text-white">Documentos Entregados</h5>
            <p class="text-muted small">Visualice y califique el progreso de sus estudiantes.</p>
        </div>
        <div class="text-right">
            <span class="badge badge-warning p-2 px-3">${docsAsignados.rowCount} ASIGNACIONES</span>
        </div>
    </div>

    <div class="table-custom shadow-lg">
        <table class="table table-dark mb-0">
            <thead>
                <tr>
                    <th>Proyecto / Estudiante</th>
                    <th>Documento</th>
                    <th>Estado Director</th>
                    <th class="text-center">Acciones</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="doc" items="${docsAsignados.rows}">
                    <tr>
                        <td>
                            <span class="project-name">${doc.nombre_proyecto}</span>
                            <span class="student-name"><i class="fas fa-user mr-1"></i> ${doc.nombre_estudiante}</span>
                        </td>
                        <td>
                            <span class="doc-badge">
                                <i class="fas fa-file-alt mr-2 text-warning"></i>${doc.nombre_documento}
                            </span>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${doc.estado_director == 'Aprobado'}">
                                    <span class="badge badge-aprobado"><i class="fas fa-check-circle mr-1"></i> APROBADO</span>
                                </c:when>
                                <c:when test="${doc.estado_director == 'Corregir'}">
                                    <span class="badge badge-corregir"><i class="fas fa-exclamation-circle mr-1"></i> CORREGIR</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-pendiente"><i class="fas fa-clock mr-1"></i> ${doc.estado_director}</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <div class="btn-group">
                                <a href="${doc.link_drive}" target="_blank" class="btn btn-outline-light btn-sm mr-2" title="Ver en Drive">
                                    <i class="fas fa-external-link-alt"></i>
                                </a>
                                <button type="button" class="btn-review" data-toggle="modal" data-target="#modal${doc.id}">
                                    CALIFICAR
                                </button>
                            </div>
                        </td>
                    </tr>

                    <%-- MODAL DE CALIFICACIÓN --%>
                    <div class="modal fade" id="modal${doc.id}" tabindex="-1" role="dialog">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content bg-dark border-secondary text-white shadow-lg">
                                <div class="modal-header border-secondary">
                                    <h5 class="modal-title text-warning">Calificar Documento #${doc.id}</h5>
                                    <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
                                </div>
                                <%-- LÓGICA DE ENVÍO QUE FUNCIONÓ --%>
                                <form action="../acciones_director.jsp?id_documento=${doc.id}" method="POST">
                                    <div class="modal-body">
                                        <div class="form-group">
                                            <label class="text-warning small font-weight-bold">SELECCIONAR NUEVO ESTADO</label>
                                            <select name="txtEstado" class="form-control bg-black text-white border-secondary" required>
                                                <option value="Aprobado" ${doc.estado_director == 'Aprobado' ? 'selected' : ''}>Aprobado</option>
                                                <option value="Corregir" ${doc.estado_director == 'Corregir' ? 'selected' : ''}>Requiere Correcciones</option>
                                                <option value="Pendiente" ${doc.estado_director == 'Pendiente' ? 'selected' : ''}>Pendiente</option>
                                            </select>
                                        </div>
                                        <p class="text-muted small">Al guardar, el estudiante podrá visualizar el estado actualizado de su entrega.</p>
                                    </div>
                                    <div class="modal-footer border-secondary">
                                        <button type="button" class="btn btn-outline-light btn-sm px-4" data-dismiss="modal">Cerrar</button>
                                        <button type="submit" class="btn btn-warning btn-sm font-weight-bold px-4">GUARDAR CAMBIOS</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>