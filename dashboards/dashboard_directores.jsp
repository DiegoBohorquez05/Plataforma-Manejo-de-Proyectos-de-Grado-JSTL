<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. CONSULTA: Traer los documentos de los proyectos que este director tiene a cargo --%>
<sql:query dataSource="${ds}" var="docsAsignados">
    SELECT 
        dp.id AS doc_id,
        dp.nombre_documento,
        dp.link_drive,
        dp.fecha_subida,
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
    <title>Panel Director | Revisión de Proyectos</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        :root { --accent: #ffc107; --bg-dark: #0d0d0d; --card-bg: #161616; --border: #333; }
        body { background-color: var(--bg-dark); color: #e0e0e0; font-family: 'Segoe UI', sans-serif; }
        
        .navbar-custom { background-color: var(--card-bg); border-bottom: 1px solid var(--border); padding: 1rem 2rem; }
        
        /* Estilo de Tabla tipo Coordinador */
        .table-custom { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 12px; overflow: hidden; }
        .table-custom thead { background-color: #1a1a1a; }
        .table-custom th { border: none; color: var(--accent); font-size: 0.75rem; text-transform: uppercase; letter-spacing: 1px; padding: 20px; }
        .table-custom td { border-top: 1px solid #222; vertical-align: middle; padding: 20px; font-size: 0.9rem; }
        
        .btn-review { background-color: var(--accent); color: #000; font-weight: 700; border: none; border-radius: 6px; padding: 8px 15px; transition: 0.3s; }
        .btn-review:hover { background-color: #e0a800; transform: scale(1.05); }
        
        .project-name { font-weight: 700; color: #fff; display: block; }
        .student-name { font-size: 0.8rem; color: #888; }
        .doc-badge { background: #333; color: #fff; padding: 4px 10px; border-radius: 4px; font-size: 0.75rem; }
    </style>
</head>
<body>

<nav class="navbar-custom d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0 font-weight-bold">Panel <span class="text-warning">Director</span></h4>
    <div class="d-flex align-items-center">
        <span class="text-muted small mr-3">Director: ${sessionScope.usuarioLogueado.nombre_director}</span>
        <a href="../logout.jsp" class="btn btn-outline-danger btn-sm px-4">Cerrar Sesión</a>
    </div>
</nav>

<div class="container-fluid px-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h5 class="mb-1 text-white">Documentos por Revisar</h5>
            <p class="text-muted small">Listado de avances subidos por los estudiantes de sus proyectos asignados.</p>
        </div>
        <div class="text-right">
            <span class="badge badge-warning p-2 px-3">${docsAsignados.rowCount} PENDIENTES</span>
        </div>
    </div>

    <%-- TABLA DE REVISIÓN --%>
    <div class="table-custom shadow-lg">
        <table class="table table-dark mb-0">
            <thead>
                <tr>
                    <th>Proyecto / Estudiante</th>
                    <th>Documento</th>
                    <th>Fecha de Entrega</th>
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
                        <td class="text-muted small">
                            ${doc.fecha_subida}
                        </td>
                        <td class="text-center">
                            <a href="${doc.link_drive}" target="_blank" class="btn-review text-decoration-none">
                                <i class="fas fa-external-link-alt mr-1"></i> REVISAR DRIVE
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                
                <c:if test="${docsAsignados.rowCount == 0}">
                    <tr>
                        <td colspan="4" class="text-center py-5 text-muted">
                            <i class="fas fa-folder-open fa-3x mb-3 d-block"></i>
                            No hay documentos pendientes de revisión en sus proyectos.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>