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
    <%-- ========================================================
         ACCIÓN 1: ENVIAR SOLICITUD DE PROYECTO (La que ya tenías)
         ======================================================== --%>
    <c:when test="${param.accion == 'enviar_solicitud'}">
        <%-- Insertar la solicitud en la tabla de trámites --%>
        <sql:update dataSource="${ds}">
            INSERT INTO solicitudes_proyectos (proyecto_id, estudiante_id, compañero1_id, compañero2_id, link_propuesta, estado)
            VALUES (?, ?, ?, ?, ?, 'Pendiente')
            <sql:param value="${param.id_proyecto}" />
            <sql:param value="${sessionScope.usuarioLogueado.id}" />
            <sql:param value="${not empty param.id_companero1 ? param.id_companero1 : null}" />
            <sql:param value="${not empty param.id_companero2 ? param.id_companero2 : null}" />
            <sql:param value="${param.txtLink}" />
        </sql:update>

        <%-- Opcional: Marcar el proyecto como 'En Proceso' para que no lo vean otros --%>
        <sql:update dataSource="${ds}">
            UPDATE proyectos SET estado = 'En Proceso' WHERE id = ?
            <sql:param value="${param.id_proyecto}" />
        </sql:update>

        <c:redirect url="dashboards/dashboard_estudiante.jsp" />
    </c:when>

    <%-- ========================================================
         ACCIÓN 2: SUBIR DOCUMENTO / AVANCE (La nueva funcionalidad)
         ======================================================== --%>
    <c:when test="${param.accion == 'subir_documento'}">
        <sql:update dataSource="${ds}">
            INSERT INTO documentos_proyecto (proyecto_id, link_drive, nombre_documento)
            VALUES (?, ?, ?)
            <sql:param value="${param.id_proyecto}" />
            <sql:param value="${param.txtLinkDrive}" />
            <sql:param value="${param.txtNombreDoc}" />
        </sql:update>
        
        <%-- Volvemos al dashboard para ver el historial actualizado --%>
        <c:redirect url="dashboards/dashboard_estudiante.jsp" />
    </c:when>

    <%-- CASO POR DEFECTO: Si alguien entra aquí sin acción, mandarlo al index --%>
    <c:otherwise>
        <c:redirect url="index.jsp" />
    </c:otherwise>
</c:choose>