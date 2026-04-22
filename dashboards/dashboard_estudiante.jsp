<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="../WEB-INF/conexion.jspf" %>

<%-- Seguridad --%>
<c:if test="${empty sessionScope.usuarioLogueado || sessionScope.tipoUsuario != 'estudiantes'}">
    <c:redirect url="../login_usuarios.jsp?rol=estudiantes" />
</c:if>

<sql:setDataSource var="ds" driver="${applicationScope.dbDriver}" url="${applicationScope.dbUrl}" user="${applicationScope.dbUser}" password="${applicationScope.dbPass}" />

<%-- Consulta de proyectos DISPONIBLES (Corregida: p.id) --%>
<sql:query dataSource="${ds}" var="disponibles">
    SELECT * FROM proyectos WHERE estado = 'Disponible' ORDER BY id DESC
</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Estudiante | Proyectos</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <style>
        body { background: #0f0f0f; color: #e0e0e0; }
        .card-custom { background: rgba(255,255,255,0.05); border: 1px solid #333; border-radius: 10px; }
        .table { color: #e0e0e0; }
        .modal-content { background: #1a1a1a; border: 1px solid #444; }
    </style>
</head>
<body>
<div class="container py-5">
    <div class="d-flex justify-content-between mb-4">
        <h2 class="text-warning">Proyectos Disponibles</h2>
        <a href="../logout.jsp" class="btn btn-outline-danger btn-sm">Cerrar Sesión</a>
    </div>

    <div class="card-custom p-4">
        <table class="table table-hover">
            <thead class="small text-muted">
                <tr>
                    <th>CÓDIGO</th>
                    <th>PROYECTO</th>
                    <th>FACULTAD</th>
                    <th>ACCIÓN</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="p" items="${disponibles.rows}">
                    <tr>
                        <td class="text-warning">${p.codigo_proyecto}</td>
                        <td><strong>${p.nombre_proyecto}</strong></td>
                        <td>${p.facultad}</td>
                        <td>
                            <button class="btn btn-warning btn-sm" data-toggle="modal" data-target="#payModal${p.id}">
                                Escoger Proyecto
                            </button>
                        </td>
                    </tr>

                    <%-- Modal para simular subida de PDF --%>
                    <div class="modal fade" id="payModal${p.id}" tabindex="-1">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <form action="../acciones_estudiante.jsp" method="POST">
                                    <div class="modal-header"><h5 class="modal-title">Subir Pago de Derechos</h5></div>
                                    <div class="modal-body">
                                        <p class="small">Proyecto: ${p.nombre_proyecto}</p>
                                        <input type="hidden" name="id_proyecto" value="${p.id}">
                                        <div class="form-group">
                                            <label class="small">Adjunte comprobante (.pdf)</label>
                                            <input type="file" name="fakeFile" class="form-control-file" accept=".pdf" required>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="submit" class="btn btn-success btn-block">Enviar Comprobante</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </tbody>
        </table>
        <c:if test="${disponibles.rowCount == 0}">
            <p class="text-center text-muted">No hay proyectos disponibles en este momento.</p>
        </c:if>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/js/bootstrap.bundle.min.js"></script>
</body>
</html>