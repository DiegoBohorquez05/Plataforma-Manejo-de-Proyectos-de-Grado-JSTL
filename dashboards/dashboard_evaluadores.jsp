<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- CONSULTA: Solo documentos con aval del Director. 
     Si el estudiante re-entrega tras una corrección del evaluador, 
     el estado_director vendrá como 'Aprobado' automáticamente --%>
<sql:query dataSource="${ds}" var="docsParaEvaluar">
    SELECT 
        dp.id, 
        dp.nombre_documento, 
        dp.link_drive,
        dp.estado_director,
        dp.estado_evaluador, 
        p.nombre_proyecto, 
        e.nombre_estudiante 
    FROM documentos_proyecto dp
    JOIN proyectos p ON dp.proyecto_id = p.id
    JOIN estudiantes e ON p.estudiante_id = e.id
    WHERE p.evaluador_id = ? 
      AND dp.estado_director = 'Aprobado'
    ORDER BY dp.fecha_subida DESC
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Evaluador | Calificación Final</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        :root { --accent: #17a2b8; --bg-dark: #0d0d0d; --card-bg: #161616; --border: #333; }
        body { background-color: var(--bg-dark); color: #e0e0e0; font-family: 'Segoe UI', sans-serif; }
        .navbar-custom { background-color: var(--card-bg); border-bottom: 1px solid var(--border); padding: 1rem 2rem; }
        .table-custom { background-color: var(--card-bg); border: 1px solid var(--border); border-radius: 12px; overflow: hidden; }
        .table-custom th { color: var(--accent); font-size: 0.75rem; text-transform: uppercase; padding: 20px; }
        .table-custom td { border-top: 1px solid #222; vertical-align: middle; padding: 20px; }
        .btn-evaluar { background-color: var(--accent); color: #fff; font-weight: 700; border: none; border-radius: 6px; padding: 8px 15px; transition: 0.3s; }
        .btn-evaluar:hover { background-color: #138496; transform: scale(1.05); color: #fff; }
        .btn-evaluar:disabled { background-color: #444; color: #888; cursor: not-allowed; transform: none; }
        .badge-eval { padding: 5px 10px; border-radius: 4px; font-size: 0.8rem; }
    </style>
</head>
<body>

<nav class="navbar-custom d-flex justify-content-between align-items-center mb-4">
    <h4 class="mb-0 font-weight-bold">Panel <span class="text-info">Evaluador</span></h4>
    <div class="d-flex align-items-center">
        <span class="text-muted small mr-3"><i class="fas fa-user-check mr-1"></i> ${sessionScope.usuarioLogueado.nombre_evaluador}</span>
        <a href="../logout.jsp" class="btn btn-outline-danger btn-sm px-4">SALIR</a>
    </div>
</nav>

<div class="container-fluid px-5">
    <div class="mb-4">
        <h5 class="text-white">Proyectos por Evaluar</h5>
        <p class="text-muted small">Mostrando documentos con Aval del Director o Re-entregas directas.</p>
    </div>

    <div class="table-custom shadow-lg">
        <table class="table table-dark mb-0">
            <thead>
                <tr>
                    <th>Proyecto / Estudiante</th>
                    <th>Documento</th>
                    <th>Aval Director</th>
                    <th>Estado Evaluador</th>
                    <th class="text-center">Acciones</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="doc" items="${docsParaEvaluar.rows}">
                    <tr>
                        <td>
                            <span class="d-block font-weight-bold text-white">${doc.nombre_proyecto}</span>
                            <small class="text-muted">${doc.nombre_estudiante}</small>
                        </td>
                        <td><span class="badge badge-secondary">${doc.nombre_documento}</span></td>
                        <td><span class="text-success small"><i class="fas fa-check-double mr-1"></i> Aprobado</span></td>
                        <td>
                            <c:set var="estEv" value="${doc.estado_evaluador}" />
                            <span class="badge-eval ${estEv == 'Aprobado' ? 'bg-success' : (estEv == 'Corregir' ? 'bg-danger' : 'bg-warning')}">
                                ${estEv}
                            </span>
                        </td>
                        <td class="text-center">
                            <div class="btn-group">
                                <a href="${doc.link_drive}" target="_blank" class="btn btn-outline-light btn-sm mr-2">
                                    <i class="fas fa-external-link-alt"></i>
                                </a>
                                
                                <button type="button" class="btn-evaluar" 
                                    data-toggle="modal" 
                                    data-target="#modalEval${doc.id}"
                                    ${doc.estado_evaluador != 'Pendiente' ? 'disabled' : ''}>
                                    ${doc.estado_evaluador != 'Pendiente' ? 'EVALUADO' : 'EVALUAR'}
                                </button>
                            </div>
                        </td>
                    </tr>

                    <%-- MODAL DE EVALUACIÓN --%>
                    <div class="modal fade" id="modalEval${doc.id}" tabindex="-1" role="dialog">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content bg-dark border-info text-white">
                                <div class="modal-header border-info">
                                    <h5 class="modal-title text-info">Calificación del Evaluador</h5>
                                    <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
                                </div>
                                <form action="../acciones_evaluador.jsp" method="POST">
                                    <input type="hidden" name="id_documento" value="${doc.id}">
                                    <div class="modal-body">
                                        <div class="form-group">
                                            <label class="text-info small font-weight-bold">DECISIÓN FINAL</label>
                                            <select name="txtEstado" class="form-control bg-dark text-white border-secondary" required>
                                                <option value="Aprobado">Aprobado (Sustentación)</option>
                                                <option value="Corregir">Rechazado / Corregir</option>
                                            </select>
                                        </div>
                                        <p class="text-muted small italic">Al guardar, el estudiante recibirá la notificación en su panel.</p>
                                    </div>
                                    <div class="modal-footer border-info">
                                        <button type="submit" class="btn btn-info btn-block font-weight-bold">CONFIRMAR EVALUACIÓN</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
                <c:if test="${docsParaEvaluar.rowCount == 0}">
                    <tr>
                        <td colspan="5" class="text-center py-5 text-muted">No hay documentos pendientes de evaluación.</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>