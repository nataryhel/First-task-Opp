public with sharing class OppTriggerHandler extends TriggerHandler {
    private Map<Id, Opportunity> newOppMap;
    private Map<Id, Opportunity> OldOppMap;
    public OppTriggerHandler() {
        this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.OldOppMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    public static void amountChanges(List<String> opportunityAmount){
        QueueableCallout_Task6 callout = new QueueableCallout_Task6(opportunityAmount);
        ID jobID = System.enqueueJob(callout);
        System.debug(' in method amountChanges========');
    }
    public override void beforeUpdate() {
        List<Invoice__c> updateInvoice = new List<Invoice__c>();
        updateInvoice.addAll([SELECT Id , Status__c 
                              FROM Invoice__c 
                              WHERE Opportunity__c 
                              IN :newOppMap.keySet()]);//   OpportunityLineItem  -><OPPORTUNITY,INVOICE>
        List<String> opportunityAmount = new List<String>();
        for (Opportunity o : (List<Opportunity>)Trigger.new ){
            System.debug('loop update');
            Opportunity oldOpp = OldOppMap.get(o.Id);
            System.debug('oldOpp'+ oldOpp);

            if(o.Amount!= oldOpp.Amount){
                opportunityAmount.add(o.Id);
                System.debug('amountChanges========');
            } 

            for (Invoice__c invoice : updateInvoice){
                if(o.stageName!= oldOpp.stageName &&  oldOpp.stageName =='Invoice paid' && o.stageName != 'Invoice paid'){
                    invoice.Status__c = 'Obsolete';
                    System.debug('if obsolete');
                }  
                if(o.stageName!= oldOpp.stageName &&  oldOpp.stageName =='Invoice requested' && o.stageName == 'Invoice paid'){
                    invoice.Status__c = 'Paid';
                    System.debug('if paid');
                } 

                if(o.stageName!= oldOpp.stageName &&  oldOpp.stageName == 'Invoice requested' && o.stageName == 'Invoice sent'){
                    invoice.Status__c = 'Sent';
                    invoice.Invoice_Sent_Date__c = System.today();
                }
            }
        }
        amountChanges(opportunityAmount);
        upsert updateInvoice;
    }
  
    public override void afterUpdate() { 
        Map<Id, Set<OpportunityLineItem>> Opportunity_OpportunityProduct = new  Map<Id, Set<OpportunityLineItem>>();
        Map<Id, List<Invoice_Item__c>> Invoice_InvoiceItem = new  Map<Id, List<Invoice_Item__c>>();
        Map<Id,Invoice__c> Opportunity_Invoice = new Map<Id,Invoice__c>();
        List<Invoice_Item__c> newInvoiceItem = new List<Invoice_Item__c>();
        List<Invoice__c> newInvoice = new List<Invoice__c>();
        List<OpportunityLineItem> OpportunityProducts = new List<OpportunityLineItem>();
        List<Opportunity> Opportunities = new List<Opportunity>();
        System.debug('after update');
        for (Opportunity o : (List<Opportunity>)Trigger.new ) {
            System.debug('create loop');
            Opportunity oldOpp = OldOppMap.get(o.Id);
            System.debug(oldOpp);
            if (o.StageName == 'Invoice requested' && oldOpp.StageName != 'Invoice requested') { 
                Invoice__c invoice = new Invoice__c();     
                invoice.Opportunity__c = o.Id;
                invoice.Account__c = o.AccountId;
                invoice.Status__c = 'New'; 
                newInvoice.add(invoice); 
                Opportunities.add(o);//opportunities with invoice
                System.debug(invoice);
            }
        } 

        System.debug('Invoice List' + newInvoice);
        upsert newInvoice;	//INVOICES

        for (Invoice__c inv : newInvoice) {
            Opportunity_Invoice.put(inv.Opportunity__c, inv); //<OPPORTUNITY,INVOICE>
        }
        OpportunityProducts.addAll([SELECT Id , OpportunityId, Product2Id 
                                    FROM OpportunityLineItem
                                    WHERE OpportunityId 
                                    IN :Opportunity_Invoice.keySet()]);//   OpportunityLineItem  -><OPPORTUNITY,INVOICE>
        for (Invoice__c invoice : Opportunity_Invoice.values()){ 
            System.debug('loop1');
            for (OpportunityLineItem opp : OpportunityProducts){ 
                System.debug('loop2');
                if(opp.OpportunityId == invoice.Opportunity__c){
                    System.debug('invoice item');
                    Invoice_Item__c ii = new Invoice_Item__c();     
                    ii.Product__c = opp.Product2Id;
                    ii.Invoice__c = invoice.Id;
                    newInvoiceItem.add(ii);
                    Invoice_InvoiceItem.put(invoice.Id,newInvoiceItem);
                }
            }
        }
        upsert newInvoiceItem;	
    }      
}