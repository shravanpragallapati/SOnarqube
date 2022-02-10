/**=====================================================================
 * Appirio, Inc
 * Name: Constants
 * Description: Class to hold constants used throughout the application
 * Created Date: Feb 03rd, 2014
 * Created By: Naresh Kr Ojha (Appirio)
 *
 * Date Modified        Modified By                  Description of the update
 * 02/07/2014           Sadar Yacob                  Added Constants for CaseTriggerHandler
 * Feb 12th, 2014       Nathalie Le Guay             Added GLOBAL_SETTING
 * Feb 16th, 2014       Nathalie Le Guay             Merge to add OPPTY_CLOSED_LOST and OPPTY_STATUS_LOST back
 * Feb 20th, 2014       Nathalie Le Guay (Appirio)   Adding SObject Names
 * Feb 26th, 2014       Nathalie Le Guay             Adding Activity Types
 * Feb 28th, 2014       Nathalie Le Guay             Adding Profile & Account Team Roles
 * Mar 03rd, 2014       Arpita Bose (Appirio)        Added Constants for Access Level, Node Type
 * Mar 04th, 2014       Arpita Bose (Appirio)        Added Constansts for Trigger Names
 * Mar 18th, 2014       Naresh Kr Ojha               Added Oppty type renwal constant
 * Mar 21st, 2014       Nathalie Le Guay             Added ORDERTYPE_TRIAL
 * Mar 07th, 2014       Nathalie Le Guay             Added ORDER_LINE_ITEM_RENEWAL_ONE_OFF & ORDER_RENEWAL
 * Apr 07th, 2014       Arpita Bose                  Added RECORDTYPE_MASS_TRANSFER_REQUEST
 * Apr 09th, 2014       Nathalie Le Guay             Added SOBJECT_ORDER_REVENUE_SCHEDULE, REGION_INDIA,
 *                                                   REGION_LATAM, REGION_EMEA, REGION_NA, REGION_UKI
 *                                                   STATUS_NEW, CASE_TYPE_INTERNAL, STATUS_PENDING
 * Apr 10th, 2014       Nathalie Le Guay             PROFILE_EXP_SALES_ADMIN becomes 'Experian Sales Effectiveness'
 * Apr 11th, 2014       Naresh Kr Ojha               GROUP_DELIVERY_MANAGEMENT added 'Delivery Management'
 * Apr 16th, 2014       Jinesh Goyal                 Added Constants for picklist values in User.Global_Business_Line__c
 * Apr 17th, 2014       Nathalie Le Guay             Added STATUS_ACTIVE
 * Apr 18th, 2014       Rahul Jain                   Added Constant -for trigger ESDEL_TimecardTrigger (for T-270393 and T-270392)
 * Apr 23rd, 2104       Rahul Jain                   Added Constant -for Case Type - CASE_TYPE_SPAIN_DELIVERY_TASK(for T-270394)
 * Apr 28th, 2014       Arpita Bose                  Added Constant ADDRESS_CA_AIAU_BIBU_TRIGGER
 * Apr 28th, 2014       Rahul Jain                   Added Constants.OPPORTUNITY_PLAN_TRIGGER for (T-273695)
 * May 1st,  2014       Rahul Jain                   Added Constants.ACCOUNT_PLAN_TEAM_TRIGGER for (T-275542)
 * May 7th,  2014       Rahul Jain                   Added Constants ACCOUNT_PLAN_SWOT_TRIGGER,ACCOUNT_PLAN_OPPORTUNITY_TRIGGER for T-276704, T-276706
 * May 20th, 2014       Jinesh Goyal                 Added STATUS_INACTIVE
 * Aug 20th, 2014       Arpita Bose                  Added SOBJECT_PROJECT
 * Sep 08th, 2014       Arpita Bose                  Added Constants for CaseTrigger_ResolutionTime
 * Sep 16th, 2014       Arpita Bose                  Added Constant CASE_REC_TYPE_EDQ_GPD_CASE
 * Sep 17th, 2014       Arpita Bose                  Added constants for T-319512
 * Sep 18th, 2014       Noopur (Appirio)             Added constants for a profile T-320438
 * Sep 19th, 2014       Nathalie Le Guay             Added EDQ
 * Sep 23rd, 2014       Arpita Bose                  Added OPPTY_CONTACT_ROLE_RENEWAL and OPPTY_CONTACT_ROLE_UPDATE
 * Sep 18th, 2014       James Weatherall             Case #6875: Added TEAM_ROLE_STRAT_ACCOUNT_MANAGER
 * Sep 28th, 2014       Nathalie Le Guay             Added TIMECARD_TYPE_DELIVERY and TIMECARD_TYPE_TRAVEL
 * Sep 26th, 2014       Arpita Bose                  Added Constants for T-322814
 * Oct 1st, 2014        Nathalie                     Added RECORDTYPE_CASE_EDQ_COMMERCIAL, RECORDTYPE_CASE_SPANISH, RECORDTYPE_CASE_EDQ
 * Oct 6/7th, 2014      Nathalie                     Added SOBJECT_ASSET, REGION_LATIN_AMERICA, REGION_GLOBAL, OPPTY_SALES_PROCESS_STANDARD
 * Oct 9th,  2014       Noopur                       Added Constant for Opportunity Type Credited
 * Oct 13th, 2014       Pallavi Sharma               Added Constant for Order Line Item Delivery Method
 * Oct 20th, 2014       Arpita Bose                  Updated for task T-326528
 * Oct 21st, 2014       Arpita Bose                  Added Constant SOBJECT_USER
 * Oct 22th, 2014       Pallavi Sharma               Added Constant for Country Japan
 * Oct 27th, 2014       Nathalie Le Guay             Added ASSET_ITEM_NUMBER and ASSET_QUOTE_NUMBER
 * Nov 03rd, 2014       Nathalie Le Guay             I-137453: COPS Roles
 * Nov 25th, 2014       Naresh Kr Ojha               Added : EDQ user types on user object for field EDQ_User_Type__c
 * Dec 03rd, 2014       Arpita Bose                  Added Constants for RLI.Type__c and RLI.Status__c
 * Dec 05th, 2014       James Weatherall             Case #9748 Pre Sales Support Constants SALES_SUPPORT_REQUEST_TRIGGER, SOBJECT_SALES_SUPPORT_REQUEST, REDIRECT_PRE_SALES_SUPPORT
 * Dec 23rd, 2014       Nathalie                     Added ASSET_IMPLEMENTATION_ON_DEMAND
 * Jan 13th, 2015       Arpita Bose                  Added Constants for T-349831
 * Jan 19th, 2015       Naresh Kr Ojha               Added Constants for String Ignore and Service.
 * Jan 21st, 2015       Arpita Bose                  Added Constant  ACCOUNT_ASSIGNMENT_TEAM_TRIGGER
 * Jan 28th, 2015       Naresh Kr Ojha               Added ACCOUNTPLAN_CSF_TRIGGER
 * Feb 02nd, 2015       Naresh Kr Ojha               Added String Constants for Positive and Negative string values.
 * Feb 10th, 2015       Gaurav Kumar Chadha          Added String Constant for Order Type Free Trial
 * Feb 18th, 2015       Arpita Bose                  Added constants BUSINESSPROCESS_TRIGGER
 * Feb 20th, 2015       Arpita Bose                  Updated for deployment of S-281999 to merge the code of DevOppStag
 * Feb 24th, 2015       Gaurav Kumar Chadha          Added constant for Picklist value buisnessProcessItem.Status__c i.e READY
 * Feb 26th, 2015       Gaurav Kumar Chadha          Added constant  MEMBERSHIP_CHANGE_TYPE_STATUS , MEMBERSHIP_CHANGE_TYPE_OWNER
                                                     MEMBERSHIP_HISTORY_OWNER_TYPE_USER , HISTORY_OWNER_TYPE_USER , HISTORY_OWNER_TYPE_QUEUE
 * Feb 26th, 2015       James Weatherall             Added ACTIVITY_TYPE_CROSS_BUSINESS_UNIT
 * Mar 3rd,  2015       Gaurav Kumar Chadha          Added constact for ContractTrigger , VALIDATION_STATUS_FAIL , Agency
 * Mar 4th, 2015        James Weatherall             Case #542997: Added Case Record Types for SLA Metrics
 * Mar 11th, 2015       Terri Kellough               Changed ASSET_TRIGGER = 'AssertTrigger' to ASSET_TRIGGER = 'AssetTrigger'
 * Mar 11th, 2015       Diego Olarte                 Case #583716: OpportunityContactAddressTriggerHandler
 * Mar 23rd, 2015       Nathalie Le Guay             T-372844: Update OPPTY_CONTACT_ROLE_PURCHASE_LEDGER from 'Purchase Ledger' to 'Bill-To'
 * Mar 26th, 2015       Terri Kellough               Changed MEMBERSHIP_CHANGE_TYPE_STATUS to CHANGE_TYPE_STATUS as a part of
 * Mar 27th, 2015       Naresh Kr                    Added STR_QUEUE constant.
 * Apr 01st, 2015       Terri Kellough               T-375024 Added BUSINESSPROCESSTEMPLATEITEM_TRIGGER, PROFILE_EXP_ATTORNEY_MEMBERSHIP, PERMISSIONSET_BPT_ADMINISTRATOR
 * Apr 3th, 2015        Nur Azlini                   Case #555032: Added STATUS_EXPIRED
 * Apr 08th, 2015       Terri Kellough               Added Business Process Template constants section
 * Apr 10th, 2015       Terri Kellough               Changed RELATED_TO_MEMBERSHIPS from Memberships to Membership
 * Apr 13th, 2015       Paul Kissick                 Case #607717: Added ORDER_TYPE_CREDIT_NOTE
 * Apr 15th, 2015       Nathalie Le Guay             Added ACCOUNT_SEGMENT_*
 * Apr 20th, 2015       Paul Kissick                 Case #593979: Added TEAM_ROLE_RENEWAL_OWNER
 * Apr 22nd, 2015       Arpita Bose                  I-156139: Added CPQ_USERTYPE_*
 * Apr 23th, 2014       Richard Joseph               Case # 00607940- Added RPI % and RPI Amount field names for Asset
 * Apr 27th, 2015       Nathalie Le Guay             Adding MEMBERSHIP_TRIGGER
 * Apr 29th, 2015       Noopur                       Added constants for EMS case functionality
 * Apr 29th, 2015       Arpita Bose                  Added constants CASE_COMMENT_TRIGGER
 * May 01st, 2015        Terri Kellough               Added ORDER_TYPE_NEW_FROM_NEW
 * May 09th, 2015        Nathalie Le Guay             Added new Oppty close reasons: OPPTY_PRIMARY_CLOSED_REASON_INADEQUATE_COMP_CAP,
 *                                                   *EXP_STRATEGIC_DECISION, INADEQUATE_SERVICE_REC
 * May 19th, 2015       Nur Azlini                    Case #630336 - Added new EDQ COPS Group
 * Jul 10th, 2015       Paul Kissick                  Case #988670 - Fixed role that was renamed in Prod
 * July 10th, 2015      James Weatherall              Case #648853 - Added REGION_APAC
 * Aug 12th, 2015       Naresh Kr Ojha                I-175699: Added Direct Sales Constant as ORDER_CHANNEL_SOURCE_DIRECT_SALES
 * Aug 14th, 2015       Paul Kissick                  Case #01039554 - Adding 2 more channel types
 * Aug 17th, 2015       Terri Jiles                   Added ACC_WS_ACTION_NO_ADRESS
 * Aug 19th, 2015       Parul Gupta                   T-424576: Added Case Record type constants
 * Aug 22nd, 2015       Terri Jiles                   Added ACC_WS_ACCOUNT_MATCHED_BY_NAME_AND_ADDRESS and ACC_WS_ACCOUNT_MATCHED_BY_ID, ACC_WS_ACCOUNT_NO_ACCOUNT, ACC_WS_ACCOUNT_NO_CONTACT
 * Aug 23rd, 2015       Terri Jiles                   Added ACC_WS_ACTION_DEFAULT_ADDRESS
 * Aug 28th, 2015       Terri Jiles                   Added ACC_WS_ACTION_MISSING_MINIMAL_INFO
 * Oct 01st, 2015       Arpita Bose                   I-182628 : Added RECORDTYPE_LEAD_LATAM_SERASA
 * Oct 14th, 2015       Paul Kissick                  Case 01169791: Adding reference to Stage_2_Duration__c for calculations
 * Nov 16th, 2015       Nur Azlini                    Added new picklist value for Deployment Request
 * Nov 20th, 2015       Paul Kissick                  Case 01251745: Replaced 'Approved' with 'SA Approved'
 * Jan 5th,  2016       James Wills                   Case 01266714: Updated Constant names and text to reflect updates to Case Record Types (see comments below).
 * Jan 15th, 2016       Diego Olarte                  Case 01135171: Added PROFILE_CHATTER_FREE_USER
 * Jan 26th, 2016       Tyaga Pati                    Case 01789056: Added RECORDTYPE_CASE_AUTOMOTIVE  to hold Automotive Record type Name
 * Mar 29th, 2016       Miguel Rodriguez              Case 1821654: Relabel role NA MS EDQ Customer Operations to NA CS EDQ Customer Operations
 * Apr 12th, 2016       Paul Kissick                  Case 00986897: Adding new constant OPPTY_LINE_ITEM_TYPE_RENEWAL & ORDER_LINE_ITEM_TYPE_RENEWAL
 * Apr 13th, 2016       Paul Kissick                  Case 01925347: New oppty team roles TEAM_ROLE_PRICING_LEAD & TEAM_ROLE_COMMERCIAL_OPERATIONS
 * May 17th, 2016       Sadar Yacob                   Rolling back Case #00986897 : Since its not yet in the release  OPPTY_LINE_ITEM_TYPE_RENEWAL & ORDER_LINE_ITEM_TYPE_RENEWAL)
 * June 8th, 2016       James Wills                   Case 01192655: Show the Business Unit alongside each AE under Account Team
 * July 11th, 2016(QA)  Tyaga Pati                    CRM2:W-005396 -- Changing constant value Decider to Decission Maker
 * Aug 5th, 2016        Paul Kissick                  CRM2:W-005393: Removed Lead Qualifier - All code now references Sales Rep
 * Aug 22nd, 2016       Paul Kissick                  CRM2:W-005405: Adding new contact status (Inactive) - Removed unused constants
 * Aug 31st, 2016       Manoj Gopu                    CRM2.W-005424: Adding new constant names for Task Standard and  Marketing Activity Record types and Opportunity Transactional sale record type
 * Sep 28th, 2016       Manoj Gopu                    CRM2.W-005949: Adding new constant  for Opportunity free trial recordtype
 * Nov. 10th, 2016      James Wills                   Case 02201503: Updated to include constant for Platform Support Case Record Type
 * Nov 18th, 2016       Manoj Gopu                    ITSM.W-006264: Adding new constant  for Case Service Central Record type and add Case FieldSet.       
 * Nov 18th, 2016       Manoj Gopu                    ITSM.W-006282: Adding new constant  for Asset FieldSet.
 * Dec  05th, 2016      Manoj Gopu                    Case 02215771: Adding new constant  for Opportunity Partner Community recordtype
 * Dec  13th, 2016      Diego Olarte                  Case 01265676: Adding new constant  CASE_STATUS_CLOSED_COMPLETE, CASE_STATUS_CLOSED_PENDING_ACCEPTANCE, CASE_STATUS_CLOSED_NO_ACTION, CASE_STATUS_CLOSED_CANCELLED, CASE_STATUS_CLOSED_NOT_RESOLVED, CASE_STATUS_CLOSED_ESCALATED for EDQ Hard close process
 * Dec 13th, 2016       Manoj Gopu                    Case #02196955 Added a new constant Consultant for Opportunity team role
 * Dec 15th, 2016       Manoj Gopu                    Case #02136424 Added a new constant Completed for Task Status
 * Dec. 9th, 2016       James Wills                   DRM:W-006453: Added REGION_NORTH_AMERICA, ACCOUNT_SEGMENT_TRIGGER     
 * Dec. 15th, 2016      James Wills                   DRM:W-006551: Added ACCOUNT_STAGING_TRIGGER
 * Jan 12th, 2016       Diego Olarte                  Case #02184830:Adding new constant OPPTY_CONTACT_ROLE_DECISION_MAKER
 * Jan 26th, 2017       Sanket Vaidya                 Case #02239844: Added new constant BUSINESS_UNIT_UKI_GTM = 'UK&I GTM';
 * Feb 24th, 2017       Manoj Gopu                    Case #02227631: Updated the Spelling for the existing Constant Selection confirmed 
 * Mar 21st, 2017       Manoj Gopu                    W-007099: Added new Constants for Serasa Recordtypes for Case and Contact
 * Apr 27st, 2017       Manoj Gopu                    W-007318: Added new Constant for CaseActivitytrigger.
 * May 4th,  2017       Ryan (Weijie) Hu              W-007121: Added new Constant for Serasa Customer Care Profiles 
 * May 16th, 2017       Sanket Vaidya                 Case 02166372 - New Customer Success Process - OPPTY_NEW_FROM_NEW, OPPTY_NEW_FROM_EXISTING
 * Jun 19th, 2017       James Wills                   Case 02233635 - Added entry for PROFILE_EXP_SERASA_SALES_OPERATION
 * Jun 26th, 2017       James Wills                   Case 02233635 - Added OPPTY_STATUS_REJECTED.
 * Jul 26th, 2017       Mauricio Murillo              Case 02394456 - Added UK_I_MS_DATA_QUALITY
 * Jul 26th, 2017       Diego Olarte                  User Story US-0000026 - Added new constant COPADO_USER_STORY_TRIGGER
 * Aug 14th, 2017       Mauricio Murillo              Case 02322628 - Added new constant FEED_ITEM_TRIGGER
 * 18 Aug 2017          Tyaga Pati                    Case 13566757 Added new Record type to List of Records types "'EDQ Business Operations'
 * Aug 23th, 2017       Mauricio Murillo              Case 13737951 - Added new constant FEED_COMMENT_TRIGGER 
 * Sep 13th, 2017       Manoj Gopu                    W-009128: Added new Constants for BFS Recordtypes for project and DeliveryLines 
 * Oct 02nd, 2017       Mauricio Murillo              BFS: Added new Constant for CoverLetterTrigger
 * Oct 25th, 2017       Malcolm Russell               DP Migration:W-009619 - New Contact Role Admin Contact
 * Nov 19th, 2017       Diego Olarte                  Case 02334289 - Added new constant PROFILE_XPE_PARTNER_COMM_USER 
 * Nov 26th, 2017       James Wills                   Updated reference to PROFILE_EXP_SERASA_SALES_OPERATION
 * Dec 08th, 2017       Manoj Gopu                    W - 0010207  Added new Constants for Cover Letter Record types
 * Dec 12th, 2017       Malcolm Russell               DP Migration:W-009642:Credit Note Request DP Record Type
 * April 10th 2018      Richard Joseph                DP MIgration - Issue I2340 - added REDIRECT_CREATE_TRANSAC_OPTY
 * May 9th, 2018        Malcolm Russell               CSDA : W-011781 - Make membership rules selective
 * May 16th, 2018       Manoj Gopu                    CSDA : W-011031 - Added new Constant for Membership Request Recordtype
 * Aug 30th, 2018       Mauricio Murillo              PACE : W-012870 - Added new Constant for PACE_Questionnaire Record Type
 * Sep  7th, 2018       Malcolm Russell               PACE : W-012876 - Added new Contaant for PACEProductProposalTeam Trigger
 * Sep  7th, 2018       Herbert Oliveira              PACE : W-012869 - Added new Constant for PACE_Product_Proposal Record Type
 * Nov 30th, 2018       Diego Olarte                  Case 17803866  - Added new constant CSDAMemDocRelationship_Trigger
 * Dec 13th, 2018       Mauricio Murillo              Case 17685968 - Added new Constant INSTALLMENT_PERIOD_SEMIANNUAL
 * Feb 12th, 2019       Tianyi Cao                    Task T-03804 - Added new Constant for OutputDelieveryTrigger
 * 25th Aug, 2019       Herbert Oliveira              Case 19538248: New credentialing survey trigger for Clarity accounts
 *Mar 26th, 2021        Navya                         W-031691 - Added New constant variables for confidential information records based on the requirement
 *Apr 22nd, 2021        Navya                         W-031968 - Added New constant variable for NA Targeting Record Type RECORDTYPE_NA_TARGETING
 *July 8th, 2021        Shweta Bhuria                 Case 20883362 - Add New Constant for PRODUCT_MASTER_OBJECT_API_NAME
===========================================================================*/

public with sharing class Constants {


  public static Boolean OPPTY_CHECK_SKIPPING = true;
  public static final String ACCESS_LEVEL_EDIT = 'Edit';
  public static final String ACCESS_LEVEL_READ = 'Read';
  public static final String ACCESS_LEVEL_NONE = 'None';
  public static final String ACCESS_LEVEL_ALL = 'All';
  public static final String READ_ONLY = 'Read Only';
  public static final String OPEN = 'Open';
  public static final String READY = 'Ready';
  public static final String ORDER = 'Order';
  public static final String INSTALLMENT_PERIOD_DAILY = 'Daily';
  public static final String INSTALLMENT_PERIOD_WEEKLY = 'Weekly';
  public static final String INSTALLMENT_PERIOD_MONTHLY = 'Monthly';
  public static final String INSTALLMENT_PERIOD_BI_MONTHLY = 'Bi-Monthly'; //21710723
  public static final String INSTALLMENT_PERIOD_QUATERLY = 'Quarterly';
  public static final String INSTALLMENT_PERIOD_SEMIANNUAL = 'Semiannual'; //17685968
  public static final String INSTALLMENT_PERIOD_YEARLY = 'Yearly';
  public static final String REVENUE_SCHEDULED_TYPE_REPEAT = 'Repeat';
  public static final String REVENUE_SCHEDULED_TYPE_REVENUE = 'Revenue';
  public static final String STATUS_ACTIVE = 'Active';
  public static final String STATUS_INACTIVE = 'Inactive';
  public static final String CONTACT_STATUS_INACTIVE = 'Inactive - Still With Company'; // CRM2:W-005405
  public static final String CONTACT_STATUS_LEFT = 'No Longer With Company';  // CRM2:W-005405

  //Trigger Names
  public static final String ACCOUNT_TRIGGER = 'AccountTrigger';
  public static final String ACCOUNT_SEGMENT_TRIGGER = 'AccountSegmentTrigger';//DRM:W-006453       
  public static final String ACCOUNT_STAGING_TRIGGER = 'AccountStagingTrigger';//DRM:W-006551
  public static final String ACCOUNT_ADDRESS_TRIGGER = 'AccountAddressTrigger';
  public static final String ADDRESS_CA_AIAU_TRIGGER = 'Address_CA_AIAU';
  public static final String ADDRESS_CA_BIBU_TRIGGER = 'Address_CA_BIBU';
  public static final String CASE_TRIGGER = 'CaseTrigger';
  public static final String CASE_Activity_TRIGGER = 'CaseActivityTrigger';
  public static final String CONTACT_ADDRESS_TRIGGER = 'ContactAddressTrigger';
  public static final String CONTACT_TRIGGER = 'ContactTrigger';
  public static final String CONTRACT_TRIGGER = 'ContractTrigger';
  public static final String COPADO_USER_STORY_TRIGGER = 'CopadoUserStoryTrigger';
  public static final String FILTER_CHATTER_FEED_COMMENT_TRIGGER = 'FilterChatterFeedComment';
  public static final String FILTER_CHATTER_FEED_ITEM_TRIGGER = 'FilterChatterFeedItem';
  public static final String LEAD_TRIGGER = 'LeadTrigger';
  public static final String OPPTY_LINE_ITEM_TRIGGER = 'OpportunityLineItemTrigger';
  public static final String OPPORTUNITY_TRIGGER = 'OpportunityTrigger';
  public static final String TASK_TRIGGER = 'TaskTrigger';
  public static final String CONFINFO_TRIGGER = 'ConfidentialInformationTrigger';
  public static final String OPPTYTEAMMEMBER_TRIGGER = 'OpportunityTeamMemberTrigger';
  public static final String ARIAPLAN_TRIGGER = 'ARIAPlanTrigger';
  public static final String USER_TRIGGER = 'UserTrigger';
  public static final String ESDEL_TIMECARD_TRIGGER = 'ESDEL_TimecardTrigger';
  public static final String ADDRESS_CA_AIAU_BIBU_TRIGGER = 'Address_CA_AIAU_BIBU';
  public static final String OPPORTUNITY_PLAN_TRIGGER = 'Opportunity_PlanTrigger';
  public static final String ACCOUNT_PLAN_TEAM_TRIGGER = 'Account_Plan_TeamTrigger';
  public static final String ACCOUNT_PLAN_SWOT_TRIGGER = 'Account_Plan_SWOTTrigger';
  public static final String ACCOUNT_PLAN_OPPORTUNITY_TRIGGER = 'Account_Plan_OpportunityTrigger';
  public static final String ASSET_TRIGGER = 'AssertTrigger';
  public static final String DELIVERY_LINE_TRIGGER = 'DeliveryLineTrigger';
  public static final String ACCOUNT_ASSIGNMENT_TEAM_TRIGGER = 'AccountAssignmentTeamTrigger';
  public static final String ACCOUNTPLAN_CSF_TRIGGER = 'AccountPlan_CSF_Trigger';
  public static final String ACCOUNTPLANCOMPETITOR_TRIGGER = 'AccountPlanCompetitorTrigger';
  public static final String ASSIGNMENTTEAMMEMBER_TRIGGER = 'AssignmentTeamMemberTrigger';
  public static final String BUSINESSPROCESSITEM_TRIGGER = 'BusinessProcessItemTrigger';
  public static final String DEPLOYMENT_TRIGGER = 'DeploymentTrigger';
  public static final String SALES_SUPPORT_REQUEST_TRIGGER = 'SalesSupportRequestTrigger';
  public static final String BUSINESSPROCESS_TRIGGER = 'BusinessProcessTrigger';
  public static final String BUSINESSPROCESSTEMPLATEITEM_TRIGGER = 'BusinessProcessTemplateItemTrigger';
  public static final String ORDER_TRIGGER = 'OrderTrigger';
  public static final String OPPORTUNITY_CONTACT_ADDRESS_TRIGGER = 'OpportunityContactAddressTrigger';
  public static final String MEMBERSHIP_TRIGGER = 'MembershipTrigger';
  public static final String FEED_ITEM_TRIGGER = 'FeedItemTrigger';
  public static final String FEED_COMMENT_TRIGGER = 'FeedCommentTrigger';
  public static final String COVER_LETTER_TRIGGER = 'CoverLetterTrigger';
  public static final String Project_Product_Score_TRIGGER = 'ProjectProductScoreTrigger';
  public static final String PACEProductProposalTeam_Trigger = 'PACEProductProposalTeamTrigger';
  public static final String CSDAMemDocRelationship_Trigger = 'CSDAMemDocRelationshipTrigger';
  public static final String OUTPUT_DELIVERY_TRIGGER = 'OutputDeliveryTrigger';
  public static final String ApexLog_TRIGGER = 'ApexLogTrigger'; // W-030936
  public static final String ThirdPartyInformation_TRIGGER = 'ThirdPartyInformationTrigger'; // W-031565
  // Custom Settings Constants
  public static final String GLOBAL_SETTING = 'Global';

  public static final String OPPTY_STAGE_2 = 'Identify'; // PK: 01169791
  public static final String OPPTY_STAGE_3 = System.Label.OPPTY_STAGE_QUALIFY; // '3 - Qualify opportunity';
  public static final String OPPTY_STAGE_4 = System.Label.OPPTY_STAGE_PROPOSE; // '4 - Tailor and present solutions';
  public static final String OPPTY_STAGE_5 = System.Label.OPPTY_STAGE_COMMIT; // '5 - Negotiate sale';
  public static final String OPPTY_STAGE_6 = System.Label.OPPTY_STAGE_CONTRACT; //'6 - Negotiate contract';
  public static final String OPPTY_STAGE_7 = System.Label.OPPTY_STAGE_EXECUTE; // '7 - Implement solution';
  public static final String OPPTY_PARTNER_STAGE_3 = System.Label.OPPTY_PARTNER_STAGE_QUALIFY; // '3 - Partner Qualify';
  public static final String OPPTY_PARTNER_STAGE_5 = System.Label.OPPTY_PARTNER_STAGE_COMMIT; 
  public static final String OPPTY_PARTNER_STAGE_6 = System.Label.OPPTY_PARTNER_STAGE_CONTRACT;
  public static final String OPPTY_STAGE_SETUP = 'Set-up';
  public static final String STAGE_CLOSED_WON = System.Label.OPPTY_STAGE_EXECUTE; //'7 - Implement solution';
  public static final String OPPTY_CLOSED_LOST = 'Closed Lost';
  public static final String OPPTY_STAGE_CLOSED_WON = 'Closed Won';
  public static final String OPPTY_STATUS_REJECTED = 'Rejected';//Case #02233635
  public static final String OPPTY_STATUS_LOST = 'Lost';
  public static final String OPPTY_STAGE_EXECUTION = 'Execution';
  //public static final String DECIDER = 'Decider';
  public static final String DECIDER = 'Decision Maker';
  public static final String PRIMARY_REASON_WLC_DATA_QUALITY = 'Data Quality';
  public static final String PRIMARY_REASON_WLC_TERMS = 'Terms';
  public static final String PRIMARY_REASON_WLC_COMPETITION = 'Competition';
  public static final String STANDARD_PRICE_BOOK = 'Standard Price Book';


  public static final String ORDERTYPE_TRIAL = 'Trial';
  public static final String ORDER_LINE_ITEM_RENEWAL_ONE_OFF = 'One-off Sale';
  public static final String ORDER_LINE_ITEM_TYPE_RENEWAL = 'Renewable';// Case 00986897
  public static final String ORDER_RENEWAL = 'Renewal';
  public static final String ORDER_TYPE_CREDITED = 'Credited';
  public static final String ORDER_TYPE_CREDIT_NOTE = 'Credit Note';
  public static final String ORDER_TYPE_NEW_FROM_NEW = 'New From New'; //May 1st, 2015 - added by ttk

  public static final String PARAM_NAME_RETURL = 'retURL';
  public static final String STATUS_COMPLETED = 'Completed';
  public static final String STATUS_NEW = 'New';
  public static final String STATUS_PENDING = 'Pending';
  public static final String STATUS_EXPIRED = 'Expired';

  // Objects
  public static final String SOBJECT_EVENT = 'Event';
  public static final String SOBJECT_TASK = 'Task';
  public static final String SOBJECT_MKTG_ACTIVITY = 'ELQA_Marketing_Activity__c';
  public static final String SOBJECT_CONTACT = 'Contact';
  public static final String SOBJECT_CASE = 'Case';
  public static final String SOBJECT_ACCOUNT = 'Account';
  public static final String SOBJECT_OPPORTUNITY = 'Opportunity';
  public static final String SOBJECT_CAMPAIGN = 'Campaign';
  public static final String SOBJECT_ORDER = 'Order__c';
  public static final String SOBJECT_ORDER_LINE_ITEM = 'Order_Line_Item__c';
  public static final String SOBJECT_ORDER_REVENUE_SCHEDULE = 'Order_Revenue_Schedule__c';
  public static final String SOBJECT_PROJECT = 'Project__c';
  public static final String SOBJECT_ASSET = 'Asset';
  public static final String SOBJECT_USER = 'User';
  public static final String SOBJECT_CONFIDENTIAL_INFO = 'Confidential_Information__c';
  public static final String SOBJECT_SALES_SUPPORT_REQUEST = 'Sales_Support_Request__c';
  public static final String SOBJECT_CONTRACT = 'Contract__c';
  public static final String SOBJECT_MEMBERSHIP = 'Membership__c';
  public static final String SOBJECT_OPPORTUNITYLINEITEM = 'OpportunityLineItem';
  public static final String SOBJECT_LEAD = 'Lead';


  // Profile
  public static final String PROFILE_EXP_SALES_EXEC = 'Experian Sales Executive';
  public static final String PROFILE_EXP_APAC_SALES_EXEC = 'Experian APAC Sales Executive';
  public static final String PROFILE_EXP_UKI_EMEA_SALES_EXEC = 'Experian UK&I/EMEA Sales Executive';
  public static final String PROFILE_SYS_ADMIN = 'System Administrator';
  public static final String PROFILE_EXP_SALES_ADMIN = 'Experian Sales Effectiveness';
  public static final String PROFILE_EXP_SALES_MANAGER = 'Experian Sales Manager';
  public static final String PROFILE_EXP_APAC_SALES_MANAGER = 'Experian APAC Sales Manager';
  public static final String PROFILE_EXP_UKI_EMEA_SALES_MANAGER = 'Experian UK&I/EMEA Sales Manager';
  public static final String PROFILE_EXP_FINANCE = 'Experian Finance';
  public static final String PROFILE_EXP_SALES_SUPPORT = 'Experian Sales Support';
  public static final String PROFILE_EXP_APAC_SALES_SUPPORT = 'Experian APAC Sales Support';
  public static final String PROFILE_EXP_UKI_EMEA_SALES_SUPPORT = 'Experian UK&I/EMEA Sales Support';
  public static final String PROFILE_EXP_PROJ_DELIVERY_MANAGER = 'Experian Project / Delivery - Manager';
  public static final String PROFILE_EXP_ATTORNEY_MEMBERSHIP = 'Experian Attorney / Membership';
  public static final String PROFILE_CHATTER_FREE_USER = 'Chatter Free User';
  public static final String PROFILE_XPE_PARTNER_COMM_USER = 'XPartner - NA Auto Sales Exec';
  //public static final String PROFILE_XPE_PARTNER_COMM_USER = 'Xperian Partner Community User'; //DO: Case 02334289
  public static final String PROFILE_XPARTNER_EXP_SALES_EXEC = 'XPartner Experian Sales Exec';
  public static final String PROFILE_GLOBAL_EXPERIAN_EMPLOYEE = 'Global Experian Employee';
  public static final String PROFILE_GLOBAL_EXPERIAN_EMPLOYEE_MANAGER = 'Global Experian Employee - Manager';

  public static final String PROFILE_EXP_CERT_SALES_ADMIN = 'Experian Certified Sales Administrators';//Case 01192655
  public static final String PROFILE_EXP_DQ_ADMIN = 'Experian DQ Administration';                     //Case 01192655


  //permission sets
  public static final String PERMISSIONSET_BPT_ADMINISTRATOR = 'Business_Process_Template_Administrator';
  public static final String PERMISSIONSET_EDQ_SAAS_DEPLOYMENT_MANAGER = 'EDQ_SaaS_Deployment_Manager';
  public static final String PERMISSIONSET_MODERATOR = 'Moderator'; //Permission set for community moderators

  // Roles
  public static final String ROLE_GLOBAL_ADMIN = 'Global Admin';
  public static final String ROLE_SALES_EXEC_RETAIL_PROPERTY = 'UK&I MS Targeting Retail Sales';  // Case #988670 - Changed because the role has changed in prod
  //public static final String ROLE_NA_COPS = 'NA MS EDQ Customer Operations';
  public static final String ROLE_NA_COPS = 'NA CS EDQ Customer Operations'; // Case 1821654: Relabel role NA MS EDQ Customer Operations
  public static final String ROLE_UKI_COPS = 'UK&I MS EDQ Customer Operations';

  // Team Role
  public static final String TEAM_ROLE_SALES_REP = 'Sales Rep';
  public static final String TEAM_ROLE_SALES_MANAGER = 'Sales Manager';
  public static final String TEAM_ROLE_ACCOUNT_MANAGER = 'Account Manager';
  public static final String TEAM_ROLE_STRAT_ACCOUNT_MANAGER = 'Strategic Account Manager'; // 09182014 JW - Case #6875
  public static final String TEAM_ROLE_CHANNEL_MANAGER = 'Channel Manager';
  public static final String TEAM_ROLE_PRE_SALES_CONSULTANT = 'Pre-Sales Consultant'; // 14th April, 2015 JW - Case #9748
  public static final String TEAM_ROLE_DELIVERY_TEAM = 'Delivery Team';
  // public static final String TEAM_ROLE_LEAD_QUALIFIER = 'Lead Qualifier'; // CRM2:W-005393: Replaced with Sales Rep
  public static final String TEAM_ROLE_RENEWAL_OWNER = 'Renewal Owner'; // 20/4/15 PK: Case #593979
  public static final String TEAM_ROLE_PRICING_LEAD = 'Pricing Lead';  // Case 01925347
  public static final String TEAM_ROLE_COMMERCIAL_OPERATIONS = 'Commercial Operations'; // Case 01925347
  public static final String CASE_TEAM_ROLE_REQUESTOR = 'Requestor';


  //OLI
  public static final String CURRENCY_GBP = 'GBP';
  public static final String CURRENCY_USD = 'USD';
  public static final String CURRENCY_EUR = 'EUR';
  public static final String CURRENCY_AUD = 'AUD';

  public static final String CORPORATE_ISOCODE = 'USD';
  public static final String PRODUCT_COMPLEX = 'Complex';
  public static final String PRODUCT_SIMPLE_COMPLEX = 'Simple / Complex';


  //Closed/Lost labels for Opportunity used by OpportunityClosedLostExtension.cls
  public static final String OPPTY_PRIMARY_CLOSED_REASON_OTHER = 'Other';
  public static final String OPPTY_STAGE_NO_DECISION = 'Closed No Decision';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_ASPROJECT = 'Abandon/Stalled Project';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_EXPERION_NO_GO_DECISION = 'Experian No Go Decision';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_CUSTOMER_UNDECIDED = 'Customer Undecided';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_NO_BUDGET = 'No/Insufficient Budget';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_INADEQUATE_DATA_QUALITY = 'Inadequate Data Quality';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_INADEQUATE_DATA_RANGE = 'Inadequate Data Range';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_INADEQUATE_DEL_CAP = 'Inadequate Delivery Capability';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_LEGAL_REST = 'Legal Restriction';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_LOST_TO_COMPE = 'Lost to Competition';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_PRICE_TOO_HIGH = 'Price Too High';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_INADEQUATE_FUNCTIONALITY = 'Inadequate Product / Functionality';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_INADEQUATE_TERMS = 'Inadequate Terms';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_INADEQUATE_CLI_REL = 'Inadequate Client Relationship';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_INADEQUATE_COMP_CAP = 'Inadequate Compliance Capability';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_EXP_STRATEGIC_DECISION = 'Experian Strategic Decision';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_INADEQUATE_SERVICE_REC = 'Inadequate service record';
  public static final String OPPTY_PRIMARY_CLOSED_REASON_SUPERSEDED_OPP = 'Superseded Opportunity';
  public static final String OPPTY_TYPE_RENEWAL = 'Renewal';
  public static final String OPPTY_TYPE_NEW_FROM_NEW = 'New From New';
  public static final String OPPTY_TYPE_NEW_FROM_EXISTING = 'New From Existing';
  public static final String OPPTY_TYPE_CREDITED = 'Credited';
  public static final String OPPTY_FORECAST_CATEGORY_PIPELINE = 'Pipeline';
  public static final String OPPTY_FORECAST_CATEGORY_FORECAST = 'Forecast';
  public static final String OPPTY_NEW_FROM_NEW = 'New From New';
  public static final String OPPTY_NEW_FROM_EXISTING = 'New From Existing';
  public static final String CROSS_SELL = 'Cross-Sell';
  public static final String OPPTY_LINE_ITEM_TYPE_RENEWAL = 'Renewable';// Case 00986897

  // Activity Types
  public static final String ACTIVITY_TYPE_QUOTE_DELIVERED      = 'Quote delivered';
  public static final String ACTIVITY_TYPE_SELECTION_CONFIRMED  = 'Selection confirmed';
  public static final String ACTIVITY_TYPE_SIGNED_CONTRACT      = 'Received signed contract';
  public static final String ACTIVITY_TYPE_CROSS_BUSINESS_UNIT  = 'Cross Business Unit Lead'; // JW - 26/02/2015 - Case #562501

  // URL Redirect Page Actions
  public static final String REDIRECT_CREATE_OPPORTUNITY = 'createOpportunity';
  public static final String REDIRECT_CREATE_ORDER = 'createOrder';
  public static final String REDIRECT_PRE_SALES_SUPPORT = 'createPreSalesSupport';

  //Address Merge Request merge process status
  public static final String MERGE_PROCESS_STATUS_PENDING = 'Pending';
  public static final String MERGE_PROCESS_STATUS_FAILURE = 'Failure';
  public static final String MERGE_PROCESS_STATUS_SUCCESS = 'Success';
  public static final String MERGE_TYPE_MANUAL = 'Manual Merge';
  public static final String MERGE_TYPE_BOOMI = 'Integration Merge via Boomi';
  public static final String BOOMI = 'Boomi';
  public static final String MANUAL = 'Manual';

  //Address Type
  public static final String ADDRESS_TYPE_REGISTERED = 'Registered';
  public static final String ADDRESS_TYPE_SECONDARY = 'Secondary';

  //Country Name
  public static final String COUNTRY_NAME_DEFAULT ='Default';
  public static final String COUNTRY_NAME_JAPAN ='Japan';

  //Constants used for BURelationshipCalculator
  public static final String BUSINESS_UNIT_MS_CIT = 'MS: CI&T';
  public static final String GLOBAL_BUSINESS_MARKETING_SERVICES = 'Marketing Services';
  public static final String BU_RELATIONSHIP_TYPE_PROSPECT = 'Prospect';
  public static final String BU_RELATIONSHIP_TYPE_CLIENT = 'Client';
  public static final String BU_RELATIONSHIP_TYPE_FORMER_CLIENT = 'Former Client';
  public static final String BUSINESS_UNIT_UKI_GTM = 'UK&I GTM';

  //Constants used for USER's Business Line
  public static final String USER_BUSINESS_LINE_DC = 'UK&I Decision Analytics';
  public static final String USER_BUSINESS_LINE_CS = 'UK&I Credit Services';


  public static final String ACCOUNT_SEGMENT_GBL = 'Global Business Line';
  public static final String ACCOUNT_SEGMENT_BL = 'Business Line';
  public static final String ACCOUNT_SEGMENT_BU = 'Business Unit';
  public static final String ACCOUNT_SEGMENT_REGION = 'Region';
  public static final String ACCOUNT_SEGMENT_COUNTRY = 'Country';


  //Node type
  public static final String NODE_TYPE_START = 'start';
  public static final String NODE_TYPE_END = 'end';
  public static final String NODE_TYPE_CHILD = 'child';
  public static final String NODE_TYPE_CHILD_END = 'child_end';
  public static final String NODE_TYPE_PARENT = 'parent';
  public static final String NODE_TYPE_PARENT_END = 'parent_end';

  public static final String STAGE_2_DURATION = 'Stage_2_Duration__c';  // PK: Case 01169791
  public static final String STAGE_3_DURATION = 'Stage_3_Duration__c';
  public static final String STAGE_4_DURATION = 'Stage_4_Duration__c';
  public static final String STAGE_5_DURATION = 'Stage_5_Duration__c';
  public static final String STAGE_6_DURATION = 'Stage_6_Duration__c';

  public static final String ROWCAUSE_OPPTY_TEAM = 'Opportunity_Team__c';
  public static final String ROWCAUSE_OPPTY_OWNER = 'Opportunity_Owner__c';
  public static final String ROWCAUSE_ACCOUNT_TEAM = 'Account_Team__c';  // PK Changed

  public static final String PICKLISTVAL_YES = 'Yes';
  public static final String PICKLISTVAL_NO = 'No';

  public static final String REVENUE_TYPE_DIVIDE_AMT_MULTIPLE_INST = 'Divide Amount into multiple installments';
  public static final String REVENUE_TYPE_REPEAST_AMT_EACH_INST = 'Repeat Amount for each installment';

  public static final String RECORDTYPE_STANDARDS = 'Standard';
  public static final String RECORDTYPE_MASS_TRANSFER_REQUEST ='Mass Transfer Request';
  public static final String RECORDTYPE_CONF_INFO_OPPTY = 'Confidential Information - Opportunity';
  public static final String RECORDTYPE_CONF_INFO_CONTRACTHEAD = 'Confidential Information - Contract Header';
  public static final String RECORDTYPE_CONF_INFO_PRODUCTPROPOSAL = 'Confidential Information - Pace Product Proposal';
  public static final String RECORDTYPE_CONTRACT_CSDA_HEADER = 'CSDA Contract Header';

  public static final String REGION_APAC = 'APAC';
  public static final String REGION_INDIA = 'India';
  public static final String REGION_LATAM = 'LATAM';
  public static final String REGION_EMEA = 'EMEA';
  public static final String REGION_NA = 'NA';
  public static final String REGION_UKI = 'UK&I';
  public static final String REGION_NORTH_AMERICA = 'North America';//DRM:W-006453
  public static final String REGION_LATIN_AMERICA = 'Latin America';
  public static final String REGION_GLOBAL = 'Global';


  public static final String CASE_TYPE_INTERNAL = 'Internal';
  public static final string CASE_TYPE_SPAIN_DELIVERY_TASK = 'Spain Delivery Task';

  // Group
  public static final String GROUP_DELIVERY_MANAGEMENT = 'Delivery Management';
  public static final String GROUP_EDQ_COPS = 'EDQ COPS Team';

  public static final String TYPE_OF_SALE_CONSULTANCY = 'Consultancy';
  public static final String TYPE_OF_SALE_SOFTWARESALE = 'Software Sale';
  public static final String TYPE_OF_SALE_ADHOC = 'Ad-Hoc';
  public static final String TYPE_OF_SALE_INITIALSOFTWAREFEE = 'Initial Software Fee';

  public static final String PERIOD_MONTHLY = 'Monthly';
  public static final String PERIOD_QUARTERLY = 'Quarterly';

  public static final String SCHEDULE_TYPE_DIVIDE_AMOUNT = 'Divide Amount into multiple installments';
  public static final String SCHEDULE_TYPE_REPEAT_AMOUNT = 'Repeat Amount for each installment';

  public static final String USER_GBL_CREDIT_SERVICES = 'Credit Services';
  public static final String USER_GBL_DECISION_ANALYTICS = 'Decision Analytics';
  public static final String USER_GBL_INTERACTIVE = 'Interactive';
  public static final String USER_GBL_LATAM_SERASA_SALES = 'LATAM Serasa Sales';
  public static final String USER_GBL_MARKETING_SERVICES = 'Marketing Services';
  public static final String STR_PROSPECTING = 'prospecting';
  public static final String STR_QUALIFICATION = 'qualification';
  public static final String STR_NEEDSANALYSIS = 'needs analysis';
  public static final String STR_VALUE_PROPOSITION = 'value proposition';
  public static final String STR_ID_DECISIO_NMAKERS = 'id. decision makers';
  public static final String STR_PERCEPTION_ANALYSIS = 'perception analysis';
  public static final String STR_PROPOSAL_PRICEQUOTE = 'proposal/price quote';
  public static final String STR_NEGOTIATION_REVIEW = 'negotiation/review';
  public static final String STR_CLOSED_WON = 'closed won';
  public static final String STR_CLOSED_LOST = 'closed lost';

  //Access Request Case Contacts
  public static final String CASE_REC_TYPE_ACCOUNT_ACCESS_REQUEST = 'Account Reallocation Request';//Case #01266714 James Wills; Changed from CASE_REC_TYPE_ACCESS_REQUEST = 'Access Request'
  public static final String ACCT_TEAM_ACCESS = 'Edit';
  public static final String CONTACT_TEAM_ACCESS = 'Edit';
  public static final String OPTY_TEAM_ACCESS = 'Edit';
  public static final String CASE_STATUS_APPROVED = 'SA Approved';  // Case #01251745 : Updated to SA Approved

  //Constants for CaseTrigger_ResolutionTime
  public static final String CASE_REC_TYPE_NA_CCM_Support = 'NA CCM Support';        //Case #01266714 James Wills; Changed from CASE_REC_TYPE_CCM_NA_CASE = 'CCM NA Case'
  public static final String CASE_REC_TYPE_EDQ_CASE_TECH_SUPPORT = 'EDQ Technical Support';  //Case #01266714 James Wills; Changed from CASE_REC_TYPE_EDQ_CASE = 'EDQ Case'

  // Start: Case #542997 - 04/03/2015 - JW
  public static final String CASE_REC_TYPE_CSDA_CONT_REQ = 'CSDA Contract Request';
  public static final String CASE_REC_TYPE_ACC_REQUEST = 'Account Access Request';      //Case #01266714 James Wills; Changed from CASE_REC_TYPE_ACC_REQUEST = 'Access Request'
                                                //This is a duplicate of CASE_REC_TYPE_ACCOUNT_ACCESS_REQUEST and is not currently in use.
  public static final String CASE_REC_TYPE_SFDC_SUPPORT = 'Salesforce.com Support';          //Case #01266714 James Wills; Changed from CASE_REC_TYPE_CRM_REQUEST = 'CRM Request'
  public static final String CASE_REC_TYPE_PLATFORM_SUPPORT = 'Platform Support';                    //Case #02201503
  public static final String CASE_REC_TYPE_CAN_DOWN_REQUEST = 'Cancellation/Downgrade Request';
  public static final String CASE_REC_TYPE_CPQ_REQUEST = 'CPQ Requests';
  public static final String CASE_REC_TYPE_NEW_PRODUCT = 'New Product';            //Case #01266714 James Wills; Changed from CASE_REC_TYPE_PROD_REQUEST = 'Product Request'
  public static final String CASE_REC_TYPE_NEW_USER = 'New User';              //Case #01266714 James Wills; Changed from CASE_REC_TYPE_USER_ONBOARDING = 'Onboarding'
                                                //This is a duplicate of RECORDTYPE_CASE_NEW_USER.
  // End

  public static final String CASE_CHANGE_TYPE_STATUS = 'Status';
  public static final String CHANGE_TYPE_STATUS = 'Status';
  public static final String MEMBERSHIP_CHANGE_TYPE_STATUS = 'Status';
  public static final String CASE_CHANGE_TYPE_OWNER = 'Owner';
  public static final String MEMBERSHIP_CHANGE_TYPE_OWNER = 'Owner';
  public static final String MEMBERSHIP_HISTORY_OWNER_TYPE_USER = 'User';
  public static final String CASE_HISTORY_OWNER_TYPE_USER = 'User';
  public static final String CASE_HISTORY_OWNER_TYPE_QUEUE = 'Queue';
  public static final String HISTORY_OWNER_TYPE_USER = 'User';
  public static final String HISTORY_OWNER_TYPE_QUEUE = 'Queue';


  public static final String CASE_REC_TYPE_EDQ_GPD_SUPPORT = 'EDQ GPD Support';        //Case #01266714 James Wills; Changed from CASE_REC_TYPE_EDQ_GPD_CASE = 'EDQ GPD Case'
                                                //As of 07/01/2015 this is not in use. It is just present commented out in the CaseTriggerHandler class.
  // constants for T-319512
  public static final String OPPTY_CONTACT_ROLE_SHIPTO = 'Ship-to' ;
  public static final String OPPTY_CONTACT_ROLE_PURCHASE_LEDGER = 'Bill-To';
  public static final String OPPTY_CONTACT_ROLE_COMMERCIAL = 'Commercial';
  // T-322814
  public static final String OPPTY_CONTACT_ROLE_RENEWAL = 'Renewals';
  public static final String OPPTY_CONTACT_ROLE_UPDATE = 'Updates';

  public static final String OPPTY_CONTACT_ROLE_CONTRACTUAL = 'Contractual' ;
  // DO Case 02184830
  public static final String OPPTY_CONTACT_ROLE_DECISION_MAKER = 'Decision Maker';
  //MR DP Migration:W-009619 - New Contact Role Admin Contact
  public static final String OPPTY_CONTACT_ROLE_ADMIN = 'Admin Contact';


  // T-320132
  public static final String OPPTY_CHANNEL_TYPE_DIRECT = 'Direct';
  public static final String OPPTY_CHANNEL_TYPE_INDIRECT = 'Indirect';
  // PK Case 01039554
  public static final String OPPTY_CHANNEL_TYPE_AGENT = 'Agent';
  public static final String OPPTY_CHANNEL_TYPE_OTHER = 'Other';


  // Case Status
  public static final String CASE_STATUS_CLOSED_RESOLVED = 'Closed Resolved';
  public static final String CASE_STATUS_CLOSED_PENDING_ACCEPTANCE = 'Closed Pending Acceptance';
  public static final String CASE_STATUS_CLOSED_NO_ACTION = 'Closed No Action';
  public static final String CASE_STATUS_CLOSED_CANCELLED = 'Closed Cancelled';
  public static final String CASE_STATUS_CLOSED_NOT_RESOLVED = 'Closed Not Resolved';
  public static final String CASE_STATUS_CLOSED_ESCALATED = 'Closed Escalated';
  public static final String CASE_STATUS_CLOSED_COMPLETE = 'Closed - Complete';
  public static final String CASE_STATUS_IN_PROGRESS = 'In progress';
  public static final String CASE_STATUS_IMPLEMENTED = 'Implemented';
  public static final String CASE_STATUS_READY_FOR_PRODUCTION = 'Ready for Prod';
  

  //Release Automation
  public static final String CASECOMP_DEPLOYTYPE_AUTOMATED = 'Automated Deployment';

  // Added for EMS functionality
  public static final String CASE_COMMENT_TRIGGER = 'CaseCommentTrigger';
  public static final String RECORDTYPE_CASE_EMS = 'EMS';
  public static final String CASE_TYPE_INCIDENT = 'Incident';

  public static final String CASE_BUSINESSHOURS_FRANCE_MORNING = 'France Morning Hours';
  public static final String CASE_BUSINESSHOURS_FRANCE_AFTERNOON = 'France Afternoon Hours';
  public static final String CASE_BUSINESSHOURS_SPAIN = 'Germany';
  public static final String CASE_BUSINESSHOURS_GERMANY = 'Spain';
  public static final String CASE_BUSINESSHOURS_UKI_MS_EDQ = 'UKI MS EDQ';

  public static final String USER_ROLE_FRANCE_EVOLUTION = 'France Evolution';
  public static final String USER_ROLE_GERMANY_EVOLUTION = 'Germany Evolution';
  public static final String USER_ROLE_SPAIN_EVOLUTION = 'Spain Evolution';
  public static final String USER_ROLE_FRANCE_ONBOARDING = 'France Onboarding';
  public static final String USER_ROLE_GERMANY_ONBOARDING = 'Germany Onboarding';
  public static final String USER_ROLE_SPAIN_ONBOARDING = 'Spain Onboarding';
  public static final String CASE_TYPE_TASK = 'Task';

  public static final String USER_ROLE_FRANCE_L1_CLIENT_SERVICE_AGENT = 'France Level 1 Client Services Agent';
  public static final String USER_ROLE_FRANCE_L2_CLIENT_SERVICE_AGENT = 'France Level 2 Client Services Agent';
  public static final String USER_ROLE_GERMANY_L1_CLIENT_SERVICE_AGENT = 'Germany Level 1 Client Services Agent';
  public static final String USER_ROLE_GERMANY_L2_CLIENT_SERVICE_AGENT = 'Germany Level 2 Client Services Agent';
  public static final String USER_ROLE_SPAIN_L1_CLIENT_SERVICE_AGENT = 'Spain Level 1 Client Services Agents';
  public static final String USER_ROLE_SPAIN_L2_CLIENT_SERVICE_AGENT = 'Spain Level 2 Client Services Agents';

  public static final String USER_ROLE_UKI_MS_EDQ_TECHNICAL_SUPPORT = 'UK&I MS EDQ Technical Support';
  public static final String USER_ROLE_UKI_MS_EDQ_TECHNICAL_SUPPORT_MANAGER = 'UK&I MS EDQ Technical Support Manager';

  public static final String QUEUE_DEVELOPERNAME_UK_I_MS_EDQ_SUPPORT_TIER_2  = 'UK_I_MS_EDQ_Support_Tier_2';
  public static final String QUEUE_DEVELOPERNAME_UK_I_MS_EDQ_SUPPORT_TIER_1 = 'UK_I_MS_EDQ_Support_Tier_1';
  public static final String QUEUE_DEVELOPERNAME_UK_I_MS_EDQ_PRIORITY_SUPPORT = 'UK_I_MS_EDQ_Priority_Support';
  public static final String QUEUE_DEVELOPERNAME_UK_I_MS_EDQ_MANAGEMENT = 'UK_I_MS_EDQ_Management';


  public static final String RECORDTYPE_CASE_EDQ_GPD_SUPPORT = 'EDQ GPD Support';            //Case #01266714 James Wills; Changed from RECORDTYPE_CASE_EDQ_GPD = 'EDQ GPD Case'
  public static final String RECORDTYPE_CASE_NEW_USER = 'New User';                    //Case #01266714 James Wills; Changed from RECORDTYPE_CASE_ONBOARDING = 'User Onboarding';
                                                      //This is a duplicate of CASE_REC_TYPE_NEW_USER
  public static final String RECORDTYPE_CASE_EDQ_COMMERCIAL = 'EDQ Commercial Support';          //Case #01266714 James Wills; Changed from RECORDTYPE_CASE_EDQ_COMMERCIAL = 'EDQ Commercial Case'
  public static final String RECORDTYPE_CASE_SPANISH = 'Spanish Delivery';
  public static final String RECORDTYPE_CASE_EDQ_TECH_SUPPORT = 'EDQ Technical Support';        //Case #01266714 James Wills; Changed from RECORDTYPE_CASE_EDQ = 'EDQ Case';
                                                      //This is a duplicate of CASE_REC_TYPE_EDQ_CASE_TECH_SUPPORT , and I don't think that it is in use.
  public static final String RECORDTYPE_CASE_CSDA_BIS_SUPPORT = 'CSDA BIS Support';
  public static final String RECORDTYPE_CASE_CSDA_CIS_BA_REQUEST = 'CSDA CIS BA Request';
  public static final String RECORDTYPE_CASE_CSDA_CIS_SUPPORT = 'CSDA CIS Support';
  public static final String OLI_FLD_UPDATE_FREQENCY = 'update_frequency__c';
  public static final String OLI_FLD_DELIVERY_METHOD = 'delivery_method__c';
  public static final String OLI_FLD_TYPE = 'type__c';
  public static final String OLI_FLD_LAST_MODIFIED_DT = 'lastmodifieddate';
  public static final String OLI_FLD_LAST_MODIFIED_BY = 'lastmodifiedby';
  public static final String BUSINESSLINE_DATA_QUALITY = 'Experian Data Quality';

  public static final String EDQ = 'EDQ';

  public static final String AGENCY = 'Agency';

  public static final String TIMECARD_TYPE_DELIVERY = 'Delivery';
  public static final String TIMECARD_TYPE_TRAVEL = 'Travel';

  public static final String OPPTY_TYPE_FREE_TRIAL = 'Free Trial';
  public static final String OLI_TYPE_FREE_TRIAL = 'Free Trial';
  public static final String OPPTY_SALES_PROCESS_STANDARD = 'Standard';
  //T-359589 GC 10/02/2015
  public static final String ORDER_TYPE_FREE_TRIAL = 'Free Trial';

  public static final String ASSET_DATA_USAGE = 'Data_Usage__c';
  public static final String ASSET_IMPLEMENTATION_ON_DEMAND = 'On Demand';
  public static final String ASSET_DIRECT_RENEWAL = 'Direct_Renewal__c';
  public static final String ASSET_INSTALL_DATE = 'InstallDate';
  public static final String ASSET_LAST_MODIFIED_DATE = 'LastModifiedDate';
  public static final String ASSET_OPERATING_SYSTEM = 'Operating_System__c';
  public static final String ASSET_ORDER_LINE = 'Order_Line__c';
  //public static final String ASSET_OS_VERSION = 'OS_Version__c'; //T-326528
  public static final String ASSET_PARTNER = 'Partner__c';
  public static final String ASSET_PARTNER_AMOUNT = 'Partner_Amount__c';
  public static final String ASSET_PRICE = 'Price';
  public static final String ASSET_PURCHASE_DATE = 'PurchaseDate';
  public static final String ASSET_QUANTITY = 'Quantity';
  public static final String ASSET_RELEASE_VERSION = 'Release_Version__c';
  public static final String ASSET_RENEWAL_DISCOUNT = 'Renewal_Discount__c';
  //public static final String ASSET_RENEWAL_VAR = 'Renewal_VAR__c'; //T-326528
  public static final String ASSET_START_DATE = 'Start_Date__c';
  public static final String ASSET_STATUS = 'Status';
  public static final String ASSET_TOTAL_ROYALTY = 'Total_Royalty__c';
  public static final String ASSET_USAG_END_DATE = 'UsageEndDate';
  public static final String ASSET_TYPE_CREDITED = 'Credited';
  public static final String ASSET_ITEM_NUMBER = 'Callidus_Item_Number__c';
  public static final String ASSET_QUOTE_NUMBER = 'Callidus_Quote_Number__c';
  //RJ Case 00607940- Added two field names (ASSET_RPI and ASSET_RPI_AMOUNT)
  public static final String ASSET_RPI = 'RPI__c';
  public static final String ASSET_RPI_AMOUNT = 'RPI_Amount__c';

  public static final String ORDER_LINE_ITEM_DELIVERY_METHOD_NOT_REQ = 'Not Required';

  public static final String LOCALNAME_RESULT = 'Result';
  public static final String STR_NOK = 'NOK';
  public static final String STR_OK = 'NOK';

  public static final String OPPTY_STAGE_ABANDONED = 'Abandoned';
  public static final String OLI_ORDER_TYPE_PDT = 'Paid Dev Tools';
  public static final String OLI_ORDER_TYPE_UPSELL = 'Up-Sell';
  public static final String OLI_ORDER_TYPE_REPLACEMENT = 'Replacement';

  //EDQ user types on user object for field EDQ_User_Type__c
  public static final String EDQ_USER_TYPE_SALES_MANAGER = 'EDQ Sales Manager';
  public static final String EDQ_USER_TYPE_CUSTOMER_OPERATIONS = 'EDQ Customer Operations';
  public static final String EDQ_USER_TYPE_COMM_TECH_LEGAL = 'EDQ Commercial Technicians Legal';
  public static final String EDQ_USER_TYPE_FINANCE_MANAGER = 'EDQ Finance Managers';
  public static final String EDQ_USER_TYPE_PROFESSIONAL_SERVICES = 'EDQ Professional Services';
  public static final String CPQ_USERTYPE_CSDA_AE_MANAGER = 'CSDA AE Manager';
  public static final String CPQ_USERTYPE_CSDA_STRATEGIC_PRICING = 'CSDA Strategic Pricing';

  //RLI.Type__c and Status__c
  public static final String RLI_TYPE_LONG = 'Long';
  public static final String RLI_TYPE_STANDARD = 'Standard';
  public static final String RLI_STATUS_PAID = 'Paid';
  public static final String RLI_STATUS_UNPAID = 'Unpaid';
  public static final String RLI_STATUS_LOST = 'Lost';

  //T-349831
  public static final String SALES_PROCESS_STANDARD = 'Standard';
  public static final String SALES_PROCESS_LEAD = 'Lead';
  public static final String STR_IGNORE = 'IGNORE';
  public static final String STR_SERVICE = 'Service';
  public static final String STR_QUEUE = 'Queue';

  public static final String STR_POSITIVE = 'Positive';
  public static final String STR_NEGATIVE = 'Negative';


  public static final String STATUS_WAIT = 'Wait';
  public static final String STATUS_SUCCESS = 'Completed';

  public static final String STATUS_FAILED = 'Failed';

  public static final String VALIDATION_STATUS_FAIL = 'Fail';


  //Business Process Template Constants
  public static final String RELATED_TO_CASES = 'Cases';
  public static final String RELATED_TO_OPPORTUNITIES = 'Opportunities';
  public static final String RELATED_TO_ACCOUNTS = 'Accounts';
  public static final String RELATED_TO_MEMBERSHIPS = 'Credentialing';
  public static final String BU_CSDA = 'CSDA';
  public static final String SUB_BU_BIS = 'BIS';
  public static final String SUB_BU_CIS = 'CIS';

  public static final String TASK_STATUS_NOT_STARTED = 'Not Started';
  public static final String TASK_STATUS_IN_PROGRESS = 'In Progress';
  public static final String TASK_STATUS_COMPLETED = 'Completed';
  public static final String RECORDTYPE_TASK_PROJECT_DELIVERY = 'Project and Delivery';
  public static final String SOBJECT_DELIVERY_LINE = 'Delivery_Line__c';

  // Added for Integration Event Functionality for Serasa
  public static final String COUNTRY_BRAZIL = 'Brazil';
  public static final String INTEGRATION_HYPERION = 'Hyperion';
  public static final String ACTION_DELETE = 'Delete';
  public static final String CAMPAIGNMEMBER_TRIGGER = 'CampaignMemberTrigger';

  public static final String SOBJECT_CAMPAIGNMEMBER = 'CampaignMember';
  public static final String CAMPAIGN_TRIGGER = 'CampaignTrigger';

  public static final String PROFILE_EXP_SERASA_FINANCE = 'Experian Serasa Finance';
  public static final String PROFILE_EXP_SERASA_SALES_EXEC = 'Experian Serasa Sales Executive';
  public static final String PROFILE_EXP_SERASA_SALES_MANAGER = 'Experian Serasa Sales Manager';
  public static final String PROFILE_EXP_SERASA_SALES_OPERATION = 'Experian Serasa Sales Operation';//Case 02233635
  public static final String REGION_SERASA = 'Latin America';
  public static final String SERASA = 'Serasa';

  public static final String ORDER_CHANNEL_SOURCE_DIRECT_SALES = 'Direct Sales';
  public static final String ACC_WS_ACTION_MATCHED = 'Matched';
  public static final String ACC_WS_ACTION_CREATED = 'Created';
  public static final String ACC_WS_ACCOUNT_ADDRESS_TYPE_REG = 'Registered';
  public static final String ACC_WS_ACCOUNT_ADDRESS_TYPE_SEC = 'Secondary';
  public static final String ACC_WS_ACCOUNT_NO_ADDRESS = 'No Valid Address Provided or Request failed validation';
  public static final String ACC_WS_ACCOUNT_ERROR = 'ERROR';
  public static final String ACC_WS_ACCOUNT_MATCHED_BY_ID = 'Id';
  public static final String ACC_WS_ACCOUNT_MATCHED_BY_NAME_AND_ADDRESS = 'Name and Address';
  public static final String ACC_WS_ACCOUNT_NO_ACCOUNT = 'No Account Provided or Request failed validation';
  public static final String ACC_WS_ACCOUNT_NO_CONTACT = 'No Contact Provided or Request failed validation';
  public static final String ACC_WS_ACTION_DEFAULT_ADDRESS = 'Defaulted Address';
  public static final String ACC_WS_ACTION_MISSING_MINIMAL_INFO = 'Request is missing the minimal information required. '
  + ' Please provide at a minimum either 1. An SFDC Account Id AND a contact email address OR '
  + ' 2. An Account Name AND An Address with a Country and Address 1 AND a contact email';

  // Added for Fraud and Adtruth functionality
  public static final String RECORDTYPE_CASE_FRAUD_AND_IDENTITY = 'Fraud and Identity Support';
  public static final String RECORDTYPE_CASE_AUTOMOTIVE = 'Automotive';
  public static final String RECORDTYPE_CASE_ADTRUTH = 'AdTruth Support';
  public static final String BUSINESS_HOURS_PHOENIX = 'Phoenix Business Hours';
  public static final String Opportunity_Team_Role_Consultant = 'Consultant'; //Added by Manoj
  public static final String RECORDTYPE_CASE_EDQ_BUS_OPS = 'EDQ Business Operations'; // Case 13566757 Adding new Record Type to use in CaseTriggerHandler  
  
  
  
  public static final String RECORDTYPE_LEAD_LATAM_SERASA = 'LATAM Serasa';

  public static final String RECORDTYPE_Transactional_Sale = 'Transactional Sale';//Added by Manoj
  public static final String RECORDTYPE_Transactional_Sale_DEV = 'Transactional_Sale';//Added by Ganesh
  public static final String RECORDTYPE_STANDARD_TASK = 'Standard Task';//Added by Manoj
  public static final String RECORDTYPE_MARKETING_TASK = 'Marketing Activity';//Added by Manoj
  public static final String RECORDTYPE_FREE_TRIAL = 'Free Trial';
  public static final String RECORDTYPE_Service_Central = 'Service Central';
  public static final String RECORDTYPE_Partner_Community = 'XPartner Community - NA Auto';
  
  public static final String RECORDTYPE_ACCOUNT_MASTER = 'Master';//DRM:W-006551
  public static final String RECORDTYPE_Customer_Success = 'Customer Success';
  

  //Added for Deployment Request Object
  public static final String APP_REQUESTED_DR_STATUS = 'Approval Requested';
  public static final String NOT_STARTED_DR_STATUS = 'Not Started';
  public static final String DEPLOYED_DR_STATUS = 'Deployed';
  public static final String DEPLOYED_TO_PROD_DR_STATUS = 'Deployed to Production';
  public static final String LOCKED_DR_STATUS = 'Locked for Deployment';
  public static final String PICKED_DR_STATUS = 'Picked';
  public static final String CANCELLED_DR_STATUS = 'Cancelled';
  public static final String APP_FOR_DEPLOY_DR_STATUS = 'Approved for Deployment';
    
  // record Types for Serasa Customer Care -Added by Manoj
  public static final String RECORDTYPE_Serasa_Cancellation = 'Serasa Cancellation';
  public static final String RECORDTYPE_Serasa_Support_Request = 'Serasa Support Request';
  public static final String RECORDTYPE_Serasa_Support_Request_Internal = 'Serasa Support Request Internal';
  public static final String RECORDTYPE_Consumer_Contact = 'Consumer Contact';
  public static final String RECORDTYPE_Cover_Letter = 'Cover Letter';
  public static final String RECORDTYPE_Cover_Letter_Archive = 'Cover Letter - Archive';
  public static final String RECORDTYPE_Cover_Letter_Prescreen = 'Cover Letter - Prescreen';
  public static final String RECORDTYPE_Cover_Letter_Quest = 'Cover Letter - Quest';
  public static final String RECORDTYPE_Cover_Letter_Read_Only = 'Cover Letter Read Only';
  public static final String RECORDTYPE_Order_Form = 'Order Form';
  public static final String RECORDTYPE_Order_Form_Read_Only = 'Order Form Read Only';  
  public static final String Case_Activity_Status_Completed = 'Completed';
  
   // Record Types for BFS -Added by Manoj
  public static final String RECORDTYPE_BFS_Standard_Project = 'BFS Standard Project';
  public static final String RECORDTYPE_Prospect = 'Prospect';
  public static final String RECORDTYPE_BFS_Project_Delivery_Line = 'BFS Project Delivery Line';
  public static final String RECORDTYPE_BFS_PA_QA_Request = 'BFS PA QA Request';
  public static final String RECORDTYPE_BFS_BA_QA_Request = 'BFS BA QA Request';
  public static final String RECORDTYPE_Project_Delivery_Line = 'Project Delivery Line';
  public static final String RECORDTYPE_Global_SFDC_Delivery_Line = 'Global SFDC Delivery Line';
  public static final String RECORDTYPE_NA_Targeting = 'NA Targeting';
  
  // Record Types for Confidential Information -Added by Srihari
  public static final String RECORDTYPE_Confidential_Information_Project = 'Confidential Information - Project';
    
  // Record Types for CSDA
  //public static final String  RECORDTYPE_Membership_Non_Revenue = 'Membership Non-Revenue';
  //public static final String  RECORDTYPE_Membership_Request = 'Membership Request';
   
  
  // Record Types for CSDA, changed from above lines 
  public static final String  RECORDTYPE_Membership_Non_Revenue = 'Credentialing Non-Revenue';
  public static final String  RECORDTYPE_Membership_Request = 'Credentialing Request'; 
   
   
  //Record Types for PACE
  public static final String  RECORDTYPE_PACE_Questionnaire = 'PACE Questionnaire';
  public static final String  RECORDTYPE_PACE_Product_Proposal = 'PACE Product Proposal';

  //Added Case Fieldset
  public static final String Fieldset_Transaction_Queue_Fieldset = 'Transaction_Queue_Fieldset';
  public static final String Fieldset_Transaction_Queue_Assets = 'Transaction_Queue_Fieldset_For_Assets';
  
  //User business units
  public static final String UK_I_MS_DATA_QUALITY = 'UK&I MS Data Quality';

  // Serasa Customer Care Profiles
  public static final String SERASA_CUSTOMER_CARE_PROFILES = 'Serasa Customer Care Profiles';
  
  // CSDA Membership Conf Info Name
  public static final String CSDA_CONF_INFO_NAME = 'Credentialing Client Documents';
  public static final String CSDA_FCRA_GLB = 'Access_Security_Requirements_for_FCRA_and_GLB_5A_Data';
  public static final String CSDA_FCRA_REQ = 'FCRA_Requirements';
  
  //W-031691 - Added new constants
   public static final String CSDA_CA_CONF_INFO_NAME = 'Credentialing Application';
   public static final String CSDA_STCPD_CONF_INFO_NAME = 'Standard Terms and Conditions for Participating Dealers';
   public static final String CSDA_CSS_CONF_INFO_NAME = 'Consumer Services Schedule';
   public static final String CSDA_CSSA_CONF_INFO_NAME = 'Credit Services Scoring Agreement';
  
  
  //MR DP Migration:W-009642:Credit Note Request DP Record Type
  public static final String RECORDTYPE_Credit_Note_Request_DP = 'Credit Note Request DP';
  public static final Map<String, String> SERASA_CASE_TO_EMAIL_EMAIL_USERISLAND_MATCH_MAP = new Map<String, String>{
      'vip.meproteja@br.experian.com' => 'VIP',
      'suporte.serasaconsumidor@br.experian.com' => 'Social Media',
      'atendefacil@br.experian.com' => 'Social Media',
      'atende.redesocial@br.experian.com' => 'Social Media',
      'poderesponder@serasaconsumidor.com.br' => 'CAC',
      'formalizacaocd@br.experian.com' => 'eID',
      'atendepme@br.experian.com' => 'Back Office CR',
      'concentreoficio@br.experian.com' => 'Back Office CR',
      'ativoserasa@br.experian.com' => 'Back Office CR',
      'canaldireto@br.experian.com' => 'Back Office CR',
      'atendejuridico@br.experian.com' => 'Back Office CR',
      'atendenotificacoes@br.experian.com' => 'Back Office CR',
      'meproteja@serasaconsumidor.com.br' => 'CAC',
      'atende.consumidor@br.experian.com' => 'CAC',
      'atendimento@serasaconsumidor.com.br' => 'CAC',
      'faleconoscocd@certificadodigital.com.br' => 'eID',
      'acordopromotor@br.experian.com' => 'eID Dealer Agreement',
      'autoatendimento@br.experian.com' => 'SME Logon',
      'atendeacesso@br.experian.com' => 'SME Logon',
      'formalizacaoanexo@br.experian.com' => 'SME',
      'atendimento.comercial@br.experian.com' => 'Back Office Retention',
      'formalizacaocancelamento@br.experian.com' => 'Back Office Retention',
      'blindado@br.experian.com' => 'VIP',
      'atende.distribuidores@br.experian.com' => 'VIP',
      'extensao@br.experian.com' => 'VIP',
      'atende.estrategico@br.experian.com' => 'VIP',
      'atende.corporativo@br.experian.com' => 'VIP',
      'remessa@br.experian.com' => 'VIP',
      'atendeserasaconecta@br.experian.com' => 'VIP'
    };

    public static final Map<String, String> SERASA_CASE_TRANSFER_ISLAND_RE_MAPPING = new Map<String, String> {
      'eID' => 'Serasa_Cases_eID, eID, eID',
      'SME' => 'Serasa_Cases_SME, SME, SME',
      'SME Logon' => 'Serasa_Cases_SME_Logon, SME Logon, SME Logon',
      'Retention' => 'Serasa_Cases_Retention, Retention, Retention',
      'Serasa Consumidor' => 'Serasa_Cases_Consumer, Serasa Consumidor, CAC',
      'Telesales' => '',
      'Promoter agreement' => '',
      'increase VCM' => '',
      'Guidance on exchange' => '',
      'reduce VCM' => '',
      'Positive Data' => 'Serasa_Cases_Consumer, Positive Registration, CAC',
      'MS Attendance' => 'Serasa_Cases_SME, SME, SME',
      'Contact out of office' => '',
      'Retention' => 'Serasa_Cases_Retention, Retention, Retention'
    };
    Public static final string REDIRECT_CREATE_TRANSAC_OPTY = 'createTranscOpportunity';
    Public static final string REDIRECT_CREATE_QUICK_WIN_OPTY = 'createQuickWinOpportunity';
    
    // Case 19538248
    public static final String CREDENTIALING_SURVEY_SUBJECT = 'Email: Experian Welcome Information for';
    public static final String CREDENTIALING_CLARITY_SURVEY_SUBJECT = 'Email: Clarity Welcome Information for';
    
    public static final string PRODUCT_MASTER_OBJECT_API_NAME = 'Product_Master__c';
}