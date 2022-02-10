/**===========================================================================================================
 * Appirio, Inc
 * Name: Opportunity_ExitCriteriaUtility.cls
 * Description: T:235320: Exit criteria for Opportunities
 * Created Date: 02/07/2014
 * Created By: Naresh Kr Ojha (Appirio)
 *
 * Date Modified      Modified By                  Description of the update
 * Feb 19th, 2014     Nathalie Le Guay (Appirio)   Created oppStagesAllowedMap & updated all
 *                                                 criteria check methods to simplify logic &
 *                                                 use CurrencyUtility class
 * Feb 22th, 2014     Naresh kr Ojha (Appirio)     T-251145: updated to remove ref Has_Completed_Task__c
 * Feb 25th, 2014     Nathalie Le Guay (Appirio)  Renamed checkPreviousStageNotMet() to isPassingRequiredExitCriteria()
 *                                                 Rewrote isPassingRequiredExitCriteria() + added oppStageNameToNumberMap
 *                                                 and oppStageNumberToNameMap
 *                                                 Removed duplicate calls to check exit criteria
 *                                                 Created isStage6ExitCriteriaMet()
 * Feb 26th, 2014     Nathalie Le Guay (Appirio)   Removing references to Selection_confirmed__c and Signed_Contract__c
 *                                                 and Task_Quote_Delivered__c
 * Feb 27th, 2014     Naresh Kr Ojha (Appirio)     Updated hasRequiredTask() method to use queried opportunities, as it can have Tasks on oppty
 *                                                 after querying them.
 * Feb 28th, 2014     Naresh kr Ojha (Appirio)     Fixed issue: I-103440
 * March 3rd, 2014    Nathalie Le Guay             Updated opp query
 * Mar 04th, 2014     Arpita Bose(Appirio)         T-243282: Added Constants in place of String
 * Mar 27th, 2014     Nathalie Le Guay             Adding debug statements
 * Mar 31st, 2014     Arpita Bose(Appirio)         T-267875: Removed reference to field Total_Annual_Amount__c and the validations for
 *                                                 Stage_4_to_5_Opportunity_Approval, Stage_4_to_5_AmountOrTAA_Over_Approval
 *                                                 and Stage_5_to_6_Opportunity_Approval
 * April 3rd, 2014    Mohit Parnami(Appirio)       T-266502: updated isMeetingExitCriteria method to use the constructor of currencyUtility
                                                   having parameter as set of ISO codes
 * Apr 15th, 2014     Arpita Bose                  T-271695: Removed reference to Below_Review_Thresholds__c field
 * Apr 15th, 2014     Nathalie Le Guay             T-265496: Removed Stage_4_Exit_Criteria_Met  and Stage_5_Exit_Criteria_Met logic
 * Apr 15th, 2014     Nathalie Le Guay             T-265496: Removed Stage_4_Exit_Criteria_Met in isStage4ExitCriteriaMet()
 *                                                 and Stage_5_Exit_Criteria_Met in isStage5ExitCriteriaMet()
 * Apr 16th, 2014     Arpita Bose                  T-271695: Renamed fields Has_Stage_4_Approval__c to Has_Stage_3_Approval__c
 *                                                  and Has_Stage_5_Approval__c to Has_Senior_Approval__c
 * May 21st, 2014     Nathalie Le Guay             Updated getOpportunitiesExitCriteriaNotMet() skipping stage section so that it doesnt apply in testing
 * Jul 28th, 2014     Nathalie Le Guay             S-252919 - Added Outcomes__c to the Opp query (getOpportunitiesExitCriteriaNotMet)
 * Sep 29th, 2014     Naresh Kr Ojha               T-323155: Free trial opportunity wont go through Oppty Exit criteria Validations, added check
 * Nov 11th, 2014     Noopur                       Added the conditions to check of the current user is EDQ and UK&I to bypass some of the criteria.
 * Jun 26th, 2015     Arpita Bose (Appirio)        T-413194: Added Custom Labels
 * Aug 13th, 2015     Naresh Kr Ojha               I-174978: Updated to fix issue Too Many SOQL.
 * Feb 25th, 2016     Paul Kissick                 Case 01872263: Fixed query to return archived tasks
 * Apr 5th, 2016      Paul Kissick                 Case 01028611: Adding checks to stage 4
 * Jul 20th, 2016     Manoj Gopu                   CRM2:W-005438 Commented out the code related to Opp Stages
 * Jul 28th, 2016     Cristian Torres              CRM2:W-005403: If a contact Role is no Longer with Company the Opportunity cannot be moved to Executed
 * Aug 1st, 2016      Paul Kissick                 CRM2: Fixed code formatting, which was somehow completely lost!
 * Aug 5th, 2016      Manoj Gopu                   CRM2:W-005438 Moved the Competetior check from Qualify to Propose And made it required
 * Aug 9th, 2016      Paul Kissick                 CRM2:W-005495: Removing fields no longer used, and adding new BU check on stage 4
 * Aug 9th, 2016      Diego Olarte                 CRM2:W-005496: Adding new error on check on stage 6 for making sure a Primary_Quote_has_been_Approved
 * Aug 10th, 2016     Paul Kissick                 CRM2:W-005495: Adding missing check of amount on exit stage 6 for UK&I
 * Aug 19th, 2016     Paul Kissick                 CRM2:W-005403: Adding label for Contacts not at company notification, and added constant
 * Sep 07th, 2016     Manoj Gopu                   CRM2:W-005438:  Updated the missing criteria error message for Opp Validation.
 * Sep 07th, 2016     Manoj Gopu                   CRM2:W-005421: Added a new error message for Transacational Order
 * Sep 14th, 2016     Diego Olarte                 CRM2:W-005496: Added new field CPQ_User_to_Validate__c to validate users based on the CPQ User Type for the new error on Quote Approval
 * Sep 28th, 2016     Manoj gopu                   CRM2:w-005949: Added Constants to Free trial and transactional sale Record types. 
 * Oct 03rd, 2016     Manoj Gopu                   CRM2:W-005938: Replaced the stage value ith stage label wherever error message is displayed.
 * Oct 14th, 2016     Paul Kissick                 Corrected code for getting the picklist labels, also named properly.
 * Nov 16th, 2016     Diego Olarte                 Case 02144295: Added additional evaluation to check for opp.Quote_Count__c == null, add a rule to include CPQ_User_to_Validate2__c and CPQ_User_to_Validate3__c to add additional CPQ Users to validate for a non BIS CPQ User and because only quote is required
 * Dec 05th, 2016     Manoj Gopu                   Case 02215771: Added a exception for product count and Competitor count for Partner Community Record type 
 * Oct 11th, 2017     Diego Olarte                 Case 13543302: Disabled Stage 3 Approver for UK&I opps over 500000.
 * Nov 15th, 2017     Diego Olarte                 Case 12880367: New check for UK&I MS Data Quality and UK&I MS Targeting
 * Apr 17th, 2018     Malcolm Russell              DP Migration : add code coverae for DP logic
 * Feb 20th, 2018     Malcolm Russell              Case 14818841 : make conflit of interest required for UK&I opp owners 
 * May 29th, 2018     Malcolm Russell              Case 16313036 : Ensure Decison Maker exists on Trans Opps for DP users
 * May 30th, 2018     Malcolm Russell              Case 16166194 : DP Admin contact nor allways required
 * Jan 18th, 2019     Malcolm Russell              Case 18320337 : Allow CPQ users to add product at Qualify stage
 * Jan 18th, 2019     Malcolm Russell              Case 17877595 : Allow CPQ users bypass CPQ for SOTI Opportunities
 * July 9th, 2019     Charlie Park                 Validation for NA Consumer EBA fields before execute
 * Aug 19th, 2019     Chaldrin Cruz                Deprecated Contracted_MRR__c, removed null check of Setup_Fee__c and Pre_Payment__c from isStage7Ready
 * Nov  8th, 2019     Mauricio Murillo             I-4173: Added new message for Classic or Lightning users stored in OECS_Check_Stage_Requirements label
 * Jan  7th, 2020     Mauricio Murillo             Case 19457481: Removed COMMIT stage from logic.  Also, commented out calls to checkQuoteApproved when moving to Contract
 *                                                 (so it only fires when moving to Execute.  This is based on chatter posts added in case 20132019
 * Feb 26th, 2020     Sunil Kumar                  Bypassed Validation for EBA Add Products Users custom setting
 * Jun 29th, 2020     Sunil Kumar                  Case - 20830009 EBA - Opty Close Validation Criteria
 * Mar 03rd, 2021     Sai Navya Yerrabelli         W-030686 To check the Customer profile is NA Customer
 * Mar 08th, 2021     Herbert Oliveira             W-029760: Updated API version to 51 to avoind issues when code is executed by Automated Process user (scheduled-trigger flow)
 * Mar 16th, 2021     Rohit Aryan                  W-031814 : Deal Category, Exit validations for NA Auto
 * Jun 11th, 2021     Sai Navya Yerrabelli         W-033293: UKI Targeting team to have access to Deal Category field for UK&I MS Targeting
 * Jun 11th, 2021     Pavani Jidagam               W-032331 :  APAC DA - Setting "Deal Category" field as required field for APAC DA ANZ
 * Jul 08th, 2021     Rohit Aryan                  22227844 - W-033337 : Add Integration Parter Validation while Exiting Qualify when Verify Product added to Oppty 
 ============================================================================================================*/
public with sharing class Opportunity_ExitCriteriaUtility {

  private static Boolean isCriteriaMet;
  public static String errorMessage;

  public static Map<String, String> stagePicklistLabels {get{
    if (stagePicklistLabels == null) {
      stagePicklistLabels = new Map<String, String>();
      for (Schema.PicklistEntry a : Opportunity.StageName.getDescribe().getPickListValues()) {
        stagePicklistLabels.put(a.getValue(),a.getLabel());
      }
    }
    return stagePicklistLabels;
  }set;}

  public static Map<String, Id> oppRecordTypeMap {get{
    if (oppRecordTypeMap == null) {
      oppRecordTypeMap = new Map<String, Id>();
      for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Opportunity']) {
        oppRecordTypeMap.put(rt.Name, rt.Id);
      }
    }
    return oppRecordTypeMap;
  }set;}

  public static User currentUser = [
    SELECT Id, Region__c, Profile.Name
    FROM User
    WHERE Id = :Userinfo.getUserId()
  ];
 
    //Start- To check the Customer profile is NA Customer --> Navya
    @TestVisible
    private Static Boolean isNACustomer{
        get{
            if(isNACustomer == null){
                String profileName = currentUser?.Profile?.Name;
                isNACustomer = profileName != null && profileName.contains('XPartner - NA Auto Sales Exec');
            }
            return isNACustomer;
        }
        set;
    }

    //End- To check the Customer profile is NA Customer --> Navya
    
  public static Boolean bypassTheCriteria;
    //CT removing the repeating message
  public static Boolean didCriteria6AlreadyRun = false;

  //Queried opportunities
  public static Map<String, Opportunity> opportunityMap;

  private static Map<String, Set<String>> oppStagesAllowedMap = new Map<String, Set<String>>{
    Constants.OPPTY_STAGE_3 => new Set<String>{Constants.OPPTY_STAGE_4},
    Constants.OPPTY_STAGE_4 => new Set<String>{Constants.OPPTY_STAGE_5, Constants.OPPTY_STAGE_3},
    Constants.OPPTY_STAGE_5 => new Set<String>{Constants.OPPTY_STAGE_6, Constants.OPPTY_STAGE_4, Constants.OPPTY_STAGE_3},
    Constants.OPPTY_STAGE_6 => new Set<String>{Constants.OPPTY_STAGE_7, Constants.OPPTY_STAGE_5, Constants.OPPTY_STAGE_4, Constants.OPPTY_STAGE_3}
  };

  public static Map<String, Integer> oppStageNameToNumberMap = new Map<String, Integer>{
    Constants.OPPTY_STAGE_3 => 3,
    Constants.OPPTY_STAGE_4 => 4,
    //Constants.OPPTY_STAGE_5 => 5, commented as commit stage is no more exists
    Constants.OPPTY_STAGE_6 => 5,
    Constants.OPPTY_STAGE_7 => 6
  };

  public static Map<Integer, String> oppStageNumberToNameMap = new Map<Integer, String>{
    3 => Constants.OPPTY_STAGE_3,
    4 => Constants.OPPTY_STAGE_4,
    //5 => Constants.OPPTY_STAGE_5, commented as commit stage is no more exists
    5 => Constants.OPPTY_STAGE_6,
    6 => Constants.OPPTY_STAGE_7
  };

  //============================================================================================
  // T-251412: Exit Criteria: Display error message if Exit Criteria of previous Stages not met
  //============================================================================================
  @Testvisible
  private static Boolean isPassingRequiredExitCriteria (Opportunity opp, String stageName, String oldStage,Opportunity newopp) {

    Boolean meetingCriteria = true;

    Integer startApplyingCriteriaStage = 3;

    system.debug('\n[Opportunity_ExitCriteriaUtility : isPassingRequiredExitCritria] : opp.Starting_Stage__c' + opp.Starting_Stage__c + ' oldStage' + oldStage);

    Integer startingStageNumber = oppStageNameToNumberMap.get(opp.Starting_Stage__c);
    Integer stageNumber = oppStageNameToNumberMap.get(stageName);
    Integer oldStageNum = oppStageNameToNumberMap.get(oldStage);

    system.debug('\n[Opportunity_ExitCriteriaUtility : isPassingRequiredExitCritria] : startingStageNumber: '+ startingStageNumber + ' and opps startingstage: ' + opp.Starting_Stage__c);

    if (String.isNotEmpty(opp.Starting_Stage__c) && startingStageNumber != null) {
      startApplyingCriteriaStage = startingStageNumber;
    }

    do {
      system.debug('\n[Opportunity_ExitCriteriaUtility : isPassingRequiredExitCriteria] : \nstartApplyingCriteriaStage:' + startApplyingCriteriaStage + ' \nstageNumber:'+ stageNumber);
      system.debug('\n[Opportunity_ExitCriteriaUtility : isPassingRequiredExitCriteria] :startApplyingCriteriaStage <= stageNumber?' + (startApplyingCriteriaStage <= stageNumber) + '\nstageNumber > oldStageNum?'+(stageNumber > oldStageNum));

      if (startApplyingCriteriaStage <= stageNumber && stageNumber > oldStageNum) { // || (startApplyingCriteriaStage < oldStageNum && stageNumber < oldStageNum)

        system.debug('\nIs tempStage >= oldStageNum ? tempStage='+startApplyingCriteriaStage + ' and oldStageNum='+oldStageNum);

        meetingCriteria = isMeetingExitCriteria(opp, oppStageNumberToNameMap.get(startApplyingCriteriaStage+1), oppStageNumberToNameMap.get(startApplyingCriteriaStage), newopp);

        system.debug(meetingCriteria+'\n[Opportunity_ExitCriteriaUtility: isPassingRequiredExitCritria111] : from: '+ oppStageNumberToNameMap.get(startApplyingCriteriaStage+1)+ ' to: '+ oppStageNumberToNameMap.get(startApplyingCriteriaStage)+ '\n:::'+ meetingCriteria);

      }
      // PK: Adding spacing between the errors!
      if (!meetingCriteria) {
        errorMessage = Label.OECS_MSG_CRITERIA_NOT_MET + ' ' + oldStage + ' ' + Label.OECS_MSG_to + ' ' + stagePicklistLabels.get(stageName) + '. '+ errorMessage; //T-413194 : Added Custom Labels
        return false;
      }
      startApplyingCriteriaStage++;

    } while (startApplyingCriteriaStage < stageNumber);

    return meetingCriteria;
  }


  //============================================================================================
  // Returns list of opportunities which do not match exit criteria
  //============================================================================================
  public static Boolean getOpportunitiesExitCriteriaNotMet (Map<Id, Opportunity> newOpps, Map<Id, Opportunity> oldOpps) {

    if (!OpportunityTriggerHandler.hasCheckedExitCriteria) {
      OpportunityTriggerHandler.hasCheckedExitCriteria = true;
    }

    List<Opportunity> notMetOpportunitiesList = new List<Opportunity>();
    opportunityMap = new Map<String, Opportunity>();


    Global_Settings__c globalSettings = Global_Settings__c.getValues(Constants.GLOBAL_SETTING);

    // PK Case 01872263 - Altered query below
    for (Opportunity oppty : [SELECT ID, RecordTypeId, Competitor_Count__c, Turn_Off_Contact_Role_Criteria_Check__c, StageName,Starting_Stage__c,
                                     CurrencyIsoCode, Budget__c, Has_Stage_3_Approval__c, Has_Senior_Approval__c,Opportunity_Products_Count__c,
                                     Owner.Region__c, Stage_3_Approver__c, Senior_Approver__c,
                                     /*Is_There_Commercial_Risk__c, Is_There_Delivery_Risk__c,
                                     Is_There_Financial_Risk__c, Is_There_Legal_Risk__c,
                                     Has_There_Been_Significant_Change__c,*/ Type, OwnerId, Owner_s_Business_Unit__c,
                                     Risk_Tool_Output__c, Risk_Tool_Output_Code__c,
                                     //Below_Review_Thresholds__c, T-271695: Removed reference to Below_Review_Thresholds__c
                                     Amount, CloseDate, Tech_Support_Maintenance_Tiers__c,
                                     Primary_Quote_has_been_Approved__c, Quote_Primary__c, Quote_Count__c,CPQ_User_to_Validate__c,CPQ_User_to_Validate2__c,CPQ_User_to_Validate3__c,Auto_Renewed__c, // CRM2:W-005496
                                     Amount_Corp__c,DP_Qualify_Approval__c,Contract__c,Original_Contract_Effective_date__c,
                                     Conflict_of_Interest__c, //Case 14818841
                                     SOTI_Contract__c,SOTI_Contract_Number__c,//17877595
                                     Deployment__c, Hard_Go_Live_Date__c, Total_Eligible_Population__c,Customer_Base_Migration__c,
                                     Recurring_Incremental__c,Deal_Category__c,CPQ_Approval_Required__c,Title_of_Original_Agreement__c,Commencement_Date_of_Original_Agreement__c,Effective_Date__c,Quote_Status__c,Installment_Interval__c,Installment_Number_of_Splits__c,
                                     (SELECT Id, Type_of_Sale__c, PricebookEntry.Product2.Global_Business_Line__c, PricebookEntry.Product2.Business_Line__c,
                                             PricebookEntry.Product2.Name,DP_Product_Package_Code__c, //16166194
                                             Product_Features__c,Product_Type__c,Contracted_MRR__c,Setup_Fee__c,Pre_payment__c,Revenue_type__c,Blanket_Coverage__c, 
                                             Data_Usage__c, Manual_Registration__c, Users_To__c, Release__c, Product2Id //20188554 Manoj added these fields
                                      FROM OpportunityLineItems WHERE IsDeleted = false),  
                                     (SELECT Id, Role, IsPrimary
                                      FROM OpportunityContactRoles
                                      WHERE (Role = :Constants.DECIDER AND IsDeleted = false)
                                        OR (Role =: Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER AND IsDeleted = false) OR (Role =: Constants.OPPTY_CONTACT_ROLE_ADMIN AND IsDeleted = false)),
                                     (SELECT Id, Type, Status, Outcomes__c FROM Tasks
                                      WHERE Status = :Constants.STATUS_COMPLETED AND IsDeleted = false),
                                     (SELECT ID, Role__c FROM Opportunity_Contact_Addresses__r)
                                     FROM Opportunity WHERE ID IN: newOpps.keySet() ALL ROWS]) {
      opportunityMap.put(oppty.ID, oppty);
    }

    for (Opportunity oppty : newOpps.values()) {
      //As per task : T-323155 Free trial opportunity wont go through Opportunity exit criteria validations
      if (String.isNotBlank(oppty.Type) && oppty.Type.equalsIgnoreCase(Constants.OPPTY_TYPE_FREE_TRIAL)) {
        continue;
      }
      errorMessage = '';
      //Commented by Manoj to go stage from Qualify to Propose without validation rules
      /*if (oppty.StageName == globalSettings.Opp_Stage_4_Name__c && oldOpps.get(oppty.Id).StageName == globalSettings.Opp_Stage_3_Name__c) {
        //If this was an originally loaded Opportunity then we don't require people to fill in the contact role
        if (opportunityMap.get(oppty.ID).OpportunityContactRoles.size() < 1 && !opportunityMap.get(oppty.ID).Turn_Off_Contact_Role_Criteria_Check__c) {
          oppty.StageName.addError(Label.Opp_Stage_3_Stage_Exit_Failure);
          continue;
        }
      }*/

      //Added by manoj to check the opportunity product count
      if ((oppty.StageName==Constants.OPPTY_STAGE_5 || oppty.StageName==Constants.OPPTY_STAGE_6 || oppty.StageName==Constants.OPPTY_STAGE_7)
          && oldOpps.get(oppty.Id).StageName!= oppty.StageName && oppty.Opportunity_Products_Count__c==0 &&
          oppty.RecordTypeId != oppRecordTypeMap.get(Constants.RECORDTYPE_Partner_Community)) { //Added by Mj to check Opty Product Count if record type is not Partner Community
        //Get the RecordTypeId from map to compare Transactional sale
        if (oppty.RecordTypeId != oppRecordTypeMap.get(Constants.RECORDTYPE_Transactional_Sale)) {
          oppty.StageName.addError(Label.PROPOSE_CRITERIA_NOT_MET + ' ' + stagePicklistLabels.get(oppty.StageName) + '. ' + Label.OECS_Check_Stage_Requirements);
        }
        else{
          oppty.StageName.addError(Label.TRANS_SALE_CRITERIA_NOT_MET + '. ' + Label.OECS_Check_Stage_Requirements);
        }
        return false;
      }

      if ((oppty.StageName==Constants.OPPTY_STAGE_5 || oppty.StageName==Constants.OPPTY_STAGE_6 || oppty.StageName==Constants.OPPTY_STAGE_7) &&
          (oppty.Competitor_Count__c == null || Integer.valueOf(oppty.Competitor_Count__c) == 0) &&
           oppty.Type != Constants.OPPTY_TYPE_RENEWAL && oppty.RecordTypeId != oppRecordTypeMap.get(Constants.RECORDTYPE_FREE_TRIAL) &&
           oppty.RecordTypeId != oppRecordTypeMap.get(Constants.RECORDTYPE_Transactional_Sale) &&
           oppty.RecordTypeId != oppRecordTypeMap.get(Constants.RECORDTYPE_Partner_Community) && !isNACustomer ) { //  Added by Mj to check Opty Competitor Count if record type is not Partner Community
        oppty.StageName.addError(Label.PROPOSE_CRITERIA_NOT_MET + ' ' + stagePicklistLabels.get(oppty.StageName));
        return false;
      }
      
      if ((oppty.StageName==Constants.OPPTY_STAGE_5 || oppty.StageName==Constants.OPPTY_STAGE_6 || oppty.StageName==Constants.OPPTY_STAGE_7)
              && (oppty.Owner_s_Region__c == Constants.REGION_UKI || currentUser.Region__c == Constants.REGION_UKI) && oppty.Skip_Version_Validation__c == false){
              
            Opportunity opp = opportunityMap.get(oppty.ID);
            Map<Id, Set<string>> mapProductVersions = new Map<Id, Set<string>>();
            Set<Id> setProdIds = new Set<Id>();
            for(OpportunityLineItem oli:opp.OpportunityLineItems){
                setProdIds.add(oli.Product2Id);
            }       
            
            for(Product_Version__c pv:[SELECT Id, Name, Product__c FROM Product_Version__c WHERE Product__c IN:setProdIds AND Is_Active__c = true]){
                if(!mapProductVersions.containsKey(pv.Product__c)){
                    mapProductVersions.put(pv.Product__c, new Set<String>());
                }        
                mapProductVersions.get(pv.Product__c).add(pv.Name);
            }
            boolean isVersionNotMatched = false;
            for(OpportunityLineItem oli:opp.OpportunityLineItems){
                if(mapProductVersions.containsKey(oli.Product2Id)){
                    Set<string> activeProductVersions = mapProductVersions.get(oli.Product2Id);
                    if(string.isBlank(oli.Release__c) || (string.isNotBlank(oli.Release__c) && activeProductVersions!=null && !activeProductVersions.contains(oli.Release__c))){
                    
                            isVersionNotMatched = true;
                            break;
                    }
                }
            }
            system.debug('isVersionNotMatched @@@'+isVersionNotMatched );
            if(isVersionNotMatched == true){
                oppty.StageName.addError(Label.UKI_PRODUCT_VERSION_NOT_MATCHED);
                return false;
            }         
      }

      if (oppty.StageName == Constants.OPPTY_STAGE_7 && !isStage7Ready(opportunityMap.get(oppty.Id))) {
          oppty.StageName.addError(Label.OPPTY_STAGE_7_EPS_NA + '. ' + Label.OECS_Check_Stage_Requirements);
          //if (!hasBillToAddress )
            // oppty.StageName.addError(Label.OPPTY_ERR_NO_BUY_TO_CONTACT); 
          return false;
      }
      //Case-20830009 Changes
      string retVal = isStage7ReadyForEBA(opportunityMap.get(oppty.Id));
      if (oppty.StageName == Constants.OPPTY_STAGE_7 && retVal != '') {
                  oppty.StageName.addError(retVal);
                  return false;
      }
      // Check whether opportunity skipping stage
      if (Test.isRunningTest() &&
          Constants.OPPTY_CHECK_SKIPPING &&
          !oppty.isClosed &&
          !oppty.StageName.equalsIgnoreCase(Constants.OPPTY_STAGE_NO_DECISION) &&
          isSkippingStages(oppty.StageName, oldOpps.get(oppty.ID).StageName)) {
        oppty.addError (Label.OECS_MSG_SKIPSTAGE);
        notMetOpportunitiesList.add(oppty);
        continue;
      }

      system.debug('\nOldStageName: '+oldOpps.get(oppty.ID).StageName + '\nNew StageNAME: '+ oppty.StageName);

     // system.debug('\n===isPassingRequiredExitCriteria(opportunityMap.get(oppty.ID), oppty.StageName, oldOpps.get(oppty.ID).StageName)=' + isPassingRequiredExitCriteria(opportunityMap.get(oppty.ID), oppty.StageName, oldOpps.get(oppty.ID).StageName));

      //Saving the current state of the error message so that it doesn't get modified after this and we don't get duplicated
      //error messages since the variable is vissible to the entire class
      //String auxStringErrorMessage = errorMessage;

        // passing both opp and oppty's StageName because the opp from the opportunityMap is retrieved from DB, not from trigger
        //26/02/2020 bypassed validation for EBA Add Products Users custom setting.
      if (oppty.StageName != oldOpps.get(oppty.ID).StageName &&
          !isPassingRequiredExitCriteria(opportunityMap.get(oppty.ID), oppty.StageName, oldOpps.get(oppty.ID).StageName, oppty) && EBA_Add_Products_Users__c.getValues(UserInfo.getUserId()) == null) {
        //Moving to new stage
        //CT oppty.StageName.addError('HELLO ' + errorMessage + ' GREETINGS ');
        oppty.StageName.addError(errorMessage + '. ' + Label.OECS_Check_Stage_Requirements);
        system.debug('debug--'+errorMessage + '. ' + Label.OECS_Check_Stage_Requirements);
      }
    }
    return (notMetOpportunitiesList.size() > 0 ? false : true);
  }

  //============================================================================================
  // Check two stages weather the stage is skpping
  //============================================================================================
  private static Boolean isSkippingStages (String newStage, String oldStage) {
    Boolean isSkipping = false;
    if (oppStagesAllowedMap.get(oldStage) != null &&
        newStage != oldStage && !oppStagesAllowedMap.get(oldStage).contains(newStage)) {   isSkipping = true;
    }
    return isSkipping;
  }

  //============================================================================================
  //check opportunity weather that is meeting exit criteria
  //============================================================================================
  public static Boolean isMeetingExitCriteria (Opportunity opp, String newStage, String oldStage, Opportunity newopp) {
    Boolean isOpptyMeetingExitCriteria = true;

    Decimal adjustedRate = 0.00;
    Decimal currencyRate = 1.00;

    Set<String> setOppCurrencyISOCode = new Set<String>();
    setOppCurrencyISOCode.add(opp.CurrencyIsoCode);

    CurrencyUtility currencyUtil = new CurrencyUtility(setOppCurrencyISOCode);
    currencyRate = currencyUtil.convertCurrency(opp.CurrencyIsoCode, 1, Constants.CURRENCY_GBP, opp.CloseDate);
    adjustedRate = 1 - currencyRate;

    // Noopur - added to remove to many SOQL queries
    String groupName = (!String.isBlank(OpportunityTriggerHandler.groupname) ? OpportunityTriggerHandler.groupname : BusinessUnitUtility.getBusinessUnit(opp.OwnerId));

    if (String.isNotBlank(groupName) && groupName.equalsIgnoreCase(Constants.EDQ) && opp.Owner.Region__c == Constants.REGION_UKI) { bypassTheCriteria = true;
    }
    else {
      bypassTheCriteria = false;
    }

    system.debug('\n[Opportunity_ExitCriteriaUtility : isMeetingExitCriteria]' + bypassTheCriteria);
    //When opportunity moving Stage 3 to Stage 4.
    if ((newStage == Constants.OPPTY_STAGE_4 && oldStage == Constants.OPPTY_STAGE_3)
        || (newStage == Constants.OPPTY_STAGE_4 && oldStage == Constants.OPPTY_PARTNER_STAGE_3)) {
      isOpptyMeetingExitCriteria = isStage3ExitCriteriaMet(opp, newStage, oldStage, adjustedRate);
    } //When opportunity moving Stage 4 to Stage 5.
    //MM 19457481: New Stage will be Contract (Stage 6) instead of Commit
    else if ((newStage == Constants.OPPTY_STAGE_6 && oldStage == Constants.OPPTY_STAGE_4)
        || (newStage == Constants.OPPTY_PARTNER_STAGE_6 && oldStage == Constants.OPPTY_STAGE_4)) {
            System.debug('inside stage4');
      isOpptyMeetingExitCriteria = isStage4ExitCriteriaMet(opp, newStage, oldStage, adjustedRate,newopp);
    } //When opportunity moving Stage 5 to Stage 6.
    //MM 19457481: Commented out, not needed anymore since Commit stage is removed
    /*
    else if ((newStage == Constants.OPPTY_STAGE_6 && oldStage == Constants.OPPTY_STAGE_5)
        || (newStage == Constants.OPPTY_STAGE_6 && oldStage == Constants.OPPTY_PARTNER_STAGE_5)) {
      isOpptyMeetingExitCriteria = isStage5ExitCriteriaMet(opp, newStage, oldStage, adjustedRate);
    }
    */
    else if (newStage == Constants.OPPTY_STAGE_7 && oldStage == Constants.OPPTY_STAGE_6) {
      //system.debug(opp.Has_There_Been_Significant_Change__c+'[**8opp****]'+opp);
      isOpptyMeetingExitCriteria = isStage6ExitCriteriaMet(opp, newStage, oldStage, newopp);
    }

    system.debug('[errorMessageerrorMessageerrorMessage----]'+errorMessage);
    return isOpptyMeetingExitCriteria;
  }

  // 7/9/19 - Charlie Park - This change is for EPS
   @Testvisible
  private static Boolean isStage7Ready(Opportunity opp) {      
      if (opp.Owner_s_Business_Unit__c == 'NA Consumer Services') {
          // 8/8/19 - CP
          /*if (String.isBlank(opp.Hard_Go_Live_Date__c)) {
              return false;
          }*/ // RJ commented it case # 19624121

          for (OpportunityLineItem eachLineItem: opp.OpportunityLineItems) {
              if (String.isBlank(eachLineItem.Product_Features__c) 
                     // || String.isBlank(eachLineItem.Product_Type__c)
                      || String.isBlank(eachLineItem.Revenue_type__c)|| String.isBlank(eachLineItem.Blanket_Coverage__c)
                       ) {
                  return false;
              }
          }

           // 8/8/19 - CP: Look through all contact roles, if there are NO bill to contacts then return false.
          /*Boolean hasBillToContact = false;
          for (OpportunityContactRole eachRole: opp.OpportunityContactRoles) {
              if (eachRole.Role == Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER) {
                  hasBilltoContact = true;
                  break;
              }
          }

          if (!hasBillToContact) {
              return false;
          }*/ // RJ commented it case # 19624121



          // 8/8/19 - CP: Look through all addresses, if there are NO bill to addresses, then return false.
          /*Boolean hasBillToAddress = false;
          for (Opportunity_Contact_Address__c eachAddress: opp.Opportunity_Contact_Addresses__r) {
              if (eachAddress.Role__c == Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER) {
                  hasBillToAddress = true;
                  break;
              }
          }

          if (!hasBilltoAddress) {
              
              // opp.StageName.addError(Label.OPPTY_ERR_NO_BUY_TO_CONTACT); 
              return false;
          } */ // As per discussion on 8/22 to skip this as of now RJ
             

      }
      
      return true;
  }
      //Case-20830009 Changes
      @Testvisible
      private static String isStage7ReadyForEBA(Opportunity opp) { 
            boolean hasBillToContact = false;
            String retString = '';
            for (OpportunityContactRole eachRole : opp.OpportunityContactRoles) {
                  if (eachRole.Role == Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER){
                      hasBilltoContact = true;
                      break;
                  }else{
                      hasBilltoContact = false;
                  }
            }
            for (OpportunityLineItem eachLineItem : opp.OpportunityLineItems) {
                  if(eachLineItem.PricebookEntry.Product2.Name==label.EBA_Business_Express_Credit_Review && !hasBilltoContact){
                      retString = Label.OECS_EBA_ERROR;
                      break;
                  }else if((eachLineItem.PricebookEntry.Product2.Name.Contains(Label.EBA_Business_Express) && eachLineItem.PricebookEntry.Product2.Name != label.EBA_Business_Express_Credit_Review) && (opp.Installment_Interval__c == null || opp.Installment_Number_of_Splits__c == null || !hasBilltoContact)){
                      retString = Label.OECS_EBA_ERROR_2;
                      break;
                  }else{
                      retString = '';
                  }
             }
            return retString;
      }
  //============================================================================================
  // Stage 3 exit criteria met ?
  //============================================================================================
  private static Boolean isStage3ExitCriteriaMet(Opportunity opp, String newStage, String oldStage, Decimal adjustedRate) {
    isCriteriaMet = true;

    system.debug('\n[Opportunity_ExitCriteriaUtility: isStage3ExitCriteriaMet] new Stage:' +newStage + ' oldStage: '+oldStage + '; adjustedRate: '+ adjustedRate);
    //Commented by Manoj to go stage from Qualify to Propose without validation rules
    /*
    if (opp != null && (
         (opp.Tasks != null && opp.Tasks.size() < 1) ||
         opp.Budget__c == '' ||
         (opp.Competitor_Count__c == null || Integer.valueOf(opp.Competitor_Count__c) == 0) ||
         (opp.OpportunityContactRoles != null && opp.OpportunityContactRoles.size() < 1 && !opp.Turn_Off_Contact_Role_Criteria_Check__c))) {
      isCriteriaMet = false;
      errorMessage = Label.OECS_MSG_STAGE3_EXIT;
    }
    */
    system.debug('[errorMessageerrorMessageerrorMessage3333]'+errorMessage);
    system.debug('[---debug1.0--]'+opp.Stage_3_Approver__c);
    system.debug('[---debug1.1--]'+opp.Has_Stage_3_Approval__c);
    system.debug('[---debug1.2--]'+opp.StageName);
    system.debug('[---debug1.3--]'+opp);
    system.debug('[---debug1.4--]'+bypassTheCriteria);

    //DO Case 13543302: Disable as no longer needed
    /*if (opp.Owner.Region__c == Constants.REGION_UKI && !bypassTheCriteria && opp.Amount >= 500000 && oppStageNameToNumberMap.get(newStage) == 4) {
      if (opp.Stage_3_Approver__c == null) {
        errorMessage += ' ' + Label.OECS_MSG_POPULATE_STAGE_3_APPROVER;
        isCriteriaMet = false;
      }
      else if (opp.Has_Stage_3_Approval__c == false) {
        errorMessage += ' ' + Label.OECS_MSG_STAGE_3_TO_4_AMOUNTORTAA_OVER_APPROVAL;
        isCriteriaMet = false;
      }
    }*/

    if(opp.Owner_s_Business_Unit__c =='APAC CS SEA' && (Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_NEW  || Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_EXISTING) &&
         opp.amount_corp__c >= 15000 &&  !opp.DP_Qualify_Approval__c ){
        errorMessage += system.label.OPPTY_ERR_NO_DP_STAGE3_APPROVAL;
        isCriteriaMet = false;
      }
    //22227844 :  Add Integration Parter Validation while Exiting Qualify when Verify Product
    List<String> bunitList = new List<String>();
    for(BU_Unit_Verify_Product__c buobj : BU_Unit_Verify_Product__c.getall().values()) {
      bunitList.add(buobj.Name);
    }
    List<OpportunityPartner> oppPartnerList = [Select Id from OpportunityPartner where OpportunityId =: opp.Id];
    if(bunitList.contains(opp.Owner_s_Business_Unit__c) && oppPartnerList.isEmpty()) {
      errorMessage += '\n' + Label.OPPTY_ERR_NO_INTEGRATION_PARTNER;
      isCriteriaMet = false;
    }


    //MR :  Case 14818841 : make conflit of interest required for UK&I opp owners
    If(opp.Owner.Region__c==constants.REGION_UKI && string.isEmpty(opp.Conflict_of_Interest__c) ){
          errorMessage += '\n' + Label.OECS_Conflict_of_Interest_required;
          isCriteriaMet = false;
    }

    system.debug('\n[Opportunity_ExitCriteriaUtility: isStage3ExitCriteriaMet] stage 3 met:' +isCriteriaMet);

    return isCriteriaMet;
  }

  //============================================================================================
  // Stage 4 exit criteria met ?
  // MM 19457481: Moved logic from method isStage5ExitCriteriaMet since Stage 4 (Propose) will move now to Contract and not to Commit
  //============================================================================================
  private static Boolean isStage4ExitCriteriaMet(Opportunity opp, String newStage, String oldStage, Decimal adjustedRate,Opportunity newOpp ) {
    isCriteriaMet = true;

    //Boolean hasQuoteDelivered = hasRequiredTask(opp, Constants.ACTIVITY_TYPE_QUOTE_DELIVERED);

    //if (!hasQuoteDelivered || opp.Opportunity_Products_Count__c == 0) {
    //Commented by Manoj to go stage from Propose to Commit without validation rules except products selected
    /*
    if (opp.Opportunity_Products_Count__c == 0) {
      errorMessage += '\n'+Label.OECS_MSG_STAGE_4_EXIT_CRITERIA;
      isCriteriaMet = false;
    }
    */
    // CRM2:W-005438 - Added by Manoj
    /*Id freeTrialRecId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.OPPTY_TYPE_FREE_TRIAL).getRecordTypeId();
    Id transaleRecId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get(Label.Opty_Transactional_Sale).getRecordTypeId();
    if ((opp.Competitor_Count__c == null || Integer.valueOf(opp.Competitor_Count__c) == 0) &&
        opp.Type != Constants.OPPTY_TYPE_RENEWAL &&
        opp.RecordTypeId != freeTrialRecId &&
        opp.RecordTypeId != transaleRecId) {
      errorMessage += '\n'+Label.OECS_MSG_STAGE_4_EXIT_CRITERIA;
      isCriteriaMet = false;
    }*/

    // 8/8/19 - CP
    if (opp.Owner_s_Business_Unit__c == 'NA Consumer Services') {
        if (String.isBlank(opp.Deployment__c)) {
            isCriteriaMet = false;  errorMessage += '\n' + Label.OPPTY_DEPLOY_REQ;
        }

        if (opp.Total_Eligible_Population__c == null) {
            for (OpportunityLineItem eachLI: opp.OpportunityLineItems) {
                if (eachLI.PricebookEntry.Product2.Name == 'DTC Core') { isCriteriaMet = false;
                    errorMessage += '\n' + Label.OPPTY_TOTAL_ELIGIBLE_REQUIRED;
                }
            }
        }
    }

    system.debug('\nOpp Region: '+ opp.Owner.Region__c + ' bypass: ' + bypassTheCriteria);

    Boolean foundTechRequirement = hasTechSuppFieldRequired(opp);

    if (foundTechRequirement && String.isBlank(opp.Tech_Support_Maintenance_Tiers__c)) { isCriteriaMet = false; errorMessage += '\n' + Label.OECS_MSG_POPULATE_Tech_Support_Main_Tiers;
    }
    
    if (opp.Owner.Region__c == Constants.REGION_UKI && !bypassTheCriteria) {
      /*
      // Removing since fields no longer required.
      if (opp.Is_There_Commercial_Risk__c == null || opp.Is_There_Delivery_Risk__c == null ||
          opp.Is_There_Financial_Risk__c == null|| opp.Is_There_Legal_Risk__c == null) {
        errorMessage += '\n'+Label.OECS_MSG_POPULATE_RISK_FIELDS;
        isCriteriaMet = false;
      }
      */
      // CRM2:W-005495 - New check for GTM
      if (opp.Amount >= 250000 && String.isNotBlank(opp.Owner_s_Business_Unit__c) &&
          (opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I GTM ') ||
           opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I CS ') ||
           opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I DA '))) {
        if (opp.Risk_Tool_Output__c == null || String.isBlank(opp.Risk_Tool_Output_Code__c)) { errorMessage = Label.OECS_MSG_RISK_TOOL_OUTPUT_MISSING; isCriteriaMet = false;
        }
      }
      // DO Case:12880367 - New check for UK&I MS Data Quality and UK&I MS Targeting
      if (opp.Amount >= 100000 && String.isNotBlank(opp.Owner_s_Business_Unit__c) &&
          (opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I MS Data Quality'))){
           //opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I MS Targeting'))) {
        if (opp.Risk_Tool_Output__c == null || String.isBlank(opp.Risk_Tool_Output_Code__c)) { errorMessage = Label.OECS_MSG_RISK_TOOL_OUTPUT_MISSING; isCriteriaMet = false;
        }
      }

      //if (/*(opp.Has_There_Been_Significant_Change__c != null && opp.Has_There_Been_Significant_Change__c.equalsIgnoreCase('Yes')) || */ opp.Amount >= 500000) {
        /*if (opp.Senior_Approver__c == null) {
          errorMessage = Label.OECS_MSG_POPULATE_SENIOR_APPROVER;
          isCriteriaMet = false;
        }
        else if (opp.Has_Senior_Approval__c == false) {
          errorMessage += '\n' + Label.OECS_MSG_STAGE_4_TO_5_AMOUNTORTAA_OVER_APPROVAL;
          isCriteriaMet = false;
        }
      }*/
    }

    if(opp.Owner_s_Business_Unit__c =='APAC CS SEA' && (Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_NEW || Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_EXISTING) &&
         opp.amount_corp__c >= 15000 &&  !opp.DP_Qualify_Approval__c ){
        errorMessage += system.label.OPPTY_ERR_NO_DP_STAGE3_APPROVAL;
        isCriteriaMet = false;
      }
    
    //MM 19457481: Commenting code, this should only runs when moving to Execute
    //if(String.isNotBlank(opp.Owner_s_Business_Unit__c) && !opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I GTM')){
        //BIS Primary aprove quote requirement
           //system.debug('CheckQuoteApproved');     
    //    isCriteriaMet = checkQuoteApproved(opp,isCriteriaMet);
    //  }

    Boolean CPQUser = false;
    for(user u : [Select cpq_user__c,cpq_user_type__c From User Where Id = :UserInfo.getUserId()]){
      if(u.cpq_user_type__c != null && u.cpq_user_type__c !='CPQ Admin' && !String.valueof(u.cpq_user_type__c).startsWith('EDQ')  ){CPQUser=u.cpq_user__c;}
    }
      List<PermissionSetAssignment> psas = [ select Id from PermissionSetAssignment where PermissionSet.Name='Execute_Opportunity_Without_Quote' AND AssigneeId =:UserInfo.getUserId()];
      if(psas.size() == 0 && CPQUser &&(String.isBlank(opp.Owner_s_Business_Unit__c) || (String.isNotBlank(opp.Owner_s_Business_Unit__c) && (!opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('APAC DA ANZ') && !opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I GTM') && !opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I MS Data Quality')  && !opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('NA MS Consumer Insights & Targeting') && !opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I MS Targeting') && !opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('NA CS Automotive')))) && (opp.Quote_Count__c==0 ||  opp.Quote_Count__c == null) && !opp.Auto_Renewed__c && !opp.Recurring_Incremental__c){// // W-032331 APAC DA ANZ and W-033293 UK&I MS Targetin 
        errorMessage += system.label.OECS_MSG_CPQ_QUOTE_PRODUCED;
        isCriteriaMet = false;
      }
      
    map<string,Opportunity_Deal_Categories__mdt> mapDeals = new map<string,Opportunity_Deal_Categories__mdt>();
      for(Opportunity_Deal_Categories__mdt dc:[select MasterLabel, Deal_Category__c, Mandatory_Label__c, Business_Unit__c, CPQ_Quote_Required__c, CPQ_Contract_Required__c, Mandatory__c from Opportunity_Deal_Categories__mdt]){
        mapDeals.put(dc.Deal_Category__c + '-' + dc.Business_Unit__c, dc);
      }
          
    if(mapDeals.containsKey(newOpp.Deal_Category__c + '-' + newOpp.Business_Unit__c)){
                Opportunity_Deal_Categories__mdt dealCu = mapDeals.get(newOpp.Deal_Category__c + '-' + newOpp.Business_Unit__c);
                system.debug('Opportunity_Deal_Categories__mdt##########'+dealCu);

        if(psas.size() == 0 && CPQUser && String.isNotBlank(opp.Owner_s_Business_Unit__c) && (opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I GTM') || opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('APAC DA ANZ') ||opp.Owner_s_Business_Unit__c.startsWithIgnoreCase ('UK&I MS Targeting') || opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('NA MS Consumer Insights & Targeting') || (opp.Owner_s_Business_Unit__c == 'NA CS Automotive' && dealCu.Deal_Category__c =='New Standard Product')) && (opp.Quote_Count__c==0 ||  opp.Quote_Count__c == null) && dealCu.CPQ_Quote_Required__c == true){//W-032331 APAC DA ANZ and W-033293 UK&I MS Targeting   
            errorMessage += system.label.OECS_MSG_CPQ_QUOTE_PRODUCED;
            isCriteriaMet = false;
        }
        system.debug('Owner_s_Business_Un##########'+opp.Owner_s_Business_Unit__c);
        system.debug('dealCu.Deal_Category__c##########'+dealCu.Deal_Category__c);
        if( opp.Owner_s_Business_Unit__c == 'NA CS Automotive' && (dealCu.Deal_Category__c == 'Master Agreement' || dealCu.Deal_Category__c == 'Straight Renewal')){
          list<string> lstFieldLabels = new list<string>();
            if(string.isNotBlank(dealCu.Mandatory_Label__c)){
                if(dealCu.Mandatory_Label__c.contains(',')){
                    lstFieldLabels = dealCu.Mandatory_Label__c.split(',');
                }else{
                    lstFieldLabels.add(dealCu.Mandatory_Label__c);
                }
            }
          if(string.isNotBlank(dealCu.Mandatory__c)){
            list<string> lstFields = new list<string>();
            if(dealCu.Mandatory__c.contains(',')){
              lstFields = dealCu.Mandatory__c.split(',');
            }else{
              lstFields.add(dealCu.Mandatory__c);
            }
            integer i=0;
            for(string strF:lstFields){                
              if(string.isBlank(string.valueof(newopp.get(strF)))){
                errorMessage+= '\n'+lstFieldLabels[i]+' is required, when Deal Category is Master Agreement or Straight Renewal.Please attach original contract/pricing back-up\n';
                isCriteriaMet = false;
              }
              i = i+1;
            }
          }
        }
    }

    //MM 19457481 consolidated logic from Commit to Contract
    if(opp.Owner_s_Business_Unit__c =='APAC CS SEA' && (Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_NEW || Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_EXISTING) &&
         opp.amount_corp__c >= 15000 &&  !opp.DP_Qualify_Approval__c ){
        errorMessage += system.label.OPPTY_ERR_NO_DP_STAGE3_APPROVAL;
        isCriteriaMet = false;
      }
     
    system.debug('\n[Opportunity_ExitCriteriaUtility: isStage4ExitCriteriaMet] stage 4 met:' +isCriteriaMet);
    return isCriteriaMet;
  }
  //============================================================================================
  // Stage 5 exit criteria met ?
  // MM: 19457481 commented entire method
  //============================================================================================
  
  //private static Boolean isStage5ExitCriteriaMet(Opportunity opp, String newStage, String oldStage, Decimal adjustedRate) {
  //  isCriteriaMet = true;
  //  //Commented by Manoj to go stage from Commit to Contract without validation rules
    
  //  Boolean hasSelectionConfirmed = hasRequiredTask(opp, Constants.ACTIVITY_TYPE_SELECTION_CONFIRMED);

  //  if (!hasSelectionConfirmed) {
  //    errorMessage += '\n'+Label.OECS_MSG_STAGE_5_EXIT_CRITERIA_MET;
  //    isCriteriaMet = false;
  //  }
    
  //  system.debug('[errorMessageerrorMessageerrorMessage5555]'+errorMessage);
  //  //if (opp.Owner.Region__c == Constants.REGION_UKI && !bypassTheCriteria) {
  //    /*
  //    // PK Removing since these fields are no longer required.
  //    if (opp.Is_There_Commercial_Risk__c == null || opp.Is_There_Delivery_Risk__c == null || opp.Is_There_Financial_Risk__c == null || opp.Is_There_Legal_Risk__c == null) {
  //      errorMessage += Label.OECS_MSG_POPULATE_RISK_FIELDS;
  //      isCriteriaMet = false;
  //    }

  //    if (opp.Has_There_Been_Significant_Change__c == null) {
  //      isCriteriaMet = false;
  //    }
  //    */
  //    /*if (opp.Amount >= 500000 || (opp.Has_There_Been_Significant_Change__c != null && opp.Has_There_Been_Significant_Change__c.equalsIgnoreCase('Yes'))) {
  //      if (opp.Senior_Approver__c == null) {
  //        errorMessage += Label.OECS_MSG_POPULATE_SENIOR_APPROVER;
  //        isCriteriaMet = false;
  //      }
  //      else if (opp.Has_Senior_Approval__c == false) {
  //        errorMessage += Label.OECS_MSG_STAGE_5_TO_6_OPPTY_APPROVAL;
  //        isCriteriaMet = false;
  //      }
  //    }
  //  }*/

  //   if(opp.Owner_s_Business_Unit__c =='APAC CS SEA' && (Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_NEW || Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_EXISTING) &&
  //       opp.amount_corp__c >= 15000 &&  !opp.DP_Qualify_Approval__c ){
  //      errorMessage += system.label.OPPTY_ERR_NO_DP_STAGE3_APPROVAL;
  //      isCriteriaMet = false;
  //    }
     
  //    if(String.isNotBlank(opp.Owner_s_Business_Unit__c) && !opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I GTM')){
  //      //BIS Primary aprove quote requirement           
  //      isCriteriaMet = checkQuoteApproved(opp,isCriteriaMet);
  //    }
      

  //  system.debug('\n[Opportunity_ExitCriteriaUtility: isStage5ExitCriteriaMet] stage 5 met:' +isCriteriaMet);
  //  return isCriteriaMet;
  //}
  //============================================================================================
  // Stage 6 Exit Criteria not met?
  //============================================================================================
  private static Boolean isStage6ExitCriteriaMet(Opportunity opp, String newStage, String oldStage,Opportunity newOpp) {
    /*
    if (didCriteria6AlreadyRun == false) {
        System.debug('TEST Cris 1');
        didCriteria6AlreadyRun = true;
    }
    else {
        return false;
    }
    */ 

    isCriteriaMet = true;
    // New Changes Start

    system.debug('[---opp.Owner.bu--->]'+opp.Owner_s_Business_Unit__c+'Deal@@@'+newOpp.Deal_Category__c+'oldDeal@@'+opp.Deal_Category__c);
    if(String.isNotBlank(opp.Owner_s_Business_Unit__c) && (opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I GTM') || opp.Owner_s_Business_Unit__c == 'NA CS Automotive')){

        map<string,Opportunity_Deal_Categories__mdt> mapDeals = new map<string,Opportunity_Deal_Categories__mdt>();
        for(Opportunity_Deal_Categories__mdt dc:[select MasterLabel, Deal_Category__c, CPQ_Quote_Required__c,Mandatory_Label__c, CPQ_Contract_Required__c, Mandatory__c from Opportunity_Deal_Categories__mdt]){
            mapDeals.put(dc.Deal_Category__c, dc);
        }

        if(mapDeals.containsKey(newOpp.Deal_Category__c)){
            Opportunity_Deal_Categories__mdt dealCu = mapDeals.get(newOpp.Deal_Category__c);
            system.debug('[---dealCu 1111--->]'+dealCu );
            if(dealCu.Deal_Category__c != 'Master Agreement' && dealCu.Deal_Category__c != 'Straight Renewal') {

              if(dealCu.CPQ_Quote_Required__c == true && opp.Quote_Primary__c == false){
                  errorMessage += '\n'+'Primary Quote is Mandatory for CPQ Quote.\n';
                  isCriteriaMet = false;
              }
              if(opp.CPQ_Approval_Required__c == 'Yes' && (opp.Quote_Status__c == 'Preparing' || opp.Quote_Status__c == 'Awaiting Internal Approval' || opp.Quote_Status__c == 'Rejected')){
              errorMessage += '\n'+'Primary Quote should be approved for CPQ Approval.\n';
              isCriteriaMet = false;           
              }
              if(dealCu.CPQ_Contract_Required__c == true && opp.Quote_Status__c != 'Completed' && opp.Quote_Status__c != 'Closed/Won'){
                  errorMessage += '\n'+'Quote status should be completed for CPQ Contract.\n';
                  isCriteriaMet = false;
              }
            }  
            list<string> lstFieldLabels = new list<string>();
            if(string.isNotBlank(dealCu.Mandatory_Label__c)){
                if(dealCu.Mandatory_Label__c.contains(',')){
                    lstFieldLabels = dealCu.Mandatory_Label__c.split(',');
                }else{
                    lstFieldLabels.add(dealCu.Mandatory_Label__c);
                }
            }
            if(string.isNotBlank(dealCu.Mandatory__c)){
                list<string> lstFields = new list<string>();
                if(dealCu.Mandatory__c.contains(',')){
                    lstFields = dealCu.Mandatory__c.split(',');
                }else{
                    lstFields.add(dealCu.Mandatory__c);
                }
                integer i=0;
                for(string strF:lstFields){                
                    if(string.isBlank(string.valueof(newopp.get(strF)))){
                        errorMessage+= '\n'+lstFieldLabels[i]+' is required to move the Opp to Execute.\n';
                        isCriteriaMet = false;
                    }
                    i = i+1;
                }
            }
        }

    }
    // New Changes END
    //Commented by Manoj to go stage from Contract to Execute without validation rules
    /*
    Boolean hasSignedContract = hasRequiredTask(opp, Constants.ACTIVITY_TYPE_SIGNED_CONTRACT);

    if (hasSignedContract == false) {
      isCriteriaMet = false;
      errorMessage += Label.OECS_MSG_STAGE_6_EXIT_CRITERIA_MET;
    }
    */
    // Added by Manoj
    if(String.isNotBlank(opp.Owner_s_Business_Unit__c) && opp.Owner_s_Business_Unit__c == 'NA CS Automotive' && 
    opp.Quote_Status__c == 'Awaiting Internal Approval'){
        errorMessage += Label.OECS_MSG_QUOTE_STATUS_AWAITING_APPROVAL;
        isCriteriaMet = false;           
    }

    if(String.isNotBlank(opp.Owner_s_Business_Unit__c) && !opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('UK&I GTM')  && !opp.Owner_s_Business_Unit__c.startsWithIgnoreCase('APAC DA ANZ') && (opp.Deal_Category__c !='Master Agreement' && opp.Deal_Category__c !='Straight Renewal')){  // W-032331 APAC DA ANZ
        //BIS Primary aprove quote requirement
                
        isCriteriaMet = checkQuoteApproved(opp,isCriteriaMet);
        //Non BIS Primary quote requirement
        if (((opp.Quote_Primary__c == false && opp.Quote_Count__c > 0) || (opp.Quote_Count__c == 0 || opp.Quote_Count__c == null)) && (opp.CPQ_User_to_Validate2__c == true || opp.CPQ_User_to_Validate3__c == true) && opp.Auto_Renewed__c == False) {
          errorMessage += Label.OECS_MSG_PRIMARY_QUOTE_REQUIRED;
          isCriteriaMet = false;
        }
    }
    

    
    system.debug('[errorMessageerrorMessageerrorMessage666]'+errorMessage);
    system.debug('[---opp.Owner.Region__c--->]'+opp.Owner.Region__c);

    //if (opp.Owner.Region__c == Constants.REGION_UKI && !bypassTheCriteria && opp.Amount >= 500000) {
      /*
      system.debug('[---opp.Has_There_Been_Significant_Change__c--->]'+opp.Has_There_Been_Significant_Change__c);
      if (String.isBlank(opp.Has_There_Been_Significant_Change__c)) {
        system.debug('[---opp.e--->]:'+opp.Has_There_Been_Significant_Change__c);
        errorMessage += Label.OECS_MSG_POPULATE_SIGNIFICANT_CHANGE;
        isCriteriaMet = false;
      }
      else if (opp.Has_There_Been_Significant_Change__c.equalsIgnoreCase('Yes')) {*/
        /*if (opp.Senior_Approver__c == null) {
          errorMessage += Label.OECS_MSG_POPULATE_SENIOR_APPROVER;
          isCriteriaMet = false;
        }
        else if (opp.Senior_Approver__c != null && opp.Has_Senior_Approval__c == false) {
          errorMessage += Label.OECS_MSG_STAGE_6_TO_7_OPPTY_APPROVAL;
          isCriteriaMet = false;
        }*/
      // }
    //}
    //Check the contact roles if the status is either No longer with Company or Inactive then
    //display the warning in the VF
    List<OpportunityContactRole> contactRoles = [
      SELECT ContactId, Contact.Status__c, Contact.Name, IsPrimary
      FROM OpportunityContactRole
      WHERE OpportunityId = :opp.Id
      AND Contact.Status__c != null
    ];

    List<String> contactNameList = new List<String>();

    if (!contactRoles.isEmpty()) {

      Set<Id> contactIds = new Set<Id>();
      boolean isPrimaryRoleFound = false;
      // Check status of each contact
      for (OpportunityContactRole ocr : contactRoles) {
        if(ocr.IsPrimary == true){
            isPrimaryRoleFound = true;
        }  
        if (ocr.Contact.Status__c.equalsIgnoreCase(Constants.CONTACT_STATUS_LEFT)) {
          if (!contactIds.contains(ocr.ContactId)) {
            contactNameList.add(ocr.Contact.Name);
            contactIds.add(ocr.ContactId);
          }
        }
      }
      if(isPrimaryRoleFound == false){
          errorMessage += system.label.OPPTY_ERR_NO_PRIMARY_CONTACT;
          isCriteriaMet = false;
      }
      if (!contactNameList.isEmpty()) {
        errorMessage += system.label.OPPTY_ERR_NO_LONGER_COMPANY_CONTACTS + ' ' + String.join(contactNameList, ', ');
        isCriteriaMet = false;
      }
    }

    boolean hasContactRole=false;
    boolean hasBuyToContactRole=false;
    boolean hasAdminContactRole=false;

    // 16166194 START
    boolean DPProdAdminReq=false;
    Map <string,DP_No_Admin_Required__c> mapDPNoAdmin = DP_No_Admin_Required__c.getAll();
    set<string> setDPNoAdmin = new set<string>(); // 16166194

    for(DP_No_Admin_Required__c DPno : mapDPNoAdmin.values()){
      string key = DPno.Product_Name__c+DPno.DP_Package_Code__c;
      setDPNoAdmin.add(key);
    }
    if (opp.OpportunityLineItems.size() > 0 ){
      for(OpportunityLineItem oli : opp.OpportunityLineItems){
        Product2 p = oli.PriceBookEntry.Product2;
        string key = p.name + oli.DP_Product_Package_Code__c;

        if(!setDPNoAdmin.contains(key)){

         DPProdAdminReq = true;
        }

      }
    }
    // 16166194 END

    if(opp.OpportunityContactRoles.size() > 0){

            for (OpportunityContactRole ocr : opp.OpportunityContactRoles){
            if (ocr.role == Constants.DECIDER) {hasContactRole = true;}
            if (ocr.role == Constants.OPPTY_CONTACT_ROLE_PURCHASE_LEDGER) {hasBuyToContactRole = true;}
            if (ocr.role == Constants.OPPTY_CONTACT_ROLE_ADMIN) {hasAdminContactRole = true;}
            }

      }
      if(!hasBuyToContactRole && opp.Owner_s_Business_Unit__c =='APAC CS SEA'){
        errorMessage += system.label.OPPTY_ERR_NO_BUY_TO_CONTACT;
        isCriteriaMet = false;
      }
      if(!hasAdminContactRole && DPProdAdminReq && opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_NEW && opp.Owner_s_Business_Unit__c =='APAC CS SEA'){
        errorMessage += system.label.OPPTY_ERR_NO_ADMIN_CONTACT;
        isCriteriaMet = false;
      }

      //Case 16313036 : Ensure Decison Maker exists on Trans Opps for DP users
      if(!hasContactRole && opp.RecordTypeId == oppRecordTypeMap.get(Constants.RECORDTYPE_Transactional_Sale) && opp.Owner_s_Business_Unit__c =='APAC CS SEA'){
        errorMessage += system.label.OPPTY_ERR_NO_DECIDER_CONTACT;
        isCriteriaMet = false;
      }

      if(opp.Owner_s_Business_Unit__c =='APAC CS SEA' && (Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_NEW || Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_EXISTING) &&
         opp.amount_corp__c >= 15000 &&  !opp.DP_Qualify_Approval__c ){
        errorMessage += system.label.OPPTY_ERR_NO_DP_STAGE3_APPROVAL;
        isCriteriaMet = false;
      }
      /*
      if(opp.Owner_s_Business_Unit__c =='APAC CS SEA' && (Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_NEW || Opp.Type ==Constants.OPPTY_TYPE_NEW_FROM_EXISTING) &&
         opp.amount_corp__c >= 10000 &&  opp.amount_corp__c < 15000){
        errorMessage += system.label.OPPTY_ERR_NO_DP_STAGE6_APPROVAL;
        isCriteriaMet = false;
      }
      */
      //20188554
      //List<string> EDQLicenceList = new list<string>();
      //for(EDQ_Licence_Key__mdt elkm : [select label from EDQ_Licence_Key__mdt]){
      //  EDQLicenceList.add(elkm.label.toUpperCase());
      // }
      //for (OpportunityLineItem eachLI: opp.OpportunityLineItems) {
      //    if (((eachLI.Data_Usage__c != null && EDQLicenceList.contains(eachLI.Data_Usage__c.toUpperCase()))|| eachLI.Manual_Registration__c == true) && eachLI.Users_To__c == null){
      //        isCriteriaMet = false;
      //        errorMessage += system.label.OECS_MSG_USER_TO_REQUIRED;
      //        break;
      //    }
      // }
      // 8/8/19 - CP
      if (opp.Owner_s_Business_Unit__c == 'NA Consumer Services') {
          /*if (String.isBlank(opp.Customer_Base_Migration__c)) {
              isCriteriaMet = false;
              errorMessage += Label.OPPTY_CONTRACT_REQ;
          }*/ // RJ commented for case # 19624121

          for (OpportunityLineItem eachLI: opp.OpportunityLineItems) {
              if (String.isBlank(eachLI.Blanket_Coverage__c) || String.isBlank(eachLI.Product_Features__c)) {
                  isCriteriaMet = false;
                  errorMessage += Label.OPPTY_CONTRACT_REQ2;
                  break;
              }
          }
      }
      

    system.debug('\n[Opportunity_ExitCriteriaUtility: isStage6ExitCriteriaMet] stage 6 met:' +isCriteriaMet);
    return isCriteriaMet;
  }

  //============================================================================================
  // Utility method to check wether quote has been approved
  //============================================================================================
  private static Boolean checkQuoteApproved(Opportunity opp,Boolean isCriteriaMet){
    
    if (opp.Primary_Quote_has_been_Approved__c == false && (opp.Quote_Count__c >= 0 || opp.Quote_Count__c == null) && opp.CPQ_User_to_Validate__c == true && opp.Auto_Renewed__c == False) {
          errorMessage += Label.OECS_MSG_APPROVED_QUOTE_REQUIRED;
          isCriteriaMet = false;

        }
    return isCriteriaMet;
  }

  //============================================================================================
  // Utility method to check wether an Opp has a required task or not by specifying the task Type
  //============================================================================================
  public static Boolean hasRequiredTask(Opportunity opp, String taskType) {
    if (opp.Tasks.size() > 0) {
      for (Task t: opp.Tasks) {
        if (String.isNotBlank(t.Outcomes__c) && t.Outcomes__c.containsIgnoreCase(taskType) && String.isNotEmpty(t.Status) && t.Status.equalsIgnoreCase(Constants.STATUS_COMPLETED)) {
          return true;
        }
      }
    }
    return false;
  }

  public static Boolean hasTechSuppFieldRequired(Opportunity opp) {
    Boolean foundTechRequirement = false;
    try {
      if (Constants.REGION_EMEA.equals(opp.Owner.Region__c) && opp.Type.startsWith('New')) {
        for (OpportunityLineItem oli : opp.OpportunityLineItems) {
          if (oli.PriceBookEntry != null && oli.PriceBookEntry.Product2 != null) {
            Product2 p = oli.PriceBookEntry.Product2;
            if (Constants.USER_GBL_DECISION_ANALYTICS.equals(p.Global_Business_Line__c)) {
              if ('Software'.equals(p.Business_Line__c)) {
                if (String.isNotBlank(oli.Type_of_Sale__c) && oli.Type_of_Sale__c.contains('Maintenance')) {
                  foundTechRequirement = true;
                }
              }
            }
          }
        }
      }
    }
    catch (Exception e) {
      system.debug(e.getMessage());
    }
    return foundTechRequirement;
  }

}