<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. CONSULTA: Verificar si el estudiante ya tiene un proyecto aprobado --%>
<sql:query dataSource="${ds}" var="proyectoAsignado">
    SELECT * FROM proyectos 
    WHERE estudiante_id = ? 
    LIMIT 1
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 2. CONSULTA: Ver estado de la solicitud pendiente (si envió una) --%>
<sql:query dataSource="${ds}" var="miSolicitud">
    SELECT s.*, p.nombre_proyecto 
    FROM solicitudes_proyectos s
    JOIN proyectos p ON s.proyecto_id = p.id
    WHERE s.estudiante_id = ? AND s.estado = 'Pendiente'
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 3. CONSULTA: Proyectos disponibles para solicitar --%>
<sql:query dataSource="${ds}" var="proyectosDisponibles">
    SELECT * FROM proyectos 
    WHERE estado = 'Disponible' 
    ORDER BY id DESC
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
        .btn-tomar { background-color: var(--accent); color: #000; font-weight: 700; border-radius: 8px; border: none; padding: 10px; transition: 0.3s; }
        .btn-tomar:hover { background-color: #e5ad06; box-shadow: 0 0 15px rgba(255, 193, 7, 0.4); }
        .input-drive { background-color: #0d0d0d !important; border: 1px solid #444 !important; color: white !important; font-size: 0.8rem; }
        .empty-state { background-color: var(--card-bg); border: 1px dashed var(--border); border-radius: 12px; padding: 40px; text-align: center; color: #666; }
    </style>
</head>
<body>

<nav class="navbar-custom d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0 font-weight-bold">Panel <span class="text-warning">Estudiante</span></h4>
    <div class="d-flex align-items-center">
        <%-- Usando el nuevo nombre de columna: nombre_estudiante --%>
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
                    <c:forEach var="miP" items="${proyectoAsignado.rows}">
                        <div class="card-proyecto" style="border-left: 5px solid #28a745;">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h4 class="text-white mb-1">${miP.nombre_proyecto}</h4>
                                    <span class="badge-facultad">${miP.facultad}</span>
                                    <p class="text-muted mt-3">${miP.descripcion}</p>
                                </div>
                                <div class="text-right">
                                    <span class="badge badge-success px-3 py-2">ASIGNADO OFICIALMENTE</span>
                                    <h5 class="text-warning mt-3">${miP.codigo_proyecto}</h5>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <p class="mb-0">No tienes proyectos asignados oficialmente todavía.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <c:if test="${miSolicitud.rowCount > 0}">
        <h6 class="text-warning small font-weight-bold mb-3">SOLICITUD EN REVISIÓN</h6>
        <div class="row mb-5">
            <div class="col-12">
                <div class="card-proyecto" style="border-left: 5px solid var(--accent); opacity: 0.85;">
                    <div class="d-flex justify-content-between align-items-center">
                        <p class="mb-0">Has enviado una solicitud para: <strong>${miSolicitud.rows[0].nombre_proyecto}</strong></p>
                        <span class="badge badge-warning text-dark px-3 py-2 font-weight-bold">PENDIENTE DE APROBACIÓN</span>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

    <h6 class="text-muted small font-weight-bold mb-3">PROYECTOS DISPONIBLES</h6>
    <div class="row">
        <c:forEach var="p" items="${proyectosDisponibles.rows}">
            <div class="col-md-4 mb-4">
                <div class="card-proyecto">
                    <h5 class="text-white font-weight-bold mb-2">${p.nombre_proyecto}</h5>
                    <span class="badge-facultad">${p.facultad}</span>
                    <p class="text-muted small mt-3" style="height: 60px; overflow: hidden;">${p.descripcion}</p>
                    
                    <hr style="border-color: #333;">
                    
                    <%-- Solo permite solicitar si no tiene proyectos ni solicitudes activas --%>
                    <c:choose>
                        <c:when test="${proyectoAsignado.rowCount == 0 && miSolicitud.rowCount == 0}">
                            <form action="../acciones_estudiante.jsp" method="POST">
                                <input type="hidden" name="accion" value="enviar_solicitud">
                                <input type="hidden" name="id_proyecto" value="${p.id}">
                                
                                <div class="form-group mb-2">
                                    <label class="small text-muted mb-1">LINK GOOGLE DRIVE (ANTEPROYECTO)</label>
                                    <input type="url" name="linkDrive" class="form-control input-drive" 
                                           placeholder="https://drive.google.com/..." required>
                                </div>
                                
                                <div class="d-flex justify-content-between align-items-center mt-3">
                                    <span class="text-warning font-weight-bold">${p.codigo_proyecto}</span>
                                    <button type="submit" class="btn btn-tomar px-4">
                                        <i class="fas fa-paper-plane mr-1"></i> SOLICITAR
                                    </button>
                                </div>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <div class="d-flex justify-content-between align-items-center mt-3">
                                <span class="text-warning font-weight-bold">${p.codigo_proyecto}</span>
                                <button class="btn btn-secondary btn-sm disabled" disabled>NO DISPONIBLE</button>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:forEach>
    </div>
</div>

</body>
</html>