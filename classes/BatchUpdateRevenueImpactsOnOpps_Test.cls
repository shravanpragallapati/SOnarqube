/*=============================================================================
 * Experian
 * Name: BatchUpdateRevenueImpactsOnOpps_Test
 * Description: 
  * Created Date: 22nd Jan. 2018
 * Created By: James Wills
 *
 * Date Modified      	Modified By           	Description of the update
 * 30th Aug 2018		James Wills           	Case 16849335: Added section to improve coverage.
 * 19th Jul 2021		Herbert Oliveira		Change to fix SOQL 101 issues
 ============================================================================*/
@isTest
private class BatchUpdateRevenueImpactsOnOpps_Test{

    static testMethod void testDataReset(){
        Profile p = [SELECT Id FROM Profile WHERE Name = :Constants.PROFILE_SYS_ADMIN];
        User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
        insert testUser1;
        
        IsDataAdmin__c ida = new IsDataAdmin__c(SetupOwnerId = testUser1.Id, IsDataAdmin__c = true);
        insert ida;
        
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1]; 
        
        system.runAs(testUser1) {            
            
            testOpp.FY15_Revenue_Impact__c = 1000.00;
            update testOpp;
            
            Date dateStart     = Date.valueOf('2014-04-02 00:00:00');
            Date dateEnd       = Date.valueOf(dateStart)+800;   
            
            PricebookEntry PrcBookEntry = [select id from PricebookEntry order by LastModifiedDate DESC limit 1];
            
            OpportunityLineItem oppLineItem1 = Test_Utils.createOpportunityLineItem(testOpp.Id,PrcBookEntry.Id,'Renewal');
            oppLineItem1.Start_Date__c = dateStart;
            oppLineItem1.End_Date__c   = dateEnd;
            oppLineItem1.Revenue_Schedule_Amt_Per_Period__c = 500.0;
            oppLineItem1.Revenue_Schedule_Num_of_Periods__c = 2;
            insert oppLineItem1;
            
            OpportunityLineItemSchedule olis1 = Test_Utils.insertOpportunityLineItemSchedule(oppLineItem1.id);
            olis1.ScheduleDate=dateStart;   
            //update olis1;
            
            OpportunityLineItemSchedule olis2 = Test_Utils.insertOpportunityLineItemSchedule(oppLineItem1.id);
            olis2.ScheduleDate=dateStart+30;   
            //update olis2;
            
            OpportunityLineItemSchedule olis3 = Test_Utils.insertOpportunityLineItemSchedule(oppLineItem1.id);
            olis3.ScheduleDate=dateStart+500;   
            //update olis3; 
            update new List<OpportunityLineItemSchedule>{olis1, olis2, olis3};
                
        }
            
        test.startTest();
            
        Database.executeBatch(new  BatchUpdateRevenueImpactsOnOpps());
        
        BatchUpdateRevenueImpactsOnOpps bc = new   BatchUpdateRevenueImpactsOnOpps();                
        String sch = '0 0 18 * * ?'; 
        system.schedule('Test BatchUpdateCurrenciesForUSDConversions', sch, bc);            
        
        Test.stoptest();
    } 
  
  static testMethod void testDataProcessing(){
    
    Batch_Class_Timestamp__c bct = new Batch_Class_Timestamp__c();
    bct.Name = 'BatchUpdateRevImpactsOnOpps';
    bct.Time__c = Date.valueOf('2014-04-02 00:00:00');
    insert bct;
    
    Date dateStart     = Date.valueOf('2014-04-02 00:00:00');
    Date dateEnd       = Date.valueOf(dateStart)+1600;
    
    Opportunity testOpp = [select id from Opportunity order by LastModifiedDate DESC limit 1];
    PricebookEntry PrcBookEntry = [select id from PricebookEntry order by LastModifiedDate DESC limit 1];
    Test.startTest(); 
        OpportunityLineItem oppLineItem1 = Test_Utils.createOpportunityLineItem(testOpp.Id,PrcBookEntry.Id,'Renewal');
        oppLineItem1.Start_Date__c = dateStart;
        oppLineItem1.End_Date__c   = dateEnd;
        oppLineItem1.Revenue_Schedule_Amt_Per_Period__c = 500.0;
        oppLineItem1.Revenue_Schedule_Num_of_Periods__c = 2;
        insert oppLineItem1;
        
        List<OpportunityLineItemSchedule> olisList = new List<OpportunityLineItemSchedule>();
        
        OpportunityLineItemSchedule olis1 = Test_Utils.createOpportunityLineItemSchedule(oppLineItem1.id);
        olisList.add(olis1);
        
        OpportunityLineItemSchedule olis2 = Test_Utils.createOpportunityLineItemSchedule(oppLineItem1.id);
        olisList.add(olis2);
        
        OpportunityLineItemSchedule olis3 = Test_Utils.createOpportunityLineItemSchedule(oppLineItem1.id);
        olisList.add(olis3);
        
        OpportunityLineItemSchedule olis4 = Test_Utils.createOpportunityLineItemSchedule(oppLineItem1.id);
        olisList.add(olis4);
        
        OpportunityLineItemSchedule olis5 = Test_Utils.createOpportunityLineItemSchedule(oppLineItem1.id);
        olisList.add(olis5);
        
        OpportunityLineItemSchedule olis6 = Test_Utils.createOpportunityLineItemSchedule(oppLineItem1.id);
        olisList.add(olis6);
        
        OpportunityLineItemSchedule olis7 = Test_Utils.createOpportunityLineItemSchedule(oppLineItem1.id);
        olisList.add(olis7);        
        
        insert olisList;
                
        olis1.ScheduleDate=dateStart;   
        olis2.ScheduleDate=dateStart+30;   
        olis3.ScheduleDate=dateStart+500; 
        olis4.ScheduleDate=dateStart+900; 
        olis5.ScheduleDate=dateStart+1300; 
        olis6.ScheduleDate=dateStart+1700; 
        olis7.ScheduleDate=dateStart+2100; 
        
        update olisList;
        
        
    
                          

      Database.executeBatch(new  BatchUpdateRevenueImpactsOnOpps());
 
      BatchUpdateRevenueImpactsOnOpps bc = new   BatchUpdateRevenueImpactsOnOpps();                
      String sch = '0 0 18 * * ?'; 
      system.schedule('Test BatchUpdateCurrenciesForUSDConversions', sch, bc);            
        
    Test.stoptest();
  }
  
  @testSetup
  private static void createTestData(){
       
  
    Account acc = Test_Utils.insertAccount();//Account Created with Name as Test Account appended with a Randon Number.
    
    Opportunity testOpp = Test_Utils.createOpportunity(acc.Id);    
    Datetime today      = System.Now();
    
    //Date dateStart     = Date.valueOf(today)+1;
    //Date dateEnd       = Date.valueOf(dateStart)+365;
    
    Date dateStart     = Date.valueOf('2014-04-02 00:00:00');
    Date dateEnd       = Date.valueOf(dateStart)+1600;
    
    testOpp.Contract_Start_Date__c = dateStart;
    testOpp.Contract_End_Date__c   = dateEnd;
    insert testOpp;
    
    Product2 prod = Test_Utils.createProduct();
    prod.Global_Business_Line__c = 'Decision Analytics';
    prod.Business_Line__c        = 'Software';
    prod.CanUseRevenueSchedule   = true;
    insert prod;
    
    Id prcBookId = Test.getStandardPricebookId();
    PricebookEntry prcBookEntry = Test_Utils.createPricebookEntry(Prod.Id,prcBookId ,'USD');
   
    insert prcBookEntry;
        
  }
  
}