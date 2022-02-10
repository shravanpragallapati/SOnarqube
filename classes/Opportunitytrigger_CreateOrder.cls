/**=====================================================================
 * Experian
 * Name: OpportunityTrigger_CreateOrder
 * Description:
 * Created Date: Nov 16th, 2018
 * Created By: Malcolm Russell
 *
 * Date Modified      Modified By                  Description of the update
 * 18 Apr 2019        Malcolm Russell              EBA - two new fields on opportunity and order
 * Aug 01st, 2019     Malcolm Russell              Case #16125252 - Run as Owner group when  user is in APAC
 * Jan 23rd, 2020     Malcolm Russell              EDQ CPQ W-019873 - new fields from Oppty Line Item to Order Line item and Asset
 * Feb 06, 2020       Akash                        W-019940 - Copied Order line fields from opportunity line item
 * Sep 03rd, 2020     Herbert Oliveira             Case #20781315 - Replace apexLogHandler.createLogAndSave for createLogAndSendEmail on future/queueable methods with try catch 
 * Nov 5th, 2020      Mauricio Murillo             W-025538: Exposed populateOrderDetails as public so it can be reused
 * Mar 12th, 2021     Herbert Oliveira             Case 21897332: Fix to createLineItems method on finally block to not return null
 * Apr 19th, 2021     Rohit Aryan                  Case 21906469: Retry framework Enhancement
 * Jul 04th, 2021	  Herbert Oliveira			   W-033420: 22308221 - EDQ - Can we add "Upsell" Field to the Order Line Object
 =====================================================================*/
public without sharing class Opportunitytrigger_CreateOrder  implements Queueable{

   public Map<ID, Opportunity> newMap = new Map<ID, Opportunity>();
  public Map<ID, Opportunity> oldMap = new Map<ID, Opportunity>();


  public static String orderReadOnlyRT_ID;
  public static String orderLineReadOnlyRT_ID;
  public static String orderScheduleRT_Id;

  public static Boolean isExecuted = false;
  public static List<OpportunityLineItem> opptyLineList;
  public static Map<ID, List<OpportunityLineItem>> opptyID_OpptyLinesMap;
  
  public Opportunitytrigger_CreateOrder (Map<ID, Opportunity> newM, Map<ID, Opportunity> oldM){
        newMap=newM;
        oldMap=oldM;
  }

  public void execute(QueueableContext context){
     // PK: Case #583351 - 5/3/15 - Replacing this line as it caused doubling up of queries when testing...
    // if (isExecuted && !Test.isRunningTest()) {
    if (isExecuted) {
      return;
    }
    isExecuted = true;

    Map<ID, Order__c> opptyID_order = new Map<ID, Order__c>();
    Map<ID, Order__c> orderId_OrderMap = new Map<ID, Order__c>();
    Map<ID, Order_Line_Item__c> optyLineId_orderLineItemMap = new Map<ID, Order_Line_Item__c>();
    // List<Asset> assetListToInsert = new List<Asset>();
    
    // PK 16/7/15 - THIS BLOCK DOESN'T SEEM TO BE USED, SO COMMENTING OUT FOR TESTING...
    /// *******
    /*
    //Populating Opportunities to get latest value of closed and won fields.
    Map<ID, Opportunity> opportunityID_OpptyMap = new Map<ID, Opportunity>();
    for (Opportunity oppty : [SELECT ID, isWon, isClosed, StageName FROM Opportunity WHERE ID IN : newMap.keySet()]) {
      opportunityID_OpptyMap.put(oppty.ID, oppty);
    }
    system.debug('\n[OpportunityTrigger_OrderHelper: createOrderAndOrderLineItems] opportunityID_OpptyMap: '+ opportunityID_OpptyMap);
    */
    /// ********
    List<Opportunity> oppList = new List<Opportunity>();
    Set<String> opptyIDs = new Set<String>();

    Map<ID, OpportunityContactRole> opptyId_ContactRoleMap = new Map<ID, OpportunityContactRole>();
    for (Opportunity oppty : newMap.values()) {
      if (oppty.isClosed == true && oppty.isWon == true && oldMap.get(oppty.ID).isWon != true) {
        opptyIDs.add(oppty.ID);
      }
    }      
      
    //Pallavi Sharma @ Oct 17th 2014 - NLG Uncomment on same day (breaks Order creation)
    //Refactoring Code for improvement
    //No Need to check Primary Contact Role here
    //Already validated on before update on validateOpptyContactRoleOnClosedWon method
    if (opptyIDs.size() > 0) {
      opptyId_ContactRoleMap = getContactRoleForOppties (opptyIDs);
    } 
    else { // Added NLG March 5th, 2014 - Return if no Opp qualifies
      return;
    }
      
    //Process closed won opportunities only for order creation
    for (Opportunity oppty : newMap.values()) {
      system.debug('\n[OpportunityTrigger_OrderHelper: createOrderAndOrderLineItems] is closed: '+ oppty.StageName + ' & isWon  : '+ oldMap.get(oppty.ID).StageName);
      
      if (oppty.isClosed == true && oppty.isWon == true && oldMap.get(oppty.ID).isWon != true) {
        system.debug('\n[OpportunityTrigger_OrderHelper: createOrderAndOrderLineItems] oppty: '+ oppty.StageName );
        oppList.add(oppty);
      }
    }
    //End Changes by Pallavi Sharma @ Oct 17th 2014
     
    // Prior to create any order, we want to delete existing Orders, if any  
    deleteExistingOrders(oppList);
      
    orderReadOnlyRT_ID = DescribeUtility.getRecordTypeIdByName(Constants.SOBJECT_ORDER, Label.OPPTY_TYPE_READ_ONLY);
    orderLineReadOnlyRT_ID = DescribeUtility.getRecordTypeIdByName(Constants.SOBJECT_ORDER_LINE_ITEM, Label.OPPTY_TYPE_READ_ONLY);
    orderScheduleRT_ID = DescribeUtility.getRecordTypeIdByName(Constants.SOBJECT_ORDER_REVENUE_SCHEDULE, Label.OPPTY_TYPE_READ_ONLY);
      
    populateOpptyVsLineMapAndOpptyLineList(oppList);

    //Calling method to create orders for each closed won opportunity
    if (opptyId_ContactRoleMap.size() > 0) {
      opptyID_order = createOrders (oppList, opptyId_ContactRoleMap);
    }
    try {
      if (opptyID_order.size() > 0) {
        insert opptyID_order.values();
        populateOrderDetails(orderId_OrderMap, opptyID_order);
      }
    } 
    catch (DMLException e) {
      ApexLogHandler.createLogAndSendEmail('OpportunityTrigger_CreateOrder','execute', e.getMessage(), e);
        system.debug('[OpportunityTrigger_OrderHelper: createOrderAndOrderLineItems]: ['+e.getMessage()+']]');
      for (Integer i=0; i < e.getNumDml(); i++) {
        newMap.values().get(0).addError('\n'+ Label.OPPTY_Error_in_Order_Creation + e.getDMLMessage(i));
      }
      return;
    }

    //Creating order lines.
    if (opptyID_order.size() > 0) {
      optyLineId_orderLineItemMap = createOrderLines(oppList, opptyID_order);
    }
      
    //Creating revenue schedule for Order Lines
    //Feb 17th, 2014       Jinesh Goyal (Appirio)  added the null pointer check
    if (optyLineId_orderLineItemMap != null && optyLineId_orderLineItemMap.size() > 0) {
      createRevenueSchedules(optyLineId_orderLineItemMap);
    }      
    
    //Case #02380009 - Update Projects with Order details
    Map<Id, Project__c> proj_Map = new Map<Id, Project__c>([SELECT id, Opportunity__c FROM Project__c 
                                                            WHERE Opportunity__c IN :opptyIDs
                                                            AND Type__c='Presales']); 
                                                            
    if(!proj_Map.isEmpty()){
      Map<Id,Id> ordersToOpp_Map = new Map<Id,Id>();
      for(Order__c ord : opptyID_order.values()){
        ordersToOpp_Map.put(ord.Opportunity__c, ord.id);
      }
      for(Project__c proj : proj_Map.values()){
        proj.Order__c = ordersToOpp_Map.get(proj.Opportunity__c);
      }
    
      update proj_Map.values();
    }
    //Case #02380009

    //Creating Assets for Order Lines
    /*
    if (orderId_OrderMap.size() > 0) {
      assetListToInsert = generateAssets (orderId_OrderMap.values());
      if (!assetListToInsert.isEmpty()) {
        insert assetListToInsert;
      }
    }
    */
  }
  
  //===========================================================================
  // To populate oppty and line map and opptyline list.
  //Oct 20, 2014 Tyaga Pati Case#00010129: Added Finance BU Name and Product Finance BU
  //===========================================================================  
  public static void populateOpptyVsLineMapAndOpptyLineList (List<Opportunity> oppList) {
    if (oppList.size() > 0) {
      opptyLineList = new List<OpportunityLineItem>();
      opptyID_OpptyLinesMap = new Map<ID, List<OpportunityLineItem>>();
      for (OpportunityLineItem oli : [SELECT ID, Billing_Product__c, PricebookEntry.Product2Id, Start_Date__c, CPQ_Discount__c, Description, 
                                              Quantity, UnitPrice, Type_of_Sale__c, OpportunityId, End_Date__c, /*ListPrice,*/ List_Price__c,
                                              PricebookEntry.Product2.Name, CurrencyIsoCode ,Type__c, CPQ_Quantity__c,
                                              EDQ_Margin__c, Renewal_EDQ_Margin__c, EDQ_On_Demand_Product__c, // T-322945:EDQ specific fields are added
                                              No_Update__c, Renewal_Sale_Price__c,
                                              Extended_Amount__c, Renewal_Extended_Amount__c, 
                                              Partner_Amount__c,Partner_2_Amount__c,Partner_3_Amount__c,
                                              Partner_1_Name__c,Partner_2_Name__c,Partner_3_Name__c,
                                              Renewal_Partner_Amount__c,Renewal_Partner_2_Amount__c,Renewal_Partner_3_Amount__c,
                                               Order_Type__c, Program_Required__c, Opportunity_Country__c,
                                              Data_Required__c, Manuals_Required__c, Delivery_Method__c, Program_Media__c,
                                              Data_Media__c, Quantity_Type__c, Data_Usage__c, Product_Family__c, Hardware__c,
                                              Implementation__c, Compiler__c, Update_Frequency__c, Renewals_Exclude__c,
                                              Manual_Registration__c, Renewal_Registration__c, Click_Expiry__c, 
                                              No_Delivery__c, Precise_Day_License__c, //On_Demand__c,  Removed ths field from the object
                                              Operating_System__c, Part_Number__c, Renewal_Discount__c, Discount_Amount__c,
                                              Renewal_Discount_Amount__c, 
                                              Partner__c,Partner_2__c,Partner_3__c, Renewal_Partner__c,Renewal_Partner_2__c,Renewal_Partner_3__c,  
                                              Users_From__c, Users_To__c, Application__c,
                                              CRM_Product_Name__c, Product_Code__c, Product_Reference__c, Product_Data__c,
                                              Registration_Key__c, //Manuals__c,
                                              Release__c, Distribution_Notes__c, Despatch_Status__c, Delivery_Time__c,
                                              Major_Version__c, CD_Name__c, Data_Installer_Password__c, Release_Reference__c,
                                              Total_Royalty__c, Renewal_Total_Royalty__c, Item_Number__c, Quote_Number__c,
                                              eRenewal_Exception__c, Original_Asset_ID__c, Product_Upgrade__c, //Data__c, Progs__c,
                                              Price_Category__c, Media_Quantity__c, Renewal_List_Price__c, Parent_Item_Number__c,
                                              Product_Finance_BU__c, Finance_BU_Name__c, SaaS__c, SaaS_Product_Code__c,
                                              //, Product_Finance_BU__c, Finance_BU_Name__c
                                              Adj_Amount__c, Adj_Percentage__c, AE_Discount__c, Annual_Sales_Price__c, /*Auto_Quote__c,*/                                             
                                              CSDA_Estimated_Annual_Volume__c, CSDA_List_Price__c, CSDA_Product_Group__c, CSDA_Product_Org__c,
                                              CSDA_Product_Suite__c, CSDA_Unit_Type__c,Manager_Discount__c,
                                              Manual_Adj_Amount__c, Manual_Discount__c, Manual_Price_Override__c,
                                              Max_Volume__c, Min_Volume__c, Original_Price__c, Quotable__c,
                                               Requested_Adjustment_Amount__c, Requested_Unit_Price__c, SA_Discount__c,
                                              Serasa_BI_Split__c, Serasa_CI_Split__c, Serasa_DA_Split__c, Serasa_ECS_Split__c,
                                              Serasa_ID_Split__c, Serasa_MS_Split__c,Serasa_Targeting_Split__c,
                                              /*Auto_Total_Price__c,Auto_Unit_Price__c,*/Expected_Bill_Date__c, // RJ: Added fields for Story S# 0161
                                              Opportunity.Owner.Country__c, // PK: Case 953780, to get the opp country if missing,
                                              Brazil_Business_Lifecycle__c, // CASE 01770348
                                              Opportunity.Describe_Client_Deliverable__c, Opportunity.Describe_Data_Use_DPPA_Use__c,  //CRM2:W-005655                                              
                                              NBQ__c,                                                                                            
                                              NBQ_Product__c,//Case #13429450
                                              DP_Product_Package_code__c, DP_Admin_Required__c, auto_renew__c,//MR DP Migration
                                              IFRS15_Primary_Revenue_Subaccount__c, IFRS15_Primary_Revenue_Subaccount_Code__c,
                                              IFRS15_Secondary_Revenue_Subaccount__c, IFRS15_Secondary_Revenue_Subaccount_Code__c,
                                              IFRS15_Transac_2ary_Revenue_Subaccount__c,//IFRS15:Case 15572930
                                              Automotive_Custom_Product__c, //CASE 02259280
                                              Payment_Method_formula__c,Installments_Splits_formula__c,Installment_Interval_formula__c,Payment_Options_formula__c,//Added by Sunil
                                              Renewal_Margin_Split__c, New_Business_Margin_Split__c, //Case 01877853
                                              Rank__c, // EC:: 02462677
                                              Advocacy__c,Container_Category__c,Customer_Application_Version__c,Delivery_Variant__c, //W-019873
                                              DRMID__c,Edition__c,EDQ_Integration_Solution_Version__c,Minimum_of_Days__c,CPQ_Segment__c, //W-019873
                                              Package__c,ProspectIQ_Pricing_Tool_Unique_ID__c,Variation__c,Variant__c,Use_Case__c, //W-019873
                                              Case_Study_Concession__c,Commercial_Approval__c,  Product_Lifecycle__c,Transaction_Rate__c,Quote_Item_Type__c,//W-019873
                                              Deferred_Revenue__c,All_Other_Attr__c,CPQ_Add_on__c,
                                              CPQ_Attrib_1_Label__c, CPQ_Attrib_2_Label__c, CPQ_Attrib_3_Label__c, CPQ_Attrib_4_Label__c, CPQ_Attrib_5_Label__c,
                                              CPQ_Attrib_6_Label__c, CPQ_Attrib_7_Label__c, CPQ_Attrib_8_Label__c, CPQ_Attrib_9_Label__c, CPQ_Attrib_10_Label__c, 
                                              CPQ_Attrib_1_Value__c, CPQ_Attrib_2_Value__c, CPQ_Attrib_3_Value__c, CPQ_Attrib_4_Value__c, CPQ_Attrib_5_Value__c, 
                                              CPQ_Attrib_6_Value__c, CPQ_Attrib_7_Value__c, CPQ_Attrib_8_Value__c, CPQ_Attrib_9_Value__c, CPQ_Attrib_10_Value__c,
                                      		  Upsell__c
                                              FROM OpportunityLineItem 
                                      WHERE OpportunityID IN: oppList]) {
        opptyLineList.add(oli);
        if (!opptyID_OpptyLinesMap.containsKey(oli.OpportunityID)) {
          opptyID_OpptyLinesMap.put(oli.OpportunityID, new List<OpportunityLineItem>());
        }
        opptyID_OpptyLinesMap.get(oli.OpportunityID).add(oli);
      }
    }
    system.debug('[**opptyID_OpptyLinesMap**]'+opptyID_OpptyLinesMap);
  }
  
  //Commented code by Pallavi Sharma @ Oct 17th 2014 - uncommented by NLG
  //============================================================================================
  // Get OpportunityContactRole record for the opportunities
  //============================================================================================
  private static Map<ID, OpportunityContactRole> getContactRoleForOppties (Set<String> opptyIDs) {
    
    Map<ID, OpportunityContactRole> opptyId_ContRoleMap = new Map<ID, OpportunityContactRole>();
        
    for (OpportunityContactRole contactRole : [SELECT IsPrimary, Id, ContactId, OpportunityId 
                                               FROM OpportunityContactRole 
                                               WHERE OpportunityId IN: opptyIDs]) {
      if (!opptyId_ContRoleMap.containsKey(contactRole.OpportunityId) && 
          contactRole.IsPrimary == true && 
          contactRole.ContactId <> null) {
        opptyId_ContRoleMap.put(contactRole.OpportunityId, contactRole);
      }
    }
    return opptyId_ContRoleMap;
  }
  //End Changes Pallavi Shasma @ Oct 17 2014
  
  //============================================================================================
  // Deletes orders related to given opportunities.
  //============================================================================================
  private static void deleteExistingOrders(List<Opportunity> opps) {
    // Order Revenue Schedule has master detail with Order Line Item
    // Order Line Item has master detail with Order
    // If ASSETS ARE CREATED at any time, we will have to delete them separately as they can't
    // support master detail
    List<Order__c> existingOrders = new List<Order__c>();
    List<Order_Split__c> orderSplits = new List<Order_Split__c>();
    
    for (Order__c ord : [SELECT Id, (Select Id From Order_Splits__r) 
                         FROM Order__c
                         WHERE Opportunity__c IN: opps]) {
      existingOrders.add(ord);
      for (Order_Split__c split : ord.Order_Splits__r) {
        orderSplits.add(split);
      }
    }
    
    try {
      if (orderSplits.size() > 0) {
        delete orderSplits;
      }
      if (existingOrders.size() > 0) {
        delete existingOrders;
      }
    }
    catch (DMLException e) {
      ApexLogHandler.createLogAndSendEmail('OpportunityTrigger_CreateOrder','deleteExistingOrders', e.getMessage(), e);
        
      for (Integer i=0; i < e.getNumDml(); i++) {
        opps.get(0).addError('\n'+ Label.OPPTY_Error_in_Deleting_Order +e.getDMLMessage(i));
      }
    }
  }

  //=========================================================================
  //To create orders from closed won Opportunities(passed as parameter)
  //=========================================================================
  public static Map<ID, Order__c> createOrders (List<Opportunity> opptyList,
                      Map<ID, OpportunityContactRole> opptyId_ContactRoleMap) {

    Map<ID, Order__c> opptyID_newOrder = new Map<ID, Order__c>();
    Map<String, String> oppId_AccIdMap = new Map<String, String>();
    
    //T-324899
    for (OpportunityPartner oppPrtnr : [SELECT AccountToId, OpportunityId
                                        FROM OpportunityPartner 
                                        WHERE OpportunityId IN :opptyList AND IsPrimary =: true]) {
      oppId_AccIdMap.put(oppPrtnr.OpportunityId, oppPrtnr.AccountToId);
    }
      
    for (Opportunity oppty : opptyList) {
      if (!opptyID_OpptyLinesMap.containsKey(oppty.Id) || (opptyID_OpptyLinesMap.containsKey(oppty.Id) && opptyID_OpptyLinesMap.get(oppty.Id).size() < 1)) {
        continue;
      }
      //Putting newOrder to map for further processing and inserts
      opptyID_newOrder.put(oppty.ID, createOrder (oppty, opptyId_ContactRoleMap.get(oppty.ID).ContactId, oppId_AccIdMap));
    }

    return opptyID_newOrder;
  }

  //==========================================================================
  //To create individual order from passed opportunity
  //==========================================================================
  public static Order__c createOrder (Opportunity oppty, ID opptyContact, 
                                        Map<String, String> oppId_AccIdMap) {
                                     
    //String groupName = BusinessUnitUtility.getBusinessUnit(runAsUser); //T-322945: EDQ specific

    // Case #00984131
    Map<String, Order__c> opptyID_oldOrder = new Map<String, Order__c>();
   
    if (oppty.Previous_Opportunity__c != null){
      for (Order__c ord : [SELECT Id, Opportunity__c, Order_to_Credit__c
                           FROM Order__c 
                           WHERE Opportunity__c = :oppty.Previous_Opportunity__c
                           AND Opportunity__r.Type = :Constants.OPPTY_TYPE_CREDITED]) {
        if (ord.Order_to_Credit__c != null) {
          // credit note
          opptyID_oldOrder.put('CRD~' + ord.Opportunity__c, ord);
        }
        else {
          opptyID_oldOrder.put('ORD~' + ord.Opportunity__c, ord);
        }
      }  
    } 
                     
    system.debug('====opptyID_oldOrder==>>>' +opptyID_oldOrder);

    Order__c newOrder = new Order__c();
    newOrder.Name = 'Order: '+oppty.Name;
    if (newOrder.Name.length() > 80) {
      newOrder.Name = newOrder.Name.substring(0, 80);
    }
    //newOrder.Original_Order_Value__c
    Double originalOrderValue = 0;

    system.debug('[OpportunityTrigger_OrderHelper][***opptyID_OpptyLinesMap**]' + opptyID_OpptyLinesMap.size());
    system.debug('[OpportunityTrigger_OrderHelper][***oppty.ID**]' + oppty.ID);
    
    for (OpportunityLineItem oli : opptyID_OpptyLinesMap.get(oppty.ID)) {
      originalOrderValue = originalOrderValue + (oli.UnitPrice * oli.Quantity);
    }

    newOrder.Original_Order_Value__c = originalOrderValue;
    newOrder.CurrencyIsoCode        = oppty.CurrencyIsoCode;
    newOrder.Account__c             = oppty.AccountId;
    //newOrder.Business_Unit__c       = oppty.Business_Unit__c;
    newOrder.Campaign__c            = oppty.CampaignId;
    //newOrder.Global_Line_of_Business__c = oppty.Global_Line_of_Business__c;
    newOrder.Opportunity__c         = oppty.ID;
    newOrder.Contract_Start_Date__c = oppty.Contract_Start_Date__c;
    newOrder.Contract_End_Date__c   = oppty.Contract_End_Date__c;
    newOrder.Contact__c             = opptyContact;
    newOrder.Type__c                = oppty.Type;
    newOrder.Locked__c              = true;
    newOrder.Transactional_Sale__c  = oppty.RecordTypeId==Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.Opty_Transactional_Sale).getRecordTypeId()?true:false;
    newOrder.RecordTypeId           = orderReadOnlyRT_ID;
    newOrder.OwnerId                = oppty.OwnerId;
    newOrder.Reporting_Sales_Team__c = oppty.Reporting_Sales_Team__c;  // JW - Case #8566
    newOrder.Invoice_to_End_User__c = oppty.Invoice_to_End_User__c; // NLG - I-135699
    newOrder.FYR__c                 = oppty.FYR__c; // JW - Case 7603
    newOrder.SYR__c                 = oppty.SYR__c; // JW - Case 7603
    newOrder.Quote_Active__c               = oppty.Quote_Active__c; //TTK I-162285 
   // newOrder.Quote_Bill_Plan_Code__c       = oppty.Quote_Bill_Plan_Code__c; //TTK I-162285 
   // newOrder.Quote_Close_Date__c           = oppty.Quote_Close_Date__c; //TTK I-162285 
   // newOrder.Quote_Created_Date__c         = oppty.Quote_Created_Date__c; //TTK I-162285 
   // newOrder.Quote_Effective_As_Of__c      = oppty.Quote_Effective_As_Of__c; //TTK I-162285 
   // newOrder.Quote_Effective_Through__c    = oppty.Quote_Effective_Through__c; //TTK I-162285 
    newOrder.Quote_Last_Modified_Date__c   = oppty.Quote_Last_Modified_Date__c; //TTK I-162285 
    newOrder.Quote_Number__c               = oppty.Quote_Number__c; //TTK I-162285 
    newOrder.Quote_Primary__c              = oppty.Quote_Primary__c; //TTK I-162285 
    newOrder.Quote_Revision__c             = oppty.Quote_Revision__c; //TTK I-162285 
    newOrder.Quote_Status__c               = oppty.Quote_Status__c; //TTK I-162285 
    newOrder.Quote_Type__c                 = oppty.Quote_Type__c; //TTK I-162285 
    newOrder.Requested_Bill_Plan__c        = oppty.Requested_Bill_Plan__c; //TTK I-162285 
    newOrder.Suggested_Bill_Plan__c        = oppty.Suggested_Bill_Plan__c; //TTK I-162285 
    newOrder.CSDA_Annual_Contract_Value__c = oppty.CSDA_Annual_Contract_Value__c; //TTK I-162285 
    newOrder.Quote_Created_by__c           = oppty.Quote_Created_by__c; //TTK I-162285 
    newOrder.Channel_Source__c             = Constants.ORDER_CHANNEL_SOURCE_DIRECT_SALES;
    
    newOrder.IsSplit__c                    = oppty.IsSplit;//Case #13429450

    //New field mapping for Automotive fields - Story S-0161
    newOrder.Solution_Overview__c          = oppty.Solution_Overview__c;
    //Expected_Bill_Date__c
    newOrder.Disposition__c                = oppty.Disposition__c;
    newOrder.Sales_Comments__c             = oppty.Sales_Comments__c;
    newOrder.Mash_Approval__c              = oppty.Mash_Approval__c;
    newOrder.Disposition_More_Info__c      = oppty.Disposition_More_Info__c;
    newOrder.Sizing_Initial__c             = oppty.Sizing_Initial__c;
    newOrder.Sales_Reply__c                = oppty.Sales_Reply__c;
    newOrder.Sizing_Ongoing__c             = oppty.Sizing_Ongoing__c;
    newOrder.Contracts_Comments__c         = oppty.Contracts_Comments__c;     
    //EC:: 02395815 Send CPQ Special Terms to new opportunites
    newOrder.CPQ_Special_Terms__c          = oppty.CPQ_Special_Terms__c;

    //01039554 Add channel type to the order (as it is missing). This will then filter down to the Asset (in orderlineitemtriggerhandler)
    newOrder.Channel_Type__c               = oppty.Channel_Type__c;
    //As per T-269796
    if (oppty.Option_To_Terminate_Date__c != null) {
      newOrder.Option_To_Terminate_Date__c = oppty.Option_To_Terminate_Date__c;
    }
    //T-324899
    Id accId;
    if (oppId_AccIdMap.containsKey(oppty.Id)) {
      accId = oppId_AccIdMap.get(oppty.Id);
    }   

    //As per T-322945 : EDQ Specific code
    // Per Case # 02215099 ; PO Number and PO Required is now copied to all Optys
   // if (String.isNotBlank(groupName) && groupName.equalsIgnoreCase(Constants.EDQ)) {
      newOrder.PO_Required__c       = oppty.PO_Required__c;
      newOrder.PO_Number__c         = oppty.PO_Number__c;
      newOrder.Partner__c           = accId; //T-324899
    //}
    
    //As per T-420484: Make order saas by saas_order = true when oppty has
    // at-least one saas oppty line. 
    if (oppty.Count_of_SaaS_Line_Items__c > 0) {
      newOrder.SaaS_Order__c = true;
    }
    
    // Case #00984131
    if (oppty.Previous_Opportunity__c != null && opptyID_oldOrder.containsKey('ORD~'+oppty.Previous_Opportunity__c)) {       
      newOrder.Previous_Order__c = opptyID_oldOrder.get('ORD~'+oppty.Previous_Opportunity__c).Id;
    }
    if (oppty.Previous_Opportunity__c != null && opptyID_oldOrder.containsKey('CRD~'+oppty.Previous_Opportunity__c)) {       
      newOrder.Previous_Credit_Note__c = opptyID_oldOrder.get('CRD~'+oppty.Previous_Opportunity__c).Id;
    }
    
    //TP CRM2:W-005655 - Adding new fields to be carried over from Opp to Order
    newOrder.Describe_Client_Deliverable__c = oppty.Describe_Client_Deliverable__c ;
    newOrder.Describe_Data_Use_DPPA_Use__c  = oppty.Describe_Data_Use_DPPA_Use__c ;
    
    // Case 02259280
    
    newOrder.Auto_Client_Budget__c=oppty.Auto_Client_Budget__c;
    newOrder.Mash_Review__c=oppty.Mash_Review__c;
    newOrder.Mash_Approval_Date__c=oppty.Mash_Approval_Date__c;
    newOrder.Compliance_Review_Requested__c=oppty.Compliance_Review_Requested__c;
    newOrder.CS_Project_Manager_Review__c=oppty.CS_Project_Manager_Review__c;
    newOrder.LOE_Change__c=oppty.LOE_Change__c;
     
    
    //MR DP Migration:W-009914 - Adding new fields to be carried over from Opp to Order
    newOrder.Special_Instructions__c = oppty.Special_Instructions__c;
    //MR DP Migration:W-009626 - Adding new fields to be carried over from Opp to Order
    newOrder.Auto_Renew__c = oppty.Auto_Renew_Count__c > 0;
    
    //EBA
    newOrder.Payment_Method__c = oppty.Payment_Method__c;
    newOrder.First_Invoice_Date__c=oppty.First_Invoice_Date__c;
    //    
        
    system.debug('====Previous_Order__c==>>>' +newOrder.Previous_Order__c);
    system.debug('---orderReadOnlyRT_ID--'+orderReadOnlyRT_ID);
    
    return newOrder;
  }

  //============================================================================================
  //Populate Order details on maps provided
  //============================================================================================
  public static void populateOrderDetails (Map<ID, Order__c> orderId_OrderMap, Map<ID, Order__c> opptyID_order) {
    for (Order__c ord : [SELECT o.RecordTypeId, o.OwnerId, o.Opportunity__c, 
                                o.Id, o.Account__c,
                                o.Contract_Start_Date__c, o.Contract_Number__c, 
                                o.Contract_End_Date__c, o.Contact__c, o.Close_Date__c, 
                                o.Cancellation_Date__c, o.Campaign__c //, o.Business_Unit__c, o.Global_Line_of_Business__c
                        FROM Order__c o 
                        WHERE ID IN: opptyID_order.values()]) {
      //Populating orderId and Order map
      if (!orderId_OrderMap.containsKey(ord.ID)) {
        orderId_OrderMap.put(ord.ID, ord);
      }
      //Populating opptyId and order map
      if (ord.Opportunity__c <> null && !opptyID_order.containsKey(ord.Opportunity__c)) {
        opptyID_order.put(ord.Opportunity__c, ord);
      }
    }
  }

  //============================================================================================
  //To create order lines for closed won Opportunities (Passed as parameter)
  //============================================================================================
  public static Map<ID, Order_Line_Item__c> createOrderLines (List<Opportunity> oppList,
                                         Map<ID, Order__c> opptyID_order) {
    List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
    Map<ID, Order_Line_Item__c> oliId_ordLIMap = new Map<ID, Order_Line_Item__c>(); 
    Order_Line_Item__c ordLine;

    try {
    
      //IFRS15:Case 15572930
      //IFRS15_Secondary_Revenue_Subaccount__mdt[] secRev =[SELECT MasterLabel, Subaccount_Code__c
      //                                                   FROM IFRS15_Secondary_Revenue_Subaccount__mdt];
    
      //Fetching opportunityLineItems
      for (OpportunityLineItem oli : opptyLineList) { 
        if (opptyID_order.containsKey(oli.OpportunityId) == true) {
          ordLine = new Order_Line_Item__c();
  
          if (oli.Billing_Product__c <> null) {
            ordLine.Billing_Product__c = oli.Billing_Product__c;
          }
          //ordLine.Cancellation_Date__c
          ordLine.Order__c                = opptyID_order.get(oli.OpportunityId).ID;
          ordLine.CurrencyIsoCode         = oli.CurrencyIsoCode;
          ordLine.Product__c              = oli.PricebookEntry.Product2Id;
          ordLine.Quantity__c             = oli.Quantity;
          ordLine.Type_of_Sale__c         = oli.Type_of_Sale__c;
          ordLine.Opportunity_Line_Item_Id__c = oli.ID;
          ordLine.Start_Date__c           = oli.Start_Date__c;
          ordLine.End_Date__c             = oli.End_Date__c;
          ordLine.RecordTypeId            = orderLineReadOnlyRT_ID;
          ordLine.Total__c                = oli.UnitPrice * oli.Quantity;
          ordLine.Type__c                 = oli.Type__c;
          ordLine.SaaS__c                 = oli.SaaS__c;
          ordLine.SaaS_Product_Code__c    = oli.SaaS_Product_Code__c;
          ordLine.Product_Finance_BU__c   = oli.Product_Finance_BU__c; //Oct 20, 2014 Tyaga Pati Case#00010129: Added Finance BU Name and Product Finance BU
          ordLine.Finance_BU_Name__c      = oli.Finance_BU_Name__c;
          ordLine.CPQ_Quantity__c         = oli.CPQ_Quantity__c; // T-313163
          ordLine.EDQ_Margin__c           = oli.EDQ_Margin__c; //T-317883
          ordLine.Renewal_EDQ_Margin__c   = oli.Renewal_EDQ_Margin__c; //T-317883
          ordLine.Product_Upgrade__c      = oli.Product_Upgrade__c;
          ordLine.Order_Type__c           = oli.Order_Type__c; //T-326349
          ordLine.Renewal_List_Price__c   = oli.Renewal_List_Price__c;
          // PK Case 953780 - Adding missing country of origin to order lines from opportunity.
          ordLine.Country_of_Origin__c = (String.isNotBlank(oli.Opportunity_Country__c)) ? oli.Opportunity_Country__c : oli.Opportunity.Owner.Country__c;
              
          //As per T-322945 : EDQ Specific code
          ordLine.Application__c             = oli.Application__c;
          ordLine.Compiler__c                = oli.Compiler__c;
          ordLine.CD_Name__c                 = oli.CD_Name__c;
          ordLine.Click_Expiry__c            = oli.Click_Expiry__c;
          ordLine.CRM_Product_Name__c        = oli.CRM_Product_Name__c;
          //RJ added variant 
          ordLine.Variant__c                 =oli.Variant__c;
          //I-135696 : removed Mappings
          //ordLine.Data__c                    = oli.Data__c;
          ordLine.Data_Installer_Password__c = oli.Data_Installer_Password__c;
          ordLine.Data_Media__c              = oli.Data_Media__c;
          ordLine.Data_Required__c           = oli.Data_Required__c;
          ordLine.Data_Usage__c              = oli.Data_Usage__c;
          ordLine.Delivery_Method__c         = oli.Delivery_Method__c;
          ordLine.Despatch_Status__c         = oli.Despatch_Status__c;
          ordLine.Delivery_Time__c           = oli.Delivery_Time__c;
          ordLine.Discount__c                = oli.CPQ_Discount__c; /*oli.Discount;*/ // I-146888
          ordLine.Discount_Amount__c         = oli.Discount_Amount__c;
          ordLine.Distribution_Notes__c      = oli.Distribution_Notes__c;
          ordLine.EDQ_On_Demand_Product__c   = oli.EDQ_On_Demand_Product__c;
          ordLine.eRenewal_Exception__c      = oli.eRenewal_Exception__c;
          ordLine.Extended_Amount__c         = oli.Extended_Amount__c;
          ordLine.Hardware__c                = oli.Hardware__c;
          ordLine.Implementation__c          = oli.Implementation__c;
          ordLine.Item_Description__c        = oli.Description;
        //  ordLine.Item_Quantity__c           = oli.Item_Quantity__c;
          ordLine.Item_Number__c             = oli.Item_Number__c;
          ordLine.List_Price__c              = oli.List_Price__c; //oli.ListPrice; - I-146698
          ordLine.Major_Version__c           = oli.Major_Version__c;
          ordLine.Manual_Registration__c     = oli.Manual_Registration__c;
          //I-135696 : removed Mappings 
          //ordLine.Manuals__c                 = oli.Manuals__c;
          ordLine.Manuals_Required__c        = oli.Manuals_Required__c;
          ordLine.Media_Quantity__c          = oli.Media_Quantity__c;
          ordLine.No_Delivery__c             = oli.No_Delivery__c;
          ordLine.No_Update__c               = oli.No_Update__c;
              
          // I-137435 - Removed these fields from OLI and OrderLI
          // ordLine.OnDemand__c                = oli.On_Demand__c;
           
          ordLine.Operating_System__c        = oli.Operating_System__c;
          ordLine.Original_Asset_ID__c       = oli.Original_Asset_ID__c;
          ordLine.Parent_Item_Number__c      = oli.Parent_Item_Number__c;
          ordLine.Part_Number__c             = oli.Part_Number__c;
          ordLine.Partner_Amount__c          = oli.Partner_Amount__c;
          ordLine.Partner_2_Amount__c        = oli.Partner_2_Amount__c;
          ordLine.Partner_3_Amount__c        = oli.Partner_3_Amount__c;
          ordLine.Partner__c                 = oli.Partner__c;
          ordLine.Partner_2__c               = oli.Partner_2__c;
          ordLine.Partner_3__c               = oli.Partner_3__c;
          ordLine.Partner_1_Name__c          = oli.Partner_1_Name__c;
          ordLine.Partner_2_Name__c          = oli.Partner_2_Name__c;
          ordLine.Partner_3_Name__c          = oli.Partner_3_Name__c;
          ordLine.Precise_Day_License__c     = oli.Precise_Day_License__c;
          ordLine.Price_Category__c          = oli.Price_Category__c;
          ordLine.Product_Code__c            = oli.Product_Code__c;
          ordLine.Product_Data__c            = oli.Product_Data__c;
          ordLine.Product_Family__c          = oli.Product_Family__c;
          ordLine.Product_Reference__c       = oli.Product_Reference__c;
         // ordLine.Product_Release_Name__c    = oli.Product_Release_Name__c;
          ordLine.Program_Media__c           = oli.Program_Media__c;
          ordLine.Program_Required__c        = oli.Program_Required__c;
          //I-135696 : removed Mappings
          //ordLine.Progs__c                   = oli.Progs__c;
          ordLine.Quantity_Type__c           = oli.Quantity_Type__c;
          ordLine.Quote_Number__c            = oli.Quote_Number__c;
          ordLine.Registration_Key__c        = oli.Registration_Key__c;
          ordLine.Release__c                 = oli.Release__c;
          ordLine.Release_Reference__c       = oli.Release_Reference__c;
          ordLine.Renewal_Discount__c        = oli.Renewal_Discount__c;
          ordLine.Renewal_Discount_Amount__c = oli.Renewal_Discount_Amount__c;
          ordLine.Renewal_Extended_Amount__c = oli.Renewal_Extended_Amount__c;
          ordLine.Renewal_Partner_Amount__c  = oli.Renewal_Partner_Amount__c;
          ordLine.Renewal_Partner_2_Amount__c  = oli.Renewal_Partner_2_Amount__c;
          ordLine.Renewal_Partner_3_Amount__c  = oli.Renewal_Partner_3_Amount__c;
          ordLine.Renewal_Partner__c         = oli.Renewal_Partner__c;
          ordLine.Renewal_Partner_2__c         = oli.Renewal_Partner_2__c;
          ordLine.Renewal_Partner_3__c         = oli.Renewal_Partner_3__c;
          ordLine.Renewal_Registration__c    = oli.Renewal_Registration__c;
          ordLine.Renewal_Sales_Price__c     = oli.Renewal_Sale_Price__c;
          ordLine.Renewal_Total_Royalty__c   = oli.Renewal_Total_Royalty__c;
          ordLine.Renewals_Exclude__c        = oli.Renewals_Exclude__c;
          //ordLine.Sale_Price__c              = oli.UnitPrice; // NLG update to 'unitPrice' 2014-09-30 - field deleted 2014-10-09
          ordLine.Total_Royalty__c           = oli.Total_Royalty__c;
          ordLine.Update_Frequency__c        = oli.Update_Frequency__c;
          ordLine.Users_From__c              = oli.Users_From__c;
          ordLine.Users_To__c                = oli.Users_To__c;
          ordLine.Adj_Amount__c              = oli.Adj_Amount__c; //TTK - I-162285
          ordLine.Adj_Percentage__c          = oli.Adj_Percentage__c; //TTK - I-162285
          ordLine.AE_Discount__c             = oli.AE_Discount__c; //TTK - I-162285
          ordLine.Annual_Sales_Price__c      = oli.Annual_Sales_Price__c; //TTK - I-162285
        //  ordLine.Auto_Quote__c              = oli.Auto_Quote__c; //TTK - I-162285
        //  ordLine.Bill_Plan_Product_Name__c  = oli.Bill_Plan_Product_Name__c; //TTK - I-162285
        //  ordLine.Bundle_Discount_Category__c= oli.Bundle_Discount_Category__c; //TTK - I-162285
        //  ordLine.Bundle_Discount_Name__c    = oli.Bundle_Discount_Name__c; //TTK - I-162285
          ordLine.CSDA_Estimated_Annual_Volume__c = oli.CSDA_Estimated_Annual_Volume__c; //TTK - I-162285
          ordLine.CSDA_List_Price__c         = oli.CSDA_List_Price__c; //TTK - I-162285
          ordLine.CSDA_Product_Group__c      = oli.CSDA_Product_Group__c; //TTK - I-162285
          ordLine.CSDA_Product_Org__c        = oli.CSDA_Product_Org__c; //TTK - I-162285
          ordLine.CSDA_Product_Suite__c      = oli.CSDA_Product_Suite__c; //TTK - I-162285
          ordLine.CSDA_Unit_Type__c          = oli.CSDA_Unit_Type__c; //TTK - I-162285
       //   ordLine.Escalate__c                = oli.Escalate__c; //TTK - I-162285
       //   ordLine.Final_Price__c             = oli.Final_Price__c; //TTK - I-162285
          ordLine.Manager_Discount__c        = oli.Manager_Discount__c; //TTK - I-162285
          ordLine.Manual_Adj_Amount__c       = oli.Manual_Adj_Amount__c; //TTK - I-162285
          ordLine.Manual_Discount__c         = oli.Manual_Discount__c; //TTK - I-162285
          ordLine.Manual_Price_Override__c   = oli.Manual_Price_Override__c; //TTK - I-162285
         // ordLine.Maximum_Price__c           = oli.Maximum_Price__c; //TTK - I-162285
          ordLine.Max_Volume__c              = oli.Max_Volume__c; //TTK - I-162285
         // ordLine.Minimum_Price__c           = oli.Minimum_Price__c; //TTK - I-162285
          ordLine.Min_Volume__c              = oli.Min_Volume__c; //TTK - I-162285
          ordLine.Original_Price__c          = oli.Original_Price__c; //TTK - I-162285
         // ordLine.Plan__c                    = oli.Plan__c; //TTK - I-162285
          ordLine.Quotable__c                = oli.Quotable__c; //TTK - I-162285
         // ordLine.Quote_Sheet_Type__c        = oli.Quote_Sheet_Type__c; //TTK - I-162285
          ordLine.Requested_Adjustment_Amount__c = oli.Requested_Adjustment_Amount__c; //TTK - I-162285
          ordLine.Requested_Unit_Price__c    = oli.Requested_Unit_Price__c; //TTK - I-162285
          ordLine.SA_Discount__c             = oli.SA_Discount__c; //TTK - I-162285
          //Serasa fields T-437145
          ordLine.Serasa_BI_Split__c         = oli.Serasa_BI_Split__c;
          ordLine.Serasa_CI_Split__c         = oli.Serasa_CI_Split__c;
          ordLine.Serasa_DA_Split__c         = oli.Serasa_DA_Split__c;
          ordLine.Serasa_ECS_Split__c        = oli.Serasa_ECS_Split__c;
          ordLine.Serasa_ID_Split__c         = oli.Serasa_ID_Split__c;
          ordLine.Serasa_MS_Split__c         = oli.Serasa_MS_Split__c;
          ordLine.Serasa_Targeting_Split__c  = oli.Serasa_Targeting_Split__c; 
          //Case 01770348 
          ordLine.Brazil_Business_Lifecycle__c = oli.Brazil_Business_Lifecycle__c;
            
          //New field mapping for Automotive fields - Story S-0161
         // ordLine.Auto_Total_Price__c        = oli.Auto_Total_Price__c;
         // ordLine.Auto_Unit_Price__c         = oli.Auto_Unit_Price__c;
          ordLine.Expected_Bill_Date__c      = oli.Expected_Bill_Date__c;
          
          ordLine.NBQ__c                     = oli.NBQ__c;//Case #13429450
          ordLine.NBQ_Product__c             = oli.NBQ_Product__c;//Case #13429450 
          
          //Transfer values for EDQ Order Line Items (non-EDQ Order Line Items and Opportunity Line Items get values from Billing Product)
          //This code can be run unconditionally for all Order Line Items since values do not change.
          
          //IFRS15:Case 15572930
          ordLine.IFRS15_Primary_Revenue_Subaccount__c        = oli.IFRS15_Primary_Revenue_Subaccount__c;
          ordLine.IFRS15_Primary_Revenue_Subaccount_Code__c   = oli.IFRS15_Primary_Revenue_Subaccount_Code__c;
          
          ordLine.IFRS15_Secondary_Revenue_Subaccount__c      = oli.IFRS15_Secondary_Revenue_Subaccount__c;
          ordLine.IFRS15_Secondary_Revenue_Subaccount_Code__c = oli.IFRS15_Secondary_Revenue_Subaccount_Code__c;
          
          ordLine.IFRS15_Transac_2ary_Revenue_Subaccount__c   = oli.IFRS15_Transac_2ary_Revenue_Subaccount__c;
          //IFRS15:Case 15572930                    
          
          ordLine.Automotive_Custom_Product__c=oli.Automotive_Custom_Product__c; //Case 02259280
          
          //MR DP Migration : take DP Product code from opp product to order line
          ordLine.DP_Product_Package_code__c=oli.DP_Product_Package_code__c;
          ordLine.DP_Admin_Required__c = oli.DP_Admin_Required__c;
          
          ordLine.OrderLine_Attrib_1_Label__c = oli.CPQ_Attrib_1_Label__c;
          ordLine.OrderLine_Attrib_2_Label__c = oli.CPQ_Attrib_2_Label__c;
          ordLine.OrderLine_Attrib_3_Label__c = oli.CPQ_Attrib_3_Label__c;
          ordLine.OrderLine_Attrib_4_Label__c = oli.CPQ_Attrib_4_Label__c;
          ordLine.OrderLine_Attrib_5_Label__c = oli.CPQ_Attrib_5_Label__c;
          ordLine.OrderLine_Attrib_6_Label__c = oli.CPQ_Attrib_6_Label__c;
          ordLine.OrderLine_Attrib_7_Label__c = oli.CPQ_Attrib_7_Label__c;
          ordLine.OrderLine_Attrib_8_Label__c = oli.CPQ_Attrib_8_Label__c;
          ordLine.OrderLine_Attrib_9_Label__c = oli.CPQ_Attrib_9_Label__c;
          ordLine.OrderLine_Attrib_10_Label__c = oli.CPQ_Attrib_10_Label__c;
          
          ordLine.OrderLine_Attrib_1_Value__c = oli.CPQ_Attrib_1_Value__c;
          ordLine.OrderLine_Attrib_2_Value__c = oli.CPQ_Attrib_2_Value__c;
          ordLine.OrderLine_Attrib_3_Value__c = oli.CPQ_Attrib_3_Value__c;
          ordLine.OrderLine_Attrib_4_Value__c = oli.CPQ_Attrib_4_Value__c;
          ordLine.OrderLine_Attrib_5_Value__c = oli.CPQ_Attrib_5_Value__c;
          ordLine.OrderLine_Attrib_6_Value__c = oli.CPQ_Attrib_6_Value__c;
          ordLine.OrderLine_Attrib_7_Value__c = oli.CPQ_Attrib_7_Value__c;
          ordLine.OrderLine_Attrib_8_Value__c = oli.CPQ_Attrib_8_Value__c;
          ordLine.OrderLine_Attrib_9_Value__c = oli.CPQ_Attrib_9_Value__c;
          ordLine.OrderLine_Attrib_10_Value__c = oli.CPQ_Attrib_10_Value__c;
                    
          ordline.auto_renew__c=oli.auto_renew__c;
          
          //MRodr Case 01877853
          ordLine.Renewal_Margin_Split__c = oli.Renewal_Margin_Split__c;
          ordLine.New_Business_Margin_Split__c = oli.New_Business_Margin_Split__c;
            
          ordLine.Rank__c = oli.Rank__c; // EC:: 02462677

          //W-019873 EDQ CPQ New Fields to order Line
          ordLine.Advocacy__c = oli.Advocacy__c;
          ordLine.Container_Category__c = oli.Container_Category__c;
          ordLine.CPQ_Segment__c = oli.CPQ_Segment__c;
          ordLine.Customer_Application_Version__c=oli.Customer_Application_Version__c;
          ordLine.Delivery_Variant__c = oli.Delivery_Variant__c;
          ordLine.DRMID__c = oli.DRMID__c;
          ordLine.Edition__c = oli.Edition__c;
          ordLine.EDQ_Integration_Solution_Version__c    = oli.EDQ_Integration_Solution_Version__c; 
          ordLine.Minimum_of_Days__c = oli.Minimum_of_Days__c;
          ordLine.Package__c = oli.Package__c;
          ordLine.ProspectIQ_Pricing_Tool_Unique_ID__c = oli.ProspectIQ_Pricing_Tool_Unique_ID__c;
          ordLine.Use_Case__c = oli.Use_Case__c;
          ordLine.Variation__c = oli.Variation__c;
          ordLine.Case_Study_Concession__c = oli.Case_Study_Concession__c;
          ordLine.Commercial_Approval__c = oli.Commercial_Approval__c;
          ordLine.Product_Lifecycle__c = oli.Product_Lifecycle__c;
          ordLine.Transaction_Rate__c = oli.Transaction_Rate__c;
          ordLine.Price_Type__c = oli.Quote_Item_Type__c;
          ordLine.Deferred_Revenue__c =oli.Deferred_Revenue__c;
          ordline.CPQ_Add_on__c = oli.CPQ_Add_on__c;
          ordline.All_Other_Attr__c= oli.All_Other_Attr__c;

          // Added by Akash- W-019940
          ordLine.Payment_Method__c = oli.Payment_Method_formula__c;
          ordLine.Installments_Splits__c = oli.Installments_Splits_formula__c;
          ordLine.Installment_Interval__c = oli.Installment_Interval_formula__c;
          ordLine.Payment_Options__c = oli.Payment_Options_formula__c;
            
          // Added by Herbert Oliveira - 
          ordLine.Upsell__c = oli.Upsell__c;

          orderLineItemList.add(ordLine);
        }
      }
      //Insert of Order Line Items
      if (orderLineItemList.size() > 0) {
          
        OrderLineItemTriggerHandler.skipTriggerLogic = true;
        insert orderLineItemList;
        OrderLineItemTriggerHandler.skipTriggerLogic = false;
          
        for (Order_Line_Item__c oLine : orderLineItemList) {
          if (!oliId_ordLIMap.containsKey(oLine.Opportunity_Line_Item_Id__c)) {
            oliId_ordLIMap.put(oLine.Opportunity_Line_Item_Id__c, oLine);
          }
        }
        if (oliId_ordLIMap.size() > 0) {
          return oliId_ordLIMap;
        }
      }
    } catch (DMLException e) {
        if (oppList.size() == 1) {
                System.debug('inside catch to insert apex log###');
            ApexLogHandler.createLogWithRecordId('OpportunityTrigger_CreateOrder','createOrderLines', e.getMessage(), e, opptyID_order.get(oppList[0].Id).Id, true);    
        } else {
            ApexLogHandler.createLogAndSendEmail('OpportunityTrigger_CreateOrder','createOrderLines', e.getMessage(), e);    
        }
        system.debug('[OpportunityTrigger_OrderHelper: createOrderLines]: ['+e.getMessage()+']]');
      for (Integer i=0; i<e.getNumDml(); i++) {
        system.debug('\n'+ Label.OPPTY_Error_in_Order_Line_Creation + e.getDMLMessage(i));
      }
      // 21669549 and 21906469 Retry framework 
    } finally {
        System.debug('inside finally***');
        List<Apex_Log__c> apxloglist = new List<Apex_Log__c>();
        apxloglist = [Select Id, RecordId__c, Retry_Flag__c, Retry_Type__c, Message__c, Retry_Status__c 
                      from Apex_Log__c 
                      where class_name__c='OpportunityTrigger_CreateOrder' 
                      and method_name__c='createOrderLines' 
                      and RecordId__c =: opptyID_order.get(oppList[0].Id).Id];
                  
        if(!apxloglist.isEmpty()) {
            System.debug('inside finally if - log not empty########'+apxloglist);
            finallyMethod(apxloglist);
        } else {
            //HO Begin Case 21897332
            System.debug('inside finally else - log is empty########'+apxloglist);
            if (oliId_ordLIMap.size() > 0) {
                return oliId_ordLIMap;
            }
            // HO End Case 21897332
        }
    }
    return oliId_ordLIMap;
  }
  // 21669549 and 21906469 Retry framework   
  public static Map<Id, Order_Line_Item__c> finallyMethod(List<Apex_log__c> newlist){
    
    Map<Id, Order_Line_Item__c> odrLiMap = new Map<Id, Order_Line_Item__c>();
    List<Apex_log__c> apxLogList = new List<Apex_log__c>();
    for(Apex_log__c apxlogobj : newlist){
            System.debug('inside finally method - for statement#########'+apxlogobj);
      if(apxlogobj.Retry_Flag__c == true && apxlogobj.Message__c.contains('unable to obtain exclusive access to this record')){
        apxlogobj.Retry_Flag__c = false;
        apxlogobj.Retry_Type__c = 'Retry';
        apxlogobj.Retry_Status__c = 'Success';
            System.debug('inside finally general method under for statement if retry flag is true set as false #### '+apxlogobj.Retry_Flag__c);
        apxLogList.add(apxlogobj);    
        }else if(!apxlogobj.Message__c.contains('unable to obtain exclusive access to this record')) {
            apxlogobj.Retry_Type__c = 'Notification';
            apxLogList.add(apxlogobj);
        }         
    }
    if(!apxLogList.isEmpty())
      update apxLogList;
          System.debug('inside finally method - update logrecord to set Flag as false ##########'+apxLogList);

    Set<Id> odrIds = new  Set<Id>();
    for(Apex_log__c apxLobj : apxLogList) {
      odrIds.add(apxLobj.RecordId__c);
    }
    List<Order_Line_Item__c> oliList = [Select Id From Order_Line_Item__c where Order__c =: odrIds];
    for(Order_Line_Item__c oliObj : oliList){
      if(!odrLiMap.containsKey(oliObj.Id))
        odrLiMap.put(oliObj.Id,oliObj);
    }
    return odrLiMap;  
  }
   
  //============================================================================================
  //To create order revenue schedules form Opportunity line items
  // PK: Case 01126362 - Adding for batching order line updates per order
  //============================================================================================
  /*MR Replaced
  public static void createRevenueSchedules (Map<ID, Order_Line_Item__c> oliId_ordLIMap) {
    // List<Order_Revenue_Schedule__c> ordRevenueList = new List<Order_Revenue_Schedule__c>();
    // Order_Revenue_Schedule__c ordRevenue;
    // Map<Id,Integer> oliIDtoRevCountMap = new Map<Id,Integer>();
    Map<Id,List<Order_Revenue_Schedule__c>> oliIDtoRevList = new Map<Id,List<Order_Revenue_Schedule__c>>();
    try {
      if (oliId_ordLIMap.keySet().size() > 0) {
        for (OpportunityLineItemSchedule olis : [SELECT o.ScheduleDate, o.Revenue, 
                                                        o.OpportunityLineItemId, o.Id, 
                                                        o.Description, CurrencyIsoCode
                                                 FROM OpportunityLineItemSchedule o
                                                 WHERE OpportunityLineItemId IN : oliId_ordLIMap.keySet()]) {
          Id orderLineItemId = oliId_ordLIMap.get(olis.OpportunityLineItemId).ID;
          Order_Revenue_Schedule__c ordRevenue = new Order_Revenue_Schedule__c();
          ordRevenue.CurrencyIsoCode      = olis.CurrencyIsoCode;
          ordRevenue.Comment__c           = olis.Description;
          ordRevenue.Order_Line_Item__c   = orderLineItemId;
          ordRevenue.Revenue__c           = olis.Revenue;
          ordRevenue.Scheduled_Date__c    = olis.ScheduleDate;
          ordRevenue.RecordTypeId         = orderScheduleRT_ID;
          if (!oliIDtoRevList.containsKey(orderLineItemId)) {
            oliIDtoRevList.put(orderLineItemId, new List<Order_Revenue_Schedule__c>());
          }
          List<Order_Revenue_Schedule__c> tmpOrderScheduleList = oliIDtoRevList.get(orderLineItemId);
          tmpOrderScheduleList.add(ordRevenue);
          oliIDtoRevList.put(orderLineItemId,tmpOrderScheduleList);
        }

        //Insert order revenue schedules
        if (oliIDtoRevList.size() > 0) {
          List<Order_Revenue_Schedule__c> toInsert = new List<Order_Revenue_Schedule__c>();
          // creating customised insertion batching to prevent updates due to crossover of order line item records (prevents too many soql error)
          Integer splitCount = 200; // PK: This is the Salesforce trigger block processing limit
          Integer currentCount = 0;
          for(Id orderLineItemId : oliIDtoRevList.keySet()) {
            if (currentCount + oliIDtoRevList.get(orderLineItemId).size() > splitCount) {
              // build new list to insert....
              insert toInsert;
              toInsert.clear();
              toInsert.addAll(oliIDtoRevList.get(orderLineItemId));
              currentCount = oliIDtoRevList.get(orderLineItemId).size();
            }
            else {
              currentCount += oliIDtoRevList.get(orderLineItemId).size();
              toInsert.addAll(oliIDtoRevList.get(orderLineItemId));
            }
          }
          insert toInsert; // catch any not already inserted....     
          
        }
      }
    } 
    catch (DMLException e) {
      system.debug('[OpportunityTrigger_OrderHelper: createRevenueSchedules]: ['+e.getMessage()+']]');
      for (Integer i=0; i < e.getNumDml(); i++) {
        oliId_ordLIMap.values().get(0).addError('\n'+ Label.OPPTY_Error_in_Rev_Schedule_Creation +e.getDMLMessage(i));
      }
    }
  }
*/
  // MR Added
   public static void createRevenueSchedules (Map<ID, Order_Line_Item__c> oliId_ordLIMap) {
    // List<Order_Revenue_Schedule__c> ordRevenueList = new List<Order_Revenue_Schedule__c>();
    // Order_Revenue_Schedule__c ordRevenue;
    // Map<Id,Integer> oliIDtoRevCountMap = new Map<Id,Integer>();
    Map<Id,List<Order_Revenue_Schedule__c>> oliIDtoRevList = new Map<Id,List<Order_Revenue_Schedule__c>>();
    
    
    list<Order_Revenue_Schedule__c> orsToInsert = new list<Order_Revenue_Schedule__c>();
    set<Order_Line_Item__c> ordLineItemUpdate = new set<order_line_item__c>();
    
     List<Order_Revenue_Schedule__c> orsToDelete = new List<Order_Revenue_Schedule__c>();
     
    /*if(orderScheduleRT_ID== Null){//IFRS15:15673016 - Value not set if method called externally.
      orderScheduleRT_ID = DescribeUtility.getRecordTypeIdByName(Constants.SOBJECT_ORDER_REVENUE_SCHEDULE, Label.OPPTY_TYPE_READ_ONLY);
      
      //Need to build this list as the keyset for the Map holds values for OpportunityLineItems and not Order_Line_Items__c
      List<Id> olisID_List = new List<Id>();
      for(Order_Line_Item__c oli : oliId_ordLIMap.values()){
        olisID_List.add(oli.Id);
      }      
      orsToDelete = [SELECT id, Order_Line_Item__c, Order_Line_Item__r.Opportunity_Line_Item_Id__c 
                     FROM Order_Revenue_Schedule__c 
                     WHERE Order_Line_Item__c IN :olisID_List AND Order_Line_Item__r.Opportunity_Line_Item_Id__c!= Null];
    }//IFRS15:15673016*/
     
    try {
      if (oliId_ordLIMap.keySet().size() > 0) {
        for (OpportunityLineItemSchedule olis : [SELECT Id, ScheduleDate, Revenue, 
                                                        OpportunityLineItemId, 
                                                        Description, CurrencyIsoCode
                                                 FROM OpportunityLineItemSchedule
                                                 WHERE OpportunityLineItemId IN : oliId_ordLIMap.keySet()]) {
          Id orderLineItemId = oliId_ordLIMap.get(olis.OpportunityLineItemId).ID;
          Order_Line_Item__c ordLinetoUdpdate = oliId_ordLIMap.get(olis.OpportunityLineItemId);
          
          Order_Revenue_Schedule__c ordRevenue = new Order_Revenue_Schedule__c();
          //ordRevenue.CurrencyIsoCode      = olis.CurrencyIsoCode;  //commented out 15660309
          ordRevenue.CurrencyIsoCode      = ordLinetoUdpdate.CurrencyIsoCode; //15660309
          ordRevenue.Comment__c           = olis.Description;
          ordRevenue.Order_Line_Item__c   = orderLineItemId;
          ordRevenue.Revenue__c           = olis.Revenue;
          ordRevenue.Scheduled_Date__c    = olis.ScheduleDate;
          ordRevenue.RecordTypeId         = orderScheduleRT_ID;
          
          orsToInsert.add(ordRevenue);
          system.debug('DEBUG: ' + orsToInsert.size());
          //commented out 15660309
          /*ordLinetoUdpdate.Recalculate_Sales_Price__c =true;
          ordLineItemUpdate.add(ordLinetoUdpdate);*/
          
          
        }
        if(orsToInsert.size() > 0){
          OrderRevenueScheduleTriggerHandler.skipTriggerLogic=true;                   
          
          insert orsToInsert;
          
          //if(!orsToDelete.isEmpty()){//IFRS15:15673016 - delete Order_Revenue_Schedule__c records for Order_Line_Items__c being re-assessed. 
          //  delete orsToDelete;
          //}          
          
          OrderRevenueScheduleTriggerHandler.skipTriggerLogic=false;
        }
        //commented out 15660309
        /*if(ordLineItemUpdate.size() >0){
          list<Order_Line_Item__c> oliupdate= new list<Order_Line_Item__c>();
          oliupdate.addall(ordLineItemUpdate);
          update oliupdate;
        }*/
        
      }  
         
    } 
    catch (DMLException e) {
      ApexLogHandler.createLogAndSendEmail('OpportunityTrigger_CreateOrder','createRevenueSchedules', e.getMessage(), e);
        system.debug('[OpportunityTrigger_OrderHelper: createRevenueSchedules]: ['+e.getMessage()+']]');
      for (Integer i=0; i < e.getNumDml(); i++) {
        oliId_ordLIMap.values().get(0).addError('\n'+ Label.OPPTY_Error_in_Rev_Schedule_Creation +e.getDMLMessage(i));
      }
    }
  }

  //============================================================================================
  // Will delete related Orders and Opportunities if the lead Opportunity is reopened
  // Only goes one level, meaning if the Opp is reopened, it will delete all Orders and all Opps
  // related to that reopened opp, but not orders of the opp linked to the reopened opp.
  //============================================================================================
  //T-260145: delete related orders and related renewal opportunites for reopened opportunities
  public static void deleteOrderAndOppIfOppIsReopened(Map<ID, Opportunity> newMap, Map<ID, Opportunity> oldMap) {
    Set<Id> oppIds = new Set<Id>();
    Set<Id> relatedOpptyIDs = new Set<Id>();
    Map<String, Opportunity> opptiesToDelMap = new Map<String, Opportunity>();
    List<Opportunity> opptyListToDelOrders = new List<Opportunity>();
    List<Account_Plan_Opportunity__c> accPlanOppsToDel = new List<Account_Plan_Opportunity__c>();////As per task T-327046
    List<Order__c> orderToDelete = new List<Order__c>();
    
    for (Opportunity opp: newMap.values()) {
      // If opp is reopened
      if ((opp.isClosed == false && oldMap.get(opp.Id).isClosed == true) && 
            (opp.IsWon == false && oldMap.get(opp.Id).IsWon == true)) {
        oppIds.add(opp.Id);
        opptyListToDelOrders.add(opp);
      }
    }
    //Fetching related renewal opportunities to delete
    for (Opportunity oppty : [SELECT ID, Previous_Opportunity__c,
                                     (Select Id From Account_Plan_Opportunity__r),
                                     (Select Id From Orders__r) 
                              FROM Opportunity
                              WHERE Previous_Opportunity__c IN: oppIds
                              AND Type =: Constants.OPPTY_TYPE_RENEWAL]) {
      opptiesToDelMap.put(oppty.ID, oppty);
      
      //As per task T-327046
      if (oppty.Account_Plan_Opportunity__r.size() > 0) {
        accPlanOppsToDel.addAll(oppty.Account_Plan_Opportunity__r);
      }
      if (oppty.Orders__r.size() > 0) {
        orderToDelete.addAll(oppty.Orders__r);
      }
      //opptyListToDelOrders.add(oppty); NLG - "Do not cater for the deletion of an order on a renewal opportunity" per Luke Mar 21st, 2014 (from daily demo)
    }
    //System.assertEquals('===.>'+accPlanOppsToDel, '****'+opptiesToDelMap.values());
    //Deleting orders and opportunities
    if (opptyListToDelOrders.size() > 0) {
      try {
        //As per task T-327046
        if (accPlanOppsToDel.size() > 0) {
          delete accPlanOppsToDel;
        }
        if (orderToDelete.size() > 0) {
          delete orderToDelete;
        }
        deleteExistingOrders(opptyListToDelOrders);
        delete opptiesToDelMap.values();
      } 
      catch (DMLException e) {
        ApexLogHandler.createLogAndSendEmail('OpportunityTrigger_CreateOrder','deleteOrderAndOppIfOppIsReopened', e.getMessage(), e);
        for (Integer i=0; i < e.getNumDml(); i++) {
          newMap.values().get(0).addError(Label.OPP_ERROR_DELETING_ORDER);
        }
      }
    }
  }
}