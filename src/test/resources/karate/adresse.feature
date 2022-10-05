Feature: Gsearch adresse test

Background:
* url url + '/search'

Scenario: Response matches columns database
    Then param q = 'kocksvej'
    And param resources = 'adresse'
    When method GET
    Then status 200
    And match response == '#[10]'
    And def geometriSchema = {type: 'MultiPoint', coordinates: '#array'}
    And match response contains deep
    """
    {
      "type": 'adresse',
      "vejkode": '#string',
      "etagebetegnelse": '#string',
      "adgangspunkt_geometri": '#(geometriSchema)',
      "husnummer": '#string',
      "vejnavn": '#string',
      "kommunekode": '#string',
      "adressebetegnelse": '#string',
      "kommunenavn": '#string',
      "doerbetegnelse": '#string',
      "postnummer": '#string',
      "vejpunkt_geometri": '#(geometriSchema)',
      "id": '#string',
      "postdistrikt": '#string',
      "rang1": '#string',
      "rang2": '#string'
    }
    """

Scenario: Partial string
    Then param q = 'køben'
    And param resources = 'adresse'
    When method GET
    Then status 200
    And match response == '#[10]'

Scenario: Search is case insensitive
    Then param q = 'København'
    And param resources = 'adresse'
    When method GET
    Then status 200
    And def firstresponse = response
    And match firstresponse == '#[10]'

    Then param q = 'københavn'
    And param resources = 'adresse'
    When method GET
    Then status 200
    And def secondresponse = response
    And match secondresponse == '#[10]'

    Then match firstresponse == secondresponse

    Then param q = 'KØBENHAVN'
    And param resources = 'adresse'
    When method GET
    Then status 200
    And def thirdresponse = response
    And match thirdresponse == '#[10]'

    Then match thirdresponse == secondresponse

Scenario: Like search on københavn s returns København S and København SV
    Then param q = 'københavn S'
    And param resources = 'adresse'
    When method GET
    Then status 200
    And match response == '#[2]'
    And match response.[*].adresse contains deep ['København S', 'København SV']
    And match response.[*].praesentation contains deep ['2300 København S', '2450 København SV']

Scenario: Get Birkerød and Hillerød from using the postnumber as search input
    Then param q = '3460 3400'
    And param resources = 'adresse'
    When method GET
    Then status 200
    And match response == '#[2]'
    And match response.[*].adresse contains deep ['Birkerød', 'Hillerød']
    And match response.[*].id contains deep ['3460', '3400']

Scenario: Get København S from using the postnumber as search input and Søborg as tekst input
    Then param q = '2300 søborg'
    And param resources = 'adresse'
    When method GET
    Then status 200
    And match response == '#[2]'
    And match response.[*].adresse contains deep ['Søborg', 'København S']

Scenario: Do not have a match on '.'
    Then param q = '.'
    And param resources = 'adresse'
    When method GET
    Then status 200
    And match response == '#[0]'

Scenario: Test maximum limit and small search
    Then param q = 's'
    And param resources = 'adresse'
    And param limit = '100'
    When method GET
    Then status 200
    And match response == '#[100]'

Scenario: Empty search input
    Then param q = ''
    And param resources = 'adresse'
    When method GET
    Then status 500
    And match response ==
    """
    [
        {
            "message": "Query string parameter q is required"
        }
    ]
    """

# Need to be fixed. Should not return empty result but "message": "Query string parameter q is required"
Scenario: Missing q query parameter
    And param resources = 'adresse'
    When method GET
    Then status 500
    And match response ==
    """
    [
        {
            "message": "Query string parameter q is required"
        }
    ]
    """

Scenario: Exceed maximum limit
    Then param q = 's'
    And param resources = 'adresse'
    And param limit = '101'
    When method GET
    Then status 500
    And match response ==
    """
    [
        {
            "message": "Query string parameter limit must be between 1-100"
        }
    ]
    """
