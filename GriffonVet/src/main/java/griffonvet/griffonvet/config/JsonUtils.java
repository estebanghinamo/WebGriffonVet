package griffonvet.griffonvet.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

@Component
public class JsonUtils {

    private final ObjectMapper mapper = new ObjectMapper();
    public Jwt getJwt() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        assert auth != null;
        return (Jwt) auth.getPrincipal();
    }

    public String inyectarClaim(String json, String campo, Object valor) {
        try {
            ObjectNode node = (json == null || json.isBlank())
                    ? mapper.createObjectNode()
                    : (ObjectNode) mapper.readTree(json);

            if (valor instanceof Integer i) node.put(campo, i);
            else if (valor instanceof String s) node.put(campo, s);
            else if (valor instanceof Long l)    node.put(campo, l);

            return mapper.writeValueAsString(node);
        } catch (Exception e) {
            throw new RuntimeException("Error inyectando claim: " + e.getMessage());
        }
    }
    public Integer getIdUsuario() {
        Jwt jwt = getJwt();
        Long id = jwt.getClaim("id_usuario");
        return id != null ? id.intValue() : null;
    }


    public String resolverIdUsuario(String json) {
        Jwt jwt = getJwt();
        String rol = jwt.getClaim("rol");

        if ("ADMIN".equals(rol)) return json;

        Long idLong = jwt.getClaim("id_usuario");
        Integer idUsuario = idLong != null ? idLong.intValue() : null;
        return inyectarClaim(json, "id_usuario", idUsuario);
    }

    public String jsonSoloConIdUsuario() {
        Integer idUsuario = getIdUsuario();
        return inyectarClaim(null, "id_usuario", idUsuario);
    }
}