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
    <%-- 1. ACCIÓN: FINALIZAR PROYECTO (AVAL FINAL) --%>
    <c:when test="${param.accion == 'finalizar_proyecto'}">
        <c:set var="idProy" value="${param.id_proyecto}" />
        <c:set var="idDoc" value="${param.id_documento}" />

        <c:choose>
            <c:when test="${not empty idDoc}">
                <%-- A. Actualizar el estado del coordinador en el documento --%>
                <sql:update dataSource="${ds}">
                    UPDATE documentos_proyecto 
                    SET estado_coordinador = 'Aprobado' 
                    WHERE id = ?
                    <sql:param value="${idDoc}" />
                </sql:update>

                <%-- B. Actualizar el estado general del proyecto a Finalizado --%>
                <c:if test="${not empty idProy}">
                    <sql:update dataSource="${ds}">
                        UPDATE proyectos 
                        SET estado = 'Finalizado' 
                        WHERE id = ?
                        <sql:param value="${idProy}" />
                    </sql:update>
                </c:if>

                <c:redirect url="dashboards/dashboard_coordinadores.jsp?msj=Proyecto Finalizado Correctamente" />
            </c:when>
            <c:otherwise>
                <c:redirect url="dashboards/dashboard_coordinadores.jsp?error=No se recibio el ID del documento" />
            </c:otherwise>
        </c:choose>
    </c:when>

    <%-- 2. ACCIÓN: CREAR PROYECTO --%>
    <c:when test="${param.accion == 'crear_proyecto'}">
        <sql:update dataSource="${ds}">
            INSERT INTO proyectos (nombre_proyecto, codigo_proyecto, facultad, descripcion, coordinador_id, estado)
            VALUES (?, ?, ?, ?, ?, 'Disponible')
            <sql:param value="${param.txtNombre}" />
            <sql:param value="${param.txtCodigo}" />
            <sql:param value="${param.txtFacultad}" />
            <sql:param value="${param.txtDesc}" />
            <sql:param value="${sessionScope.usuarioLogueado.id}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:when>

    <%-- 3. ACCIÓN: APROBAR SOLICITUD DE ESTUDIANTE --%>
    <c:when test="${param.accion == 'aprobar_estudiante'}">
        <sql:update dataSource="${ds}">
            UPDATE solicitudes_proyectos SET estado = 'Aprobada' WHERE id = ?
            <sql:param value="${param.id_solicitud}" />
        </sql:update>
        <sql:update dataSource="${ds}">
            UPDATE proyectos SET estudiante_id = ?, estado = 'Asignado' WHERE id = ?
            <sql:param value="${param.id_estudiante}" />
            <sql:param value="${param.id_proyecto}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:when>

    <%-- 4. ACCIÓN: ASIGNAR DIRECTOR Y EVALUADOR (CORREGIDA PARA EVITAR ERROR DE LINK_DRIVE) --%>
    <c:when test="${param.accion == 'asignar_personal'}">
        <%-- Actualizamos la tabla de proyectos --%>
        <sql:update dataSource="${ds}">
            UPDATE proyectos SET director_id = ?, evaluador_id = ? WHERE id = ?
            <sql:param value="${param.id_director}" />
            <sql:param value="${param.id_evaluador}" />
            <sql:param value="${param.id_proyecto}" />
        </sql:update>

        <%-- Registro inicial en documentos_proyecto incluyendo link_drive para evitar error 500 --%>
        <sql:update dataSource="${ds}">
            INSERT INTO documentos_proyecto (proyecto_id, nombre_documento, link_drive, estado_director, estado_evaluador, estado_coordinador)
            VALUES (?, 'Documento Inicial', 'Sin asignar', 'Pendiente', 'Pendiente', 'Pendiente')
            <sql:param value="${param.id_proyecto}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:when>

    <%-- 5. ACCIÓN: RECHAZAR SOLICITUD --%>
    <c:when test="${param.accion == 'rechazar_estudiante'}">
        <sql:update dataSource="${ds}">
            UPDATE solicitudes_proyectos SET estado = 'Rechazada' WHERE id = ?
            <sql:param value="${param.id_solicitud}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:when>

    <%-- REDIRECCIÓN POR DEFECTO --%>
    <c:otherwise>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:otherwise>
</c:choose>