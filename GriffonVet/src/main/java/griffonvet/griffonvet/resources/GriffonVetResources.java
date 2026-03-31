package griffonvet.griffonvet.resources;


import com.fasterxml.jackson.core.JsonProcessingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.google.gson.Gson;


import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;


import java.util.HashMap;
import java.util.List;

@RestController
@RequestMapping("griffonVet")
public class GriffonVetResources {
    private final Gson gson = new Gson();


}
