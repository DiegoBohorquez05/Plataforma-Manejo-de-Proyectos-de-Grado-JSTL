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
        <c:choose>
            <%-- AJUSTE DINÁMICO DE COLUMNAS SEGÚN LA TABLA --%>
            <c:when test="${param.tabla == 'estudiantes'}">
                <sql:update dataSource="${ds}">
                    INSERT INTO estudiantes (nombre_estudiante, gmail, password) 
                    VALUES (?, ?, ?);
                    <sql:param value="${param.txtNombre}" />
                    <sql:param value="${param.txtGmail}" />
                    <sql:param value="${param.txtPass}" />
                </sql:update>
            </c:when>
            
            <c:when test="${param.tabla == 'directores'}">
                <sql:update dataSource="${ds}">
                    INSERT INTO directores (nombre_director, gmail, password) 
                    VALUES (?, ?, ?);
                    <sql:param value="${param.txtNombre}" />
                    <sql:param value="${param.txtGmail}" />
                    <sql:param value="${param.txtPass}" />
                </sql:update>
            </c:when>

            <c:when test="${param.tabla == 'evaluadores'}">
                <sql:update dataSource="${ds}">
                    INSERT INTO evaluadores (nombre_evaluador, gmail, password) 
                    VALUES (?, ?, ?);
                    <sql:param value="${param.txtNombre}" />
                    <sql:param value="${param.txtGmail}" />
                    <sql:param value="${param.txtPass}" />
                </sql:update>
            </c:when>

            <c:when test="${param.tabla == 'coordinadores'}">
                <sql:update dataSource="${ds}">
                    INSERT INTO coordinadores (nombre_coordinador, gmail, password) 
                    VALUES (?, ?, ?);
                    <sql:param value="${param.txtNombre}" />
                    <sql:param value="${param.txtGmail}" />
                    <sql:param value="${param.txtPass}" />
                </sql:update>
            </c:when>
        </c:choose>
    </c:when>

    <%-- CASO: ELIMINAR USUARIO --%>
    <c:when test="${param.accion == 'eliminar'}">
        <sql:update dataSource="${ds}">
            DELETE FROM ${param.tabla} WHERE id = ?;
            <sql:param value="${param.id}" />
        </sql:update>
    </c:when>

</c:choose>

<%-- 3. Redirección final --%>
<c:redirect url="dashboard_admin.jsp" />