public with sharing class RateCallout {
    public static HttpResponse rateHttpCallout() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://currencyapi.net/api/v1/rates?key=OxQuyJiMT1gH3MLPmktZliReosNGekLnmJ2M');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        System.debug('execute========');
        return response;
    }
}