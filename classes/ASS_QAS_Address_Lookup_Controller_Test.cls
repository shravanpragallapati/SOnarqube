/**=====================================================================
 * Appirio, Inc
 * Name: ASS_QAS_Address_Lookup_Controller_Test
 * Description: Test class for ASS_QAS_Address_Lookup_Controller
                
 * Created Date: Apr 22nd, 2014
 * Created By: Arpita Bose(Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 * Dec 10th, 2015               James Wills                  Case 01250120: Made change to testASS_QAS_Address_Lookup_Controller test method to ensure all addresses unique (see incident Case #01250120).
 * Nov 29th, 2016               Sadar Yacob/Yordan Terziev   Remove references to QAS v4
 * Jul 08th, 2021               Manoj Gopu                   Case 22376534: Upgraded API Version to 48.0
 =====================================================================*/
@isTest
public class ASS_QAS_Address_Lookup_Controller_Test {

  static testMethod void testASS_QAS_Address_Lookup_Controller() {
    Account testAcc = Test_Utils.insertAccount();
    List<Address__c> addrsLst = new List<Address__c>();
    Address__c addrs1 = new Address__c(
      Address_1__c = 'Test Addr1 001', 
      Address_2__c = 'Test Addr 0022', 
      Address_3__c = 'Test Addr 003', 
      Authenticated_Address__c = true
    );
    Address__c addrs2 = new Address__c(
      Address_1__c = 'Test Addr1 002', 
      Address_2__c = 'Test Addr 0022', 
      Address_3__c = 'Test Addr 003',
      zip__c = 'test zip', 
      Country__c = 'test country',
      Authenticated_Address__c = false
    );
    // Case 01250120: Fixed address_1__c to be unique                                    
    Address__c addrs3 = new Address__c(
      Address_1__c = 'Test Addr1 003', 
      Address_2__c = 'Test Addr 0022', 
      Address_3__c = 'Test Addr 003',
      zip__c = 'test zip', 
      Country__c = 'test country',
      Authenticated_Address__c = false
    );
    addrsLst.add(addrs1);  
    addrsLst.add(addrs2);
    addrsLst.add(addrs3);                               
    insert addrsLst; 
     
    List<Account_Address__c> accList = new List<Account_Address__c>();
           

    for (Address__c rec : addrsLst) {
      accList.add(new Account_Address__c(Account__c = testAcc.ID, Address__c = rec.ID));
    }
    insert accList;
      
      Global_Settings__c custSettings = Global_Settings__c.getValues('Global');
      if (custSettings == null) {
        custSettings = new Global_Settings__c(name='Global',Account_Team_Member_Default_Role__c= Constants.TEAM_ROLE_ACCOUNT_MANAGER,Seal_API_User__c=UserInfo.getUserId());
        insert custSettings;
      }
    
    Test.startTest();
    
    // Nov 29, 2016 - QAS v4 test logic commented out
    ASS_QAS_Address_Lookup_Controller controller = new ASS_QAS_Address_Lookup_Controller();
    controller.accId = testAcc.Id ;
    controller.accId = null; 
    
   Test.stopTest();
   /** QAS_NA__QAS_CA_Account__c account =  new QAS_NA__QAS_CA_Account__c();
    account.QAS_NA__ValidationSessionToken__c = 'test_Token';
    account.QAS_NA__InteractiveIntervalFromLastUpdate__c = 18000;
    account.QAS_NA__InteractiveInvokeIntervalFromLastUpdate__c = 8 ;
    account.QAS_NA__LicenseKey__c = 'test123';
    account.QAS_NA__TriggerRecordsLimit__c =2;
    account.QAS_NA__ValidCountryValues__c = 'CA';
    insert account;
    
    controller.accId = testAcc.Id ;
    controller.accId = null; */
    
    // Wherre are the assertions?
    
   // Test.stopTest();
    
  }

}