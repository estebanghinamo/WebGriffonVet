package griffonvet.griffonvet.repositories;

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

    public Map<String,String> login(String json) {
        SqlParameterSource params = new MapSqlParameterSource()
                .addValue("json", json);
        try {
            Map<String, Object> out = jdbcCallFactory.executeWithOutputs("sp_login_usuario_json", "dbo", params);

            Integer loginValido = (Integer) out.get("login_valido");

            if (loginValido == null || loginValido == 0) {
                return null;
            }

            String email = (String) out.get("email_out");
            String rol   = (String) out.get("rol");
            String token = generarToken(email);

            return  Map.of(
                    "token", token,
                    "rol",   rol
            );

        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            log.error(e.getMessage());
            throw new RuntimeException("Error al loguearse: " + e.getMessage());
        }
    }

    private String generarToken(String correo) {
        Date ahora = new Date();
        Date expiracion = new Date(ahora.getTime() + 1000 * 60 * 60 * 2);

        return Jwts.builder()
                .setSubject(correo)
                .setIssuedAt(ahora)
                .setExpiration(expiracion)
                .signWith(Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8)), SignatureAlgorithm.HS256)
                .compact();
    }

    public String getClientes() throws JsonProcessingException {

        Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                "sp_get_clientes_con_mascotas_json",
                "dbo",
                new MapSqlParameterSource()
        );

        List<Map<String, Object>> rs =
                (List<Map<String, Object>>) result.get("#result-set-1");

        if (rs == null || rs.isEmpty()) {
            return "{\"productos\": []}";
        }

        // El SP ya devuelve JSON → lo sacamos directo
        Object value = rs.get(0).values().iterator().next();

        if (value == null) {
            return "{\"productos\": []}";
        }

        return value.toString();
    }



    public String registrarUsuario(String json) {

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
            return "{\"ok\": false, \"mensaje\": \"Error al registrar usuario\"}";
        }

        // Convertimos el resultado a JSON string
        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.writeValueAsString(rs.get(0));
        } catch (Exception e) {
            return "{\"ok\": false, \"mensaje\": \"Error al parsear respuesta\"}";
        }
    }

    public String obtenerProductos() {

        MapSqlParameterSource params = new MapSqlParameterSource();

        Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                "sp_get_productos_json",
                "dbo",
                params
        );

        List<Map<String, Object>> rs =
                (List<Map<String, Object>>) result.get("#result-set-1");

        if (rs == null || rs.isEmpty()) {
            return "{\"productos\": []}";
        }

        // El SP ya devuelve JSON → lo sacamos directo
        Object value = rs.get(0).values().iterator().next();

        if (value == null) {
            return "{\"productos\": []}";
        }

        return value.toString();
    }

    public String insertarProducto(MultipartFile imagen, String productoJson) {

        try {
            // 🔹 Parsear JSON
            JsonObject json = JsonParser.parseString(productoJson).getAsJsonObject();

            // 🔹 Subir imagen
            String urlImagen = cloudinaryService.subirImagen(imagen);

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
                return "{\"ok\": false, \"mensaje\": \"Error al procesar el producto\"}";
            }

            // 🔹 Convertir a JSON string
            ObjectMapper mapper = new ObjectMapper();
            return mapper.writeValueAsString(rs.get(0));

        } catch (Exception e) {
            return "{\"ok\": false, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String actualizarProducto(MultipartFile imagen, String productoJson) {

        try {
            // 🔹 Parsear JSON
            JsonObject json = JsonParser.parseString(productoJson).getAsJsonObject();

            // 🔹 Si viene imagen, la subimos
            if (imagen != null && !imagen.isEmpty()) {
                String urlImagen = cloudinaryService.subirImagen(imagen);
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
                return "{\"ok\": false, \"mensaje\": \"Error al actualizar producto\"}";
            }

            // 🔹 Si el SP ya devuelve JSON → lo devolvés directo
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"ok\": false, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"ok\": false, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
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
                return "{\"ok\": false, \"mensaje\": \"Error al registrar mascota\"}";
            }

            // 🔹 Si el SP devuelve JSON → lo usamos directo
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"ok\": false, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"ok\": false, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
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

            // 🔹 Sin resultados
            if (rs == null || rs.isEmpty()) {
                return "{\"clientes\": []}";
            }

            // 🔹 El SP ya devuelve JSON
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"clientes\": []}";

        } catch (Exception e) {
            return "{\"ok\": false, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
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

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"ok\": false, \"mensaje\": \"Error al actualizar mascota\"}";
            }

            // 🔹 El SP devuelve JSON
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"ok\": false, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"ok\": false, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarConsultaClinica(String json) {

        try {
            MapSqlParameterSource params = new MapSqlParameterSource()
                    .addValue("json", json);

            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_insert_consulta_clinica_json",
                    "dbo",
                    params
            );

            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            // 🔹 Error
            if (rs == null || rs.isEmpty()) {
                return "{\"ok\": false, \"mensaje\": \"Error al registrar consulta clínica\"}";
            }

            // 🔹 El SP ya devuelve JSON
            Object value = rs.get(0).values().iterator().next();

            if (value != null) {
                return value.toString();
            }

            return "{\"ok\": false, \"mensaje\": \"Respuesta vacía\"}";

        } catch (Exception e) {
            return "{\"ok\": false, \"mensaje\": \"Error interno: " + e.getMessage() + "\"}";
        }
    }



}
