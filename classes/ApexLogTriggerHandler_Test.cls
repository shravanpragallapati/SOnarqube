/**=====================================================================
 * Name: ApexLogTriggerHandler_Test 
 * Description: 
 * Created Date: Feb 18th, 2021
 * Created By: Rohit Aryan
 * 
 * Jul 19th 2021		Herbert Oliveira		W-033420: Update to cover code change in OpportunityTrigger_CreateOrder class 
=====================================================================*/

@isTest
public class ApexLogTriggerHandler_Test {
    @isTest
    public static void test_retrymethod(){
        
        Account testAccount = Test_Utils.insertAccount();
        
        List<Opportunity> opplist = new List<Opportunity>();
        Opportunity testOpp = Test_Utils.insertOpportunity(testAccount.Id);
        opplist.add(testOpp);
        
        Product2 product = Test_Utils.insertProduct();
        PricebookEntry stdPricebookEntry = Test_Utils.insertPricebookEntry(product.Id, Test.getStandardPriceBookId(), Constants.CURRENCY_USD);
        
        List<OpportunityLineItem> opptylilist = new List<OpportunityLineItem>();
        OpportunityLineItem opportunityLineItem1 = Test_Utils.createOpportunityLineItem(testOpp.Id, stdPricebookEntry.Id, testOpp.Type);
        opportunityLineItem1.Start_Date__c = Date.today().addDays(5);
        opportunityLineItem1.End_Date__c = System.today().addDays(10);
        insert opportunityLineItem1;
        opptylilist.add(opportunityLineItem1);
        
        Contact newcontact = new Contact(
            FirstName = 'Larry', 
            LastName = 'Ellison',
            AccountId = testAccount.Id, 
            //SaaS__c = true,
            Email = 'larrye@email.com',
            Title = 'Test'      
        );
        insert newcontact;
        
        Retry_Mechanism_Counter__c retry = new Retry_Mechanism_Counter__c();
        retry.Name = 'CountVal';
        retry.RetryCount__c = 3;
        insert retry;
        
        Order__c odr = Test_Utils.insertOrder(true, testAccount.Id, newcontact.Id, testOpp.Id);
        
        Test.StartTest();
            List<OpportunityLineItem> oppLines = [SELECT ID, Billing_Product__c, PricebookEntry.Product2Id, Start_Date__c, CPQ_Discount__c, Description, 
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
                                      WHERE OpportunityID IN: oppList];
            Opportunitytrigger_CreateOrder.opptyLineList = oppLines;
            
            List<Apex_Log__c> apxLogList = new List<Apex_Log__c>();
            Apex_Log__c apxLog = new Apex_Log__c(
                class_name__c ='OpportunityTrigger_CreateOrder',
                method_name__c = 'createOrderLines',
                RecordId__c = odr.Id,
                Message__c = 'The following system error generated while processing.unable to obtain exclusive access to this record or 1 records:',
                Retry_Flag__c = true
            );
            apxLogList.add(apxLog);
            insert apxLogList;
        Test.StopTest();
         
    }
}