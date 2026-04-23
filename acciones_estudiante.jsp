<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<c:if test="${param.accion == 'enviar_pago'}">
    <%-- 1. VALIDACIÓN: Contar si el estudiante ya tiene un proyecto --%>
    <sql:query dataSource="${ds}" var="verificarAsignacion">
        SELECT COUNT(*) as total FROM proyectos WHERE estudiante_id = ?
        <sql:param value="${sessionScope.usuarioLogueado.id}" />
    </sql:query>

    <c:set var="cantidad" value="${verificarAsignacion.rows[0].total}" />

    <c:choose>
        <%-- Si ya tiene 1 o más proyectos, redirigimos con un mensaje de error opcional --%>
        <c:when test="${cantidad > 0}">
            <%-- Aquí podrías pasar un parámetro de error si tu dashboard lo maneja --%>
            <c:redirect url="dashboards/dashboard_estudiante.jsp?error=ya_tienes_proyecto" />
        </c:when>
        
        <%-- Si no tiene proyectos (cantidad == 0), procedemos con la asignación --%>
        <c:otherwise>
            <sql:update dataSource="${ds}">
                UPDATE proyectos 
                SET estado = 'Asignado', 
                    estudiante_id = ? 
                WHERE id = ?
                <sql:param value="${sessionScope.usuarioLogueado.id}" />
                <sql:param value="${param.id_proyecto}" />
            </sql:update>
            <c:redirect url="dashboards/dashboard_estudiante.jsp?success=proyecto_asignado" />
        </c:otherwise>
    </c:choose>
</c:if>

<%-- Redirección por defecto si no entra al IF --%>
<c:if test="${empty param.accion}">
    <c:redirect url="dashboards/dashboard_estudiante.jsp" />
</c:if>