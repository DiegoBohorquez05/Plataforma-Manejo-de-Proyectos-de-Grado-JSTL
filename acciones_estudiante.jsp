<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<%-- 
    IMPORTANTE: Asegúrate de que en la base de datos la columna 'estado' 
    sea VARCHAR(50) para evitar el error "Data truncated".
--%>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. Insertar la solicitud en la tabla 'solicitudes_proyectos' --%>
<%-- Usamos los nombres de columnas verificados: proyecto_id, estudiante_id, archivo_pago, estado_solicitud --%>
<sql:update dataSource="${ds}">
    INSERT INTO solicitudes_proyectos (proyecto_id, estudiante_id, archivo_pago, estado_solicitud) 
    VALUES (?, ?, 'pago_derechos.pdf', 'Pendiente');
    <sql:param value="${param.id_proyecto}" />
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
</sql:update>

<%-- 2. Cambiar el estado del proyecto a 'Proceso' --%>
<%-- Esto evitará que otros estudiantes lo vean mientras el coordinador aprueba --%>
<sql:update dataSource="${ds}">
    UPDATE proyectos SET estado = 'Proceso' WHERE id = ?;
    <sql:param value="${param.id_proyecto}" />
</sql:update>

<%-- Redirección de vuelta al dashboard para ver los cambios --%>
<c:redirect url="dashboards/dashboard_estudiante.jsp" />