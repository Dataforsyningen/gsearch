package dk.dataforsyningen.gsearch.errorhandling;

import jakarta.validation.ConstraintViolationException;

import java.sql.SQLNonTransientConnectionException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import org.apache.catalina.connector.ClientAbortException;
import org.geotools.filter.text.cql2.CQLException;
import org.jdbi.v3.core.ConnectionException;
import org.jdbi.v3.core.result.ResultSetException;
import org.jdbi.v3.core.statement.UnableToExecuteStatementException;
import org.postgresql.util.PSQLException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.NestedExceptionUtils;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.lang.NonNull;
import org.springframework.validation.FieldError;
import org.springframework.validation.ObjectError;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingRequestHeaderException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

/**
 * @RestControllerAdvice combines @ControllerAdvice and @ResponseBody
 */
@RestControllerAdvice
public class ApiServiceAdvice extends ResponseEntityExceptionHandler {
    private static final Logger logger = LoggerFactory.getLogger(ApiServiceAdvice.class);
    private static final String ERROR_STRING = "FEJL!";

    /**
     * Uses NestedExceptionUtils to get too the Root Causes of a thrown Exception
     * https://stackoverflow.com/questions/1791610/java-find-the-first-cause-of-an-exception/65442410#65442410
     * https://stackoverflow.com/questions/17747175/how-can-i-loop-through-exception-getcause-to-find-root-cause-with-detail-messa
     * https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/core/NestedExceptionUtils.html
     *
     * @param t Throwable
     * @return Throwable
     */
    @NonNull
    public static Throwable getRootCause(@NonNull Throwable t) {
        Throwable rootCause = NestedExceptionUtils.getRootCause(t);
        // Old way: return rootCause != null ? rootCause : t

        if (rootCause == null) {
            return t;
        }
        return rootCause;
    }

    /**
     * Indicates that the client closed the connection, so it does not make sense to return af response
     * to the client
     * @param exception
     */
    @ExceptionHandler(ClientAbortException.class)
    public void handleClientAbortException(ClientAbortException exception) {
        String exceptionCause = getRootCause(exception).toString();
        logger.info(ERROR_STRING, exception);
        logger.info(ERROR_STRING, exceptionCause);
    }

    @ExceptionHandler(ConnectionException.class)
    public ResponseEntity<ErrorResponse> handleConnectionException(
        ConnectionException exception) {
        String exceptionCause = getRootCause(exception).toString();

        ErrorResponse errorResponse = new ErrorResponse(HttpStatus.BAD_REQUEST, "Connection issues");
        logger.info(ERROR_STRING, exception);
        logger.info(ERROR_STRING + exceptionCause);
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ErrorResponse> handleConstraintViolationException(Exception exception) {
        String exceptionCause = getRootCause(exception).toString();

        ErrorResponse errorResponse =
            new ErrorResponse(HttpStatus.BAD_REQUEST, exception.getMessage(), exceptionCause);
        logger.debug(ERROR_STRING, exception);
        logger.debug(ERROR_STRING + errorResponse.getErrors());
        return new ResponseEntity<>(errorResponse, errorResponse.getStatus());
    }

    @ExceptionHandler(CQLException.class)
    public ResponseEntity<ErrorResponse> handleCQLException(
        CQLException exception) {
        String exceptionCause = getRootCause(exception).toString();
        ErrorResponse errorResponse = new ErrorResponse(HttpStatus.BAD_REQUEST, exception.getMessage(), exceptionCause);
        logger.info(ERROR_STRING, exception);
        logger.info(ERROR_STRING + exceptionCause);
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(EmptyResultDataAccessException.class)
    public ResponseEntity<ErrorResponse> handleEmptyResultDataAccessException(
        EmptyResultDataAccessException exception) {
        String exceptionCause = getRootCause(exception).toString();

        ErrorResponse errorResponse = new ErrorResponse(HttpStatus.NOT_FOUND, exception.getLocalizedMessage(), exceptionCause);
        logger.debug(ERROR_STRING, exception);
        logger.debug(ERROR_STRING + errorResponse.getErrors());
        return new ResponseEntity<>(errorResponse, HttpStatus.NOT_FOUND);
    }

    /**
     * A default exception handler that deals with all others exceptions that don't have specific
     * handlers
     *
     * <p>HttpStatus.INTERNAL_SERVER_ERROR = 500
     *
     * <p>Very IMPORTANT that the exception declared with @ExceptionHandler matches the exceptions
     * uses as a argument of the method
     *
     * @param exception Exception
     * @return String
     */
    @ExceptionHandler({Exception.class})
    public ResponseEntity<ErrorResponse> handleAll(Exception exception) {
        ErrorResponse errorResponse =
            new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR, exception.getLocalizedMessage(), "error occurred");
        logger.info(ERROR_STRING, exception);
        logger.info(ERROR_STRING + exception.getLocalizedMessage());
        return new ResponseEntity<>(errorResponse, errorResponse.getStatus());
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgumentException(Exception exception) {
        String exceptionCause = getRootCause(exception).toString();

        ErrorResponse errorResponse =
            new ErrorResponse(HttpStatus.BAD_REQUEST, exception.getMessage(), exceptionCause);
        logger.debug(ERROR_STRING, exception);
        logger.debug(ERROR_STRING + errorResponse.getErrors());
        return new ResponseEntity<>(errorResponse, errorResponse.getStatus());
    }

    @ExceptionHandler({MethodArgumentTypeMismatchException.class})
    public ResponseEntity<Object> handleMethodArgumentTypeMismatch(
        MethodArgumentTypeMismatchException exception, WebRequest request) {
        String error =
            exception.getName()
                + " should be of type "
                + Objects.requireNonNull(exception.getRequiredType()).getName();
        ErrorResponse errorResponse =
            new ErrorResponse(HttpStatus.BAD_REQUEST, exception.getLocalizedMessage(), error);
        logger.debug(ERROR_STRING, exception);
        logger.debug(ERROR_STRING + errorResponse.getErrors());
        return new ResponseEntity<>(errorResponse, new HttpHeaders(), errorResponse.getStatus());
    }

    /**
     * HttpStatus.BAD_REQUEST = 400
     *
     * @param exception
     * @return
     */
    @ExceptionHandler({MissingRequestHeaderException.class})
    public ResponseEntity<ErrorResponse> handleMissingRequestHeaderException(Exception exception) {

        String exceptionCause = getRootCause(exception).toString();

        ErrorResponse errorResponse =
            new ErrorResponse(HttpStatus.BAD_REQUEST, exception.getLocalizedMessage(),
                exceptionCause);
        logger.debug(ERROR_STRING, exception);
        logger.debug(ERROR_STRING + errorResponse.getErrors());
        return new ResponseEntity<>(errorResponse, errorResponse.getStatus());
    }

    @ExceptionHandler(PSQLException.class)
    public ResponseEntity<ErrorResponse> handlePSQLException(
        PSQLException exception) {
        String exceptionCause = getRootCause(exception).toString();
        ErrorResponse errorResponse =
            new ErrorResponse(HttpStatus.BAD_REQUEST, "PSQLException", "Database error");
        logger.info(ERROR_STRING, exception);
        logger.info(ERROR_STRING, exceptionCause);
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(UnableToExecuteStatementException.class)
    public ResponseEntity<ErrorResponse> handleUnableToExecuteStatementException(
        UnableToExecuteStatementException exception) {
        String exceptionCause = getRootCause(exception).toString();
        ErrorResponse errorResponse = new ErrorResponse(HttpStatus.BAD_REQUEST, "UnableToExecuteStatementException", "Invalid input");
        logger.info(ERROR_STRING, exception);
        logger.info(ERROR_STRING + exceptionCause);
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(ResultSetException.class)
    public ResponseEntity<ErrorResponse> handleResultSetException(
        ResultSetException exception) {
        String exceptionCause = getRootCause(exception).toString();
        ErrorResponse errorResponse = new ErrorResponse(HttpStatus.BAD_REQUEST, exceptionCause);
        logger.info(ERROR_STRING, exception);
        logger.info(ERROR_STRING + exceptionCause);
        return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
    }

    /**
     * HttpStatus.CONFLICT = 409
     * <p>
     * Very IMPORTANT that the exception declared with @ExceptionHandler matches the
     * exceptions uses as a argument of the method
     *
     * @param exception SQLNonTransientConnectionException
     * @param request
     * @return ResponseEntity<Object>
     */
    @ExceptionHandler({SQLNonTransientConnectionException.class})
    public ResponseEntity<Object> handleSQLNonTransientConnectionException(SQLNonTransientConnectionException exception,
                                                                           WebRequest request) {
        String exceptionCause = "Cause is null";

        if (exception.getCause() != null) {
            exceptionCause = exception.getCause().toString();
        }

        ErrorResponse errorResponse = new ErrorResponse(HttpStatus.CONFLICT, exception.getLocalizedMessage(),
            exceptionCause);
        logger.info(ERROR_STRING, exception);
        logger.info(ERROR_STRING + exceptionCause);
        return new ResponseEntity<Object>(errorResponse, new HttpHeaders(), errorResponse.getStatus());
    }

    @Override
    protected ResponseEntity<Object> handleMissingServletRequestParameter(
        MissingServletRequestParameterException exception,
        HttpHeaders headers,
        HttpStatusCode status,
        WebRequest request) {

        String exceptionCause = getRootCause(exception).toString();

        ErrorResponse errorResponse =
            new ErrorResponse(HttpStatus.BAD_REQUEST, exception.getMessage(), exceptionCause);

        logger.debug(ERROR_STRING, exception);
        logger.debug(ERROR_STRING + errorResponse.getErrors());

        return handleExceptionInternal(exception, errorResponse, headers, status, request);
    }

    /**
     * HttpStatus.UNPROCESSABLE_ENTITY = 422 Where the exception handler comes from
     * https://www.baeldung.com/global-error-handler-in-a-spring-rest-api
     *
     * <p>MethodArgumentNotValidException: This exception is thrown when argument annotated
     * with @Valid failed validation
     *
     * @param exception MethodArgumentNotValidException
     * @param headers   HttpHeaders
     * @param status    HttpStatus
     * @param request   WebRequest
     * @return ResponseEntity<Object>
     */
    @Override
    protected ResponseEntity<Object> handleMethodArgumentNotValid(
        MethodArgumentNotValidException exception,
        HttpHeaders headers,
        HttpStatusCode status,
        WebRequest request) {
        List<String> errors = new ArrayList<>();

        for (FieldError error : exception.getBindingResult().getFieldErrors()) {
            errors.add(error.getField() + ": " + error.getDefaultMessage());
        }

        for (ObjectError error : exception.getBindingResult().getGlobalErrors()) {
            errors.add(error.getObjectName() + ": " + error.getDefaultMessage());
        }

        ErrorResponse errorResponse =
            new ErrorResponse(HttpStatus.UNPROCESSABLE_ENTITY, exception.getLocalizedMessage(),
                errors);
        logger.debug(ERROR_STRING, exception);
        logger.debug(ERROR_STRING + errorResponse.getErrors());
        return handleExceptionInternal(
            exception, errorResponse, headers, errorResponse.getStatus(), request);
    }

    /**
     * HttpStatus.BAD_REQUEST = 400
     *
     * <p>HttpMessageNotReadableException: This exception is thrown when request body is invalid
     *
     * @param exception HttpMessageNotReadableException
     * @param headers   HttpHeaders
     * @param status    HttpStatus
     * @param request   WebRequest
     * @return ResponseEntity<Object>
     */
    @Override
    protected ResponseEntity<Object> handleHttpMessageNotReadable(
        HttpMessageNotReadableException exception,
        HttpHeaders headers,
        HttpStatusCode status,
        WebRequest request) {

        String exceptionCause = getRootCause(exception).toString();

        ErrorResponse errorResponse =
            new ErrorResponse(HttpStatus.BAD_REQUEST, exception.getLocalizedMessage(),
                exceptionCause);
        logger.debug(ERROR_STRING, exception);
        logger.debug(ERROR_STRING + errorResponse.getErrors());
        return handleExceptionInternal(
            exception, errorResponse, headers, errorResponse.getStatus(), request);
    }

    /**
     * HttpStatus.METHOD_NOT_ALLOWED = 405
     *
     * <p>HttpRequestMethodNotSupportedException: This exception is thrown when you send a requested
     * with an unsupported HTTP method
     *
     * @param exception HttpRequestMethodNotSupportedException
     * @param headers   HttpHeaders
     * @param status    HttpStatus
     * @param request   WebRequest
     * @return ResponseEntity<Object>
     */
    @Override
    protected ResponseEntity<Object> handleHttpRequestMethodNotSupported(
        HttpRequestMethodNotSupportedException exception,
        HttpHeaders headers,
        HttpStatusCode status,
        WebRequest request) {

        StringBuilder builder = new StringBuilder();
        builder.append(exception.getMethod());
        builder.append(" method is not supported for this request. Supported methods are ");
        Objects.requireNonNull(exception.getSupportedHttpMethods())
            .forEach(t -> builder.append(t + " "));

        ErrorResponse errorResponse =
            new ErrorResponse(
                HttpStatus.METHOD_NOT_ALLOWED, exception.getLocalizedMessage(), builder.toString());
        logger.debug(ERROR_STRING, exception);
        logger.debug(ERROR_STRING + errorResponse.getErrors());
        return handleExceptionInternal(
            exception, errorResponse, headers, errorResponse.getStatus(), request);
    }

    /**
     * HttpStatus.UNSUPPORTED_MEDIA_TYPE = 415
     *
     * <p>HttpMediaTypeNotSupportedException – which occurs when the client send a request with
     * unsupported media type
     *
     * <p>Very IMPORTANT that the exception declared with @ExceptionHandler matches the exceptions
     * uses as an argument of the method
     *
     * @param exception HttpMediaTypeNotSupportedException
     * @param headers   HttpHeaders
     * @param status    HttpStatus
     * @param request   WebRequest
     * @return ResponseEntity<Object>
     */
    @Override
    protected ResponseEntity<Object> handleHttpMediaTypeNotSupported(
        final HttpMediaTypeNotSupportedException exception,
        final HttpHeaders headers,
        final HttpStatusCode status,
        final WebRequest request) {

        final StringBuilder builder = new StringBuilder();
        builder.append(exception.getContentType());
        builder.append(" media type is not supported. Supported media types are ");
        exception.getSupportedMediaTypes().forEach(t -> builder.append(t + " "));

        final ErrorResponse errorResponse =
            new ErrorResponse(
                HttpStatus.UNSUPPORTED_MEDIA_TYPE,
                exception.getLocalizedMessage(),
                builder.substring(0, builder.length() - 2));
        logger.debug(ERROR_STRING, exception);
        logger.debug(ERROR_STRING + errorResponse.getErrors());
        return handleExceptionInternal(
            exception, errorResponse, headers, errorResponse.getStatus(), request);
    }
}