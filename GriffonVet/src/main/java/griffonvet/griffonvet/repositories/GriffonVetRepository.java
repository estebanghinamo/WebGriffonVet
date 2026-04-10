package griffonvet.griffonvet.repositories;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import griffonvet.griffonvet.components.SimpleJdbcCallFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import griffonvet.griffonvet.service.CloudinaryService;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Repository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.util.*;

@Slf4j
@Repository
public class GriffonVetRepository {
    @Autowired
    private SimpleJdbcCallFactory jdbcCallFactory;
    @Autowired
    private CloudinaryService cloudinaryService;


    @Value("${security.jwt.secret}")
    private String jwtSecret;


    public String registrarUsuario(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_registrar_usuario",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al registrar usuario\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"" + e.getMessage() + "\"}";
        }
    }

    public Map<String, Object> login(String json) {

        SqlParameterSource params = new MapSqlParameterSource()
                .addValue("json", json);

        try {
            Map<String, Object> out = jdbcCallFactory.executeWithOutputs(
                    "sp_login_usuario_json",
                    "dbo",
                    params
            );

            Integer loginValido = (Integer) out.get("login_valido");

            if (loginValido == null || loginValido == 0) {
                return Map.of(
                        "success", 0,
                        "mensaje", "Email o contraseña incorrectos"
                );
            }

            String email = (String) out.get("email_out");
            String rol = (String) out.get("rol");
            Integer idUsuario = (Integer) out.get("id_usuario");

            String token = generarToken(email, idUsuario, rol);

            return Map.of(
                    "success", 1,
                    "token", token
            );

        } catch (Exception e) {
            log.error(e.getMessage());

            return Map.of(
                    "success", 0,
                    "mensaje", "Error interno: " + e.getMessage()
            );
        }
    }

    private String generarToken(String correo, int idUsuario, String rol) {
        Date ahora     = new Date();
        Date expiracion = new Date(ahora.getTime() + 1000 * 60 * 60 * 2);

        return Jwts.builder()
                .setSubject(correo)
                .claim("id_usuario", idUsuario)
                .claim("rol", rol)
                .setIssuedAt(ahora)
                .setExpiration(expiracion)
                .signWith(Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8)), SignatureAlgorithm.HS256)
                .compact();
    }

    public String insertarClienteMascotaAdmin(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_cliente_mascota_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al registrar cliente\"}";
            }

            // 🔹 JSON directo del SP
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerCategorias() {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource();

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_categorias",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarCategoria(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_categoria_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al procesar categoria\"}";
            }

            // 🔹 El SP ya devuelve JSON completo
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerProductos() {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource();

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_productos_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarProducto(MultipartFile imagen, String productoJson) {

        try {
            // 🔹 Parsear JSON
            JsonObject json = JsonParser.parseString(productoJson).getAsJsonObject();

            // 🔹 Subir imagen
            String urlImagen = cloudinaryService.subirArchivo(imagen);

            // 🔹 Agregar URL al JSON
            json.addProperty("imagen_url", urlImagen);

            // 🔹 Ejecutar SP
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json.toString());

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_producto_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al procesar el producto\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String eliminarProducto(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_delete_producto_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al eliminar producto\"}";
            }

            // 🔹 JSON directo del SP
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String actualizarProducto(MultipartFile imagen, String productoJson) {

        try {
            // 🔹 Parsear JSON
            JsonObject json = JsonParser.parseString(productoJson).getAsJsonObject();

            // 🔹 Si viene imagen, la subimos
            if (imagen != null && !imagen.isEmpty()) {
                String urlImagen = cloudinaryService.subirArchivo(imagen);
                json.addProperty("imagen_url", urlImagen);
            }

            // 🔹 Ejecutar SP
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json.toString());

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_update_producto_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al actualizar producto\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerMascotasPorUsuario(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_mascotas_por_usuario_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Sin datos
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin datos\"}";
            }

            // 🔹 Si el SP ya devuelve JSON
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarMascota(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_mascota_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al registrar mascota\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerClientesConMascotas(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_clientes_con_mascotas_json_filtrado",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String getClientes() throws JsonProcessingException {

        try {
            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_clientes_con_mascotas_json",
                    "dbo",
                    new MapSqlParameterSource()
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String getMascota(String json) throws JsonProcessingException {

    try {
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("json", json);

        Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                "sp_get_informacioncompleta_mascota",
                "dbo",
                params
        );

        List<Map<String, Object>> rs =
                (List<Map<String, Object>>) result.get("#result-set-1");

        // 🔹 Sin datos
        if (rs == null || rs.isEmpty()) {
            return "{\"success\": 0, \"mensaje\": \"Sin datos\"}";
        }

        // 🔹 Si el SP ya devuelve JSON
        String jsonResult = (String) rs.get(0).get("json");

        if (jsonResult != null) {
            return jsonResult;
        }

        return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

    } catch (Exception e) {
        return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
    }
}

    public String editarInfoGeneralMascota(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_editar_infogeneral_mascota",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al actualizar mascota\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarConsultaClinica(String json, MultipartFile[] archivos) {

        try {
            JsonObject consulta = JsonParser.parseString(json).getAsJsonObject();
            JsonArray estudios = consulta.getAsJsonArray("estudios");

            int fileIndex = 0;

            if (estudios != null) {
                for (int i = 0; i < estudios.size(); i++) {

                    JsonObject estudio = estudios.get(i).getAsJsonObject();

                    // 🔥 Si hay archivo disponible
                    if (archivos != null && fileIndex < archivos.length) {

                        MultipartFile file = archivos[fileIndex];

                        if (file != null && !file.isEmpty()) {

                            String url = cloudinaryService.subirArchivo(file);
                            estudio.addProperty("resultado", url);

                            fileIndex++; // 🔥 SIEMPRE avanza cuando usa archivo

                        } else {
                            estudio.addProperty("resultado", "");
                        }

                    } else {
                        estudio.addProperty("resultado", "");
                    }

                    // 🔒 fallback (sin archivo)
                    if (!estudio.has("resultado")) {
                        estudio.addProperty("resultado", "");
                    }
                }
            }

            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", consulta.toString());

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_consulta_clinica_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al registrar consulta\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String actualizarConsultaClinica(String json, MultipartFile[] archivos) {

        try {
            JsonObject consulta = JsonParser.parseString(json).getAsJsonObject();
            JsonArray estudios = consulta.getAsJsonArray("estudios");

            int fileIndex = 0;

            if (estudios != null) {
                for (int i = 0; i < estudios.size(); i++) {

                    JsonObject estudio = estudios.get(i).getAsJsonObject();

                    // 🔥 SI HAY ARCHIVO
                    if (archivos != null && fileIndex < archivos.length) {

                        MultipartFile file = archivos[fileIndex];

                        if (file != null && !file.isEmpty()) {

                            String url = cloudinaryService.subirArchivo(file);

                            // 🔥 CLAVE: INYECTAR URL
                            estudio.addProperty("resultado", url);

                            fileIndex++;

                        } else {
                            estudio.addProperty("resultado", "");
                        }

                    } else {
                        estudio.addProperty("resultado", "");
                    }

                    // fallback
                    if (!estudio.has("resultado")) {
                        estudio.addProperty("resultado", "");
                    }
                }
            }

            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", consulta.toString());

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_update_consulta_clinica_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"ok\": false, \"mensaje\": \"Error al actualizar\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"" + e.getMessage() + "\"}";
        }
    }

    public String eliminarConsulta(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_delete_consulta_clinica_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del servidor\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerMedicamentos() {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource();

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_medicamentos",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");


            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarMedicamento(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_medicamento",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al procesar medicamento\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarVacunacion(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_vacunacion_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");


            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al registrar vacunación\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerVacunas() {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource();

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_vacunas",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarVacuna(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_vacuna_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al procesar vacuna\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarDesparasitacion(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_desparasitacion_mascota_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al registrar desparasitación\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerDesparasitaciones() {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource();

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_desparasitaciones",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarDesparasitacionCatalogo(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_desparasitacion_catalogo_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al procesar desparasitante\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarPeso(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_peso_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al registrar peso\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarEnfermedad(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_enfermedad_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al registrar enfermedad\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerEnfermedades() {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource();

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_enfermedades",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarEnfermedadCatalogo(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_enfermedad_catalogo_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al procesar enfermedad\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarAlergia(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_alergia_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al registrar alergia\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerAlergias() {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource();

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_alergias",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarAlergiaCatalogo(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_alergia_catalogo_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al procesar alergia\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerServicios() {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource();

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_servicios_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarServicio(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_servicio_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al insertar servicio\"}";
            }

            // 🔹 JSON directo del SP
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String actualizarServicio(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_update_servicio_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al actualizar servicio\"}";
            }

            // 🔹 JSON directo del SP
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String eliminarServicio(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_delete_servicio_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al eliminar servicio\"}";
            }

            // 🔹 JSON directo del SP
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerServicioPorMascota(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_servicio_por_mascota",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Sin datos
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Servicio no encontrado\"}";
            }

            // 🔹 JSON directo del SP
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerInfoHome(){
        try {
            MapSqlParameterSource params = new MapSqlParameterSource();

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_home_completo_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarInfoHome(MultipartFile imagen,String datajson) {
        try {

            JsonObject json = JsonParser.parseString(datajson).getAsJsonObject();

            if (imagen != null && !imagen.isEmpty()) {
                String urlImagen = cloudinaryService.subirArchivo(imagen);
                json.addProperty("imagen_url", urlImagen);
            }

            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json.toString());

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_informacion_home_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al insertar servicio\"}";
            }

            // 🔹 JSON directo del SP
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String actualizarInfoHome(MultipartFile imagen,String datajson) {

        try {

            JsonObject json = JsonParser.parseString(datajson).getAsJsonObject();

            if (imagen != null && !imagen.isEmpty()) {
                String urlImagen = cloudinaryService.subirArchivo(imagen);
                json.addProperty("imagen_url", urlImagen);
            }

            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json.toString());

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_update_informacion_home_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al actualizar servicio\"}";
            }

            // 🔹 JSON directo del SP
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String eliminarInfoHome(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_delete_informacion_home_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Error al eliminar servicio\"}";
            }

            // 🔹 JSON directo del SP
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String obtenerNoticias(){
        try {
            MapSqlParameterSource params = new MapSqlParameterSource();

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_noticias_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) {
                return "{\"success\": 0, \"mensaje\": \"Sin respuesta del SP\"}";
            }

            Object value = rs.get(0).values().iterator().next();

            return value != null
                    ? value.toString()
                    : "{\"success\": 0, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"success\": 0, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }
}
