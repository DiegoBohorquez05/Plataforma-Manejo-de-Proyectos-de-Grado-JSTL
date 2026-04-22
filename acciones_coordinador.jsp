<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" driver="${applicationScope.dbDriver}" url="${applicationScope.dbUrl}" user="${applicationScope.dbUser}" password="${applicationScope.dbPass}" />

<%-- LÓGICA DE APROBACIÓN --%>
<c:if test="${param.accion == 'aprobar_solicitud'}">
    <%-- 1. Cambiamos la solicitud a 'Aprobado' --%>
    <sql:update dataSource="${ds}">
        UPDATE solicitudes_proyectos SET estado_solicitud = 'Aprobado' WHERE id = ?;
        <sql:param value="${param.id_solicitud}" />
    </sql:update>
    
    <%-- 2. Asignamos el estudiante al proyecto y cambiamos su estado a 'Ocupado' --%>
    <sql:update dataSource="${ds}">
        UPDATE proyectos SET estado = 'Ocupado', estudiante_id = ? WHERE id = ?;
        <sql:param value="${param.id_estudiante}" />
        <sql:param value="${param.id_proyecto}" />
    </sql:update>
</c:if>

<%-- LÓGICA DE CREACIÓN (la que ya tenías) --%>
<c:if test="${param.accion == 'crear_proyecto'}">
    <sql:update dataSource="${ds}">
        INSERT INTO proyectos (nombre_proyecto, descripcion, facultad, codigo_proyecto, coordinador_id, estado) 
        VALUES (?, ?, ?, ?, ?, 'Disponible');
        <sql:param value="${param.txtNombre}" />
        <sql:param value="${param.txtDesc}" />
        <sql:param value="${param.txtFacultad}" />
        <sql:param value="${param.txtCodigo}" />
        <sql:param value="${sessionScope.usuarioLogueado.id}" />
    </sql:update>
</c:if>

<c:redirect url="dashboards/dashboard_coordinadores.jsp" />