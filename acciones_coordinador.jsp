<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<%-- Forzar codificación UTF-8 para recibir tildes correctamente --%>
<% request.setCharacterEncoding("UTF-8"); %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<c:if test="${param.accion == 'crear_proyecto'}">
    <sql:update dataSource="${ds}">
        INSERT INTO proyectos (nombre_proyecto, descripcion, facultad, codigo_proyecto, coordinador_id) 
        VALUES (?, ?, ?, ?, ?);
        <sql:param value="${param.txtNombre}" />
        <sql:param value="${param.txtDesc}" />
        <sql:param value="${param.txtFacultad}" />
        <sql:param value="${param.txtCodigo}" />
        <sql:param value="${sessionScope.usuarioLogueado.id}" />
    </sql:update>
</c:if>

<c:redirect url="dashboards/dashboard_coordinadores.jsp" />