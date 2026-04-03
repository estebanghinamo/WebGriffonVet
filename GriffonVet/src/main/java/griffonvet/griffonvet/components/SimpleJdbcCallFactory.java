package griffonvet.griffonvet.components;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

/**
 * Fábrica centralizada para la ejecución de procedimientos almacenados mediante {@link SimpleJdbcCall}.
 *
 * <p>Esta clase ofrece métodos de conveniencia para los patrones de llamada más comunes:
 * <ul>
 *   <li>Procedimientos que devuelven uno o varios result sets mapeados a beans Java.</li>
 *   <li>Procedimientos que devuelven parámetros de salida escalares.</li>
 *   <li>Procedimientos que devuelven result sets como listas de mapas (útil para serializar a JSON).</li>
 *   <li>Procedimientos de solo ejecución sin valor de retorno.</li>
 * </ul>
 *
 * <p><b>Uso básico:</b>
 * <pre>{@code
 * // Sin parámetros, resultado como lista de mapas (ideal para JSON):
 * List<Map<String, Object>> datos = factory.executeList(
 *     "sp_get_animales", "dbo", new MapSqlParameterSource());
 *
 * // Con parámetros, resultado mapeado a una clase:
 * SqlParameterSource params = new MapSqlParameterSource("id", 42);
 * Animal animal = factory.executeSingle("sp_get_animal", "dbo", params, "animal", Animal.class);
 * }</pre>
 */
@Component
public class SimpleJdbcCallFactory {

    @Autowired
    private JdbcTemplate jdbcTpl;

    // -------------------------------------------------------------------------
    // Métodos que mapean result sets a clases Java (BeanPropertyRowMapper)
    // -------------------------------------------------------------------------

    /**
     * Ejecuta un procedimiento almacenado y devuelve todos los outputs del mismo,
     * incluyendo un result set mapeado a una lista de objetos del tipo indicado.
     *
     * @param <T>           Tipo de los objetos del result set.
     * @param procedureName Nombre del procedimiento almacenado.
     * @param schemaName    Esquema de base de datos donde reside el procedimiento.
     * @param params        Parámetros de entrada del procedimiento.
     * @param resultSetName Nombre lógico con el que se registra el result set
     *                      (se usa como clave en el mapa de salida).
     * @param mappedClass   Clase destino para el mapeo de filas.
     * @return Mapa con todos los outputs del procedimiento; la clave {@code resultSetName}
     *         contiene un {@code List<T>} con las filas del result set.
     */
    public <T> Map<String, Object> executeQueryWithOutputs(
            String procedureName,
            String schemaName,
            SqlParameterSource params,
            String resultSetName,
            Class<T> mappedClass) {

        SimpleJdbcCall jdbcCall = createCall(procedureName, schemaName)
                .returningResultSet(resultSetName, BeanPropertyRowMapper.newInstance(mappedClass));
        return jdbcCall.execute(params);
    }

    /**
     * Ejecuta un procedimiento almacenado y devuelve el result set indicado
     * como una lista de objetos del tipo especificado.
     *
     * @param <T>           Tipo de los objetos del result set.
     * @param procedureName Nombre del procedimiento almacenado.
     * @param schemaName    Esquema de base de datos.
     * @param params        Parámetros de entrada.
     * @param resultSetName Nombre lógico del result set.
     * @param mappedClass   Clase destino para el mapeo de filas.
     * @return Lista de objetos {@code T} con los resultados del procedimiento.
     */
    public <T> List<T> executeQuery(
            String procedureName,
            String schemaName,
            SqlParameterSource params,
            String resultSetName,
            Class<T> mappedClass) {

        Map<String, Object> out = executeQueryWithOutputs(
                procedureName, schemaName, params, resultSetName, mappedClass);
        return (List<T>) out.get(resultSetName);
    }

    /**
     * Sobrecarga de {@link #executeQuery(String, String, SqlParameterSource, String, Class)}
     * para procedimientos que <b>no requieren parámetros de entrada</b>.
     *
     * @param <T>           Tipo de los objetos del result set.
     * @param procedureName Nombre del procedimiento almacenado.
     * @param schemaName    Esquema de base de datos.
     * @param resultSetName Nombre lógico del result set.
     * @param mappedClass   Clase destino para el mapeo de filas.
     * @return Lista de objetos {@code T} con los resultados del procedimiento.
     */
    public <T> List<T> executeQuery(
            String procedureName,
            String schemaName,
            String resultSetName,
            Class<T> mappedClass) {

        return executeQuery(
                procedureName, schemaName, new MapSqlParameterSource(), resultSetName, mappedClass);
    }

    /**
     * Ejecuta un procedimiento almacenado y devuelve el primer resultado del result set,
     * o {@code null} si el result set está vacío.
     *
     * <p>Útil cuando se espera un único registro (p. ej. búsqueda por ID).
     *
     * @param <T>           Tipo del objeto del result set.
     * @param procedureName Nombre del procedimiento almacenado.
     * @param schemaName    Esquema de base de datos.
     * @param params        Parámetros de entrada.
     * @param resultSetName Nombre lógico del result set.
     * @param mappedClass   Clase destino para el mapeo de fila.
     * @return El primer objeto {@code T}, o {@code null} si no hay resultados.
     */
    public <T> T executeSingle(
            String procedureName,
            String schemaName,
            SqlParameterSource params,
            String resultSetName,
            Class<T> mappedClass) {

        List<T> result = executeQuery(
                procedureName, schemaName, params, resultSetName, mappedClass);
        return result.isEmpty() ? null : result.get(0);
    }

    // -------------------------------------------------------------------------
    // Métodos de ejecución con parámetros de salida escalares
    // -------------------------------------------------------------------------

    /**
     * Ejecuta un procedimiento almacenado y devuelve todos sus parámetros de salida
     * en un mapa. No registra ningún result set; útil cuando el procedimiento sólo
     * retorna valores escalares (OUT params).
     *
     * @param procedureName Nombre del procedimiento almacenado.
     * @param schemaName    Esquema de base de datos.
     * @param params        Parámetros de entrada y/o salida.
     * @return Mapa con los parámetros de salida del procedimiento.
     */
    public <T> Map<String, Object> executeWithOutputs(
            String procedureName,
            String schemaName,
            SqlParameterSource params) {

        SimpleJdbcCall jdbcCall = createCall(procedureName, schemaName);
        return jdbcCall.execute(params);
    }

    // -------------------------------------------------------------------------
    // Métodos de solo ejecución (sin valor de retorno relevante)
    // -------------------------------------------------------------------------

    /**
     * Ejecuta un procedimiento almacenado descartando cualquier valor de retorno.
     * Conveniente para procedimientos de tipo DML (INSERT, UPDATE, DELETE).
     *
     * @param procedureName Nombre del procedimiento almacenado.
     * @param schemaName    Esquema de base de datos.
     * @param params        Parámetros de entrada.
     */
    public void execute(String procedureName, String schemaName, SqlParameterSource params) {
        executeWithOutputs(procedureName, schemaName, params);
    }

    /**
     * Sobrecarga de {@link #execute(String, String, SqlParameterSource)} para
     * procedimientos que <b>no requieren parámetros de entrada</b>.
     *
     * @param procedureName Nombre del procedimiento almacenado.
     * @param schemaName    Esquema de base de datos.
     */
    public void execute(String procedureName, String schemaName) {
        execute(procedureName, schemaName, new MapSqlParameterSource());
    }

    // -------------------------------------------------------------------------
    // Métodos que devuelven result sets como listas de mapas (ideal para JSON)
    // -------------------------------------------------------------------------

    /**
     * Ejecuta un procedimiento almacenado y devuelve su primer result set como una lista
     * de mapas {@code Map<String, Object>}, donde cada mapa representa una fila con sus
     * columnas como claves.
     *
     * <p>Spring almacena los result sets sin nombre bajo las claves {@code "#result-set-1"},
     * {@code "#result-set-2"}, etc. Este método extrae automáticamente el primero.
     *
     * <p><b>Ideal para serializar directamente a JSON</b> sin necesidad de crear una clase
     * de mapeo específica.
     *
     * <p><b>Ejemplo — procedimiento sin parámetros:</b>
     * <pre>{@code
     * List<Map<String, Object>> rows = factory.executeList(
     *     "sp_get_especies", "dbo", new MapSqlParameterSource());
     *
     * String json = new ObjectMapper().writeValueAsString(rows);
     * }</pre>
     *
     * @param procedureName Nombre del procedimiento almacenado.
     * @param schemaName    Esquema de base de datos.
     * @param params        Parámetros de entrada (usar {@link MapSqlParameterSource} vacío
     *                      si el procedimiento no requiere parámetros).
     * @return Lista de mapas con los datos del primer result set,
     *         o una lista vacía si no se encontró ningún result set.
     */
    public List<Map<String, Object>> executeList(
            String procedureName,
            String schemaName,
            SqlParameterSource params) {

        SimpleJdbcCall jdbcCall = createCall(procedureName, schemaName);
        Map<String, Object> result = jdbcCall.execute(params);

        Object rs = result.get("#result-set-1");
        if (rs instanceof List) {
            return (List<Map<String, Object>>) rs;
        }
        return List.of();
    }

    /**
     * Ejecuta un procedimiento almacenado y devuelve un result set nombrado como una lista
     * de mapas {@code Map<String, Object>}.
     *
     * <p>A diferencia de {@link #executeList}, este método registra explícitamente el result
     * set con un nombre conocido mediante {@link ColumnMapRowMapper}, lo que garantiza mayor
     * compatibilidad con distintos drivers JDBC.
     *
     * <p><b>Ejemplo:</b>
     * <pre>{@code
     * List<Map<String, Object>> rows = factory.executeQueryAsMap(
     *     "sp_get_razas", "dbo", new MapSqlParameterSource(), "razas");
     * }</pre>
     *
     * @param procedureName Nombre del procedimiento almacenado.
     * @param schemaName    Esquema de base de datos.
     * @param params        Parámetros de entrada.
     * @param resultSetName Nombre lógico con el que se registra el result set.
     * @return Lista de mapas con los datos del result set indicado.
     */
    public List<Map<String, Object>> executeQueryAsMap(
            String procedureName,
            String schemaName,
            SqlParameterSource params,
            String resultSetName) {

        SimpleJdbcCall jdbcCall = createCall(procedureName, schemaName)
                .returningResultSet(resultSetName, new ColumnMapRowMapper());

        Map<String, Object> out = jdbcCall.execute(params);
        return (List<Map<String, Object>>) out.get(resultSetName);
    }

    // -------------------------------------------------------------------------
    // Métodos privados de soporte
    // -------------------------------------------------------------------------

    /**
     * Crea y configura una instancia de {@link SimpleJdbcCall} para el procedimiento
     * y esquema indicados, utilizando el {@link JdbcTemplate} inyectado.
     *
     * @param procedureName Nombre del procedimiento almacenado.
     * @param schemaName    Esquema de base de datos.
     * @return Instancia de {@link SimpleJdbcCall} lista para ejecutar.
     */
    private SimpleJdbcCall createCall(String procedureName, String schemaName) {
        return new SimpleJdbcCall(jdbcTpl)
                .withProcedureName(procedureName)
                .withSchemaName(schemaName);
    }
}