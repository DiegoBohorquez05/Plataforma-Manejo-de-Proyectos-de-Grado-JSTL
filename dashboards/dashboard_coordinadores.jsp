<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<%-- Seguridad: Solo coordinadores --%>
<c:if test="${empty sessionScope.usuarioLogueado || sessionScope.tipoUsuario != 'coordinadores'}">
    <c:redirect url="../login_usuarios.jsp?rol=coordinadores" />
</c:if>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. CONSULTA DE SOLICITUDES PENDIENTES (Corregida para traer el nombre del estudiante) --%>
<sql:query dataSource="${ds}" var="solicitudes">
    SELECT 
        s.id AS id_solicitud, 
        s.archivo_pago, 
        p.nombre_proyecto, 
        p.id AS proy_id, 
        e.nombre AS est_nombre, 
        e.id AS est_id
    FROM solicitudes_proyectos s
    JOIN proyectos p ON s.proyecto_id = p.id
    JOIN estudiantes e ON s.estudiante_id = e.id
    WHERE p.coordinador_id = ? AND s.estado_solicitud = 'Pendiente'
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 2. CONSULTA DE PROYECTOS PROPIOS (Corregida: ORDER BY p.id) --%>
<sql:query dataSource="${ds}" var="misProyectos">
    SELECT p.*, e.nombre AS nombre_estudiante
    FROM proyectos p 
    LEFT JOIN estudiantes e ON p.estudiante_id = e.id 
    WHERE p.coordinador_id = ? 
    ORDER BY p.id DESC
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Coordinador | Gestión de Proyectos</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { background: #0f0f0f; color: #e0e0e0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .card-custom { background: rgba(255,255,255,0.05); border: 1px solid #333; border-radius: 12px; margin-bottom: 25px; }
        .table { color: #e0e0e0; border-bottom: 1px solid #333; }
        .table thead th { border-top: none; border-bottom: 1px solid #444; text-transform: uppercase; font-size: 0.75rem; letter-spacing: 1px; }
        .badge-proceso { background: #fd7e14; color: white; }
        .form-control { background: #1a1a1a; border: 1px solid #444; color: white; }
        .form-control:focus { background: #222; color: white; border-color: #ffc107; box-shadow: none; }
    </style>
</head>
<body>

<div class="container-fluid py-5 px-5">
    <div class="d-flex justify-content-between align-items-center mb-5">
        <div>
            <h2 class="text-warning font-weight-bold">PANEL DE GESTIÓN</h2>
            <p class="text-muted mb-0">Bienvenido, <strong>${sessionScope.usuarioLogueado.nombre}</strong></p>
        </div>
        <a href="../logout.jsp" class="btn btn-outline-danger btn-sm px-4">Cerrar Sesión</a>
    </div>

    <div class="row">
        <div class="col-md-3">
            <div class="card-custom p-4">
                <h6 class="text-warning mb-4"><i class="fas fa-plus-circle mr-2"></i>NUEVO PROYECTO</h6>
                <form action="../acciones_coordinador.jsp" method="POST">
                    <input type="hidden" name="accion" value="crear_proyecto">
                    <div class="form-group small">
                        <label>NOMBRE DEL PROYECTO</label>
                        <input type="text" name="txtNombre" class="form-control form-control-sm" required>
                    </div>
                    <div class="form-group small">
                        <label>CÓDIGO</label>
                        <input type="text" name="txtCodigo" class="form-control form-control-sm" required>
                    </div>
                    <div class="form-group small">
                        <label>FACULTAD</label>
                        <select name="txtFacultad" class="form-control form-control-sm">
                            <option>Ingeniería</option>
                            <option>Ciencias de la Salud</option>
                            <option>Derecho y Ciencias Políticas</option>
                            <option>Artes y Humanidades</option>
                        </select>
                    </div>
                    <div class="form-group small">
                        <label>DESCRIPCIÓN</label>
                        <textarea name="txtDesc" class="form-control form-control-sm" rows="3" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-warning btn-block btn-sm font-weight-bold mt-3">PUBLICAR PROYECTO</button>
                </form>
            </div>
        </div>

        <div class="col-md-9">
            
            <%-- 1. TABLA DE SOLICITUDES PENDIENTES --%>
            <c:if test="${solicitudes.rowCount > 0}">
                <div class="card-custom p-4 border-warning">
                    <h6 class="text-warning mb-4"><i class="fas fa-bell mr-2"></i>SOLICITUDES PENDIENTES POR APROBAR</h6>
                    <div class="table-responsive">
                        <table class="table table-sm small">
                            <thead class="text-muted">
                                <tr>
                                    <th>Estudiante</th>
                                    <th>Proyecto Solicitado</th>
                                    <th>Documento de Pago</th>
                                    <th class="text-center">Acción</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="s" items="${solicitudes.rows}">
                                    <tr>
                                        <td class="align-middle">
                                            <i class="fas fa-user-graduate mr-2 text-muted"></i>
                                            <strong>${s.est_nombre}</strong>
                                        </td>
                                        <td class="align-middle">${s.nombre_proyecto}</td>
                                        <td class="align-middle text-info">
                                            <i class="fas fa-file-pdf mr-1"></i>
                                            <span style="cursor: pointer; text-decoration: underline;">${s.archivo_pago}</span>
                                        </td>
                                        <td class="text-center">
                                            <form action="../acciones_coordinador.jsp" method="POST" class="d-inline">
                                                <input type="hidden" name="accion" value="aprobar_solicitud">
                                                <input type="hidden" name="id_solicitud" value="${s.id_solicitud}">
                                                <input type="hidden" name="id_proyecto" value="${s.proy_id}">
                                                <input type="hidden" name="id_estudiante" value="${s.est_id}">
                                                <button type="submit" class="btn btn-success btn-sm px-3 font-weight-bold">Aprobar</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:if>

            <%-- 2. TABLA GENERAL DE MIS PROYECTOS --%>
            <div class="card-custom p-4">
                <h6 class="mb-4 text-muted">MIS PROYECTOS PUBLICADOS</h6>
                <div class="table-responsive">
                    <table class="table table-hover table-sm">
                        <thead class="text-muted small">
                            <tr>
                                <th>CÓDIGO</th>
                                <th>PROYECTO</th>
                                <th>ESTADO</th>
                                <th>ESTUDIANTE ASIGNADO</th>
                            </tr>
                        </thead>
                        <tbody class="small">
                            <c:forEach var="p" items="${misProyectos.rows}">
                                <tr>
                                    <td class="text-warning font-weight-bold align-middle">${p.codigo_proyecto}</td>
                                    <td class="align-middle">${p.nombre_proyecto}</td>
                                    <td class="align-middle">
                                        <c:choose>
                                            <c:when test="${p.estado == 'Disponible'}">
                                                <span class="badge badge-success px-2 py-1">Disponible</span>
                                            </c:when>
                                            <c:when test="${p.estado == 'Proceso'}">
                                                <span class="badge badge-proceso px-2 py-1">En Proceso</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-dark px-2 py-1">Ocupado</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="align-middle text-muted">
                                        <c:choose>
                                            <c:when test="${not empty p.nombre_estudiante}">
                                                <span class="text-success"><i class="fas fa-check-circle mr-1"></i> ${p.nombre_estudiante}</span>
                                            </c:when>
                                            <c:otherwise>Por asignar</c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <c:if test="${misProyectos.rowCount == 0}">
                    <p class="text-center text-muted mt-3">No has publicado proyectos todavía.</p>
                </c:if>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/js/bootstrap.bundle.min.js"></script>
</body>
</html>