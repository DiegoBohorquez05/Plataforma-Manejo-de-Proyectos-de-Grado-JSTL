<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%-- 1. SEGURIDAD Y CONEXIÓN --%>
<%@ include file="WEB-INF/conexion.jspf" %>

<%-- Si no hay sesión de admin, expulsar al login --%>
<c:if test="${empty sessionScope.adminLogueado}">
    <c:redirect url="admin_login.jsp" />
</c:if>

<%-- Configuración del DataSource JSTL --%>
<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 2. CONSULTAS A LAS 4 TABLAS --%>
<sql:query dataSource="${ds}" var="listaEstudiantes">SELECT * FROM estudiantes ORDER BY id DESC</sql:query>
<sql:query dataSource="${ds}" var="listaCoordinadores">SELECT * FROM coordinadores ORDER BY id DESC</sql:query>
<sql:query dataSource="${ds}" var="listaEvaluadores">SELECT * FROM evaluadores ORDER BY id DESC</sql:query>
<sql:query dataSource="${ds}" var="listaDirectores">SELECT * FROM directores ORDER BY id DESC</sql:query>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Administrativo | Gestión de Usuarios</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        body { background-color: #0f0f0f; color: #e0e0e0; font-family: 'Inter', sans-serif; min-height: 100vh; }
        .sidebar { background: rgba(255,255,255,0.02); border-right: 1px solid rgba(255,255,255,0.1); min-height: 100vh; }
        .card-custom { background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.1); border-radius: 15px; }
        .nav-tabs { border-bottom: 1px solid rgba(255,255,255,0.1); }
        .nav-tabs .nav-link { color: #aaa; border: none; padding: 1rem 1.5rem; transition: 0.3s; }
        .nav-tabs .nav-link.active { background: transparent; color: #ffc107; border-bottom: 2px solid #ffc107; }
        .nav-tabs .nav-link:hover { color: #fff; border-bottom: 2px solid rgba(255,193,7,0.3); }
        .table { color: #ddd; margin-bottom: 0; }
        .table thead th { border-top: none; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .table td { border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: middle; }
        .btn-action { padding: 5px 10px; border-radius: 8px; transition: 0.2s; }
        .btn-action:hover { transform: scale(1.1); }
        .modal-content { background: #1a1c1e; border: 1px solid rgba(255,255,255,0.1); border-radius: 20px; }
    </style>
</head>
<body>

<div class="container-fluid">
    <div class="row">
        <div class="col-md-2 sidebar p-4 text-center">
            <h5 class="text-warning font-weight-bold mb-4" style="letter-spacing: 1px;">SISTEMA GRADO</h5>
            <div class="mb-4">
                <i class="fas fa-user-circle fa-3x text-secondary mb-2"></i>
                <p class="small text-muted mb-0">Administrador</p>
                <p class="font-weight-bold">${sessionScope.adminLogueado.nombre}</p>
            </div>
            <hr class="bg-secondary opacity-25">
            <a href="logout.jsp" class="btn btn-outline-danger btn-sm btn-block mt-4">
                <i class="fas fa-sign-out-alt mr-2"></i>Cerrar Sesión
            </a>
        </div>

        <div class="col-md-10 p-5">
            <h2 class="mb-4 font-weight-light">Gestión de Usuarios</h2>

            <ul class="nav nav-tabs mb-4" id="tabRoles" role="tablist">
                <li class="nav-item">
                    <a class="nav-link active" data-toggle="tab" href="#estudiantes" data-role="Estudiante" data-table="estudiantes">Estudiantes</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-toggle="tab" href="#coordinadores" data-role="Coordinador" data-table="coordinadores">Coordinadores</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-toggle="tab" href="#evaluadores" data-role="Evaluador" data-table="evaluadores">Evaluadores</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" data-toggle="tab" href="#directores" data-role="Director" data-table="directores">Directores</a>
                </li>
            </ul>

            <div class="tab-content">
                <%-- Iteramos sobre los 4 roles para crear las tablas dinámicamente --%>
                <c:forEach var="rol" items="estudiantes,coordinadores,evaluadores,directores">
                    <c:set var="datos" value="${rol == 'estudiantes' ? listaEstudiantes : (rol == 'coordinadores' ? listaCoordinadores : (rol == 'evaluadores' ? listaEvaluadores : listaDirectores))}" />
                    
                    <div class="tab-pane fade ${rol == 'estudiantes' ? 'show active' : ''}" id="${rol}">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h4 class="text-capitalize mb-0">Registros de ${rol}</h4>
                            <button class="btn btn-warning px-4 font-weight-bold btn-nuevo" data-toggle="modal" data-target="#modalCrear">
                                <i class="fas fa-plus mr-2"></i> Nuevo <span class="role-text text-capitalize">${rol.substring(0, rol.length()-1)}</span>
                            </button>
                        </div>

                        <div class="card-custom p-4 shadow-lg">
                            <table class="table table-hover">
                                <thead class="small text-muted text-uppercase">
                                    <tr>
                                        <th>ID</th>
                                        <th>Nombre Completo</th>
                                        <th>Gmail Institucional</th>
                                        <th class="text-center">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="u" items="${datos.rows}">
                                        <tr>
                                            <td class="text-warning">#${u.id}</td>
                                            <td>${u.nombre}</td>
                                            <td>${u.gmail}</td>
                                            <td class="text-center">
                                                <a href="#" class="btn-action text-info mr-2"><i class="fas fa-edit"></i></a>
                                                <a href="acciones_admin.jsp?accion=eliminar&id=${u.id}&tabla=${rol}" 
                                                   class="btn-action text-danger" 
                                                   onclick="return confirm('¿Desea eliminar este registro?')">
                                                    <i class="fas fa-trash"></i>
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${datos.rowCount == 0}">
                                        <tr><td colspan="4" class="text-center text-muted py-4">No hay registros encontrados.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalCrear" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-0 p-4">
                <h5 class="modal-title font-weight-bold" id="modalTitle">Registrar Nuevo Estudiante</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <form action="acciones_admin.jsp" method="POST">
                <div class="modal-body p-4">
                    <%-- Campos ocultos para la lógica del servidor --%>
                    <input type="hidden" name="accion" value="crear">
                    <input type="hidden" name="tabla" id="hiddenTabla" value="estudiantes">
                    
                    <div class="form-group mb-3">
                        <label class="small text-muted font-weight-bold">NOMBRE COMPLETO</label>
                        <input type="text" name="txtNombre" class="form-control bg-dark text-white border-secondary" placeholder="Ej: Juan Perez" required>
                    </div>
                    <div class="form-group mb-3">
                        <label class="small text-muted font-weight-bold">CORREO GMAIL</label>
                        <input type="email" name="txtGmail" class="form-control bg-dark text-white border-secondary" placeholder="usuario@gmail.com" required>
                    </div>
                    <div class="form-group mb-4">
                        <label class="small text-muted font-weight-bold">CONTRASEÑA TEMPORAL</label>
                        <input type="password" name="txtPass" class="form-control bg-dark text-white border-secondary" required>
                    </div>
                </div>
                <div class="modal-footer border-0 p-4">
                    <button type="button" class="btn btn-link text-muted" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-warning px-4 font-weight-bold">Guardar Registro</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.6.0/js/bootstrap.bundle.min.js"></script>

<script>
$(document).ready(function() {
    // Evento al cambiar de pestaña
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
        // Obtenemos los atributos data del tab activo
        var role = $(e.target).data('role');
        var table = $(e.target).data('table');
        
        // Sincronizamos el Modal
        $('#modalTitle').text('Registrar Nuevo ' + role);
        $('#hiddenTabla').val(table);
        
        // Sincronizamos el texto del botón "Nuevo"
        $('.role-text').text(role);
    });
});
</script>

</body>
</html>