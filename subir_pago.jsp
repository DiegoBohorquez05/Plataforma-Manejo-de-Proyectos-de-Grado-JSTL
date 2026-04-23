<%-- ... después de procesar la subida del archivo ... --%>
<sql:update dataSource="${ds}">
    <%-- 1. Registramos la solicitud como ya aprobada --%>
    INSERT INTO solicitudes_proyectos (proyecto_id, estudiante_id, archivo_pago, estado_solicitud) 
    VALUES (?, ?, ?, 'Aprobado');
    <sql:param value="${param.id_proyecto}" />
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
    <sql:param value="${nombreArchivo}" />
</sql:update>

<sql:update dataSource="${ds}">
    <%-- 2. Asignamos el estudiante al proyecto y cambiamos el estado --%>
    UPDATE proyectos SET estado = 'Asignado', estudiante_id = ? WHERE id = ?;
    <sql:param value="${sessionScope.usuarioLogueado.id}" />
    <sql:param value="${param.id_proyecto}" />
</sql:update>