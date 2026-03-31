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

@Component
public class SimpleJdbcCallFactory {

    @Autowired
    private JdbcTemplate jdbcTpl;

    public <T> Map<String, Object> executeQueryWithOutputs(String procedureName, String schemaName, SqlParameterSource params, String resultSetName, Class<T> mappedClass) {
        SimpleJdbcCall jdbcCall = createCall(procedureName, schemaName)
                .returningResultSet(resultSetName, BeanPropertyRowMapper.newInstance(mappedClass));
        return jdbcCall.execute(params);
    }

    public <T> List<T> executeQuery(String procedureName, String schemaName, SqlParameterSource params, String resultSetName, Class<T> mappedClass) {
        Map<String, Object> out = executeQueryWithOutputs(procedureName, schemaName, params, resultSetName, mappedClass);
        return (List<T>) out.get(resultSetName);
    }

    public <T> List<T> executeQuery(String procedureName, String schemaName, String resultSetName, Class<T> mappedClass) {
        return executeQuery(procedureName, schemaName, new MapSqlParameterSource(), resultSetName, mappedClass);
    }

    public <T> Map<String, Object> executeWithOutputs(String procedureName, String schemaName, SqlParameterSource params) {
        SimpleJdbcCall jdbcCall = createCall(procedureName, schemaName);
        return jdbcCall.execute(params);
    }

    public void execute(String procedureName, String schemaName, SqlParameterSource params) {
        executeWithOutputs(procedureName, schemaName, params);
    }
    public <T> T executeSingle(String procedureName, String schemaName, SqlParameterSource params, String resultSetName, Class<T> mappedClass) {
        List<T> result = executeQuery(procedureName, schemaName, params, resultSetName, mappedClass);
        return result.isEmpty() ? null : result.get(0);
    }

    public void execute(String procedureName, String schemaName) {
        execute(procedureName, schemaName, new MapSqlParameterSource());
    }

    private SimpleJdbcCall createCall(String procedureName, String schemaName) {
        return new SimpleJdbcCall(jdbcTpl)
                .withProcedureName(procedureName)
                .withSchemaName(schemaName);
    }
    public List<Map<String, Object>> executeList(String procedureName, String schemaName, SqlParameterSource params) {
        SimpleJdbcCall jdbcCall = createCall(procedureName, schemaName);
        Map<String, Object> result = jdbcCall.execute(params);


        Object rs = result.get("#result-set-1");
        if (rs instanceof List) {
            return (List<Map<String, Object>>) rs;
        }
        return List.of();
    }

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

}

