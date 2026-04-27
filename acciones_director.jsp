<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ include file="WEB-INF/conexion.jspf" %>

<%-- 1. Captura de parámetros enviados desde el Dashboard --%>
<c:set var="idDoc" value="${param.id_documento}" />
<c:set var="nuevoEstado" value="${param.txtEstado}" />

<c:choose>
    <%-- 2. Validación: Solo procedemos si el ID no está vacío --%>
    <c:when test="${not empty idDoc}">
        
        <sql:setDataSource var="ds" 
            driver="${applicationScope.dbDriver}" 
            url="${applicationScope.dbUrl}" 
            user="${applicationScope.dbUser}" 
            password="${applicationScope.dbPass}" />

        <%-- 3. UPDATE directo en la tabla documentos_proyecto --%>
        <sql:update dataSource="${ds}">
            UPDATE documentos_proyecto 
            SET estado_director = ? 
            WHERE id = ?
            <sql:param value="${nuevoEstado}" />
            <sql:param value="${idDoc}" />
        </sql:update>

        <%-- 
           4. Redirección al Dashboard. 
           Usamos la ruta relativa 'dashboards/' porque este archivo está en la raíz 
           y el dashboard dentro de esa carpeta.
        --%>
        <c:redirect url="dashboards/dashboard_directores.jsp?success=updated" />
    </c:when>

    <c:otherwise>
        <%-- 5. Manejo de error si el ID sigue llegando vacío --%>
        <div style="background: #ff0000; color: white; padding: 30px; font-family: Arial; text-align: center;">
            <h1 style="margin-bottom: 10px;">¡ERROR CRÍTICO DE CAPTURA!</h1>
            <p style="font-size: 1.2rem;">No se recibió el <b>ID del documento</b> desde el formulario.</p>
            <hr style="border: 1px solid rgba(255,255,255,0.3); margin: 20px 0;">
            <p>Estado que intentaste enviar: <b>${not empty nuevoEstado ? nuevoEstado : 'Nulo'}</b></p>
            <p>ID recibido: <b>[${idDoc}]</b></p>
            <br>
            <a href="dashboards/dashboard_directores.jsp" style="background: white; color: red; padding: 10px 20px; text-decoration: none; border-radius: 5px; font-weight: bold;">
                VOLVER AL DASHBOARD
            </a>
        </div>
    </c:otherwise>
</c:choose>