/**=====================================================================
 * Appirio, Inc
 * Name: ContactOppRolesController
 * Description: Component controller for Contact's Opp role component. 
 * 
 * @author Antenna (reused from Appirio's Asset "Contact Role Summarizer Related List"
 * Created Date: Feb 24th, 2014
 * Created By: Nathalie Le Guay (Appirio)
 * 
 * Date Modified        Modified By                  Description of the update
 * June 13, 2014        James Weatherall             Added checkAccountAccess method to check user is on the Account Team
 * Jun 1st, 2016        Paul Kissick                 Case 01984048 - Editing to support separate method querying
 * July 26th, 2016(QA)  Cristian Torres              CRM2:W-005402: Added field Status__c to contact query 
 * Jul 5th, 2021               Dheekonda Ganesh             22376528 - API Upgrade 5 - Salesforce Mandatory June 2022 requirement
 =====================================================================*/
public with sharing class ContactOppRolesController {

  // Contact ID from component attribute 
  public Id contactId {get;set;}
  public Id accountId {get;set;}
  public Contact contact {get;set;}
  public String nameSubstring {get;set;}
  public Boolean hasAccess {get;set;}
  Public String ConStatus {get;set;} 

  public ContactOppRolesController() {
    if (ApexPages.currentPage() != null && ApexPages.currentPage().getParameters().containsKey('Id')) {
      contactId = apexpages.currentpage().getparameters().get('id');
      ConStatus = Constants.CONTACT_STATUS_LEFT;
    }
    checkAccountAccess();      
  }

  /**
   Returns all OpportunityContactRoles for the attribute contactId. 
  */
  public OpportunityContactRole[] getOpportunityRoles() {
    if (contact == null) {
      contact = [
        SELECT Id, AccountId, Account.Name, Status__c
        FROM Contact
        WHERE Id = :contactId
      ];
    }
    return [
      SELECT Role, IsPrimary, ContactId, Contact.AccountId, Opportunity.Name, OpportunityId,
             Opportunity.RecordType.Name, Opportunity.CloseDate, Opportunity.CreatedDate,
             Opportunity.Owner.Name, Opportunity.StageName, Opportunity.Amount, Opportunity.Type
      FROM OpportunityContactRole
      WHERE ContactId = :contactId
      ORDER BY Opportunity.CloseDate DESC
    ];
  }
    
  public void checkAccountAccess() {
    hasAccess = false;
    if (contactId != null) {
      hasAccess = OpportunityUtility.canCreateOpportunity(contactId);
    }      
  } 
}