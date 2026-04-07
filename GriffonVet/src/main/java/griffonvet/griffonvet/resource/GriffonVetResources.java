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

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> logueo(@RequestBody String json) {
        try {
            System.out.println("json: "+json);
            Map<String,String> result = griffonVetRepository.login(json);
            if (result != null) {
                return ResponseEntity.ok(result);
            } else {
                return ResponseEntity.status(401).body(Map.of("error", "error en email o contraseña"));
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/usuarios/registro")
    public ResponseEntity<String> registrarUsuario(@RequestBody String json) {

        String response = griffonVetRepository.registrarUsuario(json);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/insertarClienteMascotaAdmin")
    public ResponseEntity<String> insertarClienteMascotaAdmin(@RequestBody String json) {

        String response = griffonVetRepository.insertarClienteMascotaAdmin(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/obtenerClientes")
    public ResponseEntity<String> getClientes() throws JsonProcessingException {
        String json = griffonVetRepository.getClientes();
        return ResponseEntity.ok(json);
    }

    @GetMapping("/obtenerProductos")
    public ResponseEntity<String> obtenerProductos() {

        String response = griffonVetRepository.obtenerProductos();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/insertarProductos")
    public ResponseEntity<String> crearProducto(
            @RequestParam("imagen") MultipartFile imagen,
            @RequestParam("producto") String productoJson) {

        String response = griffonVetRepository.insertarProducto(imagen, productoJson);

        return ResponseEntity.ok(response);
    }


    @PutMapping("/actualizarProductos")
    public ResponseEntity<String> actualizarProducto(
            @RequestParam(value = "imagen", required = false) MultipartFile imagen,
            @RequestParam("producto") String productoJson) {

        String response = griffonVetRepository.actualizarProducto(imagen, productoJson);

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/EliminarProducto")
    public ResponseEntity<String> eliminarProducto(@RequestBody String json) {

        String response = griffonVetRepository.eliminarProducto(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/obtenerMascota")
    public ResponseEntity<String> getMasctota(@RequestBody String json) throws JsonProcessingException {
        String resp = griffonVetRepository.getMascota(json);

        return ResponseEntity.ok(resp);
    }

    @GetMapping("/usuario/obtenerMascotas")
    public ResponseEntity<String> obtenerMascotasPorUsuario() {
        String response = griffonVetRepository.obtenerMascotasPorUsuario(
                jsonUtils.jsonSoloConIdUsuario());
        return ResponseEntity.ok(response);
    }

    @PostMapping("/insertarMascotas")
    public ResponseEntity<String> insertarMascota(@RequestBody String json) {

        String response = griffonVetRepository.insertarMascota(
                jsonUtils.resolverIdUsuario(json));

        return ResponseEntity.ok(response);
    }

    @PostMapping("/BusquedaClientes")
    public ResponseEntity<String> obtenerClientesConMascotas(@RequestBody String json) {

        String response = griffonVetRepository.obtenerClientesConMascotas(json);

        return ResponseEntity.ok(response);
    }

    @PutMapping("/actualizarMascotas")
    public ResponseEntity<String> editarInfoGeneralMascota(@RequestBody String json) {

        String response = griffonVetRepository.editarInfoGeneralMascota(
                jsonUtils.resolverIdUsuario(json));

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/nuevaConsulta")
    public ResponseEntity<String> insertarConsultaClinica(@RequestBody String json) {

        String response = griffonVetRepository.insertarConsultaClinica(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PutMapping("/ActualizarConsultaClinica")
    public ResponseEntity<String> actualizarConsultaClinica(@RequestBody String json) {

        String response = griffonVetRepository.actualizarConsultaClinica(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerMedicamentos")
    public ResponseEntity<String> obtenerMedicamentos() {

        String response = griffonVetRepository.obtenerMedicamentos();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/InsertarMedicamento")
    public ResponseEntity<String> insertarMedicamento(@RequestBody String json) {

        String response = griffonVetRepository.insertarMedicamento(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarVacunacion")
    public ResponseEntity<String> insertarVacunacion(@RequestBody String json) {

        String response = griffonVetRepository.insertarVacunacion(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerVacunas")
    public ResponseEntity<String> obtenerVacunas() {

        String response = griffonVetRepository.obtenerVacunas();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/InsertarVacuna")
    public ResponseEntity<String> insertarVacuna(@RequestBody String json) {

        String response = griffonVetRepository.insertarVacuna(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarDesparasitacion")
    public ResponseEntity<String> insertarDesparasitacion(@RequestBody String json) {

        String response = griffonVetRepository.insertarDesparasitacion(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerDesparasitaciones")
    public ResponseEntity<String> obtenerDesparasitaciones() {

        String response = griffonVetRepository.obtenerDesparasitaciones();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/InsertarTipoDesparasitacion")
    public ResponseEntity<String> insertarDesparasitacionCatalogo(@RequestBody String json) {

        String response = griffonVetRepository.insertarDesparasitacionCatalogo(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarPeso")
    public ResponseEntity<String> insertarPeso(@RequestBody String json) {

        String response = griffonVetRepository.insertarPeso(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarEnfermedad")
    public ResponseEntity<String> insertarEnfermedad(@RequestBody String json) {

        String response = griffonVetRepository.insertarEnfermedad(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerEnfermedades")
    public ResponseEntity<String> obtenerEnfermedades() {

        String response = griffonVetRepository.obtenerEnfermedades();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/InsertarEnfermedadCatalogo")
    public ResponseEntity<String> insertarEnfermedadCatalogo(@RequestBody String json) {

        String response = griffonVetRepository.insertarEnfermedadCatalogo(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/InsertarAlergia")
    public ResponseEntity<String> insertarAlergia(@RequestBody String json) {

        String response = griffonVetRepository.insertarAlergia(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerAlergias")
    public ResponseEntity<String> obtenerAlergias() {

        String response = griffonVetRepository.obtenerAlergias();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/InsertarAlergiaCatalogo")
    public ResponseEntity<String> insertarAlergiaCatalogo(@RequestBody String json) {

        String response = griffonVetRepository.insertarAlergiaCatalogo(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @GetMapping("/ObtenerServicios")
    public ResponseEntity<String> obtenerServicios() {

        String response = griffonVetRepository.obtenerServicios();

        return ResponseEntity.ok(response);
    }

    @PostMapping("/InsertarServicio")
    public ResponseEntity<String> insertarServicio(@RequestBody String json) {

        String response = griffonVetRepository.insertarServicio(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PutMapping("/ActualizarServicio")
    public ResponseEntity<String> actualizarServicio(@RequestBody String json) {

        String response = griffonVetRepository.actualizarServicio(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @DeleteMapping("/EliminarServicio")
    public ResponseEntity<String> eliminarServicio(@RequestBody String json) {

        String response = griffonVetRepository.eliminarServicio(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }

    @PostMapping("/ObtenerServicioPorMascota")
    public ResponseEntity<String> obtenerServicioPorMascota(@RequestBody String json) {

        String response = griffonVetRepository.obtenerServicioPorMascota(json);

        return ResponseEntity
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(response);
    }
}
