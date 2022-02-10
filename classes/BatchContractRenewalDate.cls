/**********************************************************************************
 * Appirio, Inc
 * Name: BatchContractRenewalDate
 * Description: T-370246: Contract Auto-Renew
 * Created Date: Mar 13th, 2015
 * Created By: Arpita Bose (Appirio)
 *
 * Date Modified        Modified By                  Description of the update
 * Mar 19th, 2015       Arpita Bose                  S-277707: updated as per the chatter
 * Apr 02nd, 2015       Arpita Bose                  I-153908: updated the calulation of Next_Auto_Renewal_Date__c
 * Apr 14th, 2015       Naresh Kr Ojha               T-375000: Updated finish method to send mail to GCS team for error.
 * Nov 9th, 2015        Paul Kissick                 Case 01234035: Adding FailureNotificationUtility
 * Dec 3rd, 2015        Paul Kissick                 Case 01266075: Removing Global_Settings__c for timings
 * Jul 6th, 2021        Rohit Aryan                  Case :22376547 - API upgrade
 **********************************************************************************/
global class BatchContractRenewalDate implements Database.Batchable<sObject>, Database.Stateful {

  private Datetime holdingRunTime;

  //=================================================
  // Query all Contract__c since last run
  //=================================================
  global Database.Querylocator start ( Database.Batchablecontext bc ) {
    
    holdingRunTime = system.now();
    
    DateTime lastRunTime = BatchHelper.getBatchClassTimestamp('ContractRenewalJobLastRun');
    system.debug('****lastRunTime****' +lastRunTime);

    return Database.getQueryLocator ([SELECT Id, Status__c, Next_Auto_Renewal_Date__c, LastModifiedDate,
                                             Initial_Term_Period_End_Date__c,
                                             CreatedDate, Auto_Renew__c, Renewal_Term_Period__c
                                      FROM Contract__c
                                      WHERE Status__c = 'Active'
                                      AND Auto_Renew__c = 'Yes'
                                      AND (Next_Auto_Renewal_Date__c <= :System.today() OR
                                             Initial_Term_Period_End_Date__c <= :System.today())   
                                      AND (LastModifiedDate >= :lastRunTime OR CreatedDate >= :lastRunTime)]);
  }

  //==================================================
  // Execute - Update all Contract__c records
  //==================================================
  global void execute (Database.BatchableContext bc, List<Contract__c> scope) {
    List<Contract__c> contractList = (List<Contract__c>) scope;
    List<Contract__c> contractToUpdate = new List<Contract__c>();
    Set<Id> contractsToUpdateIds = new Set<Id>();
    
    system.debug('****contractList****' +contractList);
    
    for (Contract__c cntrct : contractList) {
    	system.debug('===Initial_Term_Period_End_Date__c>>' +cntrct.Initial_Term_Period_End_Date__c);
      if (cntrct.Next_Auto_Renewal_Date__c == null && 
            cntrct.Initial_Term_Period_End_Date__c <= System.today()){
        system.debug('****First IF***');
        cntrct.Next_Auto_Renewal_Date__c = cntrct.Initial_Term_Period_End_Date__c.addMonths(Integer.valueOf(cntrct.Renewal_Term_Period__c)); //S-277707
        if (!contractsToUpdateIds.contains(cntrct.Id)) {
          contractToUpdate.add(cntrct);
          contractsToUpdateIds.add(cntrct.Id);
        }
        system.debug('===Next_Auto_Renewal_Date__c>>' +cntrct.Next_Auto_Renewal_Date__c);
      }
    	
      if (cntrct.Next_Auto_Renewal_Date__c <> null && cntrct.Next_Auto_Renewal_Date__c <= System.today()) {
      	while (cntrct.Next_Auto_Renewal_Date__c <= System.today()) {
      	  system.debug('****Another IF***');
          cntrct.Next_Auto_Renewal_Date__c = cntrct.Next_Auto_Renewal_Date__c.addMonths(Integer.valueOf(cntrct.Renewal_Term_Period__c));//.addDays(1);
          if (!contractsToUpdateIds.contains(cntrct.Id)) {
            contractToUpdate.add(cntrct);
            contractsToUpdateIds.add(cntrct.Id);
          }
      	}
      }
      //contractToUpdate.add(cntrct);
      system.debug('===contractToUpdate>>' +contractToUpdate);
    }

    //update Contract Renewal date
    try {
      update contractToUpdate;
    } catch (DMLException e) {
      ApexLogHandler.createLogAndSave('BatchContractRenewalDate','execute', e.getStackTraceString(), e);
      for (Integer i = 0; i < e.getNumDml(); i++) {
        System.debug('\nError when updating Contract #' + i);
      }
    }
  }

  //===================================================
  // Finish method to send mail and track errors
  //===================================================
  global void finish (Database.BatchableContext bc) {
    
    BatchHelper bh = new BatchHelper();
    bh.checkBatch(bc.getJobId(), 'BatchContractRenewalDate', true);

    BatchHelper.setBatchClassTimestamp('ContractRenewalJobLastRun', holdingRunTime);
  }
}