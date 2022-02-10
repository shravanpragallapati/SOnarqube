/**=====================================================================
 * Appirio, Inc
 * Name: CommunityCaseListViewExt_Test
 * Description: Test class for CommunityCaseListViewExt.cls
 * 
 * Created Date: Jul 5th, 2021
 * Created By: Dheekonda Ganesh
 * 
 * Date Modified        Modified By                 Description of the update
 * Jul 5th, 2021               Dheekonda Ganesh             22376528 - API Upgrade 5 - Salesforce Mandatory June 2022 requirement
 =====================================================================*/
@isTest 
private class CommunityCaseListViewExt_Test{
    @isTest
    private static void testExt() {
    
        CommunityCaseListViewExt cve1 = new CommunityCaseListViewExt(new ApexPages.StandardController(new Case()));
        CommunityCaseListViewExt cve2 = new CommunityCaseListViewExt(new ApexPages.StandardSetController(new List<Case>()));
        cve2.showList=null;
        cve2.caseListRetrive();    
         
        
        system.assertEquals(0, cve1.caseList.size() );
    
    } 
}