trigger OppTrigger on Opportunity (before update, after update) {
    new OppTriggerHandler().run();
    
}