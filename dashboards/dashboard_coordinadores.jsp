<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. CONSULTA: Proyectos del coordinador --%>
<sql:query dataSource="${ds}" var="misProyectos">
    SELECT p.*, e.nombre AS nombre_estudiante 
    FROM proyectos p 
    LEFT JOIN estudiantes e ON p.estudiante_id = e.id 
    WHERE p.coordinador_id = ? 
    ORDER BY p.id DESC
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 2. CONSULTA: Solicitudes de estudiantes esperando aprobación --%>
<sql:query dataSource="${ds}" var="solicitudes">
    SELECT s.*, e.nombre AS nombre_estudiante, p.nombre_proyecto 
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
        .table tbody tr { background-color: var(--row-bg); transition: 0.3s; }
        .table tbody td { border: none; padding: 20px; vertical-align: middle; }
        .table tbody td:first-child { border-radius: 10px 0 0 10px; }
        .table tbody td:last-child { border-radius: 0 10px 10px 0; }
        .btn-warning { background-color: var(--accent); border: none; font-weight: 700; border-radius: 10px; text-transform: uppercase; font-size: 0.85rem; }
        .badge-status { padding: 6px 12px; border-radius: 6px; font-size: 0.7rem; font-weight: 800; }
        .badge-success { background-color: #28a745; color: white; }
        .badge-info { background-color: #17a2b8; color: white; }
        .col-codigo { width: 120px; }
        .col-proyecto { max-width: 300px; }
        .col-estado { width: 150px; text-align: center; }
        .col-asignacion { min-width: 450px; }
    </style>
</head>
<body>

<div class="header-section">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <h2 class="mb-0 font-weight-bold">Gestión de <span class="text-warning">Proyectos</span></h2>
        <div class="d-flex align-items-center">
            <span class="mr-3 text-muted small"><i class="fas fa-user-tie mr-1"></i> Coordinador: ${sessionScope.usuarioLogueado.nombre}</span>
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
                    <h6 class="text-warning small font-weight-bold mb-3 uppercase">SOLICITUDES DE ESTUDIANTES POR APROBAR</h6>
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

            <div class="card-dark p-4">
                <h6 class="text-muted small font-weight-bold mb-4">TODOS LOS PROYECTOS</h6>
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th class="col-codigo">Código</th>
                                <th class="col-proyecto">Proyecto</th>
                                <th class="col-estado">Estado</th>
                                <th class="col-asignacion">Asignaciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${misProyectos.rows}">
                                <tr>
                                    <td class="text-warning font-weight-bold">${p.codigo_proyecto}</td>
                                    <td class="col-proyecto text-white font-weight-bold small">${p.nombre_proyecto}</td>
                                    <td class="col-estado">
                                        <span class="badge-status ${p.estado == 'Asignado' ? 'badge-success' : 'badge-info'}">
                                            ${p.estado}
                                        </span>
                                    </td>
                                    <td class="col-asignacion">
                                        <div class="mb-2">
                                            <i class="fas fa-user-graduate mr-2 small text-muted"></i>
                                            <c:choose>
                                                <c:when test="${not empty p.nombre_estudiante}">
                                                    <span class="text-white small font-weight-bold">${p.nombre_estudiante}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted small font-italic">Esperando aprobación...</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <c:if test="${not empty p.nombre_estudiante}">
                                            <form action="../acciones_coordinador.jsp" method="POST" class="bg-dark p-2 rounded mt-2">
                                                <input type="hidden" name="accion" value="asignar_personal">
                                                <input type="hidden" name="id_proyecto" value="${p.id}">
                                                <div class="form-row align-items-end">
                                                    <div class="col">
                                                        <label class="mb-1" style="font-size: 0.6rem;">DIRECTOR</label>
                                                        <select name="id_director" class="form-control form-control-sm bg-dark text-white border-secondary">
                                                            <option value="">Seleccionar...</option>
                                                            <c:forEach var="d" items="${listaDirectores.rows}">
                                                                <option value="${d.id}" ${p.director_id == d.id ? 'selected' : ''}>${d.nombre}</option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="col">
                                                        <label class="mb-1" style="font-size: 0.6rem;">EVALUADOR</label>
                                                        <select name="id_evaluador" class="form-control form-control-sm bg-dark text-white border-secondary">
                                                            <option value="">Seleccionar...</option>
                                                            <c:forEach var="e" items="${listaEvaluadores.rows}">
                                                                <option value="${e.id}" ${p.evaluador_id == e.id ? 'selected' : ''}>${e.nombre}</option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="col-auto">
                                                        <button type="submit" class="btn btn-warning btn-sm" style="height:31px;"><i class="fas fa-save"></i></button>
                                                    </div>
                                                </div>
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
</div>

</body>
</html>