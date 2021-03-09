@isTest
private with sharing class OppTriggerHandlerTest {
    @TestSetup
    static void setup(){
        
        Date closeDt = Date.Today();
        date myDate = date.today();
        Account a2 = new Account(Name ='TestAccount1');
        insert a2;
        Id pricebookId = Test.getStandardPricebookId();
        Opportunity opp = new Opportunity(
            Name='TestOpportunity1' , 
            AccountId= a2.Id,
            StageName = 'Invoice requested', 
            CloseDate = closeDt
            );
        insert opp;
        Opportunity opp1 = new Opportunity(
            Name='TestOpportunity2' , 
            AccountId= a2.Id,
            StageName = 'Invoice requested', 
            CloseDate = closeDt
            );
        insert opp1;
        opp1.StageName = 'Invoice paid';
        update opp1;
        Opportunity opp2 = new Opportunity(
            Name='TestOpportunity3' , 
            AccountId= a2.Id,
            StageName = 'Invoice requested', 
            CloseDate = closeDt
            );
        insert opp2;
        opp2.StageName = 'Closed Won';
        update opp2;
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 1,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = pbEntry.UnitPrice
        );
        insert oli;
           OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = opp1.Id,
            Quantity = 1,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = pbEntry.UnitPrice
        );
        insert oli1;
          OpportunityLineItem oli2 = new OpportunityLineItem(
            OpportunityId = opp2.Id,
            Quantity = 1,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = pbEntry.UnitPrice
        );
        insert oli2;
    }       
}