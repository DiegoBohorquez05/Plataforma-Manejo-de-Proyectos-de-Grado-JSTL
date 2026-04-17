<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>

<%-- 1. Conexión --%>
<%@ include file="WEB-INF/conexion.jspf" %>

<sql:setDataSource var="ds" 
    driver="${applicationScope.dbDriver}" 
    url="${applicationScope.dbUrl}" 
    user="${applicationScope.dbUser}" 
    password="${applicationScope.dbPass}" />

<%-- 2. Lógica de Procesamiento --%>
<c:choose>
    
    <%-- CASO: CREAR USUARIO --%>
    <c:when test="${param.accion == 'crear'}">
        <%-- La variable ${param.tabla} llega desde el campo oculto del modal --%>
        <sql:update dataSource="${ds}">
            INSERT INTO ${param.tabla} (nombre, gmail, password) 
            VALUES (?, ?, ?);
            <sql:param value="${param.txtNombre}" />
            <sql:param value="${param.txtGmail}" />
            <sql:param value="${param.txtPass}" />
        </sql:update>
    </c:when>

    <%-- CASO: ELIMINAR USUARIO --%>
    <c:when test="${param.accion == 'eliminar'}">
        <sql:update dataSource="${ds}">
            DELETE FROM ${param.tabla} WHERE id = ?;
            <sql:param value="${param.id}" />
        </sql:update>
    </c:when>

    <%-- Aquí podrías añadir el caso 'editar' más adelante --%>

</c:choose>

<%-- 3. Redirección final: Volvemos al dashboard para ver los cambios --%>
<c:redirect url="dashboard_admin.jsp" />