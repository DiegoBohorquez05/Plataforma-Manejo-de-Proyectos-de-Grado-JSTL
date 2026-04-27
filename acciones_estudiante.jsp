<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<c:set var="accion" value="${param.accion}" />

<c:choose>
    <%-- CASO 1: ENVIAR SOLICITUD DE PROYECTO --%>
    <c:when test="${accion == 'enviar_solicitud'}">
        <sql:update dataSource="${ds}">
            INSERT INTO solicitudes_proyectos (proyecto_id, estudiante_id, compañero1_id, compañero2_id, link_drive, estado, fecha_solicitud)
            VALUES (?, ?, ?, ?, ?, 'Pendiente', NOW())
            <sql:param value="${param.id_proyecto}" />
            <sql:param value="${sessionScope.usuarioLogueado.id}" />
            <sql:param value="${not empty param.id_companero1 ? param.id_companero1 : null}" />
            <sql:param value="${not empty param.id_companero2 ? param.id_companero2 : null}" />
            <sql:param value="${param.txtLink}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_estudiante.jsp?msj=Solicitud enviada correctamente" />
    </c:when>

    <%-- CASO 2: SUBIR NUEVO DOCUMENTO / AVANCE --%>
    <c:when test="${accion == 'subir_documento'}">
        <%-- VALIDACIÓN DE FLUJO: Consultamos el estado del documento anterior --%>
        <sql:query dataSource="${ds}" var="ultimoDoc">
            SELECT estado_evaluador FROM documentos_proyecto 
            WHERE proyecto_id = ? 
            ORDER BY id DESC LIMIT 1
            <sql:param value="${param.id_proyecto}" />
        </sql:query>

        <%-- Definimos el estado inicial para el Director --%>
        <c:set var="estadoDirectorInicial" value="Pendiente" />
        
        <%-- Si el evaluador pidió corregir, saltamos al director marcándolo como Aprobado --%>
        <c:if test="${ultimoDoc.rowCount > 0 && ultimoDoc.rows[0].estado_evaluador == 'Corregir'}">
            <c:set var="estadoDirectorInicial" value="Aprobado" />
        </c:if>

        <%-- Inserción del documento con la lógica de estado aplicada --%>
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

    <c:otherwise>
        <c:redirect url="dashboards/dashboard_estudiante.jsp?error=Accion no reconocida" />
    </c:otherwise>
</c:choose>