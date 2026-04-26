<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. CONSULTA: Trae el proyecto donde el usuario sea dueño o compañero, incluyendo todos los nombres --%>
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
    LEFT JOIN estudiantes c1 ON p.compañero1_id = c1.id
    LEFT JOIN estudiantes c2 ON p.compañero2_id = c2.id
    WHERE p.estudiante_id = ? OR p.compañero1_id = ? OR p.compañero2_id = ?
    LIMIT 1
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 2. CONSULTA: Solicitudes pendientes enviadas por el usuario --%>
<sql:query dataSource="${ds}" var="miSolicitud">
    SELECT s.*, p.nombre_proyecto 
    FROM solicitudes_proyectos s
    JOIN proyectos p ON s.proyecto_id = p.id
    WHERE s.estudiante_id = ? AND s.estado = 'Pendiente'
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 3. CONSULTA: Proyectos que nadie ha tomado --%>
<sql:query dataSource="${ds}" var="proyectosDisponibles">
    SELECT * FROM proyectos 
    WHERE estado = 'Disponible' 
    ORDER BY id DESC
</sql:query>

<%-- 4. CONSULTA: Lista para el formulario de compañeros --%>
<sql:query dataSource="${ds}" var="listaEstudiantes">
    SELECT id, nombre_estudiante FROM estudiantes WHERE id != ?
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
        .btn-tomar { background-color: var(--accent); color: #000; font-weight: 700; border-radius: 8px; border: none; padding: 10px; transition: 0.3s; }
        .input-drive { background-color: #0d0d0d !important; border: 1px solid #444 !important; color: white !important; font-size: 0.8rem; }
        .info-label { font-size: 0.65rem; color: var(--accent); font-weight: 800; letter-spacing: 1px; text-transform: uppercase; display: block; margin-bottom: 2px; }
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
                                            <c:set var="hayContenido" value="false" />
                                            
                                            <%-- Mostrar a todos los integrantes sin filtros --%>
                                            <c:if test="${not empty miP.nombre_principal}">
                                                ${miP.nombre_principal}
                                                <c:set var="hayContenido" value="true" />
                                            </c:if>
                                            
                                            <c:if test="${not empty miP.nombre_comp1}">
                                                ${hayContenido ? ', ' : ''} ${miP.nombre_comp1}
                                                <c:set var="hayContenido" value="true" />
                                            </c:if>
                                            
                                            <c:if test="${not empty miP.nombre_comp2}">
                                                ${hayContenido ? ', ' : ''} ${miP.nombre_comp2}
                                                <c:set var="hayContenido" value="true" />
                                            </c:if>

                                            <c:if test="${!hayContenido}">
                                                <span class="text-muted font-italic">SIN COMPAÑEROS</span>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="text-right ml-4">
                                <span class="badge badge-success px-3 py-2">ASIGNADO OFICIALMENTE</span>
                                <h5 class="text-warning mt-3">${miP.codigo_proyecto}</h5>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card-proyecto bg-dark text-center py-4" style="border: 1px dashed #444;">
                        <p class="mb-0 text-muted">No tienes proyectos asignados actualmente.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <h6 class="text-muted small font-weight-bold mb-3">LISTA DE PROYECTOS DISPONIBLES</h6>
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
                                
                                <div class="form-group mb-2">
                                    <label class="small text-muted mb-1">LINK GOOGLE DRIVE</label>
                                    <input type="url" name="txtLink" class="form-control input-drive" required>
                                </div>
                                
                                <div class="row mb-3">
                                    <div class="col-6">
                                        <label class="small text-muted mb-1">COMPAÑERO 1</label>
                                        <select name="id_companero1" class="form-control input-drive py-0" style="height: 30px;">
                                            <option value="">Ninguno</option>
                                            <c:forEach var="est" items="${listaEstudiantes.rows}">
                                                <option value="${est.id}">${est.nombre_estudiante}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-6">
                                        <label class="small text-muted mb-1">COMPAÑERO 2</label>
                                        <select name="id_companero2" class="form-control input-drive py-0" style="height: 30px;">
                                            <option value="">Ninguno</option>
                                            <c:forEach var="est" items="${listaEstudiantes.rows}">
                                                <option value="${est.id}">${est.nombre_estudiante}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="text-warning font-weight-bold">${p.codigo_proyecto}</span>
                                    <button type="submit" class="btn btn-tomar px-4">SOLICITAR</button>
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