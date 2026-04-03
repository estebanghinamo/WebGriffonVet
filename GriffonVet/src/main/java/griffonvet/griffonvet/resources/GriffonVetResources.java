package griffonvet.griffonvet.resources;


import com.fasterxml.jackson.core.JsonProcessingException;
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

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> logueo(@RequestBody String json) {
        try {
            System.out.println("json: "+json);
            String token = griffonVetRepository.login(json);
            if (token != null) {
                return ResponseEntity.ok(Map.of("token", token));
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

    @GetMapping("/obtenerClientes")
    public ResponseEntity<String> getClientes() throws JsonProcessingException {
        String json = griffonVetRepository.getClientes();
        System.out.println(json);
        return ResponseEntity.ok()
                .header("Content-Type", "application/json")
                .body(json);
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

    @PostMapping("/obtenerMascota")
    public ResponseEntity<String> obtenerMascotasPorUsuario(@RequestBody String json) {

        String response = griffonVetRepository.obtenerMascotasPorUsuario(json);

        return ResponseEntity.ok()
                .header("Content-Type", "application/json")
                .body(response);
    }

    @PostMapping("/insertarMascotas")
    public ResponseEntity<String> insertarMascota(@RequestBody String json) {

        String response = griffonVetRepository.insertarMascota(json);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/BusquedaClientes")
    public ResponseEntity<String> obtenerClientesConMascotas(@RequestBody String json) {

        String response = griffonVetRepository.obtenerClientesConMascotas(json);

        return ResponseEntity.ok(response);
    }

    @PutMapping("/actualizarMascotas")
    public ResponseEntity<String> editarInfoGeneralMascota(@RequestBody String json) {

        String response = griffonVetRepository.editarInfoGeneralMascota(json);

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

}
