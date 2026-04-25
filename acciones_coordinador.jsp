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
    <%-- ACCIÓN 1: CREAR UN NUEVO PROYECTO --%>
    <c:when test="${param.accion == 'crear_proyecto'}">
        <sql:update dataSource="${ds}">
            INSERT INTO proyectos (codigo_proyecto, nombre_proyecto, facultad, descripcion, estado, coordinador_id)
            VALUES (?, ?, ?, ?, 'Disponible', ?)
            <sql:param value="${param.txtCodigo}" />
            <sql:param value="${param.txtNombre}" />
            <sql:param value="${param.txtFacultad}" />
            <sql:param value="${param.txtDesc}" />
            <sql:param value="${sessionScope.usuarioLogueado.id}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp?msj=proyecto_creado" />
    </c:when>

    <%-- ACCIÓN 2: APROBAR SOLICITUD DE ESTUDIANTE --%>
    <%-- Esta es la validación que pediste: al aprobar, el estudiante se mueve a la tabla proyectos --%>
    <c:when test="${param.accion == 'aprobar_estudiante'}">
        <%-- A. Actualizamos la solicitud a 'Aprobada' --%>
        <sql:update dataSource="${ds}">
            UPDATE solicitudes_proyectos SET estado = 'Aprobada' WHERE id = ?
            <sql:param value="${param.id_solicitud}" />
        </sql:update>

        <%-- B. Vinculamos al estudiante con el proyecto y cambiamos su estado --%>
        <sql:update dataSource="${ds}">
            UPDATE proyectos 
            SET estudiante_id = ?, 
                estado = 'Asignado' 
            WHERE id = ?
            <sql:param value="${param.id_estudiante}" />
            <sql:param value="${param.id_proyecto}" />
        </sql:update>
        
        <c:redirect url="dashboards/dashboard_coordinadores.jsp?msj=estudiante_vinculado" />
    </c:when>

    <%-- ACCIÓN 3: RECHAZAR SOLICITUD (Opcional pero recomendado) --%>
    <c:when test="${param.accion == 'rechazar_estudiante'}">
        <sql:update dataSource="${ds}">
            UPDATE solicitudes_proyectos SET estado = 'Rechazada' WHERE id = ?
            <sql:param value="${param.id_solicitud}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp?msj=solicitud_rechazada" />
    </c:when>

    <%-- ACCIÓN 4: ASIGNAR DIRECTOR Y EVALUADOR --%>
    <c:when test="${param.accion == 'asignar_personal'}">
        <sql:update dataSource="${ds}">
            UPDATE proyectos 
            SET director_id = ?, 
                evaluador_id = ? 
            WHERE id = ?
            <sql:param value="${not empty param.id_director ? param.id_director : null}" />
            <sql:param value="${not empty param.id_evaluador ? param.id_evaluador : null}" />
            <sql:param value="${param.id_proyecto}" />
        </sql:update>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp?msj=personal_actualizado" />
    </c:when>

    <%-- REDIRECCIÓN POR DEFECTO SI NO HAY ACCIÓN --%>
    <c:otherwise>
        <c:redirect url="dashboards/dashboard_coordinadores.jsp" />
    </c:otherwise>
</c:choose>