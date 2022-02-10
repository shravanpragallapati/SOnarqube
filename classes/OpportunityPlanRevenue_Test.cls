/**********************************************************
   Class        :    OpportunityPlanRevenue_Test
   Author       :    Tyaga Pati
   Date         :    04/17/2015
   Description  :    For Testing Opportunity Plan Revenue Consolidation at the Opportunity plan Level. 
                     This code was to consolidate Revenue from Opty line Schedule to Opty plan is part of the 
                     Account plan Trigger Handler Code. 
                     This Test Class created User, Account, Opty, Opty line then calls a function in Test Util class
                     to create 15 rev schedules spread across 3 years starting from current fiscal year. 
   
   Modified On              Modified By                   Description
 * Apr 17th, 2014           Tyaga Pati      
 * Apr 7th, 2016            Paul Kissick                  Case 01932085: Fixing Test User Email Domain
 * Oct 20th, 2016           James Wills                   Case #02088090 - Resolved issue with test following validation rule change
  ***********************************************************/ 
@isTest
private class OpportunityPlanRevenue_Test {
  
  static testMethod void createAccountPlanOppsTest() {
      
    //Create a New User
    Profile p = [select id from profile where name=: Constants.PROFILE_SYS_ADMIN ];
    User testUser1 = Test_Utils.createUser(p, 'test1234@experian.com', 'test1');
    insert testUser1;

    system.runAs(testUser1) {

      //Create a New Account
      Global_Settings__c setting = Global_Settings__c.getValues(Constants.GLOBAL_SETTING);
      Account account = Test_Utils.insertAccount();
        
      //Create the new Opportunity
      Opportunity opp = Test_Utils.createOpportunity(account.Id);
      opp.Amount = 100;
      opp.CloseDate = date.today().addDays(5);
      opp.Contract_Start_Date__c = date.today().addDays(5);
      opp.Contract_End_Date__c = date.today().addDays(5);
      opp.Type = Constants.OPPTY_TYPE_RENEWAL;
      insert opp;     
        
      //Create the New Contact
      Contact newcontact  = new Contact (FirstName = 'Larry', LastName = 'Ellison',AccountId = account.Id, Email = 'larrye@email.com');
      insert newcontact;
      OpportunityContactRole oppContactRole = Test_Utils.insertOpportunityContactRole(true, opp.Id, newcontact.Id, Constants.DECIDER, true);
        
      //Create Opportunity Line items
      Product2 product = Test_Utils.insertProduct();
      Product.CanUseRevenueSchedule = True;
      update product;
      PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);
      OpportunityLineItem oppLi = Test_Utils.createOpportunityLineItem(opp.Id, stdPricebookEntry.Id, opp.Type);
      oppLi.Start_Date__c = Date.today().addDays(5);
      oppLi.End_Date__c = Date.today().addDays(10);
      oppLi.CPQ_Quantity__c = 1000;
      oppLi.Type__c = Constants.OPPTY_LINE_ITEM_TYPE_RENEWAL;//Case #02088090
         Test.startTest();
      insert oppLi;
        
      //Create Opportunity Revenue Schedule
      Test_Utils.createMultiOpportunityLineItemSche(oppLi.Id); 

      //Close the opty
      opp.Primary_Reason_W_L__c = Constants.PRIMARY_REASON_WLC_TERMS;
      opp.StageName = Constants.OPPTY_STAGE_CLOSED_WON;
      opp.Channel_Type__c = Constants.OPPTY_CHANNEL_TYPE_DIRECT;

      //Start test Mode to Conserve Counts:
     
        
      //Final Step Create Account plan
      Account_Plan__c accountPlan = Test_Utils.insertAccountPlan(false, account.id);
      accountPlan.Name = 'TestAccountPlan';
      insert accountPlan;
    
      //Stop Test     
      Test.stopTest();
                      
      //Final Data Retreival from Test Records and Assertion
      List<Account_Plan_Opportunity__c> optyplan = [SELECT Current_Year_Revenue__c,Year_1_Revenue__c, Year_2_Revenue__c FROM Account_Plan_Opportunity__c WHERE Account_Plan_Opportunity__c.Account_Plan__c =: accountPlan.ID AND Account_Plan_Opportunity__c.Type__c = 'Open Opps'];         
            
      system.assertEquals(500, optyplan[0].Current_Year_Revenue__c); //Assert That Current Year Rev is 500
      system.assertEquals(500, optyplan[0].Year_1_Revenue__c); //Assert That Year1 Rev is 500
      system.assertEquals(500, optyplan[0].Year_2_Revenue__c); //Assert That Year2 Rev is 500
            
    }
  } 
}