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
    <%-- ACCIÓN: ENVIAR SOLICITUD DE PROYECTO --%>
    <c:when test="${param.accion == 'enviar_solicitud'}">
        <c:catch var="error">
            <sql:update dataSource="${ds}">
                INSERT INTO solicitudes_proyectos (
                    estudiante_id, 
                    proyecto_id, 
                    link_drive, 
                    compañero1_id, 
                    compañero2_id, 
                    estado
                ) VALUES (?, ?, ?, ?, ?, 'Pendiente')
                
                <sql:param value="${sessionScope.usuarioLogueado.id}" />
                <sql:param value="${param.id_proyecto}" />
                <sql:param value="${param.txtLink}" />
                
                <%-- Manejo de nulos para compañeros opcionales --%>
                <c:choose>
                    <c:when test="${not empty param.id_companero1}">
                        <sql:param value="${param.id_companero1}" />
                    </c:when>
                    <c:otherwise><sql:param value="${null}" /></c:otherwise>
                </c:choose>
                
                <c:choose>
                    <c:when test="${not empty param.id_companero2}">
                        <sql:param value="${param.id_companero2}" />
                    </c:when>
                    <c:otherwise><sql:param value="${null}" /></c:otherwise>
                </c:choose>
            </sql:update>
            
            <%-- Opcional: Cambiar estado del proyecto a 'En Revisión' si lo deseas --%>
            <%-- 
            <sql:update dataSource="${ds}">
                UPDATE proyectos SET estado = 'Pendiente' WHERE id = ?
                <sql:param value="${param.id_proyecto}" />
            </sql:update> 
            --%>
            
            <c:redirect url="dashboards/dashboard_estudiante.jsp?msg=solicitud_enviada" />
        </c:catch>
        
        <c:if test="${not empty error}">
            <div class="alert alert-danger">
                Error al procesar la solicitud: ${error.message}
                <a href="dashboards/dashboard_estudiante.jsp">Volver</a>
            </div>
        </c:if>
    </c:when>

    <%-- OTRAS ACCIONES (EJ. SUBIR ENTREGABLES EN EL FUTURO) --%>
    <c:otherwise>
        <c:redirect url="dashboards/dashboard_estudiante.jsp" />
    </c:otherwise>
</c:choose>