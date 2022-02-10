/**============================================================================
* Experian
* Name             : OpportunityLIScheduleTriggerHandler_Test
* Description      : Test class of OpportunityLIScheduleTriggerHandler class
* Created Date     : March 03rd 2021
* Created By       : Herbert Oliveira
* 
* Date Modified          Modified By          Description of the update
*
=============================================================================*/
@isTest
    private class OpportunityLIScheduleTriggerHandler_Test {
    
    
    static testMethod void testAfterInsert() {
        test.startTest();
        
        OpportunityLineItem oppLineItem1 = [SELECT Id, OpportunityId FROM OpportunityLineItem LIMIT 1];
        OpportunityLineItemSchedule olis = Test_Utils.createOpportunityLineItemSchedule(oppLineItem1.ID);
        olis.ScheduleDate = Date.today().addDays(-40);
        insert olis;
       
        system.assertEquals(Date.today().addDays(-40), [SELECT Minimum_Revenue_Schedule_Date__c FROM OpportunityLineItem WHERE Id = : oppLineItem1.Id].Minimum_Revenue_Schedule_Date__c);
        system.assertEquals(Date.today().addDays(-40), [SELECT Minimum_Revenue_Schedule_Date__c FROM Opportunity WHERE Id = : oppLineItem1.OpportunityId].Minimum_Revenue_Schedule_Date__c);
        
        test.stopTest();
    }
    
    static testMethod void testAfterUpdate() {
        test.startTest();
        
        OpportunityLineItem oppLineItem1 = [SELECT Id, OpportunityId FROM OpportunityLineItem LIMIT 1];
        OpportunityLineItemSchedule olis = Test_Utils.createOpportunityLineItemSchedule(oppLineItem1.ID);
        olis.ScheduleDate = Date.today().addDays(-40);
        insert olis;        
        
        olis.ScheduleDate=Date.today();
        update olis;
        
        system.assertEquals(Date.today(), [SELECT Minimum_Revenue_Schedule_Date__c FROM OpportunityLineItem WHERE Id = : oppLineItem1.Id].Minimum_Revenue_Schedule_Date__c);
        system.assertEquals(Date.today(), [SELECT Minimum_Revenue_Schedule_Date__c FROM Opportunity WHERE Id = : oppLineItem1.OpportunityId].Minimum_Revenue_Schedule_Date__c);
        
        test.stopTest();
    }
    
    static testMethod void testAfterDelete() {
        test.startTest();
        OpportunityLineItem oppLineItem1 = [SELECT Id, OpportunityId FROM OpportunityLineItem LIMIT 1];
        OpportunityLineItemSchedule olis = Test_Utils.createOpportunityLineItemSchedule(oppLineItem1.ID);
        olis.ScheduleDate = Date.today().addDays(-40);
        insert olis; 
        delete olis;    
        system.assertEquals(null, [SELECT Minimum_Revenue_Schedule_Date__c FROM OpportunityLineItem WHERE Id = : oppLineItem1.Id].Minimum_Revenue_Schedule_Date__c);
        system.assertEquals(null, [SELECT Minimum_Revenue_Schedule_Date__c FROM Opportunity WHERE Id = : oppLineItem1.OpportunityId].Minimum_Revenue_Schedule_Date__c);  
        test.stopTest();
    }
    
    @testSetup
    static void setupTestData() {
        Account acc = Test_Utils.insertAccount();
        Opportunity opp = Test_Utils.createOpportunity(acc.Id);
        opp.Name = 'OpportunityLIScheduleTriggerHandler Test Opp';
        opp.Type = Constants.OPPTY_NEW_FROM_NEW;
        insert opp;
        Product2 product = Test_Utils.createProduct();
        product.RevenueScheduleType = Constants.REVENUE_SCHEDULED_TYPE_REPEAT;    
        product.RevenueInstallmentPeriod = Constants.INSTALLMENT_PERIOD_MONTHLY;    
        product.NumberOfRevenueInstallments = 2;    
        product.CanUseRevenueSchedule = true;
        insert product;
        PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);
        OpportunityLineItem oppLineItem = Test_Utils.insertOpportunityLineItem(opp.Id, stdPricebookEntry.Id, opp.Type);  
    } 
}