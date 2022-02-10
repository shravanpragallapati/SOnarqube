/**=====================================================================
 * Appirio, Inc
 * Name: BatchContractRenewalDate_Test
 * Description: T-370246: Test class for BatchContractRenewalDate.cls and ScheduleContractRenewalDate.cls
 * Created Date: Mar 16th, 2015
 * Created By: Arpita Bose(Appirio)
 *
 * Date Modified     Modified By        Description of the update
 * Dec 3rd, 2015     Paul Kissick       Case 01266075: Removing Global_Settings__c for timings
 * Jul 6th, 2021     Rohit Aryan        Case :22376547 - API upgrade
 =====================================================================*/
@isTest(seeAllData=false)
private class BatchContractRenewalDate_Test {
  public static Date previousDate1 = System.today().addDays(-1);
  public static Date previousDate2 = System.today().addDays(-2);

  @isTest
  static void testBatch() {
    // Actual test begins
    Test.StartTest();

    // Executing the batch job
    BatchContractRenewalDate batch = new BatchContractRenewalDate();
    ID batchprocessid = Database.executeBatch(batch);

    Test.StopTest();
    List<Contract__c> result1 = [SELECT ID, Next_Auto_Renewal_Date__c, Renewal_Term_Period__c, 
                                 Initial_Term_Period_End_Date__c FROM Contract__c
                                 WHERE Renewal_Term_Period__c = :3
                                 AND Next_Auto_Renewal_Date__c = :previousDate1.addMonths(3)];

    //Asserts to verify 'Next_Auto_Renewal_Date__c'
    System.assert(result1.size() == 10);
  }

  @testSetup
  private static void createTestData() {
    // Create Global Setting for datetime , for the test method.
    TestMethodUtilities.createTestGlobalSettings();
    Global_Settings__c lastRun = Global_Settings__c.getInstance(Constants.GLOBAL_SETTING);

    Datetime testBeforeDateTime = BatchHelper.getBatchClassTimestamp('ContractRenewalJobLastRun');
    
    BatchHelper.setBatchClassTimestamp('ContractRenewalJobLastRun', testBeforeDateTime.addMinutes(-60));
    
    update lastRun;

    lastRun = Global_Settings__c.getInstance(Constants.GLOBAL_SETTING);

    Account testAcc = Test_Utils.insertAccount();

    List<Contract__c> lstContrct = new List<Contract__c>();

    for (Integer i=1; i<= 10; i++) {
      Contract__c cntrct1 =  Test_Utils.insertContract(false, testAcc.Id, Constants.AGENCY, Constants.STATUS_ACTIVE);
      cntrct1.Contract_Effective_Date__c = Date.today();
      cntrct1.Auto_Renew__c = Constants.PICKLISTVAL_YES;
      cntrct1.Renewal_Term_Period__c = 3;
      cntrct1.Next_Auto_Renewal_Date__c = previousDate1;
      lstContrct.add(cntrct1);
    }

    if (lstContrct.size() > 0){
     insert lstContrct;
    }
  }
}