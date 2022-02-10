/*******************************************************************************
 * Experian
 * Name         : Opportunitytrigger_CreateOrderTest
 * Created By   : Malcolm Russell
 * Purpose      : Test class of class "Opportunitytrigger_CreateOrder"
 * Created Date : Dec 6th 2018
 *
 * Date Modified                Modified By         Description of the update
 * Feb 18th, 2021               Rohit Aryan         W-030936 : Added method to increase code coverage test_orderLineItemSch
*******************************************************************************/
@isTest
public class Opportunitytrigger_CreateOrderTest {
  
  static Map<String, TriggerSettings__c> triggerSettingMap;
  static Opportunity testOpp;
  static Opportunity testOpp1;
  static OpportunityLineItem oli2;
  static Product2 product;  
  
  static testmethod void test_reopenPostInvoiceOpp() {
    IsDataAdmin__c ida = new IsDataAdmin__c(
      SetupOwnerId = UserInfo.getOrganizationId(), 
      IsDataAdmin__c = true
    ); 
    insert ida;
    
    TriggerSettings__c insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.USER_TRIGGER);
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings;
    
    Profile p;
    UserRole copsRole;
    
    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    List<User> usrList = new List<User>();
    User testUser1;
    User testUser2;
    
    Record_Type_Ids__c recIds = new Record_Type_Ids__c(
      SetupOwnerId = Userinfo.getOrganizationId(),
      SPP_Customer_Success__c = Schema.SObjectType.Sales_Planning_Process__c .getRecordTypeInfosByName().get(Constants.RECORDTYPE_Customer_Success).getRecordTypeId(),
      Opportunity_Standard__c = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get('Standard').getRecordTypeId()
    );
    insert recIds;
    
    Global_Settings__c gs = new Global_Settings__c(Name = Constants.GLOBAL_SETTING,
      Opp_Closed_Lost_Stagename__c = Constants.OPPTY_CLOSED_LOST,
      Opp_Renewal_Probability__c = 30,
      Opp_Renewal_Name_Format__c = 'Renewal - ####',
      Opp_Renewal_StageName__c = Constants.OPPTY_STAGE_3,
      Opp_Renewal_Type__c = Constants.OPPTY_TYPE_RENEWAL,
      Opp_Stage_3_Name__c = Constants.OPPTY_STAGE_3,
      Opp_Stage_4_Name__c = Constants.OPPTY_STAGE_4
    );
    insert gs;

    system.runAs(thisUser) {
      p = [SELECT id FROM profile WHERE Name = :Constants.PROFILE_SYS_ADMIN];
      copsRole = [SELECT Id FROM UserRole WHERE Name = :Constants.ROLE_NA_COPS];
      testUser1 = Test_Utils.createEDQUser(p, 'test1234@experian.com', 'test1');
      testUser2 = Test_Utils.createEDQUser(p, 'test1235@experian.com', 'test2');
      testUser1.UserRoleId = copsRole.Id;
      testUser2.UserRoleId = copsRole.Id;
      usrList.add(testUser1);
      usrList.add(testUser2);
      insert usrList;
    }
    
    system.runAs(testUser1) {
      createTestData();
    }
    delete ida;
       
    Map<id,opportunity> Oldmap = new map<id,opportunity>();
    oldMap = oppMap();

    OpportunityTriggerHandler.isAfterUpdateTriggerExecuted = false;
    OpportunityTriggerHandler.isBeforeUpdateTriggerExecuted = false;
    OpportunityTrigger_OrderHelper.isExecuted = false;
     Test.startTest();
    system.runAs(testUser2) {
      testOpp.StageName = Constants.OPPTY_STAGE_7;
      testOpp.Primary_Reason_W_L__c = constants.PRIMARY_REASON_WLC_DATA_QUALITY;
      testOpp.Channel_Type__c = Constants.OPPTY_CHANNEL_TYPE_DIRECT;
      testOpp.Amount = 100;
      testOpp.Has_Senior_Approval__c = true;
      testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
      testOpp.CloseDate = date.today();
      testOpp.Contract_Start_Date__c = date.today().addDays(1);
      testOpp.Contract_End_Date__c = date.today().addYears(1);
      testOpp.Channel_Type__c = Constants.OPPTY_CHANNEL_TYPE_DIRECT;
      testOpp.Type = Constants.OPPTY_NEW_FROM_NEW; //ttk
      update testOpp;
      Map<id,opportunity> Newmap = new map<id,opportunity>();
      Newmap = oppMap();

       System.enqueueJob(new Opportunitytrigger_CreateOrder  (newMap, oldMap)); 
       Opportunitytrigger_CreateOrder.deleteOrderAndOppIfOppIsReopened(newMap,oldMap);
     }
     Test.stopTest();
     // Order__c testOrder = [SELECT ID, Channel_Source__c FROM Order__c WHERE Opportunity__c = :testOpp.ID];
     // system.assert(testOrder.Channel_Source__c == Constants.ORDER_CHANNEL_SOURCE_DIRECT_SALES); 
  }
  
  public static map<id,opportunity> OppMap()
    {
        String SobjectApiName = 'Opportunity';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
 
        string query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName  ;
        map<id,opportunity> oppMap = new map<id,opportunity>();
        list<opportunity> Opplist =  Database.query(query);
        for(opportunity o : OppList){ oppMap.put(o.id,o);}
        system.debug('values return in map*********'+oppMap);
        return oppMap;
        
    }

  
  static void createTestData() {
    TriggerSettings__c insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.ACCOUNT_TRIGGER);
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings;
     
    insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.CONTACT_TRIGGER);
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings;
     
    insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.ACCOUNT_ADDRESS_TRIGGER);
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings; 
     
    insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.CONTACT_ADDRESS_TRIGGER);
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings; 
     
    insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.TASK_TRIGGER);
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings; 
     
    insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.OPPORTUNITY_CONTACT_ADDRESS_TRIGGER);
    insertTriggerSettings.IsActive__c = false;
    update insertTriggerSettings; 
     
     // Create an account
    Account testAccount = Test_Utils.insertAccount();
    testAccount.Is_Competitor__c = true;
    update testAccount;
    
    //Test.startTest();
    Address__c addrs1 = Test_Utils.insertAddress(true);
    //insert account address
    Account_Address__c accAddrs = Test_Utils.insertAccountAddress(true, addrs1.Id, testAccount.Id);    
    // Create an opportunity
    testOpp = Test_Utils.createOpportunity(testAccount.Id);
    
    testOpp1 = Test_Utils.createOpportunity(testAccount.Id);
    testOpp.Starting_Stage__c = Constants.OPPTY_STAGE_6;
    testOpp.Type = Constants.OPPTY_NEW_FROM_NEW;
    
    insert testOpp;

    //Test_Utils.createOpptyTasks(testOpp.Id, true);

    Contact newcontact = new Contact(
      FirstName = 'Larry', 
      LastName = 'Ellison',
      AccountId = testAccount.Id, 
      //SaaS__c = true,
      Email = 'larrye@email.com',
      Title = 'Test'      
    );
    insert newcontact;
    
    Task newTask = new Task(WhatId = testOpp.Id,whoId = newcontact.Id,Outcomes__c = Constants.ACTIVITY_TYPE_SELECTION_CONFIRMED, Status = Constants.STATUS_COMPLETED);
    insert newTask;

    Contact_Address__c conAdd = Test_Utils.insertContactAddress(true, Test_Utils.insertAddress(true).Id, newcontact.Id);

    List<Opportunity_Contact_Address__c> oppConAdds = new List<Opportunity_Contact_Address__c>();
    Opportunity_Contact_Address__c oppConAdd = new Opportunity_Contact_Address__c();
    oppConAdd.Opportunity__c= testOpp.Id ;
    oppConAdd.Address__c = conAdd.Address__c;
    oppConAdd.Contact__c = newcontact.Id;
    oppConAdd.Role__c = Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER;
    oppConAdds.add(oppConAdd);

    Opportunity_Contact_Address__c oppConAdd1 = new Opportunity_Contact_Address__c();
    oppConAdd1.Opportunity__c= testOpp.Id ;
    oppConAdd1.Address__c = conAdd.Address__c;
    oppConAdd1.Contact__c = newcontact.Id;
    oppConAdd1.Role__c = Constants.OPPTY_CONTACT_ROLE_COMMERCIAL;
    oppConAdds.add(oppConAdd1);

    Opportunity_Contact_Address__c oppConAdd2 = new Opportunity_Contact_Address__c();
    oppConAdd2.Opportunity__c= testOpp.Id ;
    oppConAdd2.Address__c = conAdd.Address__c;
    oppConAdd2.Contact__c = newcontact.Id;
    oppConAdd2.Role__c = Constants.OPPTY_CONTACT_ROLE_CONTRACTUAL;
    oppConAdds.add(oppConAdd2);

    Opportunity_Contact_Address__c oppConAdd3 = new Opportunity_Contact_Address__c();
    oppConAdd3.Opportunity__c= testOpp.Id ;
    oppConAdd3.Address__c = conAdd.Address__c;
    oppConAdd3.Contact__c = newcontact.Id;
    oppConAdd3.Role__c = Constants.OPPTY_CONTACT_ROLE_RENEWAL;
    oppConAdds.add(oppConAdd3);

    Opportunity_Contact_Address__c oppConAdd4 = new Opportunity_Contact_Address__c();
    oppConAdd4.Opportunity__c= testOpp.Id ;
    oppConAdd4.Address__c = conAdd.Address__c;
    oppConAdd4.Contact__c = newcontact.Id;
    oppConAdd4.Role__c = Constants.OPPTY_CONTACT_ROLE_SHIPTO;
    oppConAdds.add(oppConAdd4);

    Opportunity_Contact_Address__c oppConAdd5 = new Opportunity_Contact_Address__c();
    oppConAdd5.Opportunity__c= testOpp.Id ;
    oppConAdd5.Address__c = conAdd.Address__c;
    oppConAdd5.Contact__c = newcontact.Id;
    oppConAdd5.Role__c = Constants.OPPTY_CONTACT_ROLE_UPDATE;
    oppConAdds.add(oppConAdd5);

    insert oppConAdds;

    //Test_Utils.insertEDQOpportunityContactRoles(testOpp.Id, newContact.Id);
    
    //DO Case #02137101: Added all roles to check sync Contact role address validation
      OpportunityContactRole oppContactRole =  Test_Utils.insertOpportunityContactRole(false, testOpp.Id, newcontact.Id, Constants.DECIDER, true);

      OpportunityContactRole oppConRole1 = Test_Utils.insertOpportunityContactRole(false, testOpp.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER, false);

      OpportunityContactRole oppConRole2 = Test_Utils.insertOpportunityContactRole(false, testOpp.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_RENEWAL, false);

      OpportunityContactRole oppConRole3 = Test_Utils.insertOpportunityContactRole(false, testOpp.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_UPDATE, false);

      OpportunityContactRole oppConRole4 = Test_Utils.insertOpportunityContactRole(false, testOpp.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_COMMERCIAL, false);

      OpportunityContactRole oppConRole5 = Test_Utils.insertOpportunityContactRole(false, testOpp.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_SHIPTO, false);

      OpportunityContactRole oppConRole6 = Test_Utils.insertOpportunityContactRole(false, testOpp.Id, newcontact.Id, Constants.OPPTY_CONTACT_ROLE_CONTRACTUAL, false);

      insert new List<OpportunityContactRole>{oppContactRole,oppConRole1,oppConRole2,oppConRole3,oppConRole4,oppConRole5,oppConRole6};

    // Create Opportunity Line Item
    product = Test_Utils.insertProduct();
    product.RevenueScheduleType = Constants.REVENUE_SCHEDULED_TYPE_REPEAT;
    product.RevenueInstallmentPeriod = Constants.INSTALLMENT_PERIOD_DAILY;
    product.NumberOfRevenueInstallments = 2;
    product.CanUseRevenueSchedule = true;
    update product;
    
    PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);
    //insert OLI
    oli2 = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
    oli2.Start_Date__c = Date.today().addDays(5);
    oli2.End_Date__c = System.today().addDays(10);
    oli2.CPQ_Quantity__c = 1000;
    oli2.SaaS__c = true;
    insert oli2;

    //insert OLIS
    OpportunityLineItemSchedule olsi1 = Test_Utils.createOpportunityLineItemSchedule(oli2.id);
    olsi1.ScheduleDate = System.today().addDays(5);
    olsi1.Revenue = oli2.TotalPrice / 3;
    OpportunityLineItemSchedule olsi2 = Test_Utils.createOpportunityLineItemSchedule(oli2.id);
    olsi2.ScheduleDate = olsi1.ScheduleDate.addDays(5);
    olsi2.Revenue = oli2.TotalPrice / 3;
    OpportunityLineItemSchedule olsi3 = Test_Utils.createOpportunityLineItemSchedule(oli2.id);
    olsi3.ScheduleDate = olsi1.ScheduleDate.addDays(5);
    olsi3.Revenue = oli2.TotalPrice / 3;
    
    List<OpportunityLineItemSchedule> opptySchedules = new List<OpportunityLineItemSchedule>();
    opptySchedules.add(olsi1);
    opptySchedules.add(olsi2);
    opptySchedules.add(olsi3);
    insert opptySchedules;

    Competitor__c comp = Test_Utils.createCompetitor(testOpp.Id);
    insert comp;

    //insert Order
    Order__c odr = Test_Utils.insertOrder(true, testAccount.Id, newcontact.Id, testOpp.Id);

    // insert Billing Product
    Billing_Product__c billProd = Test_Utils.insertBillingProduct();

    // insert Order line item
    Order_Line_Item__c odrOli = Test_Utils.insertOrderLineItems(true, odr.Id, billProd.Id);

    //insert Order Revenue Schedule
    Order_Revenue_Schedule__c ors = new Order_Revenue_Schedule__c(
      Comment__c = 'Test',
      Order_Line_Item__c = odrOli.Id,
      Revenue__c = 100,
      Scheduled_Date__c = System.today().addDays(5)
    );
    insert ors;
  }

  Public static Map<ID, order__C> OrderMAp(){

    String SobjectApiName = 'Order__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
 
        string query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName  ;
        map<id,Order__C> odrMap = new map<id,Order__C>();
        list<Order__c> Orderlist =  Database.query(query);
        for(Order__c o : Orderlist){ 
          odrMap.put(o.Opportunity__c,o);}
        return odrMap;
  }
  @isTest
      public static void test_orderLineItemSch(){
          User testUser = Test_Utils.insertUser(Constants.PROFILE_SYS_ADMIN);
          
          Account testAccount = Test_Utils.insertAccount();
          
          TriggerSettings__c insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.OPPORTUNITY_CONTACT_ADDRESS_TRIGGER);
          insertTriggerSettings.IsActive__c = false;
          update insertTriggerSettings;
          
          insertTriggerSettings = Test_Utils.insertTriggerSettings(Constants.ORDER_TRIGGER);
          insertTriggerSettings.IsActive__c = false;
          update insertTriggerSettings;
          
          Contact newcontact = new Contact(
              FirstName = 'Larry', 
              LastName = 'Ellison',
              AccountId = testAccount.Id, 
              //SaaS__c = true,
              Email = 'larrye@email.com',
              Title = 'Test'      
          );
          insert newcontact;
          
          testOpp = Test_Utils.insertOpportunity(testAccount.Id);
          
          // Create Opportunity Line Item
          product = Test_Utils.insertProduct();
          product.RevenueScheduleType = Constants.REVENUE_SCHEDULED_TYPE_REPEAT;
          product.RevenueInstallmentPeriod = Constants.INSTALLMENT_PERIOD_DAILY;
          product.NumberOfRevenueInstallments = 2;
          product.CanUseRevenueSchedule = true;
          update product;
          
          PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPricebookId(), Constants.CURRENCY_USD);
          //insert OLI
          oli2 = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
          oli2.Start_Date__c = Date.today().addDays(5);
          oli2.End_Date__c = System.today().addDays(10);
          oli2.CPQ_Quantity__c = 1000;
          oli2.SaaS__c = true;
          insert oli2;
          
          Test.StartTest();
          OpportunityLineItemSchedule olsi1 = Test_Utils.createOpportunityLineItemSchedule(oli2.id);
          olsi1.ScheduleDate = System.today().addDays(5);
          olsi1.Revenue = oli2.TotalPrice / 3;
          
          List<OpportunityLineItemSchedule> opptySchedules = new List<OpportunityLineItemSchedule>();
          opptySchedules.add(olsi1);
          insert opptySchedules;
          
          Order__c odr = Test_Utils.insertOrder(true, testAccount.Id, newcontact.Id, testOpp.Id);
          
          Billing_Product__c billProd = Test_Utils.insertBillingProduct();
          
          Order_Line_Item__c odrOli = Test_Utils.insertOrderLineItems(true, odr.Id, billProd.Id);
          odrOli.Opportunity_Line_Item_Id__c = oli2.id;
          update odrOli;
          
          Map<Id, Order_Line_Item__c> ordroliMap = new Map<Id, Order_Line_Item__c>();
          ordroliMap.put(odrOli.Opportunity_Line_Item_Id__c, odrOli);
          
          Order_Revenue_Schedule__c ors = new Order_Revenue_Schedule__c(
              Comment__c = 'Test',
              Order_Line_Item__c = odrOli.Id,
              Revenue__c = 100,
              Scheduled_Date__c = System.today().addDays(5)
            );
            insert ors;
          Opportunitytrigger_CreateOrder.createRevenueSchedules(ordroliMap);
          Test.StopTest();          
        }

}