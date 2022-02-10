/**=====================================================================
* Appirio, Inc
* Name: OpportunityStageIndicatorHelper
* Description: 
* Created Date: January 2014 (reused from topCoder challenge)
* Created By: Nathalie Le Guay (Appirio)
* 
* Date Modified                Modified By                  Description of the update
* Jan 30th, 2014               Jinesh Goyal(Appirio)        T-232760: Homogenize the comments
* Feb 13th, 2014               Jinesh Goyal(Appirio)        T-232763: Added Exception Logging
* Feb 22th, 2014               Naresh kr Ojha (Appirio)     T-251145: updated to remove ref Has_Completed_Task__c
* Feb 27th, 2014               Nathalie Le Guay (Appirio)   Class cleanup
* March 3rd, 2014              Nathalie Le Guay             Updated opp query
* Apr 15th, 2014               Arpita Bose (Appirio)        T-271695: Removed reference to Below_Review_Thresholds__c field
* Apr 16th, 2014               Arpita Bose (Appirio)        T-271695: Renamed fields Has_Stage_4_Approval__c to Has_Stage_3_Approval__c 
*                                                           and Has_Stage_5_Approval__c to Has_Senior_Approval__c
* Apr 16th, 2014               Nathalie Le Guay             T-272404: Adding Approval Process fields to Opportunity query
* Jul 28th, 2014               Nathalie Le Guay             S-252919 - Added Outcomes__c to the Opp query (constructor)
* Nov 13th, 2014               Arpita Bose                  T-333541 - Added method edqUKIUser()
* Mar 18th, 2015               Paul Kissick                 Case #591965 - Fix for Chinese not rendering properly.
* Sep 23rd, 2015               Paul Kissick                 I-181512 - Fixes for translated picklists to work correctly
* Feb 25th, 2016               Paul Kissick                 Case 01872263: Fixed query to return archived tasks
* Apr 5th, 2016                Paul Kissick                 Case 01028611: Adding new requirement to stage 4
* Aug 9th, 2016                Paul Kissick                 CRM2:W-005495: Removing fields no longer used
* Aug 16th, 2016               Paul Kissick                 CRM2:W-005534: Adding support for clicking the stages and updating the stage
* Oct 26th, 2017               Malcolm Russell              DP Migration:W-009619: Adding Booleans for Buy To and Admin Contact Roles
* Oct 27th, 2017               Malcolm Russell              DP Migration:W-009618: DP specific approvals required
* Nov 15th, 2017               Diego Olarte                 Case 12880367: New check for UK&I MS Data Quality and UK&I MS Targeting for TCV of 100000
* Feb 20th, 2018               Malcolm Russell              Case 14818841 : make conflit of interest required for UK&I opp owners
* May 30th, 2018               Malcolm Russell              Case 16166194 : DP Admin contact not allways required 
* Nov 18th, 2019               Vaibhav Athikam              I4173 : AuraEnabled variables to reuse them and constructor for Lightning purpose
* Feb 14th, 2020               Mauricio Murillo             Case 19721399: Added new Revenue_Information_Confirmed__c field
* Jul 08th, 2021               Rohit Aryan                  Case 22227844 - W-033337 : Add Integration Parter boolean value
=====================================================================*/
public without sharing class OpportunityStageIndicatorHelper {
    @AuraEnabled  
    public Opportunity opp {get;set;}
    @AuraEnabled  
    public List<wrapperStage> lstStages {get;set;}
    @AuraEnabled  
    public Boolean hasContactRole {get;set;}
    @AuraEnabled  
    public Boolean hasBuyToContactRole {get;set;}
    @AuraEnabled  
    public Boolean hasAdminContactRole {get;set;}
    @AuraEnabled  
    public Boolean DPProdAdminReq {get;set;}
    @AuraEnabled  
    public Boolean hasCompletedTask {get;set;}
    @AuraEnabled  
    public Boolean DPStage3ApprovalRequired {get;set;}
    @AuraEnabled  
    public Boolean OpptyIntPartner {get;set;}
    @AuraEnabled 
    public Integer NUM_500000 {get;set;}
    @AuraEnabled 
    public Integer NUM_250000 {get;set;}
    @AuraEnabled 
    public Integer NUM_100000 {get;set;} // DO: Case#12880367
    
    @AuraEnabled  
    public String newStage {get;set;}
    @AuraEnabled  
    public Boolean reloadPage {get{if(reloadPage == null) reloadPage = false; return reloadPage;}set;}
    
    public PageReference changeStageTo() {
        if (String.isNotBlank(newStage) && opp.IsClosed == false) {
            if (newStage != Constants.OPPTY_STAGE_7) {
                opp.StageName = newStage;
                try {
                    update opp;
                    reloadPage = true;
                }
                catch (Exception e) {
                    system.debug(e);
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                    // PK: Not displaying because its done my the trigger!
                }
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.OECS_Change_to_Execute_Below));
            }
        }
        return null;
    }
    
    /*
*   Constructor taking standard controller as a parameter
*/
    public OpportunityStageIndicatorHelper(ApexPages.StandardController controller) {
        NUM_500000 = Integer.valueOf(Label.NUM_500000);
        NUM_250000 = 250000; // TODO: Make label?
        NUM_100000 = 100000; // DO: Case#12880367
        if (!String.isBlank(controller.getId())) {
            Set<String> allowedStages = new Set<String>();
            
            for (Opportunity_Sales_Process__c osp : [SELECT Sales_Process_Name__c, Name
                                                     FROM Opportunity_Sales_Process__c
                                                     WHERE Sales_Process_Name__c =: Constants.OPPTY_SALES_PROCESS_STANDARD]) {
                                                         allowedStages.add(osp.Name);
                                                     } 
            // PK Case 01872263: Fixed query to return archived tasks
            opp = [SELECT Id, Turn_Off_Contact_Role_Criteria_Check__c, toLabel(StageName), Starting_Stage__c, Has_Stage_3_Approval__c, CampaignId,
                   //Below_Review_Thresholds__c,  T-271695: Removed reference to Below_Review_Thresholds__c field
                   Opportunity_Products_Count__c, Has_Senior_Approval__c, Senior_Approver__c, Auto_Renewed__c, Recurring_Incremental__c,
                   Competitor_Count__c, Amount, Budget__c, isClosed, Owner.Region__c, Owner.CPQ_User__c, Quote_Count__c, Selection_confirmed_date__c,
                   /* Is_There_Commercial_Risk__c, Is_There_Delivery_Risk__c,
Is_There_Financial_Risk__c, Is_There_Legal_Risk__c,  
Has_There_Been_Significant_Change__c,*/ IsWon, Stage_3_Approver__c, OwnerId, Received_signed_contract_date__c, Revenue_Information_Confirmed__c,
                   Tech_Support_Maintenance_Tiers__c, Type, DP_Qualify_Approval__c,Deal_Category__c, Quote_delivered_date__c, 
                   Owner_s_Business_Unit__c, Risk_Tool_Output__c, Risk_Tool_Output_Code__c, // CRM2:W-005495,
                   Amount_Corp__c, //MR DP Migration:W-009618: DP specific approvals required
                   Conflict_of_Interest__c, //Case 14818841 
                   (SELECT Id, Type_of_Sale__c, PricebookEntry.Product2.Global_Business_Line__c, PricebookEntry.Product2.Business_Line__c, PricebookEntry.Product2.Types_of_Sale__c,
                    PricebookEntry.Product2.Name,DP_Product_Package_Code__c //16166194
                    FROM OpportunityLineItems WHERE IsDeleted = false),
                   (SELECT Id, Role, IsPrimary FROM OpportunityContactRoles WHERE (Role =: Constants.DECIDER AND IsDeleted = false) 
                    OR (Role =: Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER AND IsDeleted = false) OR (Role =: Constants.OPPTY_CONTACT_ROLE_ADMIN AND IsDeleted = false)),
                   (SELECT Id, Type, Status, Outcomes__c
                    FROM Tasks WHERE Status =: Constants.STATUS_COMPLETED AND IsDeleted = false)
                   FROM Opportunity
                   WHERE Id = :controller.getId() ALL ROWS];
            String sObjectName = controller.getRecord().getSObjectType().getDescribe().getName();
            lstStages = new List<wrapperStage>();
            
            //MR DP Migration:W-009619: Adding Booleans for Buy To and Admin Contact Roles
            //hasContactRole = opp.OpportunityContactRoles.size() > 0;
            hasContactRole=false;
            hasBuyToContactRole=false;
            hasAdminContactRole=false;
            
            // 16166194 START
            DPProdAdminReq=false; 
            Map <string,DP_No_Admin_Required__c> mapDPNoAdmin = DP_No_Admin_Required__c.getAll(); 
            set<string> setDPNoAdmin = new set<string>(); // 16166194
            
            for(DP_No_Admin_Required__c DPno : mapDPNoAdmin.values()){   
                string key = DPno.Product_Name__c+DPno.DP_Package_Code__c;
                setDPNoAdmin.add(key); 
                system.debug('cs key:::' + key);
            }
            if (opp.OpportunityLineItems.size() > 0 ){
                for(OpportunityLineItem oli : opp.OpportunityLineItems){
                    
                    Product2 p = oli.PriceBookEntry.Product2;
                    string key = p.name + oli.DP_Product_Package_Code__c;
                    system.debug('oli key:::' + key);
                    system.debug('setDPNoAdmin:::' +setDPNoAdmin);
                    if(!setDPNoAdmin.contains(key)){
                        
                        DPProdAdminReq = true;  
                        system.debug(' DPProdAdminReq:::' +  DPProdAdminReq);
                    }
                    
                }
            }
            // 16166194 END

            //22227844 : Adding Integration Partner Boolean
            List<OpportunityPartner> oppPartnerList = [Select Id from OpportunityPartner where OpportunityId =: opp.Id];
            if(!oppPartnerList.isEmpty()){
                OpptyIntPartner = true;
            }
            
            if(opp.OpportunityContactRoles.size() > 0){
                
                for (OpportunityContactRole ocr : opp.OpportunityContactRoles){
                    if (ocr.role == Constants.DECIDER) {hasContactRole = true;}
                    if (ocr.role == Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER) {hasBuyToContactRole = true;}
                    if (ocr.role == Constants.OPPTY_CONTACT_ROLE_ADMIN) {hasAdminContactRole = true;}
                }
                
            }
            
            //MR DP Migration:W-009618: DP specific approvals required
            If(opp.Amount_Corp__c >=15000 && (opp.type=='New from New' || opp.type=='New from Existing')){
                DPStage3ApprovalRequired=true;
            }
            
            hasCompletedTask = opp.Tasks.size() > 0;
            Schema.DescribeFieldResult f = Schema.sObjectType.Opportunity.fields.StageName;
            // Get the field describe result from the token
            f = f.getSObjectField().getDescribe();
            List <Schema.PicklistEntry> picklistValues = f.getPicklistValues();  
            System.debug('----allowedStages---'+allowedStages);
            for (Integer x = 0; x < picklistValues.size(); x++) {
                //if (!pickListValuesToRemove.contains(picklistValues[x].getLabel().toLowerCase())) {  // PK Case #591965 - Removed as this seems pointless
                System.debug('=======>'+picklistValues[x].getLabel());
                if (allowedStages.contains(picklistValues[x].getValue())) {  // PK Case #591965 - Changed to value.
                    lstStages.add(new wrapperstage(picklistValues[x].getLabel(), picklistValues[x].getValue())); // PK I-181512 - Store both system and translated picklist values
                }
                //}
            }
            
            for (Integer i = 0; i < lstStages.size(); i++) {
                if (opp.StageName == lstStages[i].strStageName) {
                    lstStages[i].bolCompleted = true;
                    lstStages[i].bolCurrent = true;
                    if (i > 1) {
                        lstStages[i - 1].bolCurrent = false;
                    }
                    break;
                } 
                else if (opp.IsClosed && !opp.IsWon) { // I-181512 Checking for not won instead of against constant // == Constants.OPPTY_CLOSED_LOST) { 
                    lstStages[i].bolCompleted = false;
                    break;
                } 
                else {
                    lstStages[i].bolCompleted = true;
                }
            }
        }
    }
    
    //=============================================================
    // Booleans used by the VF page for one of the Exit Criteria
    //=============================================================
    @AuraEnabled
    public Boolean hasSignedContract {
        get {
            if (hasSignedContract == null && opp != null) {
                hasSignedContract = Opportunity_ExitCriteriaUtility.hasRequiredTask(opp, Constants.ACTIVITY_TYPE_SIGNED_CONTRACT);
            }
            return hasSignedContract;
        }
        set;
    }
    @AuraEnabled
    public Boolean hasSelectionConfirmed {
        get {
            if (hasSelectionConfirmed == null & opp != null) {
                hasSelectionConfirmed = Opportunity_ExitCriteriaUtility.hasRequiredTask(opp, Constants.ACTIVITY_TYPE_SELECTION_CONFIRMED);
            }
            return hasSelectionConfirmed;
        }
        set;
    }
    @AuraEnabled
    public Boolean hasQuoteDelivered {
        get {
            if (hasQuoteDelivered == null && opp != null) {
                hasQuoteDelivered = Opportunity_ExitCriteriaUtility.hasRequiredTask(opp, Constants.ACTIVITY_TYPE_QUOTE_DELIVERED);
            }
            return hasQuoteDelivered;
        }
        set;
    }
    @AuraEnabled
    public Boolean hasTechSuppFieldRequirement {
        get {
            if (hasTechSuppFieldRequirement == null) {
                hasTechSuppFieldRequirement = Opportunity_ExitCriteriaUtility.hasTechSuppFieldRequired(opp);
            }
            return hasTechSuppFieldRequirement;
        }
        set;
    }
    
    /*
*   Wrapper class 
*/
    public class wrapperStage {
        public string strStageName {get;set;}
        public string sysStageName {get;set;}
        public boolean bolCompleted {get;set;}
        public boolean bolCurrent {get;set;} 
        public wrapperStage(string y, String x) {
            strStageName = y; 
            sysStageName = x;
        }
    }
    
    //=================================================================================
    // T-333541: UK&I Exit Criteria: Approvals exit criteria do not apply to EDQ Users
    //=================================================================================
    
    public Boolean edqUKIUser {
        get {
            edqUKIUser = false;
            User currentUser = [SELECT Id,Region__c 
                                FROM User
                                WHERE Id = : opp.OwnerId];
            String groupName = BusinessUnitUtility.getBusinessUnit(userinfo.getUserId()) ;
            if (String.isNotBlank(groupName) && 
                groupName.equalsIgnoreCase(Constants.EDQ) && 
                currentUser.Region__c == Constants.REGION_UKI) {
                    edqUKIUser = true;
                }
            return edqUKIUser;
        }
        set;
    }
    
}