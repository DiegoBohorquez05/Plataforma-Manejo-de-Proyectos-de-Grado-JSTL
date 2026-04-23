<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. CONSULTA: Buscar si el estudiante ya tiene un proyecto asignado --%>
<sql:query dataSource="${ds}" var="miProyecto">
    SELECT * FROM proyectos 
    WHERE estudiante_id = ?
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<%-- 2. CONSULTA: Solo trae disponibles si el estudiante NO tiene proyectos asignados --%>
<sql:query dataSource="${ds}" var="proyectosLibres">
    SELECT * FROM proyectos 
    WHERE estado = 'Disponible' 
    AND estudiante_id IS NULL
    AND NOT EXISTS (
        SELECT 1 FROM proyectos WHERE estudiante_id = ?
    )
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel de Estudiante | Gestión de Proyectos</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        :root {
            --accent: #ffc107;
            --bg-dark: #0d0d0d;
            --card-bg: #161616;
            --border: #333;
            --text-muted: #888;
        }

        body { 
            background-color: var(--bg-dark); 
            color: #e0e0e0; 
            font-family: 'Segoe UI', Roboto, sans-serif; 
        }

        /* Navbar */
        .navbar-custom {
            background-color: var(--card-bg);
            border-bottom: 1px solid var(--border);
            margin-bottom: 40px;
            padding: 1rem;
        }

        /* Cards */
        .card-dark { 
            background-color: var(--card-bg); 
            border: 1px solid var(--border); 
            border-radius: 15px; 
            margin-bottom: 25px;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            overflow: hidden;
        }

        .card-dark:hover {
            border-color: var(--accent);
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.5);
        }

        /* Formulario de archivos */
        .file-input-wrapper {
            background: #1e1e1e;
            padding: 15px;
            border-radius: 10px;
            border: 2px dashed #444;
            transition: border-color 0.3s;
            margin-bottom: 15px;
        }

        .file-input-wrapper:hover {
            border-color: var(--accent);
        }

        .form-control-file {
            color: var(--text-muted);
            font-size: 0.9rem;
        }

        /* Botones y Badges */
        .btn-pago { 
            background-color: var(--accent); 
            color: #000; 
            font-weight: 700; 
            border: none;
            padding: 10px 25px;
            border-radius: 10px;
            text-transform: uppercase;
            font-size: 0.85rem;
            letter-spacing: 0.5px;
            transition: 0.3s;
            width: 100%;
        }

        .btn-pago:hover {
            background-color: #e5ad06;
            box-shadow: 0 0 15px rgba(255, 193, 7, 0.3);
        }

        .status-badge {
            padding: 8px 18px;
            border-radius: 30px;
            font-size: 0.75rem;
            font-weight: 800;
            letter-spacing: 1px;
        }

        .badge-facultad {
            background: rgba(255, 255, 255, 0.05);
            color: var(--accent);
            border: 1px solid rgba(255, 193, 7, 0.2);
            padding: 5px 12px;
            border-radius: 6px;
        }

        .text-warning { color: var(--accent) !important; }
        .section-title {
            font-size: 0.75rem;
            letter-spacing: 2px;
            color: var(--text-muted);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
        }
        .section-title::after {
            content: "";
            flex: 1;
            height: 1px;
            background: var(--border);
            margin-left: 15px;
        }
    </style>
</head>
<body>

<nav class="navbar-custom">
    <div class="container d-flex justify-content-between align-items-center">
        <h4 class="mb-0 font-weight-bold">Panel <span class="text-warning">Estudiante</span></h4>
        <div class="d-flex align-items-center">
            <span class="mr-3 text-muted small d-none d-sm-inline">
                <i class="fas fa-user-circle mr-1"></i> ${sessionScope.usuarioLogueado.nombre}
            </span>
            <a href="../logout.jsp" class="btn btn-outline-danger btn-sm px-3 shadow-sm">
                <i class="fas fa-sign-out-alt"></i> Salir
            </a>
        </div>
    </div>
</nav>

<div class="container">
    <div class="mb-5">
        <div class="section-title text-uppercase font-weight-bold">Mi Proyecto Asignado</div>
        <c:choose>
            <c:when test="${miProyecto.rowCount > 0}">
                <c:forEach var="mp" items="${miProyecto.rows}">
                    <div class="card-dark p-4 shadow-lg border-success" style="border-left: 5px solid #28a745;">
                        <div class="row align-items-center">
                            <div class="col-md-9">
                                <span class="badge badge-facultad mb-2">${mp.facultad}</span>
                                <h3 class="text-white mb-2 font-weight-bold">${mp.nombre_proyecto}</h3>
                                <p class="text-muted mb-3">${mp.descripcion}</p>
                                <span class="text-warning font-weight-bold">
                                    <i class="fas fa-fingerprint mr-1"></i> ID: ${mp.codigo_proyecto}
                                </span>
                            </div>
                            <div class="col-md-3 text-md-right mt-3 mt-md-0">
                                <span class="status-badge bg-success text-white">
                                    <i class="fas fa-check-circle mr-1"></i> ASIGNADO
                                </span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="card-dark p-5 text-center shadow-sm">
                    <i class="fas fa-folder-open text-muted fa-2x mb-3 d-block"></i>
                    <p class="text-muted mb-0 font-italic">No tienes proyectos asignados actualmente.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="section-title text-uppercase font-weight-bold">Proyectos Disponibles</div>
    <div class="row">
        <c:choose>
            <c:when test="${proyectosLibres.rowCount > 0}">
                <c:forEach var="p" items="${proyectosLibres.rows}">
                    <div class="col-lg-6 mb-4">
                        <div class="card-dark p-4 h-100 shadow d-flex flex-column">
                            <div class="mb-3 d-flex justify-content-between align-items-start">
                                <h5 class="text-white font-weight-bold mb-0 w-75">${p.nombre_proyecto}</h5>
                                <span class="badge badge-facultad">${p.facultad}</span>
                            </div>
                            
                            <p class="text-secondary small flex-grow-1" style="line-height: 1.6;">${p.descripcion}</p>
                            
                            <hr class="my-3">
                            
                            <form action="../acciones_estudiante.jsp" method="POST" enctype="multipart/form-data">
                                <input type="hidden" name="accion" value="enviar_pago">
                                <input type="hidden" name="id_proyecto" value="${p.id}">

                                <div class="form-group mb-3">
                                    <label class="small text-warning font-weight-bold mb-2">
                                        <i class="fas fa-file-pdf mr-1"></i> COMPROBANTE DE PAGO
                                    </label>
                                    <div class="file-input-wrapper">
                                        <input type="file" name="archivo_pdf" class="form-control-file" accept=".pdf" required>
                                    </div>
                                </div>
                                
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="text-muted small font-weight-bold">
                                        COD: <span class="text-white">${p.codigo_proyecto}</span>
                                    </span>
                                    <div style="width: 200px;">
                                        <button type="submit" class="btn btn-pago">
                                            <i class="fas fa-check mr-2"></i> Tomar Proyecto
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-12">
                    <div class="card-dark p-5 text-center shadow">
                        <c:choose>
                            <c:when test="${miProyecto.rowCount > 0}">
                                <div class="py-3">
                                    <i class="fas fa-lock text-warning fa-4x mb-4"></i>
                                    <h4 class="text-white font-weight-bold">Lista Restringida</h4>
                                    <p class="text-muted mx-auto" style="max-width: 400px;">
                                        Ya posees un proyecto asignado. Debes completar tu proceso actual antes de solicitar uno nuevo.
                                    </p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="py-3">
                                    <i class="fas fa-search text-secondary fa-4x mb-4"></i>
                                    <h4 class="text-white">Sin proyectos</h4>
                                    <p class="text-muted">No hay proyectos disponibles que coincidan con tu perfil en este momento.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/js/bootstrap.bundle.min.js"></script>

</body>
</html>