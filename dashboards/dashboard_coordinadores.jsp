<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- CONSULTA ORIGINAL --%>
<sql:query dataSource="${ds}" var="misProyectos">
    SELECT p.*, e.nombre 
    FROM proyectos p 
    LEFT JOIN estudiantes e ON p.estudiante_id = e.id 
    WHERE p.coordinador_id = ? 
    ORDER BY p.id DESC
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<sql:query dataSource="${ds}" var="listaDirectores">
    SELECT id, nombre FROM directores
</sql:query>

<sql:query dataSource="${ds}" var="listaEvaluadores">
    SELECT id, nombre FROM evaluadores
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel de Coordinador | Gestión de Proyectos</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        :root {
            --accent: #ffc107;
            --bg-dark: #0d0d0d;
            --card-bg: #161616;
            --row-bg: #1a1a1a;
            --border: #333;
            --text-muted: #888;
        }

        body { 
            background-color: var(--bg-dark); 
            color: #e0e0e0; 
            font-family: 'Segoe UI', Roboto, sans-serif; 
        }

        .header-section {
            background-color: var(--card-bg);
            border-bottom: 1px solid var(--border);
            padding: 1.5rem;
            margin-bottom: 2rem;
        }

        .card-dark { 
            background-color: var(--card-bg); 
            border: 1px solid var(--border); 
            border-radius: 15px; 
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
        }

        .form-control {
            background-color: #0d0d0d !important;
            border: 1px solid #444 !important;
            color: white !important;
            border-radius: 8px;
            padding: 12px;
        }
        .form-control:focus {
            border-color: var(--accent) !important;
            box-shadow: none;
        }
        label {
            font-size: 0.7rem;
            letter-spacing: 1px;
            font-weight: 700;
            color: var(--text-muted);
            margin-bottom: 8px;
        }

        /* Tabla Estilizada */
        .table { color: #fff; border-collapse: separate; border-spacing: 0 12px; }
        .table thead th { 
            border: none; 
            color: var(--text-muted); 
            text-transform: uppercase; 
            font-size: 0.7rem; 
            letter-spacing: 1.5px;
            padding-left: 20px;
        }
        .table tbody tr { 
            background-color: var(--row-bg); 
            transition: all 0.3s;
        }
        .table tbody tr:hover {
            transform: scale(1.005);
            background-color: #222;
        }
        .table tbody td { 
            border: none; 
            padding: 20px; 
            vertical-align: middle;
        }
        .table tbody td:first-child { border-radius: 10px 0 0 10px; }
        .table tbody td:last-child { border-radius: 0 10px 10px 0; }

        .btn-warning {
            background-color: var(--accent);
            border: none;
            font-weight: 700;
            padding: 12px;
            border-radius: 10px;
            text-transform: uppercase;
            font-size: 0.85rem;
            transition: 0.3s;
        }
        .btn-warning:hover {
            background-color: #e5ad06;
            box-shadow: 0 0 15px rgba(255, 193, 7, 0.3);
        }
        .badge-status {
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.7rem;
            font-weight: 800;
            letter-spacing: 0.5px;
        }
        .badge-success { background-color: #28a745; color: white; }
        .badge-info { background-color: #17a2b8; color: white; }
        .text-warning { color: var(--accent) !important; }

        /* Ajustes específicos de espaciado en la tabla */
        .col-codigo { width: 120px; }
        .col-proyecto { max-width: 300px; }
        .col-estado { width: 150px; text-align: center; }
        .col-asignacion { min-width: 450px; }
        
        /* Selectores dentro de la tabla */
        .select-personal {
            height: 35px !important;
            padding: 5px 10px !important;
            font-size: 0.8rem;
        }
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
                <h6 class="text-warning mb-4 font-weight-bold d-flex align-items-center">
                    <i class="fas fa-plus-circle mr-2"></i> NUEVO PROYECTO
                </h6>
                <form action="../acciones_coordinador.jsp" method="POST">
                    <input type="hidden" name="accion" value="crear_proyecto">
                    <div class="form-group">
                        <label>NOMBRE DEL PROYECTO</label>
                        <input type="text" name="txtNombre" class="form-control" required placeholder="Ej: Sistema de Gestión...">
                    </div>
                    <div class="form-group">
                        <label>CÓDIGO</label>
                        <input type="text" name="txtCodigo" class="form-control" required placeholder="PRY-000">
                    </div>
                    <div class="form-group">
                        <label>FACULTAD</label>
                        <input type="text" name="txtFacultad" class="form-control" required placeholder="Ingeniería...">
                    </div>
                    <div class="form-group">
                        <label>DESCRIPCIÓN</label>
                        <textarea name="txtDesc" class="form-control" rows="3" required placeholder="Detalles del proyecto..."></textarea>
                    </div>
                    <button type="submit" class="btn btn-warning btn-block">
                        <i class="fas fa-paper-plane mr-1"></i> Publicar Proyecto
                    </button>
                </form>
            </div>
        </div>

        <div class="col-md-9">
            <div class="card-dark p-4 mb-4">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h6 class="text-muted small font-weight-bold mb-0">ESTADO DE MIS PROYECTOS</h6>
                    <span class="badge badge-secondary">${misProyectos.rowCount} Total</span>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th class="col-codigo">Código</th>
                                <th class="col-proyecto">Nombre del Proyecto</th>
                                <th class="col-estado">Estado</th>
                                <th class="col-asignacion">Estudiante / Personal Asignado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${misProyectos.rows}">
                                <tr>
                                    <td class="text-warning font-weight-bold">
                                        <i class="fas fa-tag mr-2 small"></i>${p.codigo_proyecto}
                                    </td>
                                    <td class="col-proyecto font-weight-bold text-white">
                                        ${p.nombre_proyecto}
                                    </td>
                                    <td class="col-estado">
                                        <span class="badge-status ${p.estado == 'Asignado' ? 'badge-success' : 'badge-info'}">
                                            ${p.estado.toUpperCase()}
                                        </span>
                                    </td>
                                    <td class="col-asignacion">
                                        <div class="mb-3 d-flex align-items-center">
                                            <i class="fas fa-user-circle mr-2 ${not empty p.nombre ? 'text-success' : 'text-muted'}"></i>
                                            <c:choose>
                                                <c:when test="${not empty p.nombre}">
                                                    <span class="text-white font-weight-bold mr-2">${p.nombre}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted font-italic small">Disponible</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <c:if test="${not empty p.nombre}">
                                            <form action="../acciones_coordinador.jsp" method="POST" class="bg-dark p-2 rounded" style="border: 1px solid #333;">
                                                <input type="hidden" name="accion" value="asignar_personal">
                                                <input type="hidden" name="id_proyecto" value="${p.id}">
                                                
                                                <div class="form-row align-items-end">
                                                    <div class="col">
                                                        <label class="mb-1" style="font-size: 0.6rem;">DIRECTOR</label>
                                                        <select name="id_director" class="form-control select-personal bg-dark text-white border-secondary">
                                                            <option value="">Seleccionar...</option>
                                                            <c:forEach var="d" items="${listaDirectores.rows}">
                                                                <option value="${d.id}" ${p.director_id == d.id ? 'selected' : ''}>${d.nombre}</option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="col">
                                                        <label class="mb-1" style="font-size: 0.6rem;">EVALUADOR</label>
                                                        <select name="id_evaluador" class="form-control select-personal bg-dark text-white border-secondary">
                                                            <option value="">Seleccionar...</option>
                                                            <c:forEach var="e" items="${listaEvaluadores.rows}">
                                                                <option value="${e.id}" ${p.evaluador_id == e.id ? 'selected' : ''}>${e.nombre}</option>
                                                            </c:forEach>
                                                        </select>
                                                    </div>
                                                    <div class="col-auto">
                                                        <button type="submit" class="btn btn-warning btn-sm" style="padding: 5px 12px; height: 35px;">
                                                            <i class="fas fa-save"></i>
                                                        </button>
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

                <c:if test="${misProyectos.rowCount == 0}">
                    <div class="text-center py-5">
                        <i class="fas fa-folder-open fa-3x text-secondary mb-3 d-block"></i>
                        <p class="text-muted">No has publicado ningún proyecto todavía.</p>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

</body>
</html>