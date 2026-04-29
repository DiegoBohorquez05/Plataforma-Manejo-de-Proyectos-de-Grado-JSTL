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
    <%-- 1. ACCIÓN: CREAR NUEVO PROYECTO --%>
    <c:when test="${param.accion == 'crear_proyecto'}">
        <sql:update dataSource="${ds}">
            INSERT INTO proyectos (nombre_proyecto, codigo_proyecto, facultad, descripcion, estado, coordinador_id)
            VALUES (?, ?, ?, ?, 'Disponible', ?)
            <sql:param value="${param.txtNombre}" />
            <sql:param value="${param.txtCodigo}" />
            <sql:param value="${param.txtFacultad}" />
            <sql:param value="${param.txtDesc}" />
            <sql:param value="${sessionScope.usuarioLogueado.id}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:when>

    <%-- 2. ACCIÓN: APROBAR ESTUDIANTE Y COMPAÑEROS --%>
    <c:when test="${param.accion == 'aprobar_estudiante'}">
        <%-- Obtenemos los IDs de la solicitud --%>
        <sql:query dataSource="${ds}" var="resSol">
            SELECT * FROM solicitudes_proyectos WHERE id = ?
            <sql:param value="${param.id_solicitud}" />
        </sql:query>
        
        <c:if test="${resSol.rowCount > 0}">
            <c:set var="sol" value="${resSol.rows[0]}" />
            
            <%-- Actualizamos el proyecto solo con los integrantes --%>
            <sql:update dataSource="${ds}">
                UPDATE proyectos SET 
                    estudiante_id = ?, 
                    companero1_id = ?, 
                    companero2_id = ?, 
                    estado = 'Asignado' 
                WHERE id = ?
                <sql:param value="${sol.estudiante_id}" />
                <sql:param value="${sol.companero1_id}" />
                <sql:param value="${sol.companero2_id}" />
                <sql:param value="${sol.proyecto_id}" />
            </sql:update>

            <%-- Marcamos la solicitud como 'Aprobada' --%>
            <sql:update dataSource="${ds}">
                UPDATE solicitudes_proyectos SET estado = 'Aprobada' WHERE id = ?
                <sql:param value="${param.id_solicitud}" />
            </sql:update>
        </c:if>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:when>

    <%-- 3. ACCIÓN: RECHAZAR ESTUDIANTE --%>
    <c:when test="${param.accion == 'rechazar_estudiante'}">
        <sql:update dataSource="${ds}">
            UPDATE solicitudes_proyectos SET estado = 'Rechazada' WHERE id = ?
            <sql:param value="${param.id_solicitud}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:when>

    <%-- 4. ACCIÓN: ASIGNAR DIRECTOR Y EVALUADOR --%>
    <c:when test="${param.accion == 'asignar_personal'}">
        <sql:update dataSource="${ds}">
            UPDATE proyectos SET 
                director_id = ?, 
                evaluador_id = ? 
            WHERE id = ?
            <sql:param value="${param.id_director}" />
            <sql:param value="${param.id_evaluador}" />
            <sql:param value="${param.id_proyecto}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:when>

    <%-- 5. NUEVA ACCIÓN: FINALIZAR PROYECTO (AVAL FINAL) --%>
    <c:when test="${param.accion == 'finalizar_proyecto'}">
        <sql:update dataSource="${ds}">
            UPDATE proyectos SET estado = 'Finalizado' WHERE id = ?
            <sql:param value="${param.id_proyecto}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:when>

    <%-- REDIRECCIÓN POR DEFECTO --%>
    <c:otherwise>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:otherwise>
</c:choose>