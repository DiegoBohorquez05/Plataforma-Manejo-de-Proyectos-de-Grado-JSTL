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

<%-- 2. CONSULTA ACTUALIZADA: Solo trae disponibles si el estudiante NO tiene proyectos --%>
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
    <title>Dashboard Estudiantes</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { background-color: #0d0d0d; color: #e0e0e0; font-family: 'Segoe UI', sans-serif; }
        .card-dark { background-color: #161616; border: 1px solid #333; border-radius: 12px; transition: 0.3s; }
        .card-dark:hover { border-color: #ffc107; }
        .text-warning { color: #ffc107 !important; }
        .btn-pago { background-color: #ffc107; color: #000; font-weight: bold; border-radius: 8px; }
    </style>
</head>
<body class="p-4">

<div class="container">
    <div class="mb-5">
        <h5 class="text-warning small font-weight-bold mb-3 uppercase">MI PROYECTO ASIGNADO</h5>
        <c:choose>
            <c:when test="${miProyecto.rowCount > 0}">
                <c:forEach var="mp" items="${miProyecto.rows}">
                    <div class="card-dark p-4 shadow border-success">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h4 class="mb-1">${mp.nombre_proyecto}</h4>
                                <p class="text-muted mb-0">Código: ${mp.codigo_proyecto} | Facultad: ${mp.facultad}</p>
                            </div>
                            <span class="badge badge-success p-2">Estado: ${mp.estado}</span>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="card-dark p-4 text-center">
                    <p class="text-muted mb-0">Aún no tienes un proyecto asignado.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <h5 class="text-muted small font-weight-bold mb-3 uppercase">PROYECTOS DISPONIBLES</h5>
    <div class="row">
        <c:choose>
            <%-- Si el estudiante ya tiene uno, esta lista vendrá vacía por la consulta SQL --%>
            <c:when test="${proyectosLibres.rowCount > 0}">
                <c:forEach var="p" items="${proyectosLibres.rows}">
                    <div class="col-md-6 mb-4">
                        <div class="card-dark p-4 h-100 shadow">
                            <h5 class="text-white">${p.nombre_proyecto}</h5>
                            <p class="text-secondary small text-justify">${p.descripcion}</p>
                            <hr class="border-secondary">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="text-warning font-weight-bold">${p.codigo_proyecto}</span>
                                <%-- Formulario para asignar el proyecto --%>
                                <form action="../acciones_estudiante.jsp" method="POST">
                                    <input type="hidden" name="accion" value="enviar_pago">
                                    <input type="hidden" name="id_proyecto" value="${p.id}">
                                    <button type="submit" class="btn btn-pago btn-sm">SOLICITAR ASIGNACIÓN</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <div class="col-12">
                    <div class="card-dark p-5 text-center">
                        <c:choose>
                            <c:when test="${miProyecto.rowCount > 0}">
                                <i class="fas fa-check-circle text-success fa-3x mb-3"></i>
                                <h5 class="text-white">¡Ya tienes un proyecto en curso!</h5>
                                <p class="text-muted">No puedes ver ni solicitar más proyectos mientras tengas uno asignado.</p>
                            </c:when>
                            <c:otherwise>
                                <i class="fas fa-search text-secondary fa-3x mb-3"></i>
                                <p class="text-muted">No hay más proyectos disponibles en este momento.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>