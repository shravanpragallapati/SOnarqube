/**=====================================================================
 * Appirio, Inc
 * Name: Test_Utils
 * Description: This class is use for all related Test clases for creating Pre required
                Data if needed in case of testing any scenario.
 * Created Date: Oct 30th, 2013
 * Created By: Pankaj Mehra (Appirio)

********** NOTE THE FOLLOWING **********
 This class has been intentionally left without the @isTest notation because if we add it, the code coverage calculation take this
 class into consideration. To prevent the class counting incorrectly towards the org total, we must not add @isTest to this class!!!
 ****************************************


 *
 * Date Modified      Modified By                  Description of the update
 * Jan 30th, 2014     Jinesh Goyal(Appirio)        T-232760: Homogenize the comments
 * 02/12/2014         Naresh Ojha (Appirio)        Added method for creation of opportunity schedules
 * Feb 13th, 2014     Jinesh Goyal(Appirio)        T-232763: Added Exception Logging
 * Feb 18th, 2014     Jinesh Goyal(Appirio)        T-250105: Added Methods 'insertAddress'
 *                                                 and 'insertAddressMergeRequest'
 * Feb 20th, 2014     Nathalie Le Guay (Appirio)   Updated createOpportunity() to reference
 *                                                 Constants.OPPTY_STAGE_3 instead of 'na'
 * Feb 24th, 2014     Jinesh Goyal(Appirio)        T-250105: Added Methods 'insertAccountAddress'
 *                                                 and 'insertContactAddress'
 * Feb 26th, 2014     Nathalie Le Guay             Adding createTask() and createOpptyTasks() methods
 * Feb 27th, 2014     Arpita Bose(Appirio)         updated "insertTriggerSettings()" to get custom settings.
 * Mar 04th, 2014     Arpita Bose(Appirio)         T-243282: Added Constants in place of String
 * Mar 13th, 2014     Nathalie Le Guay             Adding createEvent()
 * Mar 27th, 2014     Nathalie Le Guay             T-266743: Remove references to Primary_Billing__c & Primary_Shipping__c (unused)
 *                                                 Comment 'newShare.ContactAccessLevel' bc ContactAccessLevel is now "Controlled by Parent"
 * Mar 28th, 2014     Arpita Bose(Appirio)         Updated createOpportunityLineItem() to set Quantity for the Validation Rule
 * Mar 31st, 2014     Nathalie Le Guay             Added createUser(Profile profile, String email, String lastName)
 * Apr 02nd, 2014     Arpita Bose                  T-268663: Renamed OrderLineItem's Service Start/End dates to Start/End dates
 * Apr 03rd, 2014     Arpita Bose                  T-268982: Updated the method name insertOrderLineItems() from inserOrder()
 * Apr 15th, 2014     Arpita Bose                  T-271695: Removed reference to Below_Review_Thresholds__c field
 * Apr 18th, 2014     Rahul Jain                   Added insertCase, insertDeliveryProject, insertTimecard methods for Task T-270393 and T-270392
 * Apr 28th, 2014     Rahul Jain                   Added insertOpportunityPlan, insertOpportunityTeamMember, insertTimecard methods for Task T-273695
 * May 02nd, 2014     Rahul Jain                   Added insertAccountTeamMember,insertAccountPlan,insertAccountPlanTeam methods for T-275545
 * May 07th, 2014     Rahul Jain                   Added insertAccountPlanSwot,insertAccountPlanOpp, insertAccountPlanOppSwot methods for T-276704, T-276706
 * Jun 03rd, 2014     Jinesh Goyal                 Added method insertAccountPlanPenetration
 * Jun 25th, 2014     Bharti
 * Jul 28th, 2014     Nathalie Le Guay             S-252919 - updated createTask(String whatId, String typeValue, String status) to use Outcomes__c instead of Type
 * Aug 01st, 2014     Arpita Bose                  Added method insertProject and insertDeliveryLine for T-268015
 * Aug 27th, 2014     Arpita Bose                  Added method insertCase for T-314309 (Experian Phase 2)
 * Sep 11th, 2014     Mohit Parnami                Added method insertRoyalty for T-318596
 * Oct 07th, 2014     Arpita Bose                  Added method insertOpportunityContactRole for T-322814
 * Oct 10th, 2014     Arpita Bose                  Added method insertAsset()
 * Oct 17th, 2014     Arpita Bose                  Added method createEDQUser()
 * Oct 21st, 2014     Pallavi Sharma               Added Math.random() for getting Unique External Ids - updated by NLG for I-135920
 * Nov 2nd,  2014     Nathalie Le Guay             Populating FirstName in the CreateUser methods, to prevent other test classes from failing
 * Jan 22nd, 2015     Arpita Bose                  Added methods insertAssignmentTeam(),insertAssignmentTeamMember()and insertAccAssignmentTeam()
 * Mar 3rd,  2015     Gaurav Kumar Chadha          Added method insertContract()
 * Mar 5th,  2015     Gaurav Kumar Chadha          Added method insertDeployment()
 * Mar 17th, 2015     Gaurav Kumar Chadha          Added method insertOpportunitySalesProcess()
 * Mar 26th, 2014     Tyaga Pati                   Added Function to Created multiple Revenue schedules for opty plan aggregation testing
 * Mar 27th, 2015     Arpita Bose                  Added method insertHierarchy() and insertAccountSegment() for T-373930
 * Apr 08th, 2015     Terri Kellough               Added insertBusinessProcessTemplateItem, insertBusinessProcessTemplate,
 *                                                 insertBusinessProcess, insertBusinessProcessItem, and insertMembership
 * May 12th, 2015     Terri Kellough               Modified createOpportunityLineItem for I-162285
 * May 13th, 2015     Terri Kellough               Modified createOpportunity(Id accountId) for I-162285
 * Jun 29th, 2015     Nur Azlini                   Release Automation - Added method insertMetadataComponent()
 * Jul 24th, 2015     Tyaga Pati                   Test Class for Creating Activity With Campaigns.
 * Jul 27th, 2015     Tyaga Pati                   Added Section for updating Opty after insertion of con roles. This will make sure RollupConRoleFlag is
                                                   updated at opty level.

 * Aug 31st, 2015     Naresh Ojha                  Added method insertOpportunityContactAddress ()
 * Set 7th, 2015      Diego Olarte                 Updated method insertEDQContact () adding email and phone
 * Sep 8th, 2015      Paul Kissick                 I-179463: Duplicate Management Failures
 * Dec 3rd, 2015      Paul Kissick                 Case 01266075: Removing Global Settings for timings
 * Jan 5th, 2016      Paul Kissick                 Fixing failing test class due to change in year.
 * Apr 4, 2016        Paul Kissick                 Case 01932085: Replacing user emails with experian.com
 * Apr 5, 2016        Paul Kissick                 Case 2376 - Updated state/country to match valid entries
 * Apr 15, 2016       Sadar Yacob                  Country and State picklist implementation use valid country values
 * Apr 25th, 2016     Paul Kissick                 Fixed insertGlobalSettings method to check for existing before creating.
 * May 16th, 2016     Paul Kissick                 Case 01220695: Fixing opp line items to support edq validations
 * May 31st, 2016     Diego Olarte                 Case 01663898: Add option to create Chatter group
 * Jun 01st, 2016     Diego Olarte                 Case 01973277: Added createCPQCaseComponent
 * Jun 16th, 2016     Paul Kissick                 Case 02024883: Fixing issue due to changes to AccountTeamMember object (v37.0)
 * Jun 27th, 2016     Manoj Gopu                   Case #01947180 - Remove EDQ specific Contact object fields - MG COMMENTED CODE OUT
 * Jul 27th, 2016(QA) Diego Olarte                 CRM2:W-005406: Contact relationship BU Lead
 * Aug 16th, 2016     Paul Kissick                 CRM2:W-005413: Added EmployeeNumber to new user methods
 * Aug 16th, 2016     Paul Kissick                 Made class a proper public test class (so it can be used by other tests.)
 * Sep 6th, 2016      Paul Kissick                 Removed previous change making this a 'proper' test class - Also started to remove unused methods
 * Sep 8th, 2016      Paul Kissick                 Commented out more unused method - improving coverage since they are never called!
 * Sep 29th, 2016     Manoj Gopu                   Case 02148690: Added User field  from the Custom Setting in the static method.
 * Oct 18th, 2016     Manoj Gopu                   Case 02172178: Added New Field Serasa Employee Number in User Creation test methods
 * Jan 26th, 2018     Malcolm Russell              Added Title to createContact to comply with Validation rule                                                                                                            
 * Feb 14th, 2018     Esteban Castro               Added createSubCode, insertSubCode. Changed createUser: added dynamic lanid
 * Jun 6th 2018       Malcolm Russell              Added createMatchingRules, createMatchingRuleAttribute      
 * Apr 22nd 2021      Navya                        W-031968 Added new method for creating NA Targeting Project record   
 * Jun 25th 2021      Navya                        W-033794 - Created new method createSalesRevenueSchedule for creating Sales revenue schedule record 
 * Jul 12th 2021      Manoj Gopu                   Case 22409346: Remove Apex code coverage field references for deletion                                                                                
=====================================================================*/
// @isTest
// DO NOT UNCOMMENT THIS - IT MAKES THE CLASS COUNT TOWARDS THE ORG APEX TEST COVERAGE TOTAL
public class Test_Utils {

  static {
    try {
      Global_Settings__c custSettings = Global_Settings__c.getValues('Global');
      if (custSettings == null) {
        custSettings = new Global_Settings__c(name='Global',Account_Team_Member_Default_Role__c= Constants.TEAM_ROLE_ACCOUNT_MANAGER,Seal_API_User__c=UserInfo.getUserId());
        insert custSettings;
      }
    }
    catch(Exception ex) {
      system.debug('#########Exception############'+ex);
      apexLogHandler.createLogAndSave('Test_Utils','static block', ex.getStackTraceString(), ex);
    }
  }

  public static Business_Unit_Group_Mapping__c edqSetting {
    get {
      try {
        edqSetting = Business_Unit_Group_Mapping__c.getValues('EDQ');
        if (edqSetting == null) {
          edqSetting = new Business_Unit_Group_Mapping__c(Name='EDQ',User_Business_Unit__c = 'APAC:SE', Common_Group_Name__c = 'EDQ');
          insert edqSetting;
        }
      }
      catch(Exception ex) {
        system.debug('#########Exception############'+ex);
        apexLogHandler.createLogAndSave('Test_Utils','static block', ex.getStackTraceString(), ex);
      } 
      return edqSetting;
    }
  }
  
  private static Map<String, Id> profileNameHold = new Map<String, Id>();

  //=============================================================//
  //Creates Opportunity
  //============================================================//
  public static Opportunity createOpportunity(Id accountId) {
    Opportunity opportunity = new Opportunity(
      Name = 'Test Opportunity',
      CloseDate = date.today().addDays(2),
      StageName = Constants.OPPTY_STAGE_3,
      AccountId = accountId,
      CurrencyIsoCode = 'USD',
      Contract_Start_Date__c = date.today().addDays(3),
      Contract_End_Date__c = date.today().addYears(1),
      Type = 'test',
      Reporting_Sales_Team__c = null,
      Invoice_to_End_User__c = 'Yes',
      FYR__c = null,
      SYR__c = null,
      Quote_Active__c = true,
     // Quote_Bill_Plan_Code__c = 'test',
     // Quote_Close_Date__c = datetime.now(),
      Quote_Created_Date__c = datetime.now(),
     // Quote_Effective_As_Of__c = date.today(),
     // Quote_Effective_Through__c = date.today().addYears(1),
      Quote_Last_Modified_Date__c= datetime.now(),
      Quote_Number__c = 'test',
      Quote_Primary__c = true,
      Quote_Revision__c = 'test',
      Quote_Type__c = 'test',
      Requested_Bill_Plan__c = 'test',
      Suggested_Bill_Plan__c = 'test'
    );
    return opportunity;
  }

  //=============================================================//
  //Creates Opportunity
  //============================================================//
  public static Opportunity insertOpportunity(Id accountId) {
    Opportunity opportunity = createOpportunity(accountId);
    //opportunity.Below_Review_Thresholds__c = 'Yes'; T-271695
    insert opportunity;
    return opportunity;
  }

  //=============================================================//
  //Creates Opportunity_Sales_Process__c
  //============================================================//
  public static Opportunity_Sales_Process__c insertOpportunitySalesProcess(Boolean isInsert,  String name) {
    Opportunity_Sales_Process__c oppSalesProcess = new Opportunity_Sales_Process__c();
    oppSalesProcess.Name = name;
    if (isInsert) {
      insert oppSalesProcess;
    }
    return oppSalesProcess;
  }

  //=============================================================//
  //Insert Contact
  // I-179463: Override for Duplicate Management Failures
  //============================================================//
  public static Contact insertContact(Id accountId) {
    Contact contact = createContact(accountId);
    Database.insert(contact, duplicateRuleOverride());
    return contact;
  }

  //=============================================================//
  //Creates Contact
  //============================================================//
  public static Contact createContact(Id accountId) {
    Contact contact = new Contact(
      MailingCountry = 'United States of America',
      MailingState = 'Texas',
      MailingCity = 'Dallas',
      FirstName = 'firstname'+randomNumber(),
      Salutation = 'Mr.',
      LastName = 'test'+randomNumber(),
      Email = 'test@'+randomNumber()+'test.com',
      AccountId = accountId,
      title='Test Manager'                        
    );
    return contact;
  }

  //=============================================================//
  //Insert Contact
  // I-179463: Override for Duplicate Management Failures
  //============================================================//
  public static Contact insertEDQContact(Id accountId, Boolean isInsert) {
    Contact contact = createContact(accountId);
    //contact.EDQ_On_Demand__c = true;
    contact.Title = 'NewTitle';
    contact.EDQ_Integration_Id__c = 'TESTID'+randomNumber();
    contact.Phone = '123442356';
    contact.Email = 'test@'+randomNumber()+'test.com';

    if (isInsert) {
      Database.insert(contact, duplicateRuleOverride());
    }
    return contact;
  }

  //=============================================================//
  //Creates Lead
  //============================================================//
  public static Lead createLead() {
    Lead lead = new Lead(
      LastName = 'Test Lead-'+randomNumber(),
      FirstName = 'Test Lead-'+randomNumber(),
      City = 'TestCity',
      State = 'Texas',
      Street = 'TestStreet',
      Country = 'United States of America',
      PostalCode = '302120',
      Status = 'Open',
      Email = 'test@test.com',
      Company = 'TestComapny',
      CurrencyIsoCode = Constants.CURRENCY_USD,
      Phone = '123442356',
      LeadSource = 'Other',
      Industry = 'Automotive',
      Region__c = 'India'
    );
    return lead;
  }

  //=============================================================//
  //Insert Lead
  //============================================================//
  public static Lead insertLead() {
    Lead lead = createLead();
    insert lead;
    return lead;
  }

   //=============================================================//
  //Creates MarketingActivity
  //============================================================//
  public static ELQA_Marketing_Activity__c createMarketingActivity() {
    ELQA_Marketing_Activity__c MarketingActivity = new ELQA_Marketing_Activity__c();
    return MarketingActivity;
  }

  //=============================================================//
  //insert MarketingActivity
  // PK - Commented out as it wasn't being used!
  //============================================================//
//  public static ELQA_Marketing_Activity__c insertMarketingActivity() {
//    ELQA_Marketing_Activity__c MarketingActivity = createMarketingActivity();
//    insert MarketingActivity;
//    return MarketingActivity;
//  }

  //=============================================================//
  //Creates Account
  //============================================================//
  public static Account createAccount() {
    Account defaultAccount = new Account();
    defaultAccount.Name = 'Test Account'+randomNumber();
    return defaultAccount;
  }

  //=============================================================//
  //Creates Accounts
  // PK - Commented out as it wasn't being used!
  //============================================================//
//  public static List<Account> createAccounts(Integer numberOfAccounts) {
//    List<Account> accounts = new List<Account>();
//    for (Integer i = 0; i < numberOfAccounts; i++) {
//      accounts.add(createAccount());
//    }
//    return accounts;
//  }

  //=============================================================//
  //Creates Account
  // PK: I-179463 Duplicate Management Rule Failures
  //============================================================//
  public static Account insertEDQAccount(Boolean isInsert) {
    Account defaultAccount = createAccount();
    defaultAccount.EDQ_Integration_Id__c = 'TESTID'+randomNumber();
    if (isInsert) {
      Database.insert(defaultAccount,duplicateRuleOverride());
    }
    return defaultAccount;
  }

  //=============================================================//
  //Inserts Account
  // PK: I-179463 Duplicate Management Rule Failures
  //============================================================//
  public static Account insertAccount() {
    Account account = createAccount();
    Database.insert(account, duplicateRuleOverride());
    return account;
  }

  //=============================================================//
  //Creates Competitor
  //============================================================//
  public static Competitor__c createCompetitor(Id opportuntiyId) {
    Opportunity opp = [Select Id, AccountId from Opportunity where Id =: opportuntiyId LIMIT 1];  
    Competitor__c competitor = new Competitor__c(
      Opportunity__c = opportuntiyId,
      Account__c = opp.AccountId
    );
    return competitor;
  }

  //=============================================================//
  //Inserts Competitor
  //============================================================//
  public static Competitor__c insertCompetitor(Id opportuntiyId) {
    Competitor__c competitor = createCompetitor(opportuntiyId);
    insert competitor;
    return competitor;
  }

   //=============================================================//
  //Create OpportunityLineItem
  //============================================================//
  public static OpportunityLineItem createOpportunityLineItem(Id OpportunityId, Id PricebookEntryId, String oppType) {
    Decimal oliTotPrice = 200 + Integer.valueOf(randomNumber()*100);
    OpportunityLineItem  oppLineItem = new OpportunityLineItem(
      TotalPrice = oliTotPrice,
      UnitPrice = null,
      Quantity = 1,
      OpportunityId = OpportunityId,
      PricebookEntryId = PricebookEntryId,
      Start_Date__c = Date.today().addDays(-5),
      End_Date__c = Date.today().addDays(5),
      Type__c = 'test',
      SaaS__c = false,
      SaaS_Product_Code__c = 'test',
      Product_Finance_BU__c = 'test',
      Finance_BU_Name__c = 'test',
      CPQ_Quantity__c = 1,
      EDQ_Margin__c = oliTotPrice,
      Renewal_EDQ_Margin__c = oliTotPrice,
      Product_Upgrade__c = false,
      //Order_Type__c = 'test', // PK 2016-05-31 - Commented out as was overwriting above setting.
      Renewal_List_Price__c = oliTotPrice,
      Opportunity_Country__c = 'United States of America',
      Application__c = 'test',
      Compiler__c = 'test',
      CD_Name__c = 'test',
      Click_Expiry__c = false,
      CRM_Product_Name__c = 'test',
      Data_Installer_Password__c = 'test',
      Data_Media__c = 'test',
      Data_Required__c = false,
      Delivery_Method__c = 'test',
      Despatch_Status__c = 'test',
      Delivery_Time__c = 'test',
      CPQ_Discount__c = 0,
      Discount_Amount__c = 0,
      Distribution_Notes__c = 'test',
      EDQ_On_Demand_Product__c = false,
      eRenewal_Exception__c = false,
      Extended_Amount__c = oliTotPrice,
      Hardware__c = 'test',
      Implementation__c = 'test',
      Description = 'test',
      //Item_Quantity__c = 1,
      Item_Number__c = 'test',
      List_Price__c = oliTotPrice,
      Manual_Registration__c = true,
      Manuals_Required__c = false,
      Media_Quantity__c = 1,
      No_Delivery__c = true,
      No_Update__c = true,
      Operating_System__c = 'test',
      Parent_Item_Number__c = 'test',
      Part_Number__c = 'test',
      Partner_Amount__c = 0,
      Partner__c = 0,
      Precise_Day_License__c = false,
      Price_Category__c = 'test',
      Product_Code__c = 'test',
      Product_Data__c = 'test',
      Product_Family__c = 'test',
      Product_Reference__c = 'test',
     // Product_Release_Name__c = 'test',
      Renewal_Discount__c = 0,
      Renewal_Discount_Amount__c = 0,
      Renewal_Extended_Amount__c = oliTotPrice,
      Renewal_Partner_Amount__c = 0,
      Renewal_Partner__c = 0,
      Renewal_Registration__c = false,
      Renewal_Sale_Price__c = oliTotPrice,
      Renewal_Total_Royalty__c = 0,
      Renewals_Exclude__c = false,
      Total_Royalty__c = 0,
      Update_Frequency__c = 'test',
      Users_From__c = 1,
      Users_To__c = 1,
      Adj_Amount__c = 1,
      Adj_Percentage__c = 1,
      AE_Discount__c = 1,
      Annual_Sales_Price__c = 1,
     // Auto_Quote__c = false,
     // Bill_Plan_Product_Name__c = 'test',
     // Bundle_Discount_Category__c = 'test',
     // Bundle_Discount_Name__c = 'test',
      CSDA_Estimated_Annual_Volume__c = 1,
      CSDA_List_Price__c = 1,
      CSDA_Product_Group__c = 'test',
      CSDA_Product_Org__c = 'test',
      CSDA_Product_Suite__c = 'test',
      CSDA_Unit_Type__c = 'test',
     // Escalate__c = true,
     // Final_Price__c = 1,
      Manager_Discount__c = 1,
      Manual_Adj_Amount__c = 1,
      Manual_Discount__c = 1,
      Manual_Price_Override__c = 1,
      //Maximum_Price__c = 1,
      Max_Volume__c = 1,
     // Minimum_Price__c = 1,
      Min_Volume__c = 1,
      Original_Price__c = 1,
      //Plan__c = 'test',
      Quotable__c = 'test',
     // Quote_Sheet_Type__c = 'test',
      Requested_Adjustment_Amount__c = 1,
      Requested_Unit_Price__c = 1,
      SA_Discount__c = 1
    );
    if (oppType == Constants.OPPTY_NEW_FROM_NEW ) {
      oppLineItem.Order_Type__c = Constants.STATUS_NEW;
    }
    else if ( oppType == Constants.OPPTY_NEW_FROM_EXISTING ) {
      oppLineItem.Order_Type__c = Constants.CROSS_SELL;
    }
    else if ( oppType == Constants.OPPTY_TYPE_RENEWAL ) {
      oppLineItem.Order_Type__c = Constants.OPPTY_TYPE_RENEWAL;
      oppLineItem.Original_Asset_ID__c = 'test';  // PK Moved this up so it only works on renewals
    }
    else if ( oppType == Constants.OPPTY_TYPE_FREE_TRIAL ) {
      oppLineItem.Order_Type__c = Constants.OPPTY_TYPE_FREE_TRIAL;
    }
    return oppLineItem;
  }

  //=============================================================//
  //Create OpportunityLineItem (overloaded)
  // PK - Commented out as it wasn't being used!
  //============================================================//
//  public static OpportunityLineItem createOpportunityLineItem(Id OpportunityId, Id PricebookEntryId, Id BillingProductId,  String oppType) {
//    OpportunityLineItem oppLineItem = createOpportunityLineItem(OpportunityId, PricebookEntryId, oppType);
//    oppLineItem.Billing_Product__c = BillingProductId;
//    return oppLineItem;
//  }

  //=============================================================//
  //Create OpportunityLineItem (overloaded)
  //============================================================//
  public static OpportunityLineItemSchedule insertOpportunityLineItemSchedule(Id opportunityLineItemId) {
    OpportunityLineItemSchedule lis = createOpportunityLineItemSchedule(opportunityLineItemId);
    insert lis;
    return lis;
  }

  //=============================================================//
  //Create OpportunityLineItem (overloaded)
  //============================================================//
  public static OpportunityLineItemSchedule createOpportunityLineItemSchedule(Id opportunityLineItemId) {
    OpportunityLineItemSchedule lis = new OpportunityLineItemSchedule(
      OpportunityLineItemId = opportunityLineItemId,
      Type = 'Revenue',
      Revenue = 100,
      ScheduleDate = Date.today().addDays(5),
      Description = 'According to invoice '+randomNumber()
    );
    return lis;
  }
    
   //=============================================================//
  //Create SalesRevenueSchedule (overloaded) - W-033794
  //============================================================//
  public static Sales_Revenue_Schedule__c createSalesRevenueSchedule(Id opportunityLineItemId) {
    Sales_Revenue_Schedule__c srs = new Sales_Revenue_Schedule__c(
      Opportunity_Line_Item_ID__c = opportunityLineItemId,
      Revenue__c = 100,
      Schedule_Date__c = Date.today().addDays(5)
      );
    return srs;
  }
    
  //=============================================================//
  // Tyaga Pati : Create OpportunityLineItem schedule with multiple schedule lines (overloaded)
  //============================================================//
  public static void createMultiOpportunityLineItemSche(Id opportunityLineItemId) {
    Integer count0 = 0;
    Integer count1 = 0;
    Integer count2 = 0;
    DateTime CurrentDt = DateTime.now();
    Integer Year1 = CurrentDt.Year();
    // Fix for failing over new year
    if (currentDt.month() < 4) {
      Year1 = Year1 - 1; // make this the previous year
    }
    Integer Year2 = Year1+1;
    Integer Year3 = Year1+2;
    Integer MonthSt = 4;
    Integer DateSt = 1;
    Decimal Rev = 100;
    List<OpportunityLineItemSchedule> RevListInsert = new List<OpportunityLineItemSchedule>();
    do {
      OpportunityLineItemSchedule lis = new OpportunityLineItemSchedule();
      lis.OpportunityLineItemId = opportunityLineItemId;
      lis.Type = 'Revenue';
      lis.Revenue = Rev;
      MonthSt +=1;
      Date RevDate = date.newinstance(Year1, MonthSt, DateSt);
      lis.ScheduleDate = RevDate;
      lis.Description = 'According to invoice '+ randomNumber();
      RevListInsert.add(lis);
      count0++;
    } while (count0 < 5);
    MonthSt = 4;
    //While Loop1 for Revn For Next Year.
    do {
      OpportunityLineItemSchedule lis = new OpportunityLineItemSchedule();
      lis.OpportunityLineItemId = opportunityLineItemId;
      lis.Type = 'Revenue';
      lis.Revenue = Rev;
      MonthSt +=1;
      Date RevDate = date.newinstance(Year2, MonthSt, DateSt);
      lis.ScheduleDate = RevDate;
      lis.Description = 'According to invoice '+randomNumber();
      RevListInsert.add(lis);
      count1++;
    } while (count1 < 5);
    MonthSt = 4;
    //While Loop1 for Revn For Year+2.
    do {
      OpportunityLineItemSchedule lis = new OpportunityLineItemSchedule();
      lis.OpportunityLineItemId = opportunityLineItemId;
      lis.Type = 'Revenue';
      lis.Revenue = Rev;
      MonthSt +=1;
      Date RevDate = date.newinstance(Year3, MonthSt, DateSt);
      lis.ScheduleDate = RevDate;
      lis.Description = 'According to invoice '+randomNumber();
      RevListInsert.add(lis);
      count2++;
    } while (count2 < 5);

    insert RevListInsert;
  }

  //=============================================================//
  //Inserts OpportunityLineItem
  //============================================================//
  public static OpportunityLineItem insertOpportunityLineItem(Id OpportunityId, Id PricebookEntryId, String oppType) {
    OpportunityLineItem oppLineItem = createOpportunityLineItem(OpportunityId, PricebookEntryId, oppType);
    insert oppLineItem;
    return oppLineItem;
  }

  //=============================================================//
  //Inserts OpportunityLineItem (overloaded)
  // PK - Commented out as it wasn't being used!
  //============================================================//
//  public static OpportunityLineItem insertOpportunityLineItem(Id OpportunityId, Id PricebookEntryId, Id BillingProductId, String oppType) {
//    OpportunityLineItem oppLineItem = createOpportunityLineItem(OpportunityId, PricebookEntryId, BillingProductId, oppType );
//    insert oppLineItem;
//    return oppLineItem;
//  }

  //=============================================================//
  //Query Pricebook2
  //============================================================//
  /*
  // PK Removing because this is no longer needed
  public static Pricebook2 getPriceBook2() {
    List<Pricebook2> lstPriceBook = [SELECT Id FROM Pricebook2 WHERE IsActive = true];
    if (lstPriceBook.size() > 0) {
        return lstPriceBook[0];
    }

    Pricebook2 priceBook = [SELECT Id FROM Pricebook2 limit 1];
    priceBook.IsActive = true;
    return priceBook;
  }

   //=============================================================//
  //Query Pricebook2
  //============================================================//
  public static Pricebook2 getPriceBook2(String priceBookName) {

    Pricebook2 priceBook = [ SELECT Id FROM Pricebook2 where Name =: priceBookName limit 1];
    return priceBook;
  }
  */
  
  //=============================================================//
  //Create Product2
  //============================================================//
  public static Product2 createProduct() {
    Double randomNumber = randomNumber();
    Product2 product = new Product2();
    product.Name = 'TestProduct'+ String.valueOf(randomNumber);
    product.IsActive = true;
    return product;
  }

  //=============================================================//
  //Create Product2
  //============================================================//
  public static Product2 insertProduct() {
    Product2 product = createProduct();
    insert product;
    return product;
  }

  //=============================================================//
  //Create PricebookEntry
  //============================================================//
  public static PricebookEntry createPricebookEntry(Id productId, Id priceBookId, String currencyType) {
    PricebookEntry  pbe = new PricebookEntry(
      Pricebook2Id = priceBookId,
      Product2Id = productId,
      IsActive = true,
      CurrencyIsoCode = currencyType,
      UnitPrice = 100.0
    );
    return pbe;
  }

  //=============================================================//
  //Create Product2
  //============================================================//
  public static PricebookEntry insertPricebookEntry(Id productId, Id priceBookId, String currencyType) {
    PricebookEntry pricebookEntry = createPricebookEntry(productId, priceBookId, currencyType);
    insert pricebookEntry;
    return pricebookEntry;
  }

  //=============================================================//
  //Creates User
  //============================================================//
  public static User createUser(String profileName) {
    Id profId;
    if (!profileNameHold.containsKey(profileName)) {
      Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
      profileNameHold.put(profileName, p.Id);
    }
    profId = profileNameHold.get(profileName);
    User testUser = new User(
      Alias = 'testUser',
      Email = 'standarduser' + Math.random()  + '@experian.com',
      EmailEncodingKey = 'UTF-8',
      FirstName = 'test user',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profId,
      TimeZoneSidKey = 'America/Los_Angeles',
      Region__c = 'EMEA',
      Username = 'teststandarduser' + Math.random() + '@experian.global.test',
      IsActive = true,
      CompanyName = 'test Company',
      EmployeeNumber = String.valueOf(Math.round(Math.random() * 100000)),
      Serasa_Employee_Number__c = String.valueOf(Math.round(Math.random() * 100000)),
      LAN_ID__c = 'c' + String.valueOf(Math.round(Math.random() * 100000)) + 'a'
    );
    return testUser;
  }

  //=============================================================//
  // Creates Users given Profile (already queried), email and LastName
  //============================================================//
  public static List<User> createUsers(Profile prof, String email, String alias, Integer numberOfUsers) {
    List<User> testUsers = new List<User>();
    for (Integer i = 0; i < numberOfUsers; i++) {
      testUsers.add(
        new User(
          Alias = alias+i,
          Email = i+email,
          EmailEncodingKey = 'UTF-8',
          FirstName = 'test user',
          LastName = 'Testing',
          LanguageLocaleKey = 'en_US',
          LocaleSidKey = 'en_US',
          ProfileId = prof.Id,
          TimeZoneSidKey = 'America/Los_Angeles',
          Region__c = 'EMEA',
          Username = email + Math.random(),
          IsActive = true,
          CompanyName = 'test Company',
          EmployeeNumber = String.valueOf(Math.round(Math.random() * 100000)),
          Serasa_Employee_Number__c = String.valueOf(Math.round(Math.random() * 100000))
        )
      );
    }
    return testUsers;
  }
  //=============================================================//
  // Creates User given Profile (already queried)
  //============================================================//
  public static User createUser(Profile prof, String email, String lastName) {
    User testUser = new User(
      Alias = lastName.mid(0,8),
      Email = email,
      EmailEncodingKey = 'UTF-8',
      FirstName = 'test user',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = prof.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      Region__c = 'EMEA',
      Username = email + Math.random(),
      IsActive = true,
      CompanyName = 'test Company',
      EmployeeNumber = String.valueOf(Math.round(Math.random() * 100000)),
      Serasa_Employee_Number__c = String.valueOf(Math.round(Math.random() * 100000))
    );
    return testUser;
  }

  //=============================================================//
  //Create Product2
  //============================================================//
  /* 
  public static BU_Relationship__c createBURelationship(Id accountId) {
    BU_Relationship__c bu = new BU_Relationship__c();
    bu.Account__c = accountId;
    return bu;
  }

  //=============================================================//
  //Create Product2
  //============================================================//
  public static BU_Relationship__c insertBURelationship(Id accountId) {
    BU_Relationship__c bu = createBURelationship(accountId);
    insert bu;
    return bu;
  }
  */
  //=============================================================//
  //Create Product2
  //============================================================//
  public static User insertUser(String profileName) {
    User user = createUser(profileName);
    insert user;
    return user;
  }
  
  public static User insertUser(String profileName,boolean isGroupSettingOff) {
    if(isGroupSettingOff){
       echosign_dev1__SIGN_Settings__c settings = echosign_dev1__SIGN_Settings__c.getOrgDefaults();
       settings.echosign_dev1__Auto_Sync_Group_Mappings__c = False;
       upsert settings;   
    }
    User user = createUser(profileName);
    insert user;
    return user;
  }

  //=============================================================//
  //Creates Custom setting Global_Settings__c
  //============================================================//
  public static Global_Settings__c insertGlobalSettings() {
    Global_Settings__c setting = new Global_Settings__c();
    Boolean isInsert = true;
    if (Global_Settings__c.getAll().containsKey(Constants.GLOBAL_SETTING)) {
      setting = Global_Settings__c.getValues(Constants.GLOBAL_SETTING);
      isInsert = false;
    }
    setting.Name = Constants.GLOBAL_SETTING;
    setting.Opp_Renewal_Probability__c = 30;
    setting.Opp_Closed_Lost_Stagename__c = Constants.OPPTY_CLOSED_LOST;
    setting.Opp_Renewal_Name_Format__c = 'Renewal - ####';
    setting.Opp_Renewal_StageName__c = Constants.OPPTY_STAGE_3;
    if (isInsert) {
      insert setting;
    }
    else {
      update setting;
    }
    return setting;
  }

  //=============================================================//
  //Creates Custom setting IsDataAdmin__c
  //============================================================//
  public static IsDataAdmin__c insertIsDataAdmin(boolean isActive) {
    IsDataAdmin__c setting = new IsDataAdmin__c();
    setting.IsDataAdmin__c = isActive;
    insert setting;
    return setting;
  }

  //=============================================================//
  //Creates Custom setting TriggerSettings__c
  //============================================================//
  public static TriggerSettings__c insertTriggerSettings(String triggerName) {
    TriggerSettings__c setting;
    Map<String, TriggerSettings__c> mcs = TriggerSettings__c.getAll();
    if (mcs.containsKey(triggerName)) {
      setting = mcs.get(triggerName);
    }
    else {
      setting = new TriggerSettings__c(Name = triggerName);
      insert setting;
    }
    setting.IsActive__c = true;
    return setting;
  }

  //=============================================================//
  //Generate Random Number
  //============================================================//
  public static Double randomNumber() {
    return Math.random();
  }

  //=============================================================//
  //Creates Billing Product
  //============================================================//
  public static Billing_Product__c insertBillingProduct() {
    return createBillingProduct(true);
  }

  //=============================================================//
  //Creates Billing Product
  //============================================================//
  public static Billing_Product__c createBillingProduct(Boolean isInsert) {
    Billing_Product__c billingProd = new Billing_Product__c(
      BP_External_Id__c = 'extID' + Math.random()
    );
    if (isInsert) {
      insert billingProd;
    }
    return billingProd;
  }

  //============================================================//
  //Insert Order__c
  //============================================================//
  public static Order__c insertOrder (Boolean insertOrder, String accntId, String contactId, String oppId) {
    Order__c ordr = new Order__c(
      Name = 'test Order',
      Contract_Start_Date__c = Date.today(),
      Locked__c = false, 
      Type__c = 'New', 
      Account__c = accntId,
      Contact__c = contactId,
      Opportunity__c = oppId,
      Close_Date__c = Date.today().addDays(30),
      Contract_Number__c = '1234test',
      Transactional_Sale__c = false
    );
    if (insertOrder) {
      insert ordr;
    }
    return ordr;
  }
  
  // T-268982: Updated the method name
  //============================================================//
  //Insert Order_Line_Item__c
  //============================================================//
  public static Order_Line_Item__c insertOrderLineItems (Boolean isInsert, String orderId, String billProdId) {
    Order_Line_Item__c oli = new Order_Line_Item__c(
      Start_Date__c = Date.today(),
      End_Date__c = Date.today().addDays(30),
      Total__c = 1111, 
      Type_of_Sale__c = 'Ad-Hoc', 
      Quantity__c = 5,
      Order__c = orderId, 
      Billing_Product__c = billProdId
    );
    if (isInsert) {
      insert oli;
    }
    return oli;
  }

  //=============================================================//
  //inserts Contract
  //============================================================//
  public static Contract__c insertContract (Boolean isInsert, String accountId, String contractType, String status) {
    Contract__c contract = new Contract__c(
      Account__c = accountId,
      Contract_Name__c = 'Test Contract',
      Contract_Type__c = contractType,
      Contract_Effective_Date__c = System.today(),
      Status__c = status
    );
    if (isInsert) {
      insert contract;
    }
    return contract;
  }

  //=============================================================//
  //Creates Address
  //============================================================//
  public static Address__c insertAddress(Boolean isInsert) {
    Address__c address = new Address__c(
      Address_1__c = '' + Math.random() + Math.random(),
      Address_2__c = 'add2'+Datetime.now(),
      Address_3__c = 'add3'+Datetime.now(),
      Address_4__c = 'add4'+Datetime.now(),
      City__c = 'Sydney',
      Country__c = 'Australia',
      Validation_Status__c = 'true',
      EDQ_Integration_Id__c = String.valueOf(Math.random())
    );
    if (isInsert) {
      insert address;
    }
    return address;
  }

  //=============================================================//
  //Creates Address Merge Request
  //============================================================//
  public static Address_Merge_Request__c insertAddressMergeRequest(Boolean isInsert, String masterId, String slaveId) {
    Address_Merge_Request__c addressMergeRequest = new Address_Merge_Request__c(
      Master_Address_SFDC_Id__c = ''+Datetime.now(),
      Master_Address__c = masterId,
      Slave_Address__c = slaveId
    );
    if (isInsert) {
      insert addressMergeRequest;
    }
    return addressMergeRequest;
  }

  //=============================================================//
  //Create Account Address
  // I-179463: Override for Duplicate Management Failures
  //============================================================//
  public static Account_Address__c insertAccountAddress (Boolean isInsert, String idParentAddress, String idParentAccount) {
    Account_Address__c accAddress = new Account_Address__c(
      Address__c = idParentAddress,
      Account__c = idParentAccount,
      Address_Type__c = Constants.ADDRESS_TYPE_REGISTERED
    );
    if (isInsert) {
      Database.insert(accAddress, duplicateRuleOverride());
    }
    return accAddress;
  }
  
  //=============================================================//
  //Create Contact Address
  //============================================================//
  public static Contact_Address__c insertContactAddress (Boolean isInsert, String idParentAddress, String idParentContact) {
    Contact_Address__c conAddress = new Contact_Address__c(
      Address__c = idParentAddress,
      Contact__c = idParentContact,
      Address_Type__c = Constants.ADDRESS_TYPE_REGISTERED
    );
    if (isInsert) {
      insert conAddress;
    }
    return conAddress;
  }
  
  //=============================================================//
  //Create Opportunity Address
  //============================================================//
  public static Opportunity_Contact_Address__c insertOpportunityAddress (Boolean isInsert, String idParentAddress, String idParentContact, String idParentOpportunity) {
    Opportunity_Contact_Address__c oppAddress = new Opportunity_Contact_Address__c(
      Address__c = idParentAddress,
      Contact__c = idParentContact,
      Opportunity__c = idParentOpportunity
    );
    if (isInsert) {
      insert oppAddress;
    }
    return oppAddress;
  }
  
  //============================================================//
  //Insert OpportunityContactRole as primay contact on opportunity
  //============================================================//
  public static OpportunityContactRole insertOpportunityCR (Boolean isInsert, String cntctId, String oppId) {
    OpportunityContactRole ocr = new OpportunityContactRole(
      ContactId = cntctId,
      IsPrimary = true,
      OpportunityId = oppId
    );
    if (isInsert) {
      insert ocr;
    }
    return ocr;
  }

  //===========================================================================
  // Return a task record
  //===========================================================================
  public static Task createTask(String whatId, String typeValue, String status) {
      
       /* Group testQueue = Test_Utils.createGroup(false);
      insert testQueue;
    return new Task(WhatId = whatId,whoId=testQueue.Id, Outcomes__c = typeValue, Status = status); */ //RJ commented it out  for test class failure 
    return new Task(WhatId = whatId, Outcomes__c = typeValue, Status = status);
  
  }
  
  //===========================================================================
  //TP: This function will return you an Activity with a Campaign
  // PK - Commented out as it wasn't being used!
  //===========================================================================
//  public static Task createTaskWithCampaign(String whoId, String typeValue, String CampaignName, String status) {
//    return new Task(WhoId = whoId, Campaign__c = CampaignName, Status = status);
//  }

  //===========================================================================
  //TP: This function will return a Campaign
  //===========================================================================
  public static Campaign createCampaign() {
    Campaign newCampaign = new Campaign(
      Name = 'Test Campaign',
      Business_Unit__c = 'Credit Services',
      Audience__c = 'Test Audience',
      Campaign_Code__c = 'TEST-123',
      IsActive = true,
      StartDate = system.today(),
      EndDate = system.today().addDays(7)
    );
    insert newCampaign;
    return newCampaign;
  }

  //===========================================================================
  // 
  //===========================================================================
  public static List<Task> createOpptyTasks(String oppId, Boolean performInsert) {
    List<Task> tasks = new List<Task>();
    tasks.add(Test_Utils.createTask(oppId, Constants.ACTIVITY_TYPE_SELECTION_CONFIRMED, Constants.STATUS_COMPLETED));
    tasks.add(Test_Utils.createTask(oppId, Constants.ACTIVITY_TYPE_SIGNED_CONTRACT, Constants.STATUS_COMPLETED));
    tasks.add(Test_Utils.createTask(oppId, Constants.ACTIVITY_TYPE_QUOTE_DELIVERED, Constants.STATUS_COMPLETED));
    if (performInsert) {
      insert tasks;
    }
    return tasks;
  }

  //================================================================//
  // Create an AccountTeamMember for given accountId
  //================================================================//
  public static AccountTeamMember createAccountTeamMembers (String accountId, String userId, Boolean isInsert) {
    AccountTeamMember atm = new AccountTeamMember(
      AccountId = accountId,
      UserId = userId,
      TeamMemberRole = 'Sales Rep',
      AccountAccessLevel = 'Edit',
      CaseAccessLevel = 'Edit',
      OpportunityAccessLevel = 'Edit'
    );
    if (isInsert) {
      insert atm;
    }
    return atm;
  }

  //================================================================//
  // Create an Event given a WhoId and WhatId
  //================================================================//
  public static Event createEvent(String whoId, String whatId) {
    return new Event(StartDateTime = Datetime.now(), DurationInMinutes = 60, WhoId = whoId, WhatId = whatId);
  }

  //================================================================//
  // Create & insert an Event given a WhoId and WhatId
  //================================================================//
  public static Event insertEvent(String whoId, String whatId) {
    Event evt = createEvent(whoId, whatId);
    insert evt;
    return evt;
  }

  //================================================================//
  // Create a Task given a WhoId and WhatId
  //================================================================//
  public static Task createTask(String whoId, String whatId) {
    return new Task(ActivityDate = Date.today(), WhoId = whoId, WhatId = whatId);
  }

  //================================================================//
  // Create & insert a Task given a WhoId and WhatId
  //================================================================//
  public static Task insertTask(String whoId, String whatId) {
    Task task = createTask(whoId, whatId);
    insert task;
    return task;
  }

  //================================================================//
  // Create & return a Order object
  //================================================================//
  public static Order__c createOrder() {
    Order__c ord = new Order__c();
    return ord;
  }

   //================================================================//
  // Create & return a OpportunitySplit object
  //================================================================//
  public static OpportunitySplit createOppSplit(Opportunity opp) {
    OpportunitySplit oppSplit = new OpportunitySplit(
      OpportunityId = opp.Id
    );
    return oppSplit;
  }

  //================================================================//
  // Experian Spain - Create & return a ESDEL_Delivery_Project__c object
  //================================================================//
  public static ESDEL_Delivery_Project__c insertDeliveryProject (Boolean isInsert, String projectName, String idAccount, String idContact, String billingOrderId) {
    ESDEL_Delivery_Project__c deliveryProject = new ESDEL_Delivery_Project__c(
      Name = projectName,
      ESDEL_Account__c = idAccount,
      ESDEL_Billing_Order_Id__c = billingOrderId,
      ESDEL_Primary_Contact__c = idContact
    );
    if (isInsert) {
      insert deliveryProject;
    }
    return deliveryProject;
  }

  //================================================================//
  //Experian Spain - Create & return a Case object
  //================================================================//
  public static Case insertCase (Boolean isInsert, String deliveryProjectId, String idAccount, String billingOrderId) {
    Case newCase = new Case(
      AccountId = idAccount,
      ESDEL_Billing_Order_Line_Id__c = billingOrderId,
      ESDEL_Project__c = deliveryProjectId
    );
    if (isInsert) {
      insert newCase;
    }
    return newCase;
  }

  //================================================================//
  //Experian Spain - Create & return a ESDEL_Timecard__c object
  // PK - Commented out as it wasn't being used!
  //================================================================//
//  public static ESDEL_Timecard__c insertTimecard(Boolean isInsert, String idCase, integer minutesWorked) {
//    ESDEL_Timecard__c newTimecard = new ESDEL_Timecard__c(
//      ESDEL_Case__c = idCase,
//      ESDEL_Minutes_Worked__c = minutesWorked
//    );
//    if (isInsert) {
//      insert newTimecard;
//    }
//    return newTimecard;
//  }

  //================================================================//
  //Experian Spain - Create & return a ESDEL_Timecard__c object
  //================================================================//
  public static ESDEL_Timecard__c insertTimecard(Boolean isInsert, String idCase, integer minutesWorked, ID projectId, ID delveryLineId) {
    ESDEL_Timecard__c newTimecard = new ESDEL_Timecard__c(
      ESDEL_Case__c = idCase,
      ESDEL_Minutes_Worked__c = minutesWorked
    );
    if (isInsert) {
      insert newTimecard;
    }
    return newTimecard;
  }

  //================================================================//
  //Experian Sales Academy - Create & return a Opportunity_Plan__c object
  //================================================================//
  public static Opportunity_Plan__c insertOpportunityPlan(Boolean isInsert, ID idOpportunity ) {
    Opportunity_Plan__c oppPlan = new Opportunity_Plan__c(
      Opportunity_Name__c = idOpportunity,
      Opportunity_Expected_Close_Date__c = System.today().addDays(15),
      CurrencyIsoCode = 'USD'
    );
    if (isInsert) {
      insert oppPlan;
    }
    return oppPlan;
  }
  //================================================================//
  //Experian Sales Academy - Create & return a OpportunityTeamMember object
  //================================================================//
  public static OpportunityTeamMember insertOpportunityTeamMember(Boolean isInsert, String idOpportunity, String idUser, String role) {
    OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(
      UserId = idUser,
      OpportunityId = idOpportunity,
      TeamMemberRole = role
    );
    if (isInsert) {
      insert oppTeamMember;
    }
    return oppTeamMember;
  }

  //===========================================================================
  // Create Opportunity Plan contact record for specified  Opportunity_Plan__c 
  // record, also adds a new contact and set it as reports to contact.
  // PK - Commented out as it wasn't being used!
  //===========================================================================
//  public static Opportunity_Plan_Contact__c createOpportunityPlanContact(Opportunity_Plan__c oppPlan) {
//    Account acc = Test_Utils.insertAccount();
//    
//    Contact con1 = Test_Utils.insertContact(acc.Id);
//    Contact con2 = Test_Utils.insertContact(acc.Id);
//
//    Opportunity_Plan_Contact__c opc1 = createOpportunityPlanContact(oppPlan, con1);
//    opc1.Role__c = 'Credit Risk Manager';
//    insert opc1;
//
//    Opportunity_Plan_Contact__c opc2 = createOpportunityPlanContact(oppPlan, con2);
//    opc2.Reports_to__c = opc1.Id;
//    opc2.Role__c = 'Purchasing Manager';
//    insert opc2;
//    
//    return opc1;
//  }

  // Create Opportunity Plan contact record for specified  Opportunity_Plan__c record, also adds a new contact and set it as reports to contact.
  public static Opportunity_Plan_Contact__c createOpportunityPlanContact(Opportunity_Plan__c oppPlan, Contact con) {
    Opportunity_Plan_Contact__c opc1 = new Opportunity_Plan_Contact__c(
      Business_Goal_1__c = 'Test',
      Decision_Criteria_1__c = 'Test',
      Personal_Goal_1__c = 'Test',
      Opportunity_Plan__c = oppPlan.Id,
      Role__c = 'Purchasing Manager',
      Contact__c = con.Id
    );
    return opc1;
  }

  // Create Plan Contact Relationship between specified Opportunity_Plan_Contact__c contacts and specified relation.
  public static Plan_Contact_Relationship__c createPlanContactRelationship (Boolean isInsert, Opportunity_Plan_Contact__c opc1, Opportunity_Plan_Contact__c opc2, String relation) {
    Plan_Contact_Relationship__c pcr = new Plan_Contact_Relationship__c(
      Contact_1__c = opc1.Id,
      Contact_2__c = opc2.Id,
      Relationship__c = relation
    );
    if (isInsert) {
      insert pcr;
    }
    return pcr;
  }

  // Create Plan Contact Relationship between specified Opportunity_Plan_Contact__c contacts and specified relation.
  // PK - Commented out as it wasn't being used!
//  public static Plan_Contact_Relationship__c createPlanContactRelationship (Opportunity_Plan_Contact__c opc1, Opportunity_Plan_Contact__c opc2, String relation) {
//    Plan_Contact_Relationship__c pcr = new Plan_Contact_Relationship__c(
//      Contact_1__c = opc1.Id,
//      Contact_2__c = opc2.Id,
//      Relationship__c = relation
//    );
//    insert pcr;
//    return pcr;
//  }
  //================================================================//
  //Experian Sales Academy - Create & return a Account_Plan__c object
  //================================================================//
  public static Account_Plan__c insertAccountPlan(Boolean isInsert, String idAccount) {
    Account_Plan__c accountPlan = new Account_Plan__c(
      Account__c = idAccount
    );
    if (isInsert) {
      insert accountPlan;
    }
    return accountPlan;
  }

  //================================================================//
  //Experian Sales Academy - Create & return a Account_Plan_Team__c object
  //================================================================//
  public static Account_Plan_Team__c insertAccountPlanTeam(boolean isInsert, String idAccountPlan, String idUser) {
    Account_Plan_Team__c accountPlanTeam = new Account_Plan_Team__c(
      Account_Plan__c = idAccountPlan,
      User__c = idUser
    );
    if (isInsert) {
      insert accountPlanTeam;
    }
    return accountPlanTeam;
  }
  
  //================================================================//
  //Experian Sales Academy - Create & return a Account_Plan_Penetration__c object
  //================================================================//
  public static Account_Plan_Penetration__c insertAccountPlanPenetration(Boolean isInsert, String idAccountPlan) {
    Account_Plan_Penetration__c accountPP = new Account_Plan_Penetration__c(
      Account_Plan__c = idAccountPlan,
      Account_Business_Unit__c = 'test BU', 
      Capability__c = 'Application Processing',
      Penetration__c = 'H',
      Annual_Revenue__c = 111
    );
    if (isInsert) {
      insert accountPP;
    }
    return accountPP;
  }
  //================================================================//
  //Experian Sales Academy - Create & return a AccountTeamMember object
  //================================================================//
  public static AccountTeamMember insertAccountTeamMember(Boolean isInsert, String idAccount, String idUser, String role) {
    AccountTeamMember accTeamMember = createAccountTeamMembers(idAccount, idUser, false);
    accTeamMember.TeamMemberRole = role;
    if (isInsert) {
      insert accTeamMember;
    }
    return accTeamMember;
  }

  //================================================================//
  //Experian Sales Academy - Create & return a Account_Plan_SWOT__c object
  //================================================================//
  public static Account_Plan_SWOT__c insertAccountPlanSwot(Boolean isInsert, String idAccountPlan) {
    Account_Plan_SWOT__c accountPlanSwot = new Account_Plan_SWOT__c(
      Account_Plan__c = idAccountPlan
    );
    if (isInsert) {
      insert accountPlanSwot;
    }
    return accountPlanSwot;
  }
  
  //================================================================//
  //Experian Sales Academy - Create & return a Account_Plan_Opportunity__c object
  //================================================================//
  public static Account_Plan_Opportunity__c insertAccountPlanOpp(Boolean isInsert, String idAccountPlan, String idOpportunity) {
    Account_Plan_Opportunity__c accountPlanOpp = new Account_Plan_Opportunity__c(
      Account_Plan__c = idAccountPlan,
      Opportunity__c = idOpportunity
    );
    if (isInsert) {
      insert accountPlanOpp;
    }
    return accountPlanOpp;
  }
  
  //================================================================//
  //Experian Sales Academy - Create & return a Account_Plan_Opportunity_SWOT__c object
  // PK - Commented out as it wasn't being used!
  //================================================================//
//  public static Account_Plan_Opportunity_SWOT__c insertAccountPlanOppSwot(Boolean isInsert, String idAccountPlanOpp, String idAccountPlanSwot) {
//    Account_Plan_Opportunity_SWOT__c accountPlanOppSwot = new Account_Plan_Opportunity_SWOT__c(
//      Account_Plan_Opportunity__c = idAccountPlanOpp,
//      Account_Plan_SWOT__c = idAccountPlanSwot
//    );
//    if (isInsert) {
//      insert accountPlanOppSwot;
//    }
//    return accountPlanOppSwot;
//  }

  //================================================================//
  //Experian Sales Academy - Create & return a Opp Plan Score Calc object
  //================================================================//
  public static Opp_Plan_Score_Calc__c insertOppPlanScoreCalc(String name, boolean isInsert) {
    Opp_Plan_Score_Calc__c opsc = new Opp_Plan_Score_Calc__c(
      Name = name,
      Expected_Score__c = 25.00,
      CurrencyIsoCode = 'USD'
    );
    if (isInsert) {
      insert opsc;
    }
    return opsc;
  }
  
  //================================================================//
  //Experian Sales Academy - Create & return a Opp Plan Scor Sub Calc object
  //================================================================//
  public static Opp_Plan_Score_Sub_Calc__c insertOppPlanScoreSubCalc(ID parentId, boolean isInsert) {
    Opp_Plan_Score_Sub_Calc__c opssc = new Opp_Plan_Score_Sub_Calc__c(
      Name = 'testing',
      Opp_Plan_Score_Calc__c = parentId,
      Object_API_Name__c = 'Opportunity_Plan_Contact__c'
    );
    if (isInsert) {
      insert opssc;
    }
    return opssc;
  }
  
  //================================================================//
  //Experian Sales Academy - Correcting Exception for Opp Plan Trigger
  //Corrects CANNOT_UPDATE_INSERT_ACTIVATE_ENTITY, For after Insert
  // PK - Commented out as it wasn't being used!
  //================================================================//
//  public static void madeupAfterInsert() {
//    List<Opp_Plan_Score_Calc__c> opsc = new List<Opp_Plan_Score_Calc__c>();
//    List<String> namelist = new List<String>{
//      'Information Scoring',
//      'Qualification Scoring',
//      'Buying Centre',
//      'Competition Scoring',
//      'Summary Position',
//      'Solution at a Glance',
//      'Joint Action Plan',
//      'Value Proposition',
//      'Action Plan'
//    };
//    for (String name : namelist) {
//      Opp_Plan_Score_Calc__c op1 = Test_Utils.insertOppPlanScoreCalc(name, true);
//      Opp_Plan_Score_Sub_Calc__c op2 = Test_Utils.insertOppPlanScoreSubCalc(op1.Id, true);
//    }
//  }

  //===================================================================//
  //===================================================================//
  //                    Experian PHASE 2
  //===================================================================//
  //===================================================================//

  //================================================================//
  //Experian Phase 2 - Create & return Project__c
  //================================================================//
  public static Project__c insertProject(Boolean isInsert) {
    Project__c project = new Project__c(
      Name = 'Test Project', 
      Type__c = 'Internal Delivery',
      Business_Unit__c = 'TBD',
      Status__c = 'Unassigned'
    );
    if (isInsert) {
      insert project;
    }
    return project;
  }

  //================================================================//
  // create and return Deployment__c
  //================================================================//
  public static Deployment__c insertDeployment(Boolean isInsert, Id AccountId, Boolean active) {
    Deployment__c deployment = new Deployment__c(
      Name = 'Test Deployment', 
      Account__c = AccountId,
      Active__c = active,
      Description__c = 'Test Descrption'
    );
    if (isInsert) {
      insert deployment;
    }
    return deployment;
  }

  //================================================================//
  //Experian Phase 2 - Create & return Delivery_Line__c
  //================================================================//
  public static Delivery_Line__c insertDeliveryLine(Boolean isInsert, Id projectId) {
    Delivery_Line__c deliveryLine = new Delivery_Line__c(
      Name = 'Test Delivery Line',
      Project__c = projectId,
      Status__c = 'Unassigned'
    );
    if (isInsert) {
      insert deliveryLine;
    }
    return deliveryLine;
  }

  //===================================================================//
  //Experian Phase 2 - Create & return Delivery_Template_Header
  //===================================================================//
  public static Delivery_Template_Header__c insertDeliveryTemplateHeader (Boolean isInsert) {
    Delivery_Template_Header__c dth = new Delivery_Template_Header__c(
      Name = 'TestDTH'+String.valueOf(Datetime.now())
    );
    if (isInsert) {
      insert dth;
    }
    return dth;
  }

  //===================================================================//
  //Experian PHASE 2 - Create & return Delivery_Template_Line
  //===================================================================//
  public static Delivery_Template_Line__c insertDeliveryTemplateLine (Boolean isInsert, String dthID) {
    Delivery_Template_Line__c dtl = new Delivery_Template_Line__c(
      Name = 'TestDTL'+String.valueOf(Datetime.now()),
      Delivery_Template_Header__c = dthID,
      Sequence__c = 1
    );
    if (isInsert) {
      insert dtl;
    }
    return dtl;
  }
  
  //===================================================================//
  //Experian PHASE 2 - Create & return Case
  //===================================================================//
  public static Case insertCase (Boolean isInsert, String idAccount) {
    Case newCase = new Case(AccountId = idAccount);
    if (isInsert) {
      insert newCase;
    }
    return newCase;
  }

  //===================================================================//
  //Experian - Create Royalty and Return
  //===================================================================//
  public static Royalty__c insertRoyalty (Boolean isInsert, String oppLineRefNo) {
    Royalty__c royalty = new Royalty__c(
      Line_Item_Reference_Number__c = oppLineRefNo
    );
    if (isInsert) {
      insert royalty;
    }
    return royalty;
  }

  //================================================================//
  //Experian - Create OpportunityContactRole and Return
  //================================================================//
  public static List<OpportunityContactRole> insertEDQOpportunityContactRoles(String oppId, String contactId) {
    List<OpportunityContactRole> oppRoles = new List<OpportunityContactRole>{
      insertOpportunityContactRole(false, oppId, contactId, Constants.DECIDER, true),
      insertOpportunityContactRole(false, oppId, contactId, Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER, false),
      insertOpportunityContactRole(false, oppId, contactId, Constants.OPPTY_CONTACT_ROLE_RENEWAL, false),
      insertOpportunityContactRole(false, oppId, contactId, Constants.OPPTY_CONTACT_ROLE_UPDATE, false),
      insertOpportunityContactRole(false, oppId, contactId, Constants.OPPTY_CONTACT_ROLE_COMMERCIAL, false),
      insertOpportunityContactRole(false, oppId, contactId, Constants.OPPTY_CONTACT_ROLE_SHIPTO, false),
      insertOpportunityContactRole(false, oppId, contactId, Constants.OPPTY_CONTACT_ROLE_CONTRACTUAL, false)
    };
    insert oppRoles;
    return oppRoles;
  }

  public static OpportunityContactRole insertOpportunityContactRole(Boolean isInsert, String idOpportunity, String IdContact, String role, Boolean isPrimary) {
    OpportunityContactRole oppConRole = new OpportunityContactRole(
      ContactId = IdContact,
      OpportunityId = idOpportunity,
      Role = role,
      IsPrimary = isPrimary
    );
    if (isInsert) {
      insert oppConRole;
      //Update opportunity to make sure flag is set. -???
      Opportunity opp = new Opportunity(Id = idOpportunity, Description = 'Test');
      update opp;
    }
    return oppConRole;
  }

  //================================================================//
  //Experian Phase 2- Create Asset and Return
  //================================================================//
  public static Asset insertAsset(Boolean isInsert, String idAccount) {
    Asset asset = new Asset(
      Name = 'Test Asset',
      AccountId = idAccount,
      Release_Version__c = 'Test Version1',
      Operating_System__c = 'PC+',
      Renewal_Discount__c = 5,
      Data_Usage__c = 'N/A',
      Price = 1.00,
      Users_To__c = 2
    );
    if (isInsert) {
      insert asset;
    }
    return asset;
  }

  //================================================================//
  //Experian Phase 2- Create Group and Return
  //================================================================//
  public static Group createGroup(Boolean isInsert) {
    Group grp = new Group();
    grp.Name = 'Test Group'+ Math.random();
    grp.Type = 'Queue';
    if (isInsert) {
      insert grp;
    }
    return grp;
  }

  //================================================================//
  //Experian Phase 2- Create User Share
  // PK - Commented out as it wasn't being used!
  //================================================================//
//  public static UserShare createUserShare(Boolean isInsert, Id userId, Id userOrGroupId) {
//    UserShare userShare = new UserShare(
//      UserId = userId,
//      UserOrGroupId = userOrGroupId,
//      UserAccessLevel = 'Edit'
//    );
//    if (isInsert) {
//      insert userShare;
//    }
//    return userShare;
//  }

  //=============================================================//
  // Creates EDQ User given Profile (already queried)
  //============================================================//
  public static User createEDQUser(Profile profile, String email, String lastName) {
    String bu = edqSetting.User_Business_Unit__c;
    User testUser = new User(
      Alias = lastName.mid(0,8),
      email = email,
      emailencodingkey = 'UTF-8',
      firstName = 'test user',
      lastname = 'Testing',
      languagelocalekey = 'en_US',
      localesidkey = 'en_US',
      profileid = profile.Id,
      timezonesidkey = 'America/Los_Angeles',
      username = email + Math.random(),
      IsActive = true,
      CompanyName = 'test Company',
      Global_Business_Line__c = 'Credit Services',
      Business_Line__c = 'APAC Credit Services',
      Business_Unit__c = bu,
      Office_Location__c = 'Amsterdam',
      Department__c = 5,
      Region__c = 'EMEA',
      Payroll__c = 100,
      EmployeeNumber = String.valueOf(Math.round(Math.random() * 100000)),
      Serasa_Employee_Number__c = String.valueOf(Math.round(Math.random() * 100000))
    );
    return testUser;
  }

  //=============================================================//
  // Creates EDQ User given Profile (already queried)
  //============================================================//
  public static User createCPQUser(Profile profile, String email, String lastName) {
    String bu = edqSetting.User_Business_Unit__c;
    User testUser = new User(
      Alias = lastName,
      Email = email,
      EmailEncodingKey='UTF-8',
      FirstName = 'Test User',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profile.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      Username = email + Math.random(),
      IsActive = true,
      CompanyName = 'test Company',
      Global_Business_Line__c = 'Credit Services',
      Business_Line__c = 'APAC Credit Services',
      Business_Unit__c = bu,
      Office_Location__c = 'Amsterdam',
      Department__c = 5,
      Region__c = 'EMEA',
      Payroll__c = 100,
      CPQ_User__c = true,
      CPQ_User_Type__c = 'CFO',
      Country__c = 'United States of America',
      EmployeeNumber = String.valueOf(Math.round(Math.random() * 100000)),
      Serasa_Employee_Number__c = String.valueOf(Math.round(Math.random() * 100000))
    );
    return testUser;
  }

  //=============================================================//
  // Creates Product Master
  //============================================================//
  public static Product_Master__c createProductMaster(Boolean isInsert) {
    Product_Master__c productMaster = new Product_Master__c(
      Name = 'Test Product Master'
    );
    if (isInsert) {
      insert productMaster;
    }
    return productMaster;
  }

  //=============================================================//
  // Creates Product Country
  //============================================================//
  public static Product_Country__c createProductCountry(Boolean isInsert, Id countryId) {
    Product_Country__c productCountry = new Product_Country__c(
      Country__c = countryId
    );
    if (isInsert) {
      insert productCountry;
    }
    return productCountry;
  }

  //=============================================================//
  // Creates Product Region
  //============================================================//
  public static Product_Region__c createProductRegion(Boolean isInsert, Id regionId) {
    Product_Region__c productRegion = new Product_Region__c(
      Region__c = regionId
    );
    if (isInsert) {
      insert productRegion;
    }
    return productRegion;
  }

  //=============================================================//
  // Creates Country
  //============================================================//
  public static Country__c createCountry(Boolean isInsert) {
    Country__c country = new Country__c(
      Name = 'United States of America'
    );
    if (isInsert) {
      insert country;
    }
    return country;
  }

  //=============================================================//
  // Creates Region
  //============================================================//
  public static Region__c createRegion(Boolean isInsert) {
    Region__c region = new Region__c(
      Name = 'North America'
    );
    if (isInsert) {
      insert region;
    }
    return region;
  }

  //============================================================//
  // Create Assignment_Team__c
  //===========================================================//
  public static Assignment_Team__c insertAssignmentTeam(Boolean isInsert, Id userId) {
    Assignment_Team__c assgnTeam = new Assignment_Team__c(
      Account_Executive__c = userId,
      Primary_Team__c = true
    );
    if (isInsert) {
      insert assgnTeam;
    }
    return assgnTeam;
  }

  //============================================================//
  // Create Assignment_Team_Member_c
  //===========================================================//
  public static Assignment_Team_Member__c insertAssignmentTeamMember(Boolean isInsert, Id assgnTeamId, Id userId, String memRole) {
    Assignment_Team_Member__c assgnTeamMem = new Assignment_Team_Member__c(
      Assignment_Team__c = assgnTeamId,
      Assignment_Team_Role__c = memRole,
      IsActive__c = true,
      User__c = userId
    );
    if (isInsert) {
      insert assgnTeamMem;
    }
    return assgnTeamMem;
  }

  //============================================================//
  // Create Account_Assignment_Team__c
  //===========================================================//
  public static Account_Assignment_Team__c insertAccAssignmentTeam(Boolean isInsert, Id assgnTeamId, Id accId) {
    Account_Assignment_Team__c accAssgnTeam = new Account_Assignment_Team__c(
      Account__c = accId,
      Assignment_Team__c =  assgnTeamId
    );
    if (isInsert) {
      insert accAssgnTeam;
    }
    return accAssgnTeam;
  }
  
  //==========================================================//
  // Create Hierarchy__c records
  //=========================================================//
  public static Hierarchy__c insertHierarchy(Boolean isInsert, Id parentId, String value, String hierarchyType) {
    Hierarchy__c hierarchy = new Hierarchy__c(
      Parent__c = parentId,
      Value__c = value,
      Type__c = hierarchyType
    );
    if (isInsert) {
      insert hierarchy;
    }
    return hierarchy;
  }
  
  //=========================================================//
  // Create Account_Segment__c
  //========================================================//
  public static Account_Segment__c insertAccountSegment(Boolean isInsert, Id accountId, Id hierarchyId, Id parAccSegId) {
    Account_Segment__c accSegment = new Account_Segment__c(
      CurrencyIsoCode = Constants.CURRENCY_USD,
      Account__c = accountId,
      Segment__c = hierarchyId,
      Parent_Account_Segment__c = parAccSegId
    );
    if (isInsert) {
      insert accSegment;
    }
    return accSegment;
  }

  //=========================================================//
  // Create Business_Process_Template__c
  //========================================================//
  public static Business_Process_Template__c insertBusinessProcessTemplate(Boolean isInsert, String relatedTo, String businessUnit, String subBusinessUnit) {
    Business_Process_Template__c busProcTemplate = new Business_Process_Template__c(
      Related_To__c = relatedTo,
      Business_Unit__c = businessUnit,
      Sub_Business_Unit__c = subBusinessUnit,
      Name = 'Test',
      Description__c = 'Test'
    );
    if (isInsert) {
      insert busProcTemplate;
    }
    return busProcTemplate;
  }

  //=========================================================//
  // Create Business_Process_Template_Item__c
  //========================================================//
  public static Business_Process_Template_Item__c insertBusinessProcessTemplateItem(Boolean isInsert, Id businessProcessTemplateId, Decimal sequence) {
    Business_Process_Template_Item__c busProcTemplateItem = new Business_Process_Template_Item__c(
      Business_Process_Template__c = businessProcessTemplateId,
      Name = 'Test',
      Description__c = 'Test Description',
      Sequence__c = sequence
    );
    if (isInsert) {
      insert busProcTemplateItem;
    }
    return busProcTemplateItem;
  }

  //=========================================================//
  // Create Business_Process___c
  //========================================================//
  public static Business_Process__c insertBusinessProcess(Boolean isInsert, Id businessProcessTemplateId, Id caseId, Id membershipId, Id accountId, Id opportunityId) {

    Business_Process__c bp = new Business_Process__c(
      Business_Process_Template__c = businessProcessTemplateId
    );
    if (caseId != null) {
      bp.Case__c = caseId;
    } 
    else if (membershipId != null) {
      bp.Membership__c = membershipId;
    } 
    else if (accountId != null) {
      bp.Account__c = accountId;
    } 
    else if (opportunityId != null) {
      bp.Opportunity__c = opportunityId;
    }
    if (isInsert) {
      insert bp;
    }
    return bp;
  }

  //=========================================================//
  // Create Business_Process_Item__c
  // PK - Commented out as it wasn't being used!
  //========================================================//
//  public static Business_Process_Item__c insertBusinessProcessItem(Boolean isInsert, Id businessProcessTemplateItemId) {
//    Business_Process_Item__c bpi = new Business_Process_Item__c(
//      Business_Process_Template_Item__c = businessProcessTemplateItemId
//    );
//    if (isInsert) {
//      insert bpi;
//    }
//    return bpi;
//  }

  //=========================================================//
  // Create Membership__c
  //========================================================//
  public static Membership__c insertMembership(Boolean isInsert, Id accountId) {
    Membership__c mem = new Membership__c(
      Account__c = accountId
    );
    if (isInsert) {
      insert mem;
    }
    return mem;
  }

  //=============================================================//
  //Creates Metadata_Component__c
  //============================================================//
  public static Metadata_Component__c createMetadataComponent() {
    Metadata_Component__c metaCom = new Metadata_Component__c(
      Component_API_Name__c = 'Test_Component__c',
      Component_Type__c = 'Custom Field',
      Name = 'Test Component'
    );
    return metaCom;
  }

  //=============================================================//
  //Insert Metadata_Component__c
  //============================================================//
  public static Metadata_Component__c insertMetadataComponent() {
    Metadata_Component__c metaCom = createMetadataComponent();
    insert metaCom;
    return metaCom;
  }
  //=============================================================//
  //Creates Case_Component__c
  //============================================================//
  public static Case_Component__c createCaseComponent(Id caseNum, Id compName) {
    Case_Component__c caseCom = new Case_Component__c(
      Deployment_Type__c = 'Automatated Deployment',
      Action__c = 'Create',
      Case_Number__c = caseNum,
      Component_Name__c = compName  
    );
    return caseCom;
  }

  //=============================================================//
  //Insert Case_Component__c
  //============================================================//
  public static Case_Component__c insertCaseComponent(Id caseNum, Id compName) {
    Case_Component__c caseCom = createCaseComponent(caseNum,compName);
    insert caseCom;
    return caseCom;
  }

  //=============================================================//
  //Creates Case_Component__c for CPQ Components
  //============================================================//
  public static Case_Component__c createCPQCaseComponent(Id caseNum) {
    Case_Component__c caseCom = new Case_Component__c(
      Deployment_Type__c = 'Manual Step',
      Action__c = 'Create',
      Case_Number__c = caseNum,
      CPQ_Component_Name__c = 'CPQ test field',
      Configuration_Type__c = 'Post - Configuration',
      Manual_Step_Details__c = 'Manual test steps'
    );
    return caseCom;
  }
  //==============================================================//
  // Insert Opportunity_Contact_Address__c
  //==============================================================//
  public static Opportunity_Contact_Address__c insertOpportunityContactAddress(Boolean isInsert, Id opptyId, Id contactId, Id addressId, String role) {
    Opportunity_Contact_Address__c opptyContAdd = new Opportunity_Contact_Address__c(
      Opportunity__c = opptyId, 
      Contact__c = contactId, 
      Address__c = addressId,
      Role__c = role
    );
    if (isInsert) {
      insert opptyContAdd;
    }
    return opptyContAdd;
  }

  //==============================================================//
  // Insert CollaborationGroup aka Chatter Group
  //==============================================================//
  public static CollaborationGroup createCollaborationGroup(Id owner, Boolean archive, String GroupType) {
    CollaborationGroup chatterGroup = new CollaborationGroup(
      Name = 'Test Group'+String.valueOf(Math.random()* 1000),
      OwnerId = owner,
      IsArchived = archive,
      CollaborationType = GroupType
    );
    // For CollaborationType only options available are Public, Private and Unlisted
    return chatterGroup;
  }

  // I-179463: Override for Duplicate Management Failures
  @testVisible
  private static Database.DMLOptions duplicateRuleOverride() {
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.DuplicateRuleHeader.allowSave = true;
    return dml;
  }

  //==============================================================//
  // Insert Contact Relationship
  //==============================================================//
  public static Contact_team__c createContactTeam(Id contact, Id user) {
    Contact_Team__c contRel = new Contact_Team__c(
      Contact__c = contact,
      Relationship_Owner__c = user
    );
    return contRel;
  }

  public static Project__c createProspectProject(ID accID, ID subcodeID)
  {
      ID RTID = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get(Constants.RECORDTYPE_Prospect).getRecordTypeId();
      Project__c testProject = new Project__c();
      testProject.RecordTypeID = RTID;
      testProject.Account__c = accID;
      testProject.Type__c = 'Data Prep';
      testProject.Project_Stage__c = 'Prospect';
      testProject.List_Type__c = 'Outside List';
      testProject.Request_Type__c = 'Production';
      testProject.TMS_Number__c = subcodeID;
      testProject.Projected_Revenue__c = 100; //RJ added for Revenue 
      return testProject;
  }

 
  //=============================================================//
  //Creates Stnd BFS project
  //============================================================//
 public static Project__c createStandardBFSProject(ID accID, ID subcodeID, ID addID ,Id TMSID , id tempContact)
  {
      

      ID RTID = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get(Constants.RECORDTYPE_BFS_Standard_Project).getRecordTypeId();
      Project__c testProject = new Project__c();
      testProject.RecordTypeID = RTID;
      testProject.Account__c = accID;
      testProject.Type__c = 'Archive';
      testProject.Project_Stage__c = 'Analysis/Consultancy';
      testProject.List_Type__c = 'Outside List';
      testProject.Request_Type__c = 'Production';
      testProject.TMS_Number__c = TMSID;
      testProject.Projected_Revenue__c = 100;//RJ added for Revenue 
      testProject.Inquiry_Logging__c = 'All';
      testProject.Promo_Logging__c = 'C: Portfolio Review';
      testProject.Requested_Ship_Time__c = system.today();
      testProject.Requested_Ship_Date__c = system.today(); //MM added     
      testProject.Billing_Contact_Address__c  = addID;
      testProject.Shipping_Contact_Address__c  = addID;
      testProject.Billing_Contact_Name__c   = tempContact;
      testProject.Shipping_Contact_Name__c   = tempContact;
      testProject.Main_Contact__c  = tempContact;
      testProject.Project_Sub_Type__c = 'ORION';
      testProject.Third_Party_Processor_Involved__c = 'No';
      testProject.Start_Date__c = system.today();
      testProject.Frequency__C = 'Daily';
      testProject.Subcode__c = subcodeID;
      testProject.Billing_Category__c = 'B';
      testProject.Bill_Complete_Date__c = system.today();//RJ added  
      testProject.Promo_Completion_Date__c = system.today();//RJ added 
      testProject.Requested_Ship_Time__c = system.today();
      testProject.Reoccurance__c = 'New';
      testProject.Campaign_Name__c = 'Test Campaign Name'; //ty added
      testProject.Client_Contact__c = tempContact;
      return testProject;
  }
  
    //=============================================================//
  //Creates NA Targeting project
  //============================================================//
 public static Project__c createNATargetingProject(ID accID, ID subcodeID, ID addID ,Id TMSID , id tempContact)
 {
      ID RTID = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get(Constants.RECORDTYPE_NA_Targeting).getRecordTypeId();
      Project__c testProject = new Project__c();
      testProject.RecordTypeID = RTID;
      testProject.Account__c = accID;
      testProject.Type__c = 'Archive';
      testProject.Project_Stage__c = 'Analysis/Consultancy';
      testProject.List_Type__c = 'Outside List';
      testProject.Request_Type__c = 'Production';
      testProject.TMS_Number__c = TMSID;
      testProject.Projected_Revenue__c = 100;//RJ added for Revenue 
      testProject.Inquiry_Logging__c = 'All';
      testProject.Promo_Logging__c = 'C: Portfolio Review';
      testProject.Requested_Ship_Time__c = system.today();
      testProject.Requested_Ship_Date__c = system.today(); //MM added     
      testProject.Billing_Contact_Address__c  = addID;
      testProject.Shipping_Contact_Address__c  = addID;
      testProject.Billing_Contact_Name__c   = tempContact;
      testProject.Shipping_Contact_Name__c   = tempContact;
      testProject.Main_Contact__c  = tempContact;
      testProject.Project_Sub_Type__c = 'ORION';
      testProject.Third_Party_Processor_Involved__c = 'No';
      testProject.Start_Date__c = system.today();
      testProject.Frequency__C = 'Daily';
      testProject.Subcode__c = subcodeID;
      testProject.Billing_Category__c = 'B';
      testProject.Bill_Complete_Date__c = system.today();//RJ added  
      testProject.Promo_Completion_Date__c = system.today();//RJ added 
      testProject.Requested_Ship_Time__c = system.today();
      testProject.Reoccurance__c = 'New';
      testProject.Campaign_Name__c = 'Test Campaign Name'; //ty added
      testProject.Client_Contact__c = tempContact;
      return testProject;
  }





  //=============================================================//
  //Creates Sub_Code__c
  //============================================================//
  public static Sub_Code__c createSubCode(Account account, String subscriber_Code){
    Sub_Code__c sub_Code = new Sub_Code__c(
      Subscriber_Code__c = subscriber_Code,
      Account__c = account.Id,
      Subscriber_Name__c = account.Name
    );
    return sub_Code;
  }

  //=============================================================//
  //Inserts Sub_Code__c
  //============================================================//
  public static Sub_Code__c insertSubCode(Account account, String subscriberCode){
    Sub_Code__c subCode = createSubCode(account, subscriberCode);
    Database.insert(subCode, duplicateRuleOverride());
    return subCode;
  }
  
  //=============================================================//
  //Creates Matching Rule
  //============================================================//
  public static Matching_Rules__c createMatchingRules(Boolean isInsert) {
    Matching_Rules__c matchrule = new Matching_Rules__c(
     Business_Unit__c = 'CSDA',
     Fail_Severity__c = 'High',
     Rule_Type__c = 'Auto', 
     Pass_Count_Required__c = 1,
     Pending_Item_Assignee__c = 'Membership Owner',
     Create_Pending_Item__c = true, 
     Complexity__c = 'Low',
     Rule_Name__c = 'Rule'  +randomNumber()
    );
    if (isInsert) {
      insert matchrule;
    }
    return matchrule;
  }
  
  //=============================================================//
  //Creates Matching Rule
  //============================================================//
  public static Matching_Rule_Attributes__c createMatchingRuleAttribute(Boolean isInsert, Matching_Rules__c MatchRule) {
    Matching_Rule_Attributes__c matchruleAtt = new Matching_Rule_Attributes__c(
     Matching_Rule__c = MatchRule.id,
     Rule_Type__c = 'Equal',
     Parameter_Name__c = 'Parm'+randomNumber() , 
     Data_Source__c = 'Data Source', 
     Source_Type__c = 'Internal',
     Parameter_Value__c = '100',
     Rule_Name__c = MatchRule.Rule_Name__c
    );
    if (isInsert) {
      insert matchruleAtt;
    }
    return matchruleAtt;
  }
  
  //Method is used to insert the content version data
    public static ContentVersion insertContentVersion(Boolean isInsert, Blob contBody, string fileName,string filePath){
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = contBody;
        cv.Title = fileName;
        cv.PathOnClient = filePath;
        if(isInsert){//Based on this boolean, insertion will happen
            insert cv;
        }
        return cv;
    }
    //Get content version record based on content version id
    public static ContentVersion getContentVersion(Id cvId){
        return [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:cvId];
    }
    //Get Content Version records in map based on content version records 
    public static map<Id,ContentVersion> getContentVersions(list<ContentVersion> lstCntents){
        return new map<Id,ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN:lstCntents]);
    }
    //insert content document link to the mentioned content document id and parent id
    public static ContentDocumentLink insertContentDocumentLink(Boolean isInsert, Id contDocId, Id parId){
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contDocId;
        cdl.LinkedEntityId = parId;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        if(isInsert){
            insert cdl;
        }
        return cdl;
    }  
}