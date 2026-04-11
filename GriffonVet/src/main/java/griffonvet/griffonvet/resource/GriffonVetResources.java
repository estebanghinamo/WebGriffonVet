package griffonvet.griffonvet.resource;

import com.fasterxml.jackson.core.JsonProcessingException;
import griffonvet.griffonvet.config.JsonUtils;
import griffonvet.griffonvet.repositories.GriffonVetRepository;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;
import java.util.function.Supplier;

@RestController
@RequestMapping("griffonVet")
public class GriffonVetResources {

    private final GriffonVetRepository griffonVetRepository;
    private final JsonUtils jsonUtils;

    public GriffonVetResources(GriffonVetRepository griffonVetRepository, JsonUtils jsonUtils) {
        this.griffonVetRepository = griffonVetRepository;
        this.jsonUtils = jsonUtils;
    }

    // ─────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────

    private ResponseEntity<String> buildResponse(Supplier<String> action) {
        String response = action.get();
        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    private ResponseEntity<Map<String, Object>> buildMapResponse(Supplier<Map<String, Object>> action) {
        Map<String, Object> result = action.get();
        if ((int) result.get("success") == 0) {
            return ResponseEntity.status(401)
                    .body(Map.of("mensaje", result.get("mensaje")));
        }
        return ResponseEntity.ok(result);
    }

    // ─────────────────────────────────────────────
    // Usuarios
    // ─────────────────────────────────────────────

    @PostMapping("/usuarios/registro")
    public ResponseEntity<String> registrarUsuario(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.registrarUsuario(json));
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> logueo(@RequestBody String json) {
        return buildMapResponse(() -> griffonVetRepository.login(json));
    }

    // ─────────────────────────────────────────────
    // Clientes y mascotas
    // ─────────────────────────────────────────────

    @PostMapping("/insertarClienteMascotaAdmin")
    public ResponseEntity<String> insertarClienteMascotaAdmin(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarClienteMascotaAdmin(json));
    }

    @GetMapping("/obtenerClientes")
    public ResponseEntity<String> getClientes() {
        return buildResponse(griffonVetRepository::getClientes);
    }

    @PostMapping("/BusquedaClientes")
    public ResponseEntity<String> obtenerClientesConMascotas(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.obtenerClientesConMascotas(json));
    }

    @GetMapping("/usuario/obtenerMascotas")
    public ResponseEntity<String> obtenerMascotasPorUsuario() {
        return buildResponse(() -> griffonVetRepository.obtenerMascotasPorUsuario(
                jsonUtils.jsonSoloConIdUsuario()));
    }

    @PostMapping("/obtenerMascota")
    public ResponseEntity<String> getMascota(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.getMascota(json));
    }

    @PostMapping("/insertarMascotas")
    public ResponseEntity<String> insertarMascota(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarMascota(
                jsonUtils.resolverIdUsuario(json)));
    }

    @PutMapping("/actualizarMascotas")
    public ResponseEntity<String> editarInfoGeneralMascota(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.editarInfoGeneralMascota(
                jsonUtils.resolverIdUsuario(json)));
    }

    // ─────────────────────────────────────────────
    // Categorías
    // ─────────────────────────────────────────────

    @GetMapping("/ObtenerCategorias")
    public ResponseEntity<String> obtenerCategorias() {
        return buildResponse(griffonVetRepository::obtenerCategorias);
    }

    @PostMapping("/InsertarCategoria")
    public ResponseEntity<String> insertarCategoria(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarCategoria(json));
    }

    // ─────────────────────────────────────────────
    // Productos
    // ─────────────────────────────────────────────

    @GetMapping("/obtenerProductos")
    public ResponseEntity<String> obtenerProductos() {
        return buildResponse(griffonVetRepository::obtenerProductos);
    }

    @PostMapping("/insertarProductos")
    public ResponseEntity<String> crearProducto(
            @RequestParam("imagen") MultipartFile imagen,
            @RequestParam("producto") String productoJson) {
        return buildResponse(() -> griffonVetRepository.insertarProducto(imagen, productoJson));
    }

    @PutMapping("/actualizarProductos")
    public ResponseEntity<String> actualizarProducto(
            @RequestParam(value = "imagen", required = false) MultipartFile imagen,
            @RequestParam("producto") String productoJson) {
        return buildResponse(() -> griffonVetRepository.actualizarProducto(imagen, productoJson));
    }

    @DeleteMapping("/EliminarProducto")
    public ResponseEntity<String> eliminarProducto(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.eliminarProducto(json));
    }

    // ─────────────────────────────────────────────
    // Consultas clínicas
    // ─────────────────────────────────────────────

    @PostMapping(value = "/nuevaConsulta", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> insertarConsultaClinica(
            @RequestParam("consulta") String json,
            @RequestParam(value = "archivos", required = false) MultipartFile[] archivos) {
        return buildResponse(() -> griffonVetRepository.insertarConsultaClinica(json, archivos));
    }

    @PutMapping(value = "/ActualizarConsultaClinica", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> actualizarConsultaClinica(
            @RequestParam("consulta") String json,
            @RequestParam(value = "archivos", required = false) MultipartFile[] archivos) {
        return buildResponse(() -> griffonVetRepository.actualizarConsultaClinica(json, archivos));
    }

    @DeleteMapping("/EliminarConsulta")
    public ResponseEntity<String> eliminarConsulta(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.eliminarConsulta(json));
    }

    // ─────────────────────────────────────────────
    // Medicamentos
    // ─────────────────────────────────────────────

    @GetMapping("/ObtenerMedicamentos")
    public ResponseEntity<String> obtenerMedicamentos() {
        return buildResponse(griffonVetRepository::obtenerMedicamentos);
    }

    @PostMapping("/InsertarMedicamento")
    public ResponseEntity<String> insertarMedicamento(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarMedicamento(json));
    }

    // ─────────────────────────────────────────────
    // Vacunas y vacunación
    // ─────────────────────────────────────────────

    @GetMapping("/ObtenerVacunas")
    public ResponseEntity<String> obtenerVacunas() {
        return buildResponse(griffonVetRepository::obtenerVacunas);
    }

    @PostMapping("/InsertarVacuna")
    public ResponseEntity<String> insertarVacuna(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarVacuna(json));
    }

    @PostMapping("/InsertarVacunacion")
    public ResponseEntity<String> insertarVacunacion(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarVacunacion(json));
    }

    // ─────────────────────────────────────────────
    // Desparasitación
    // ─────────────────────────────────────────────

    @GetMapping("/ObtenerDesparasitaciones")
    public ResponseEntity<String> obtenerDesparasitaciones() {
        return buildResponse(griffonVetRepository::obtenerDesparasitaciones);
    }

    @PostMapping("/InsertarDesparasitacion")
    public ResponseEntity<String> insertarDesparasitacion(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarDesparasitacion(json));
    }

    @PostMapping("/InsertarTipoDesparasitacion")
    public ResponseEntity<String> insertarDesparasitacionCatalogo(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarDesparasitacionCatalogo(json));
    }

    // ─────────────────────────────────────────────
    // Enfermedades
    // ─────────────────────────────────────────────

    @GetMapping("/ObtenerEnfermedades")
    public ResponseEntity<String> obtenerEnfermedades() {
        return buildResponse(griffonVetRepository::obtenerEnfermedades);
    }

    @PostMapping("/InsertarEnfermedad")
    public ResponseEntity<String> insertarEnfermedad(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarEnfermedad(json));
    }

    @PostMapping("/InsertarEnfermedadCatalogo")
    public ResponseEntity<String> insertarEnfermedadCatalogo(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarEnfermedadCatalogo(json));
    }

    // ─────────────────────────────────────────────
    // Alergias
    // ─────────────────────────────────────────────

    @GetMapping("/ObtenerAlergias")
    public ResponseEntity<String> obtenerAlergias() {
        return buildResponse(griffonVetRepository::obtenerAlergias);
    }

    @PostMapping("/InsertarAlergia")
    public ResponseEntity<String> insertarAlergia(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarAlergia(json));
    }

    @PostMapping("/InsertarAlergiaCatalogo")
    public ResponseEntity<String> insertarAlergiaCatalogo(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarAlergiaCatalogo(json));
    }

    // ─────────────────────────────────────────────
    // Peso
    // ─────────────────────────────────────────────

    @PostMapping("/InsertarPeso")
    public ResponseEntity<String> insertarPeso(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarPeso(json));
    }

    // ─────────────────────────────────────────────
    // Servicios
    // ─────────────────────────────────────────────

    @GetMapping("/ObtenerServicios")
    public ResponseEntity<String> obtenerServicios() {
        return buildResponse(griffonVetRepository::obtenerServicios);
    }

    @PostMapping("/InsertarServicio")
    public ResponseEntity<String> insertarServicio(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.insertarServicio(json));
    }

    @PutMapping("/ActualizarServicio")
    public ResponseEntity<String> actualizarServicio(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.actualizarServicio(json));
    }

    @DeleteMapping("/EliminarServicio")
    public ResponseEntity<String> eliminarServicio(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.eliminarServicio(json));
    }

    @PostMapping("/ObtenerServicioPorMascota")
    public ResponseEntity<String> obtenerServicioPorMascota(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.obtenerServicioPorMascota(json));
    }

    // ─────────────────────────────────────────────
    // Home e información general
    // ─────────────────────────────────────────────

    @GetMapping("/ObtenerInfoHome")
    public ResponseEntity<String> obtenerInfoHome() {
        return buildResponse(griffonVetRepository::obtenerInfoHome);
    }

    @PostMapping("/InsertarInfoHome")
    public ResponseEntity<String> insertarInfoHome(
            @RequestParam(value = "imagen", required = false) MultipartFile imagen,
            @RequestParam("data") String json) {
        return buildResponse(() -> griffonVetRepository.insertarInfoHome(imagen, json));
    }

    @PutMapping("/ActualizarInfoHome")
    public ResponseEntity<String> actualizarInfoHome(
            @RequestParam(value = "imagen", required = false) MultipartFile imagen,
            @RequestParam("data") String json) {
        return buildResponse(() -> griffonVetRepository.actualizarInfoHome(imagen, json));
    }

    @DeleteMapping("/EliminarInfoHome")
    public ResponseEntity<String> eliminarInfoHome(@RequestBody String json) {
        return buildResponse(() -> griffonVetRepository.eliminarInfoHome(json));
    }

    // ─────────────────────────────────────────────
    // Noticias y especies
    // ─────────────────────────────────────────────

    @GetMapping("/ObtenerNoticias")
    public ResponseEntity<String> obtenerNoticias() {
        return buildResponse(griffonVetRepository::obtenerNoticias);
    }

    @GetMapping("/ObtenerEspecies")
    public ResponseEntity<String> obtenerEspecies() {
        return buildResponse(griffonVetRepository::obtenerEspecies);
    }
}