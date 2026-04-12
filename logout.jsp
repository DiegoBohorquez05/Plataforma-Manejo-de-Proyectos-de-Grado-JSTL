<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    // 1. Invalidar la sesión actual por completo
    // Esto borra la variable 'adminLogueado' y cualquier otro dato guardado
    session.invalidate();
%>

<%-- 2. Redirigir al usuario al index (Portal Principal) --%>
<c:redirect url="index.jsp" />