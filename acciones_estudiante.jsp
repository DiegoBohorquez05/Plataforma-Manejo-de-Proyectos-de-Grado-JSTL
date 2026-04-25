<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<c:choose>
    <%-- ACCIÓN: ENVIAR SOLICITUD CON LINK DE DRIVE --%>
    <c:when test="${param.accion == 'enviar_solicitud'}">
        <sql:update dataSource="${ds}">
            INSERT INTO solicitudes_proyectos (estudiante_id, proyecto_id, link_drive, estado)
            VALUES (?, ?, ?, 'Pendiente')
            <sql:param value="${sessionScope.usuarioLogueado.id}" />
            <sql:param value="${param.id_proyecto}" />
            <sql:param value="${param.linkDrive}" />
        </sql:update>
        
        <%-- REDIRECCIÓN: Para que no se quede en blanco --%>
        <c:redirect url="dashboards/dashboard_estudiante.jsp?msj=solicitud_enviada" />
    </c:when>

    <%-- REDIRECCIÓN POR DEFECTO SI ALGO SALE MAL --%>
    <c:otherwise>
        <c:redirect url="dashboards/dashboard_estudiante.jsp" />
    </c:otherwise>
</c:choose>