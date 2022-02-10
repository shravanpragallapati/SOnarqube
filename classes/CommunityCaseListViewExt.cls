/*=============================================================================
 * Experian
 * Name: CommunityCaseListViewExt
 * Description: Extension class to handle simple custom community list views
 * Created Date: 31 Aug 2016
 * Created By: Paul Kissick
 *
 * Date Modified      Modified By           Description of the update
 * 3/26/2019           Richard Joseph        Added Query for Data table Case# 18752077
 * Jul 5th, 2021               Dheekonda Ganesh             22376528 - API Upgrade 5 - Salesforce Mandatory June 2022 requirement
 =============================================================================*/

public with sharing class CommunityCaseListViewExt {

 public List<case> caseList             {get; set; }
  
  public CommunityCaseListViewExt(ApexPages.StandardController con) {
  showList = 'OpenCases';
  caseListRetrive();
  }
  public CommunityCaseListViewExt(ApexPages.StandardSetController setCon) {
  showList = 'OpenCases';
  caseListRetrive();
  }
  
  public String showList {get{if (showList==null) showList = 'OpenCases'; return showList;}set;}
  
  
  public PageReference    caseListRetrive() {
          String timeZone = UserInfo.getTimeZone().getID();

            if ( showList == 'ClosedCases')
            {
                caseList = [SELECT id,CaseNumber,Case_Number_VFP__c,subject,status,CreatedDate FROM case where isclosed = true  order by  CaseNumber desc limit 1000];
                 
            }
                else if(showList == 'OpenCases')                {

                caseList = [SELECT id,CaseNumber,Case_Number_VFP__c,subject,status,CreatedDate FROM case where isclosed = false order by  CaseNumber desc limit 1000];
            }
                else {
                    caseList = [SELECT id,CaseNumber,Case_Number_VFP__c,subject,status,CreatedDate FROM case order by CaseNumber desc limit 1000];
                
                }
                
               return null;
    }        
  
}