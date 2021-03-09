@isTest(SeeAllData=true)
private with sharing class QueueableCallout_Test {
  @isTest static void testCallout() {
    Test.setMock(HttpCalloutMock.class, new QueueableHttpCalloutMock());
    HttpResponse res = RateCallout.rateHttpCallout();
    String contentType = res.getHeader('Content-Type');
    System.assert(contentType == 'application/json');
    String actualValue = res.getBody();
    String expectedValue = '{"rates":{"AED":3.6732,"AFN":77.09562,"ALL":102.43972}';
    System.assertEquals(200, res.getStatusCode());
  }
}