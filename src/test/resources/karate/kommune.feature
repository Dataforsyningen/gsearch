Feature: Gsearch kommune test

Background:
* url url + '/search'

Scenario: Response matches columns database
    Then param q = 'Albertslund'
    And param resources = 'kommune'
    When method GET
    Then status 200
    And match response == '#[1]'
    And def bboxSchema = {type: 'Polygon', coordinates: '#array'}
    And def geometriSchema = {type: 'MultiPolygon', coordinates: '#array'}
    And match response contains deep
    """
    {
      "type": 'kommune',
      "kommunenavn": '#string',
      "praesentation": '#string',
      "bbox": '#(bboxSchema)',
      "geometri": '#(geometriSchema)',
      "id": '#string',
      "rang1": '#string',
      "rang2": '#string'
    }
    """

Scenario: Partial string
    Then param q = 'køben'
    And param resources = 'kommune'
    When method GET
    Then status 200
    And match response == '#[1]'

    # Scenario: Search is case insensitive
    #     Then param q = 'København'
    #     And param resources = 'kommune'
    #     When method GET
    #     Then status 200
    #     And def firstresponse = response
    #     And match firstresponse == '#[10]'
    #
    #     Then param q = 'københavn'
    #     And param resources = 'kommune'
    #     When method GET
    #     Then status 200
    #     And def secondresponse = response
    #     And match secondresponse == '#[10]'
    #
    #     Then match firstresponse == secondresponse
    #
    #     Then param q = 'KØBENHAVN'
    #     And param resources = 'kommune'
    #     When method GET
    #     Then status 200
    #     And def thirdresponse = response
    #     And match thirdresponse == '#[10]'
    #
    #     Then match thirdresponse == secondresponse
    #
    # Scenario: Like search on københavn s returns København S and København SV
    #     Then param q = 'københavn S'
    #     And param resources = 'kommune'
    #     When method GET
    #     Then status 200
    #     And match response == '#[2]'
    #     And match response.[*].kommune contains deep ['København S', 'København SV']
    #     And match response.[*].praesentation contains deep ['2300 København S', '2450 København SV']
    #
    # Scenario: Get Birkerød and Hillerød from using the postnumber as search input
    #     Then param q = '3460 3400'
    #     And param resources = 'kommune'
    #     When method GET
    #     Then status 200
    #     And match response == '#[2]'
    #     And match response.[*].kommune contains deep ['Birkerød', 'Hillerød']
    #     And match response.[*].id contains deep ['3460', '3400']
    #
    # Scenario: Get København S from using the postnumber as search input and Søborg as tekst input
    #     Then param q = '2300 søborg'
    #     And param resources = 'kommune'
    #     When method GET
    #     Then status 200
    #     And match response == '#[2]'
    #     And match response.[*].kommune contains deep ['Søborg', 'København S']
    #
    # Scenario: Get kommune that matches with Ager
    #     Then param q = 'Ager'
    #     And param resources = 'kommune'
    #     When method GET
    #     Then status 200
    #     And match response == '#[3]'
    #     And match response.[*].kommune contains deep ['Agersø', 'Agerskov', 'Agerbæk']
    #
    # Scenario: Do not have a match on '.'
    #     Then param q = '.'
    #     And param resources = 'kommune'
    #     When method GET
    #     Then status 200
    #     And match response == '#[0]'
    #
    # Scenario: Test maximum limit and small search
    #     Then param q = 's'
    #     And param resources = 'kommune'
    #     And param limit = '100'
    #     When method GET
    #     Then status 200
    #     And match response == '#[100]'
    #
    # Scenario: Empty search input
    #     Then param q = ''
    #     And param resources = 'kommune'
    #     When method GET
    #     Then status 500
    #     And match response ==
    #     """
    #     [
    #         {
    #             "message": "Query string parameter q is required"
    #         }
    #     ]
    #     """
    #
    # # Need to be fixed. Should not return empty result but "message": "Query string parameter q is required"
    # Scenario: Missing q query parameter
    #     And param resources = 'kommune'
    #     When method GET
    #     Then status 500
    #     And match response ==
    #     """
    #     [
    #         {
    #             "message": "Query string parameter q is required"
    #         }
    #     ]
    #     """
    #
    # Scenario: Exceed maximum limit
    #     Then param q = 's'
    #     And param resources = 'kommune'
    #     And param limit = '101'
    #     When method GET
    #     Then status 500
    #     And match response ==
    #     """
    #     [
    #         {
    #             "message": "Query string parameter limit must be between 1-100"
    #         }
    #     ]
    #     """
