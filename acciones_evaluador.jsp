<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<%-- 1. Configurar la fuente de datos --%>
<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 2. Capturar los datos del formulario del modal --%>
<c:set var="idDoc" value="${param.id_documento}" />
<c:set var="nuevoEstado" value="${param.txtEstado}" />

<c:choose>
    <c:when test="${not empty idDoc && not empty nuevoEstado}">
        <%-- 3. Ejecutar la actualización en la base de datos --%>
        <sql:update dataSource="${ds}">
            UPDATE documentos_proyecto 
            SET estado_evaluador = ? 
            WHERE id = ?
            <sql:param value="${nuevoEstado}" />
            <sql:param value="${idDoc}" />
        </sql:update>

        <%-- 4. Redirigir de vuelta al dashboard con un mensaje de éxito (opcional) --%>
        <c:redirect url="dashboards/dashboard_evaluadores.jsp?msj=Documento Evaluado Correctamente" />
    </c:when>
    
    <c:otherwise>
        <%-- En caso de error o acceso directo al archivo --%>
        <c:redirect url="dashboards/dashboard_evaluadores.jsp?error=Datos insuficientes" />
    </c:otherwise>
</c:choose>