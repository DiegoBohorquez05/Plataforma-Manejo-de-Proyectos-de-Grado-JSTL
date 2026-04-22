<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<%-- Seguridad --%>
<c:if test="${empty sessionScope.usuarioLogueado || sessionScope.tipoUsuario != 'coordinadores'}">
    <c:redirect url="../login_usuarios.jsp?rol=coordinadores" />
</c:if>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- Consulta Limpia con la nueva columna --%>
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
    <title>Coordinación | InmoHome</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body { background: #0f0f0f; color: #e0e0e0; font-family: 'Inter', sans-serif; }
        .card-custom { background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.1); border-radius: 15px; }
        .form-control { background: #1a1a1a; border: 1px solid #333; color: white; }
        .form-control:focus { background: #222; color: white; border-color: #ffc107; box-shadow: none; }
        .badge-disponible { background: #28a745; color: white; }
        .badge-escogido { background: #ffc107; color: black; }
        .table { color: #e0e0e0; }
    </style>
</head>
<body>

<div class="container-fluid py-5 px-5">
    <div class="d-flex justify-content-between align-items-center mb-5">
        <div>
            <h2 class="text-warning font-weight-bold">Panel de Coordinación</h2>
            <p class="text-muted small">Bienvenido, ${sessionScope.usuarioLogueado.nombre}</p>
        </div>
        <a href="../logout.jsp" class="btn btn-outline-danger btn-sm">Cerrar Sesión</a>
    </div>

    <div class="row">
        <div class="col-md-3">
            <div class="card-custom p-4 shadow-sm">
                <h5 class="mb-4">Publicar Proyecto</h5>
                <form action="../acciones_coordinador.jsp" method="POST">
                    <input type="hidden" name="accion" value="crear_proyecto">
                    <div class="form-group small">
                        <label>NOMBRE DEL PROYECTO</label>
                        <input type="text" name="txtNombre" class="form-control" required>
                    </div>
                    <div class="form-group small">
                        <label>CÓDIGO ÚNICO</label>
                        <input type="text" name="txtCodigo" class="form-control" required>
                    </div>
                    <div class="form-group small">
                        <label>FACULTAD</label>
                        <select name="txtFacultad" class="form-control">
                            <option value="Ingeniería">Ingeniería</option>
                            <option value="Derecho">Derecho</option>
                            <option value="Salud">Salud</option>
                        </select>
                    </div>
                    <div class="form-group small">
                        <label>DESCRIPCIÓN</label>
                        <textarea name="txtDesc" class="form-control" rows="4" required></textarea>
                    </div>
                    <button type="submit" class="btn btn-warning btn-block font-weight-bold">PUBLICAR</button>
                </form>
            </div>
        </div>

        <div class="col-md-9">
            <div class="card-custom p-4 shadow-sm h-100">
                <h5 class="mb-4">Mis Proyectos Publicados</h5>
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead class="small text-muted text-uppercase">
                            <tr>
                                <th>Código</th>
                                <th>Nombre del Proyecto</th>
                                <th>Descripción</th>
                                <th>Estado</th>
                                <th>Estudiante</th>
                            </tr>
                        </thead>
                        <tbody class="small">
                            <c:forEach var="p" items="${misProyectos.rows}">
                                <tr>
                                    <td class="text-warning font-weight-bold">${p.codigo_proyecto}</td>
                                    
                                    <%-- LLAMADA A LA NUEVA COLUMNA nombre_proyecto --%>
                                    <td><strong>${p.nombre_proyecto}</strong></td>
                                    
                                    <td class="text-muted" style="max-width: 300px;">
                                        <small>${p.descripcion}</small>
                                    </td>
                                    <td>
                                        <span class="badge ${p.estado == 'Disponible' ? 'badge-disponible' : 'badge-escogido'}">
                                            ${p.estado}
                                        </span>
                                    </td>
                                    <td class="text-muted">
                                        <c:choose>
                                            <c:when test="${not empty p.nombre_estudiante}">
                                                <i class="fas fa-user-graduate mr-1"></i> ${p.nombre_estudiante}
                                            </c:when>
                                            <c:otherwise>Por asignar</c:otherwise>
                                        </c:choose>
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