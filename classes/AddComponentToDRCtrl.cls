/**=====================================================================
 * Experian
 * Name: AddComponentToDRCtrl
 * Description:
 * Created Date:
 * Created By: Nur Azlini Ammary
 *
 * Date Modified                Modified By                  Description of the update
 * Nov 13th,2015               Paul Kissick                 Tidied up and added a new refresh method (doesn't actually do anything)
 * Dec 2nd, 2015               Paul Kissick                 Completely replaced with better code
 * Jan 14th,2016               Paul Kissick                 Case 01802324: Adding changes to support preprod releases
 * Mar 08th,2016               Sadar Yacob                  Case 01825428: Added support for Agile Accelerator Stories 
 * Jun 01st,2016               Diego Olarte                 Case 01973277: Added filter to only use Salesforce Components and releases 
 * Feb 24th,2019               Manoj Gopu                   Case 20344570: Skip Stamping release Name from Prod DR to Case project when Case type is CSA Support 
 * May 7th  2021                 SaiNavya Y                  W-032476 : ApexSOQLInjection
 * Jul 12th 2021               Manoj Gopu                   Case 22409346: Remove Apex code coverage field references
 =====================================================================*/
public class AddComponentToDRCtrl {

  public Id recordId {get; private set;}
  
  private Boolean isCase = false;
  private Boolean isStory = false;
  private Boolean isAgileStory = false;
  private Boolean isIssue = false;
  
  private Case caseRec;
  private Story__c storyRec;
  private agf__ADM_Work__c agileStoryRec;
  private Issue__c issueRec;
  
  @testVisible private static String NOT_STARTED = 'Not Started';
  @testVisible private static String MANUAL_STEP = 'Manual Step';
  @testVisible private static String UAT_SIGNED_OFF = 'UAT Signed Off';
  @testVisible private static String READY_FOR_PROD = 'Ready for Prod';
  @testVisible private static String STORY_UAT_COMPLETE = 'UAT Complete';
  @testVisible private static String Platform_SFDC = 'Salesforce';
  @testVisible private static String UAT_APPROVED = 'UAT Approved';
  
  public Boolean forProd {get{if (forProd == null) forProd = false; return forProd;}set;}
  
  public class CaseComponentWrapper {
    public Case_Component__c cc {get;set;}
    public Boolean selected {get;set;}
    public CaseComponentWrapper(Case_Component__c c) {
      cc = c;
      selected = false;
    }
  }
  
  public List<CaseComponentWrapper> allCaseComponents {get{if(allCaseComponents == null) allCaseComponents = new List<CaseComponentWrapper>(); return allCaseComponents;}set;}
  
  public List<Deployment_Request__c> allDeploymentRequests {get{if(allDeploymentRequests == null) allDeploymentRequests = new List<Deployment_Request__c>(); return allDeploymentRequests;}set;}
  
  public String selectedDeploymentRequest {get;set;}
  
  public AddComponentToDRCtrl() {
    recordId = ApexPages.currentPage().getParameters().get('Id');
    if (recordId != null) {
      if (recordId.getSobjectType() == Case.sObjectType) {
        isCase = true;
        caseRec = [
          SELECT Id,Type, Implementation_Status__c, Target_Deployment_Date__c, Project__c, Release_Sprint_Name__c 
          FROM Case 
          WHERE Id = :recordId
        ];
      }
      if (recordId.getSobjectType() == Story__c.sObjectType) {
        isStory = true;
        storyRec = [SELECT Id, Status__c FROM Story__c WHERE Id = :recordId];
      }
      if (recordId.getSobjectType() == agf__ADM_Work__c.sObjectType) {
        isAgileStory = true;
        agileStoryRec = [SELECT Id, agf__Status__c FROM agf__ADM_Work__c WHERE Id = :recordId];
      }
      if (recordId.getSobjectType() == Issue__c.sObjectType) {
        isIssue = true;
        issueRec = [SELECT Id, Status__c, Work__c FROM Issue__c WHERE Id = :recordId];
      }
      
      loadCaseComponents();
      loadDeploymentRequests();
    }
    
  }
  
  private void loadCaseComponents() {
    allCaseComponents = new List<CaseComponentWrapper>();
    for(Case_Component__c cc : [SELECT Id, Component_Name__r.Component_API_Name__c,
                                       Metadata_Type__c, Deployment_Type__c,Manual_Step_Details__c
                                FROM Case_Component__c
                                WHERE  ( Story__c = :recordId OR Case_Number__c = :recordId or User_Story_AA__c = :recordId or Issue__c =:recordId) AND Case_Component__c.Platform__c = 'Salesforce'
                                ORDER By Metadata_Type__c, Component_Name__r.Component_API_Name__c
                                ]) {
      allCaseComponents.add(new CaseComponentWrapper(cc));                            
    }

  }
  
  private void loadDeploymentRequests() {
    List<String> fieldList = new List<String>{
      'Id', 
      'Deployment_Label__c', 
      'Deployment_Date__c', 
      'Source__r.Name', 
      'Target__r.Name', 
      'Deployment_Lead__r.Name', 
      'Is_Production__c',
      'Project__c',
      'Release__c'
    };
    String deployReqsQuery = 'SELECT '+String.escapeSingleQuotes(String.join(fieldList,','))+//W-032476
        ' FROM Deployment_Request__c '+
        ' WHERE Platform__c = \'' +String.escapeSingleQuotes(Platform_SFDC)+'\''+ ' AND Status__c = \''+String.escapeSingleQuotes(NOT_STARTED)+'\' ';//W-032476
    if ((isCase && caseRec.Implementation_Status__c == UAT_SIGNED_OFF) || (isStory && storyRec.Status__c == STORY_UAT_COMPLETE) 
         || (isAgileStory && agileStoryRec.agf__Status__c == UAT_SIGNED_OFF) || (isIssue && issueRec.Status__c == UAT_APPROVED))
     {
      // then allow the showing of prod releases.
    }
    else {
      deployReqsQuery += ' AND Is_Production__c = :forProd ';
    }
    deployReqsQuery += ' ORDER BY Deployment_Date__c ASC ';
    allDeploymentRequests = (List<Deployment_Request__c>)Database.query(deployReqsQuery); 
  }
  
  public PageReference selectAll() {
    for(CaseComponentWrapper c : allCaseComponents) {
      c.selected = true;
    }
    return null;
  }
  
  public PageReference selectNone() {
    for(CaseComponentWrapper c : allCaseComponents) {
      c.selected = false;
    }
    return null;
  }
  
  public PageReference refresh() {
    // reload dep reqs only.
    loadDeploymentRequests();
    return null;
  }
  
  
  public PageReference addToDeploymentRequest() {
    
    // first, check we have some selected from the list of components, then also that we've chosen a deployment request...
    try {
      if (allCaseComponents != null) {
        Boolean foundComponents = false;
        for(CaseComponentWrapper c : allCaseComponents) {
          if (c.selected) {
            foundComponents = true;
          }
        }
        if (String.isNotBlank(selectedDeploymentRequest) && foundComponents) {
          // now we can add to the request...
          Boolean hasManualStep = false;
          
          Deployment_Request__c selDepReq = (new Map<Id,Deployment_Request__c>(allDeploymentRequests)).get(selectedDeploymentRequest);
          system.debug(selDepReq);
          
          List<Deployment_Component__c> deploymentComponentsList = new List<Deployment_Component__c>();
          for(CaseComponentWrapper c : allCaseComponents) {
            if (c.selected) {
              if (c.cc.Deployment_Type__c == MANUAL_STEP) {
                // Deployment Request has a manual step.
                hasManualStep = true;
              }
              deploymentComponentsList.add(
               new Deployment_Component__c(
                 Case_Component__c = c.cc.Id, 
                 Slot__c = selectedDeploymentRequest  
               )
             );
            }
          }
          
          List<Deployment_Cases__c> existingDeploymentCases = [
            SELECT Case__c, Story_Name__c,Work__c, Deployment_Request_Slot__c 
            FROM Deployment_Cases__c 
            WHERE (Case__c = :recordId OR Story_Name__c = :recordId OR Work__c = :recordId)
            AND Deployment_Request_Slot__c = :selectedDeploymentRequest 
            LIMIT 1
          ];
          if (existingDeploymentCases.size() == 0) {
            Deployment_Cases__c dc = new Deployment_Cases__c(
              Deployment_Request_Slot__c = selectedDeploymentRequest
            );
            if (isCase) {
              dc.Case__c = recordId;
            }
            if (isStory) {
              dc.Story_Name__c = recordId;
            }
            if (isAgileStory) {
              dc.Work__c = recordId;
            }
            if (isIssue) {
              dc.Issue__c = recordId;
             // dc.Work__c = issueRec.Work__c;
            }
            
            insert dc;
          }
          
          insert deploymentComponentsList;
          if (hasManualStep) {
            Deployment_Request__c dr = new Deployment_Request__c(Id = selectedDeploymentRequest, Has_Manual_Steps__c = true);
            update dr;
          }
          
          // finally, if this is a prod slot, update the case implementation status
          if (isCase == true && selDepReq.Is_Production__c == true) {
            Case c = new Case(
              Id = caseRec.Id, 
              Implementation_Status__c = READY_FOR_PROD,
              Target_Deployment_Date__c = selDepReq.Deployment_Date__c,
            //  Project__c = selDepReq.Project__c,
              Release_Sprint_Name__c = selDepReq.Release__c
            );
            if(caseRec.Type!='CSA Support'){
                c.Project__c = selDepReq.Project__c;
            }
            update c;
          }
          else if ( isAgileStory ==true && selDepReq.Is_Production__c == true)
          {
           agf__ADM_Work__c ast = new agf__ADM_Work__c(Id = agileStoryRec.Id,agf__Status__c = READY_FOR_PROD);
           update ast;
          }
          else if ( isIssue ==true && selDepReq.Is_Production__c == true)
          {
           Issue__c iss = new Issue__c(Id = issueRec.Id,Status__c = READY_FOR_PROD);
           update iss;
          }
          
          return new PageReference('/'+recordId);
        } 
        else {
          if (!foundComponents) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select components to add.'));
          }
          if (String.isBlank(selectedDeploymentRequest)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'No deployment request selected.'));
          }
          return null;
        }
      }
    }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
      return null;
    }
    return null;
  }
  

}