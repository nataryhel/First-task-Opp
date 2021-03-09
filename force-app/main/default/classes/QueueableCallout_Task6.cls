public with sharing class QueueableCallout_Task6 implements Queueable , Database.AllowsCallouts {
    @TestVisible static Boolean makeCallout = true;
    private List<String> opportunityAmount;
    public QueueableCallout_Task6(List<String> opportunityAmount) {
        this.opportunityAmount = opportunityAmount;
    }

    public void execute(QueueableContext context) {
       if (makeCallout) makeGetCallout(opportunityAmount);  
    }
    
    private void makeGetCallout(List<String> opportunityAmount) {
        Double EUR,UAH,GBP;
        HttpResponse response = RateCallout.rateHttpCallout();
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> rates = ( Map<String, Object>) results.get('rates');
            
            EUR = (Double) rates.get('EUR');
            GBP = (Double) rates.get('GBP');
            UAH = (Double) rates.get('UAH');
        } 
        List<Opportunity> amoundsQueried = [SELECT Id, Amount, UAH_Rate__c, EUR_Rate__c, GBP_Rate__c, UAH_Amount__c, EUR_Amount__c, GBP_Amount__c 
                                            FROM Opportunity 
                                            WHERE Id 
                                            IN :opportunityAmount];
        System.debug('amoundsQueried========' + amoundsQueried);
        for (Opportunity opp : amoundsQueried) {
            opp.UAH_Amount__c = opp.Amount * UAH;
            opp.EUR_Amount__c = opp.Amount * EUR;
            opp.GBP_Amount__c = opp.Amount * GBP;
            opp.UAH_Rate__c = UAH;          
            opp.EUR_Rate__c = EUR;          
            opp.GBP_Rate__c = GBP;          
        }
        System.debug('amoundsQueried========' + amoundsQueried);
        upsert amoundsQueried;
    } 
}