package griffonvet.griffonvet.resources;


import com.fasterxml.jackson.core.JsonProcessingException;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import griffonvet.griffonvet.repositories.GriffonVetRepository;
import griffonvet.griffonvet.service.CloudinaryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.google.gson.Gson;
import org.springframework.web.multipart.MultipartFile;


import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;


import java.util.HashMap;
import java.util.List;

@RestController
@RequestMapping("griffonVet")
public class GriffonVetResources {
    private final Gson gson = new Gson();

    @Autowired
    private GriffonVetRepository griffonVetRepository;

    @PostMapping("/usuarios/registro")
    public ResponseEntity<String> registrarUsuario(@RequestBody String json) {

        String response = griffonVetRepository.registrarUsuario(json);

        return ResponseEntity.ok(response);
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

    @PostMapping("/obtenerMascotas")
    public ResponseEntity<String> obtenerMascotasPorUsuario(@RequestBody String json) {

        String response = griffonVetRepository.obtenerMascotasPorUsuario(json);

        return ResponseEntity.ok(response);
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
