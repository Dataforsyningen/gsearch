Feature: Gsearch errorhandling test

  Background:
    * url url + '/postnummer'

  Scenario: Empty q input
    Then param q = ''
    
    When method GET
    Then status 400
    And match response ==
    """
    {
        "status": "BAD_REQUEST",
        "message": "getPostnummer.q: must not be blank",
        "errors": [
            "jakarta.validation.ConstraintViolationException: getPostnummer.q: must not be blank"
        ]
    }
    """

  Scenario: Missing q query parameter
    
    When method GET
    Then status 400
    And match response ==
    """
    {
        "status": "BAD_REQUEST",
        "message": "Required request parameter 'q' for method parameter type String is not present",
        "errors": [
            "org.springframework.web.bind.MissingServletRequestParameterException: Required request parameter 'q' for method parameter type String is not present"
        ]
    }
    """

  Scenario: Non existing resource
    Then url url + '/postnummer1'
    Then param q = 's'
    When method GET
    Then status 404
    And match response ==
    """
    {
        "type":"about:blank",
        "title":"Not Found",
        "status":404,
        "detail":"No static resource postnummer1.",
        "instance":"#string",
        "properties":null
    }
    """

  Scenario: Exceed maximum limit
    Then param q = 's'
    
    And param limit = '101'
    When method GET
    Then status 400
    And match response ==
    """
    {
        "status": "BAD_REQUEST",
        "message": "getPostnummer.limit: must be less than or equal to 100",
        "errors": [
            "jakarta.validation.ConstraintViolationException: getPostnummer.limit: must be less than or equal to 100"
        ]
    }
    """
