/**============================================================================
* Experian
* Name             : SalesRevenueScheduleTriggerHandler_Test
* Description      : Test class of SalesRevenueScheduleTriggerHandler class
* Created Date     : June 25th 2021
* Created By       : Sai Navya Yerrabelli
* 
* Date Modified          Modified By          Description of the update
*
=============================================================================*/
@isTest
private class SalesRevenueScheduleTriggerHandler_Test {
static testMethod void testAfterInsert() {
        test.startTest();
        OpportunityLineItem oppLineItem1 = [SELECT Id, OpportunityId FROM OpportunityLineItem LIMIT 1];
        Sales_Revenue_Schedule__c srs = Test_Utils.createSalesRevenueSchedule(oppLineItem1.ID);
        srs.Opportunity__c = oppLineItem1.OpportunityId;
        insert srs;
        test.stopTest();
        system.assertEquals(True, [SELECT Is_Non_Zero_Sales_Revenue_Schedule__c FROM OpportunityLineItem WHERE Id = : oppLineItem1.Id].Is_Non_Zero_Sales_Revenue_Schedule__c);             
    }
    
    static testMethod void testAfterUpdate() {
        test.startTest();
        OpportunityLineItem oppLineItem1 = [SELECT Id, OpportunityId FROM OpportunityLineItem LIMIT 1];
        Sales_Revenue_Schedule__c srs = Test_Utils.createSalesRevenueSchedule(oppLineItem1.ID);
        srs.Opportunity__c = oppLineItem1.OpportunityId;
        insert srs;      
        srs.Revenue__c=0;
        update srs;  
        system.assertEquals(False, [SELECT Is_Non_Zero_Sales_Revenue_Schedule__c FROM OpportunityLineItem WHERE Id = : oppLineItem1.Id].Is_Non_Zero_Sales_Revenue_Schedule__c);             
        test.stopTest();
    }
      static testMethod void testAfterDelete() {
        test.startTest();
        OpportunityLineItem oppLineItem1 = [SELECT Id, OpportunityId FROM OpportunityLineItem LIMIT 1];
        Sales_Revenue_Schedule__c srs = Test_Utils.createSalesRevenueSchedule(oppLineItem1.ID);
        srs.Opportunity__c = oppLineItem1.OpportunityId;
        insert srs;      
        delete srs;  
        system.assertEquals(False, [SELECT Is_Non_Zero_Sales_Revenue_Schedule__c FROM OpportunityLineItem WHERE Id = : oppLineItem1.Id].Is_Non_Zero_Sales_Revenue_Schedule__c);             
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