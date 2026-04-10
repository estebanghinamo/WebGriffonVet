package griffonvet.griffonvet.resource;


import com.fasterxml.jackson.core.JsonProcessingException;
import griffonvet.griffonvet.config.JsonUtils;
import griffonvet.griffonvet.repositories.GriffonVetRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.google.gson.Gson;
import org.springframework.web.multipart.MultipartFile;


import java.util.Map;

@RestController
@RequestMapping("griffonVet")
public class GriffonVetResources {
    private final Gson gson = new Gson();

    @Autowired
    private GriffonVetRepository griffonVetRepository;
    @Autowired
    private final JsonUtils jsonUtils;

    public GriffonVetResources(JsonUtils jsonUtils) {
        this.jsonUtils = jsonUtils;
    }


    @PostMapping("/usuarios/registro")
    public ResponseEntity<String> registrarUsuario(@RequestBody String json) {

        String response = griffonVetRepository.registrarUsuario(json);


        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }


        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> logueo(@RequestBody String json) {

        Map<String, Object> result = griffonVetRepository.login(json);

        // ❌ credenciales inválidas
        if ((int) result.get("success") == 0) {

            String mensaje = (String) result.get("mensaje");

            return ResponseEntity.status(401)
                    .body(Map.of("mensaje", mensaje));
        }

        // ✅ éxito
        return ResponseEntity.ok(result);
    }


    @PostMapping("/insertarClienteMascotaAdmin")
    public ResponseEntity<String> insertarClienteMascotaAdmin(@RequestBody String json) {

        String response = griffonVetRepository.insertarClienteMascotaAdmin(json);

        // 🔥 ERROR → HTTP 400
        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        // ✅ OK
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }



    @GetMapping("/ObtenerCategorias")//esta mal escrito
    public ResponseEntity<String> obtenerCategorias() {

        String response = griffonVetRepository.obtenerCategorias();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }


    @PostMapping("/InsertarCategoria")
    public ResponseEntity<String> insertarCateoria(@RequestBody String json) {

        String response = griffonVetRepository.insertarCategoria(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/obtenerProductos")
    public ResponseEntity<String> obtenerProductos() {

        String response = griffonVetRepository.obtenerProductos();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/insertarProductos")
    public ResponseEntity<String> crearProducto(
            @RequestParam("imagen") MultipartFile imagen,
            @RequestParam("producto") String productoJson) {


        String response = griffonVetRepository.insertarProducto(imagen, productoJson);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @DeleteMapping("/EliminarProducto")
    public ResponseEntity<String> eliminarProducto(@RequestBody String json) {

        String response = griffonVetRepository.eliminarProducto(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PutMapping("/actualizarProductos")
    public ResponseEntity<String> actualizarProducto(
            @RequestParam(value = "imagen", required = false) MultipartFile imagen,
            @RequestParam("producto") String productoJson) {

        String response = griffonVetRepository.actualizarProducto(imagen, productoJson);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }


    @GetMapping("/usuario/obtenerMascotas")
    public ResponseEntity<String> obtenerMascotasPorUsuario() {
        String response = griffonVetRepository.obtenerMascotasPorUsuario(
                jsonUtils.jsonSoloConIdUsuario());

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/insertarMascotas")
    public ResponseEntity<String> insertarMascota(@RequestBody String json) {

        String response = griffonVetRepository.insertarMascota(
                jsonUtils.resolverIdUsuario(json));

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/BusquedaClientes")
    public ResponseEntity<String> obtenerClientesConMascotas(@RequestBody String json) {

        String response = griffonVetRepository.obtenerClientesConMascotas(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/obtenerClientes")
    public ResponseEntity<?> getClientes() throws JsonProcessingException {
        String response = griffonVetRepository.getClientes();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/obtenerMascota")
    public ResponseEntity<?> getMascota(@RequestBody String json) throws JsonProcessingException {
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(griffonVetRepository.getMascota(json));
    }

    @PostMapping(value = "/nuevaConsulta", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> insertarConsultaClinica(
            @RequestParam("consulta") String json,
            @RequestParam(value = "archivos", required = false) MultipartFile[] archivos
    ) {

        String response = griffonVetRepository.insertarConsultaClinica(json, archivos);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PutMapping("/actualizarMascotas")
    public ResponseEntity<String> editarInfoGeneralMascota(@RequestBody String json) {

        String response = griffonVetRepository.editarInfoGeneralMascota(
                jsonUtils.resolverIdUsuario(json));

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PutMapping(value = "/ActualizarConsultaClinica", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<String> actualizarConsultaClinica(
            @RequestParam("consulta") String json,
            @RequestParam(value = "archivos", required = false) MultipartFile[] archivos
    ) {

        String response = griffonVetRepository.actualizarConsultaClinica(json, archivos);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @DeleteMapping("/EliminarConsulta")
    public ResponseEntity<String> eliminarConsulta(@RequestBody String json) {

        String response = griffonVetRepository.eliminarConsulta(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerMedicamentos")
    public ResponseEntity<String> obtenerMedicamentos() {

        String response = griffonVetRepository.obtenerMedicamentos();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarMedicamento")
    public ResponseEntity<String> insertarMedicamento(@RequestBody String json) {

        String response = griffonVetRepository.insertarMedicamento(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarVacunacion")
    public ResponseEntity<String> insertarVacunacion(@RequestBody String json) {

        String response = griffonVetRepository.insertarVacunacion(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerVacunas")
    public ResponseEntity<String> obtenerVacunas() {

        String response = griffonVetRepository.obtenerVacunas();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarVacuna")
    public ResponseEntity<String> insertarVacuna(@RequestBody String json) {

        String response = griffonVetRepository.insertarVacuna(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarDesparasitacion")
    public ResponseEntity<String> insertarDesparasitacion(@RequestBody String json) {

        String response = griffonVetRepository.insertarDesparasitacion(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerDesparasitaciones")
    public ResponseEntity<String> obtenerDesparasitaciones() {

        String response = griffonVetRepository.obtenerDesparasitaciones();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarTipoDesparasitacion")
    public ResponseEntity<String> insertarDesparasitacionCatalogo(@RequestBody String json) {

        String response = griffonVetRepository.insertarDesparasitacionCatalogo(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarPeso")
    public ResponseEntity<String> insertarPeso(@RequestBody String json) {

        String response = griffonVetRepository.insertarPeso(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarEnfermedad")
    public ResponseEntity<String> insertarEnfermedad(@RequestBody String json) {

        String response = griffonVetRepository.insertarEnfermedad(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerEnfermedades")
    public ResponseEntity<String> obtenerEnfermedades() {

        String response = griffonVetRepository.obtenerEnfermedades();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarEnfermedadCatalogo")
    public ResponseEntity<String> insertarEnfermedadCatalogo(@RequestBody String json) {

        String response = griffonVetRepository.insertarEnfermedadCatalogo(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarAlergia")
    public ResponseEntity<String> insertarAlergia(@RequestBody String json) {

        String response = griffonVetRepository.insertarAlergia(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerAlergias")
    public ResponseEntity<String> obtenerAlergias() {

        String response = griffonVetRepository.obtenerAlergias();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarAlergiaCatalogo")
    public ResponseEntity<String> insertarAlergiaCatalogo(@RequestBody String json) {

        String response = griffonVetRepository.insertarAlergiaCatalogo(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerServicios")
    public ResponseEntity<String> obtenerServicios() {

        String response = griffonVetRepository.obtenerServicios();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarServicio")
    public ResponseEntity<String> insertarServicio(@RequestBody String json) {

        String response = griffonVetRepository.insertarServicio(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PutMapping("/ActualizarServicio")
    public ResponseEntity<String> actualizarServicio(@RequestBody String json) {

        String response = griffonVetRepository.actualizarServicio(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @DeleteMapping("/EliminarServicio")
    public ResponseEntity<String> eliminarServicio(@RequestBody String json) {

        String response = griffonVetRepository.eliminarServicio(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/ObtenerServicioPorMascota")
    public ResponseEntity<String> obtenerServicioPorMascota(@RequestBody String json) {

        String response = griffonVetRepository.obtenerServicioPorMascota(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerInfoHome")
    public ResponseEntity<String> obtenerInfoHome() {

        String response = griffonVetRepository.obtenerInfoHome();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarInfoHome")
    public ResponseEntity<String> insertarInfoHome(@RequestParam(value = "imagen", required = false) MultipartFile imagen,
                                                   @RequestParam("data") String json) {

        String response = griffonVetRepository.insertarInfoHome(imagen,json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PutMapping("/ActualizarInfoHome")
    public ResponseEntity<String> actualizarInfoHome(
            @RequestParam(value = "imagen", required = false) MultipartFile imagen,
            @RequestParam("data") String json) {

        String response = griffonVetRepository.actualizarInfoHome(imagen,json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @DeleteMapping("/EliminarInfoHome")
    public ResponseEntity<String> eliminarInfoHome(@RequestBody String json) {

        String response = griffonVetRepository.eliminarInfoHome(json);

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerNoticias")
    public ResponseEntity<String> obtenerNoticias() {

        String response = griffonVetRepository.obtenerNoticias();

        if (response.contains("\"success\":0")) {
            return ResponseEntity.badRequest()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(response);
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

}
