package griffonvet.griffonvet.repositories;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import griffonvet.griffonvet.components.SimpleJdbcCallFactory;
import griffonvet.griffonvet.service.CloudinaryService;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.stereotype.Repository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.util.*;

@Slf4j
@Repository
@RequiredArgsConstructor
public class GriffonVetRepository {

    private final SimpleJdbcCallFactory jdbcCallFactory;
    private final CloudinaryService cloudinaryService;

    @Value("${security.jwt.secret}")
    private String jwtSecret;

    // ─────────────────────────────────────────────
    // Helpers internos
    // ─────────────────────────────────────────────

    private static final String ERR_EMPTY   = "{\"success\":0,\"mensaje\":\"Sin respuesta del SP\"}";
    private static final String ERR_NULL    = "{\"success\":0,\"mensaje\":\"Respuesta vacía\"}";

    /**
     * Ejecuta un SP y extrae el primer valor del primer resultado.
     * Cubre el 95% de los métodos del repositorio.
     */
    private String ejecutarSp(String sp, MapSqlParameterSource params) {
        try {
            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(sp, "dbo", params);

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) return ERR_EMPTY;

            Object value = rs.get(0).values().iterator().next();
            return value != null ? value.toString() : ERR_NULL;

        } catch (Exception e) {
            return "{\"success\":0,\"mensaje\":\"Error interno: " + e.getMessage() + "\"}";
        }
    }

    /** Sobrecarga sin parámetros para SPs de solo lectura. */
    private String ejecutarSp(String sp) {
        return ejecutarSp(sp, new MapSqlParameterSource());
    }

    /** Sobrecarga con un único parámetro JSON, el caso más común. */
    private String ejecutarSp(String sp, String json) {
        return ejecutarSp(sp, new MapSqlParameterSource().addValue("json", json));
    }

    private String generarToken(String correo, int idUsuario, String rol) {
        Date ahora      = new Date();
        Date expiracion = new Date(ahora.getTime() + 1000L * 60 * 60 * 2);

        return Jwts.builder()
                .setSubject(correo)
                .claim("id_usuario", idUsuario)
                .claim("rol", rol)
                .setIssuedAt(ahora)
                .setExpiration(expiracion)
                .signWith(
                        Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8)),
                        SignatureAlgorithm.HS256
                )
                .compact();
    }

    /**
     * Sube archivos a Cloudinary e inyecta las URLs en el array "estudios" del JSON.
     * Lógica compartida entre insertarConsultaClinica y actualizarConsultaClinica.
     */
    private JsonObject procesarEstudios(String json, MultipartFile[] archivos) {
        JsonObject consulta = JsonParser.parseString(json).getAsJsonObject();
        JsonArray estudios  = consulta.getAsJsonArray("estudios");

        if (estudios == null) return consulta;

        int fileIndex = 0;
        for (int i = 0; i < estudios.size(); i++) {
            JsonObject estudio = estudios.get(i).getAsJsonObject();

            if (archivos != null && fileIndex < archivos.length) {
                MultipartFile file = archivos[fileIndex];
                if (file != null && !file.isEmpty()) {
                    try {
                        estudio.addProperty("resultado", cloudinaryService.subirArchivo(file));
                    } catch (Exception e) {
                        estudio.addProperty("resultado", "");
                    }
                    fileIndex++;
                } else {
                    estudio.addProperty("resultado", "");
                }
            } else {
                estudio.addProperty("resultado", "");
            }
        }
        return consulta;
    }

    // ─────────────────────────────────────────────
    // Usuarios
    // ─────────────────────────────────────────────

    public String registrarUsuario(String json) {
        return ejecutarSp("sp_registrar_usuario", json);
    }

    public Map<String, Object> login(String json) {
        try {
            var params = new MapSqlParameterSource().addValue("json", json);
            Map<String, Object> out = jdbcCallFactory.executeWithOutputs(
                    "sp_login_usuario_json", "dbo", params);

            Integer loginValido = (Integer) out.get("login_valido");
            if (loginValido == null || loginValido == 0) {
                return Map.of("success", 0, "mensaje", "Email o contraseña incorrectos");
            }

            String  email     = (String)  out.get("email_out");
            String  rol       = (String)  out.get("rol");
            Integer idUsuario = (Integer) out.get("id_usuario");

            return Map.of("success", 1, "token", generarToken(email, idUsuario, rol));

        } catch (Exception e) {
            log.error(e.getMessage());
            return Map.of("success", 0, "mensaje", "Error interno: " + e.getMessage());
        }
    }

    // ─────────────────────────────────────────────
    // Clientes y mascotas
    // ─────────────────────────────────────────────

    public String insertarClienteMascotaAdmin(String json) {
        return ejecutarSp("sp_insert_cliente_mascota_json", json);
    }

    public String getClientes() {
        return ejecutarSp("sp_get_clientes_con_mascotas_json");
    }

    public String obtenerClientesConMascotas(String json) {
        return ejecutarSp("sp_get_clientes_con_mascotas_json_filtrado", json);
    }

    public String obtenerMascotasPorUsuario(String json) {
        return ejecutarSp("sp_get_mascotas_por_usuario_json", json);
    }

    /**
     * getMascota extrae la columna "json" por nombre en lugar del primer valor genérico,
     * por eso mantiene su propia implementación.
     */
    public String getMascota(String json) {
        try {
            var params = new MapSqlParameterSource().addValue("json", json);
            Map<String, Object> result = jdbcCallFactory.executeWithOutputs(
                    "sp_get_informacioncompleta_mascota", "dbo", params);

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> rs =
                    (List<Map<String, Object>>) result.get("#result-set-1");

            if (rs == null || rs.isEmpty()) return ERR_EMPTY;

            String jsonResult = (String) rs.get(0).get("json");
            return jsonResult != null ? jsonResult : ERR_NULL;

        } catch (Exception e) {
            return "{\"success\":0,\"mensaje\":\"Error interno: " + e.getMessage() + "\"}";
        }
    }

    public String insertarMascota(String json) {
        return ejecutarSp("sp_insert_mascota_json", json);
    }

    public String editarInfoGeneralMascota(String json) {
        return ejecutarSp("sp_editar_infogeneral_mascota", json);
    }

    // ─────────────────────────────────────────────
    // Consultas clínicas
    // ─────────────────────────────────────────────

    public String insertarConsultaClinica(String json, MultipartFile[] archivos) {
        JsonObject consulta = procesarEstudios(json, archivos);
        return ejecutarSp("sp_insert_consulta_clinica_json", consulta.toString());
    }

    public String actualizarConsultaClinica(String json, MultipartFile[] archivos) {
        JsonObject consulta = procesarEstudios(json, archivos);
        return ejecutarSp("sp_update_consulta_clinica_json", consulta.toString());
    }

    public String eliminarConsulta(String json) {
        return ejecutarSp("sp_delete_consulta_clinica_json", json);
    }

    // ─────────────────────────────────────────────
    // Categorías
    // ─────────────────────────────────────────────

    public String obtenerCategorias() {
        return ejecutarSp("sp_get_categorias");
    }

    public String insertarCategoria(String json) {
        return ejecutarSp("sp_insert_categoria_json", json);
    }

    // ─────────────────────────────────────────────
    // Productos
    // ─────────────────────────────────────────────

    public String obtenerProductos() {
        return ejecutarSp("sp_get_productos_json");
    }

    public String insertarProducto(MultipartFile imagen, String productoJson) {
        return ejecutarSpConImagen("sp_insert_producto_json", imagen, productoJson);
    }

    public String actualizarProducto(MultipartFile imagen, String productoJson) {
        return ejecutarSpConImagen("sp_update_producto_json", imagen, productoJson);
    }

    public String eliminarProducto(String json) {
        return ejecutarSp("sp_delete_producto_json", json);
    }

    // ─────────────────────────────────────────────
    // Medicamentos
    // ─────────────────────────────────────────────

    public String obtenerMedicamentos() {
        return ejecutarSp("sp_get_medicamentos");
    }

    public String insertarMedicamento(String json) {
        return ejecutarSp("sp_insert_medicamento", json);
    }

    // ─────────────────────────────────────────────
    // Vacunas y vacunación
    // ─────────────────────────────────────────────

    public String obtenerVacunas() {
        return ejecutarSp("sp_get_vacunas");
    }

    public String insertarVacuna(String json) {
        return ejecutarSp("sp_insert_vacuna_json", json);
    }

    public String insertarVacunacion(String json) {
        return ejecutarSp("sp_insert_vacunacion_json", json);
    }

    // ─────────────────────────────────────────────
    // Desparasitación
    // ─────────────────────────────────────────────

    public String obtenerDesparasitaciones() {
        return ejecutarSp("sp_get_desparasitaciones");
    }

    public String insertarDesparasitacion(String json) {
        return ejecutarSp("sp_insert_desparasitacion_mascota_json", json);
    }

    public String insertarDesparasitacionCatalogo(String json) {
        return ejecutarSp("sp_insert_desparasitacion_catalogo_json", json);
    }

    // ─────────────────────────────────────────────
    // Peso
    // ─────────────────────────────────────────────

    public String insertarPeso(String json) {
        return ejecutarSp("sp_insert_peso_json", json);
    }

    // ─────────────────────────────────────────────
    // Enfermedades
    // ─────────────────────────────────────────────

    public String obtenerEnfermedades() {
        return ejecutarSp("sp_get_enfermedades");
    }

    public String insertarEnfermedad(String json) {
        return ejecutarSp("sp_insert_enfermedad_json", json);
    }

    public String insertarEnfermedadCatalogo(String json) {
        return ejecutarSp("sp_insert_enfermedad_catalogo_json", json);
    }

    // ─────────────────────────────────────────────
    // Alergias
    // ─────────────────────────────────────────────

    public String obtenerAlergias() {
        return ejecutarSp("sp_get_alergias");
    }

    public String insertarAlergia(String json) {
        return ejecutarSp("sp_insert_alergia_json", json);
    }

    public String insertarAlergiaCatalogo(String json) {
        return ejecutarSp("sp_insert_alergia_catalogo_json", json);
    }

    // ─────────────────────────────────────────────
    // Servicios
    // ─────────────────────────────────────────────

    public String obtenerServicios() {
        return ejecutarSp("sp_get_servicios_json");
    }

    public String insertarServicio(String json) {
        return ejecutarSp("sp_insert_servicio_json", json);
    }

    public String actualizarServicio(String json) {
        return ejecutarSp("sp_update_servicio_json", json);
    }

    public String eliminarServicio(String json) {
        return ejecutarSp("sp_delete_servicio_json", json);
    }

    public String obtenerServicioPorMascota(String json) {
        return ejecutarSp("sp_get_servicio_por_mascota", json);
    }

    // ─────────────────────────────────────────────
    // Home
    // ─────────────────────────────────────────────

    public String obtenerInfoHome() {
        return ejecutarSp("sp_get_home_completo_json");
    }

    public String insertarInfoHome(MultipartFile imagen, String datajson) {
        return ejecutarSpConImagen("sp_insert_informacion_home_json", imagen, datajson);
    }

    public String actualizarInfoHome(MultipartFile imagen, String datajson) {
        return ejecutarSpConImagen("sp_update_informacion_home_json", imagen, datajson);
    }

    public String eliminarInfoHome(String json) {
        return ejecutarSp("sp_delete_informacion_home_json", json);
    }

    /** Sube imagen opcional e inyecta imagen_url antes de llamar al SP. */
    private String ejecutarSpConImagen(String sp, MultipartFile imagen, String datajson) {
        try {
            JsonObject json = JsonParser.parseString(datajson).getAsJsonObject();
            if (imagen != null && !imagen.isEmpty()) {
                json.addProperty("imagen_url", cloudinaryService.subirArchivo(imagen));
            }
            return ejecutarSp(sp, json.toString());
        } catch (Exception e) {
            return "{\"success\":0,\"mensaje\":\"Error interno: " + e.getMessage() + "\"}";
        }
    }

    // ─────────────────────────────────────────────
    // Noticias y especies
    // ─────────────────────────────────────────────

    public String obtenerNoticias() {
        return ejecutarSp("sp_get_noticias_json");
    }

    public String obtenerEspecies() {
        return ejecutarSp("sp_get_especies");
    }
}