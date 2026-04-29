<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 1. VERIFICACIÓN DE SEGURIDAD --%>
<c:if test="${empty sessionScope.usuarioLogueado}">
    <c:redirect url="login.jsp?error=Sesion expirada, por favor ingrese de nuevo" />
</c:if>

<c:set var="accion" value="${param.accion}" />

<c:choose>
    <%-- CASO 1: ENVIAR SOLICITUD DE PROYECTO (CORREGIDO A COMPANERO) --%>
    <c:when test="${accion == 'enviar_solicitud'}">
        <sql:update dataSource="${ds}">
            INSERT INTO solicitudes_proyectos (proyecto_id, estudiante_id, companero1_id, companero2_id, link_drive, estado, fecha_solicitud)
            VALUES (?, ?, ?, ?, ?, 'Pendiente', NOW())
            <sql:param value="${param.id_proyecto}" />
            <sql:param value="${sessionScope.usuarioLogueado.id}" />
            <%-- Aseguramos que los IDs de compañeros se envíen como NULL si vienen vacíos --%>
            <sql:param value="${not empty param.id_companero1 ? param.id_companero1 : null}" />
            <sql:param value="${not empty param.id_companero2 ? param.id_companero2 : null}" />
            <sql:param value="${param.txtLink}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_estudiante.jsp?msj=Solicitud enviada correctamente" />
    </c:when>

    <%-- CASO 2: SUBIR NUEVO DOCUMENTO / AVANCE --%>
    <c:when test="${accion == 'subir_documento'}">
        <%-- Consultamos el estado del último documento para ver si es una re-entrega --%>
        <sql:query dataSource="${ds}" var="ultimoDoc">
            SELECT estado_evaluador FROM documentos_proyecto 
            WHERE proyecto_id = ? 
            ORDER BY id DESC LIMIT 1
            <sql:param value="${param.id_proyecto}" />
        </sql:query>

        <c:set var="estadoDirectorInicial" value="Pendiente" />
        
        <%-- Lógica: Si el último fue rechazado por evaluador, el director ya lo conoce, se pone como aprobado --%>
        <c:if test="${ultimoDoc.rowCount > 0 && ultimoDoc.rows[0].estado_evaluador == 'Corregir'}">
            <c:set var="estadoDirectorInicial" value="Aprobado" />
        </c:if>

        <sql:update dataSource="${ds}">
            INSERT INTO documentos_proyecto 
            (proyecto_id, nombre_documento, link_drive, fecha_subida, estado_director, estado_evaluador, estado_coordinador) 
            VALUES (?, ?, ?, NOW(), ?, 'Pendiente', 'Pendiente')
            <sql:param value="${param.id_proyecto}" />
            <sql:param value="${param.txtNombreDoc}" />
            <sql:param value="${param.txtLinkDrive}" />
            <sql:param value="${estadoDirectorInicial}" />
        </sql:update>
        
        <c:redirect url="dashboards/dashboard_estudiante.jsp?msj=Documento subido con exito" />
    </c:when>

    <%-- CASO POR DEFECTO --%>
    <c:otherwise>
        <c:redirect url="dashboards/dashboard_estudiante.jsp?error=Accion no reconocida" />
    </c:otherwise>
</c:choose>