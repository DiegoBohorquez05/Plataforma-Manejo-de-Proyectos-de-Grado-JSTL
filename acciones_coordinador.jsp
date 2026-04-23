<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<c:if test="${param.accion == 'crear_proyecto'}">
    <%-- Agregamos 'facultad' al INSERT para evitar el error 500 --%>
    <sql:update dataSource="${ds}">
        INSERT INTO proyectos (nombre_proyecto, descripcion, facultad, codigo_proyecto, coordinador_id, estado) 
        VALUES (?, ?, ?, ?, ?, 'Disponible')
        <sql:param value="${param.txtNombre}" />
        <sql:param value="${param.txtDesc}" />
        <sql:param value="Ingeniería" /> <%-- Valor por defecto o puedes usar un param --%>
        <sql:param value="${param.txtCodigo}" />
        <sql:param value="${sessionScope.usuarioLogueado.id}" />
    </sql:update>
</c:if>

<c:redirect url="dashboards/dashboard_coordinadores.jsp" />