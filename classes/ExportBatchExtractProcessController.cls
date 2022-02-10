/******************************************************************************
 * Name: ExportBatchExtractProcessController 
 * Description: S-254156
 * Created Date: Oct 20th, 2014
 * Created By: Richard
 * Description : Class to Query , Extract and Format all Oracle finance report extract CSV files.
 * Change Log- 
 * Feb 11th 2015 Richard Joseph  Case # 00553884- This is to derive customer site value based on billing EDQ Integration ID for UK.
 * Feb 12th 2015 Richard Joseph Case # 00554006- To change the process to refer Global_Unique_ID__c if the Experian_ID__c is SFDC ID. If its EDQ ID then will pass the same.
 * Feb 18th 2015 Richard Jospeph Case # 00562967 
 * Mar 12th 2015 Richard Joseph  Case 00584024- To change Experian id to all upper case for APAC/EMEA .
 * Apr 16th 2015 Richard Joseph  Remove logic on credited order. Case # 00607717
 * Apr 16th 2015 Richard Joseph   Case # 568901- Changes to RPM file
 * Apr 20th 2015 Richard Joseph   Case # 607717- Changed to credit process -Changed status from Credit to 'Credit Note'
 * Sep 21st, 2015, Paul Kissick  I-179463: Cleaned up, commented out unused code to improve coverage
 * Dec 21, 2015, Richard Joseph - Including Targeting and other changes for APAC
 * May 26th 2016 Richard Joseph - Further changes for NON US Summit and Split the logic and template between APAC and EMEA. C# 00579994,00562259, C# 01157755
 * Dec 16th 2016 Richard Joseph - Changed all YYYY to yyyy for case 02238401.
 * Apr 21st 2017 Richard Joseph - changes for Case #02350405
 * Dec 15th 2018 Malcolm Russell - DP Migration added DPFile Export
 * Mar 28th 2018 Richard Joseph -  Added IFRS15_Secondary_Revenue_Subaccount_Code__c for Memoline for ANZ 
 * Apr  5th 2018 Malcolm Russell - Added Closedate and Ownername transform for DP Migration
 * Apr 10th 2018 Malcolm Russell - DP Migration added DPCustomerFile Export
 * Apr 12th 2018 Malcolm Russell - DP Migration added DPUniqueRef
 * July 1st 2018 Richard Joseph - case #16494509
 * Nov 19th 2018 Mauricio Murillo - Case 17523752: Added logic to avoid duplicate field names for Customer file
 * Apr  4th 2019 Malcolm Russell - EBA W-013923 - Added Extracts for EBA project
 * May 29th 2019 Chaldrin Cruz   - added Order__r.account__r.Company_Registration__c to ExtractEBACustomerFile
 * Nov 4th  2019 Chaldrin Cruz   - added processing for Transform--NAEDQAcctRules, Trasnform--NAEDQAcctStartDate, Transform--NAEDQDefGLCode in generateCSVFile()
 * MAR 10th 2020                 - updated logic for Transform--NAEDQAcctRules, Trasnform--NAEDQAcctStartDate, Transform--NAEDQDefGLCode QASNBatchL, QASRBatchL, QASN Admin ChargeL, QASRAdmin ChargeL
 * Jun 16th 2020 Sunil Kumar     - EBA I5553 and I5554
 * Jul 31st 2020 Malcolm Russell - Updated Transform--MemoLn to only add 'A' for Autralia and New Zealand when producing apacsummit export
 * Aug 26th 2020 Malcolm Russell - case 21003466 Updated NAEDQDefGLCode
 * Oct 29th 2020 Ilhami Halici   - Case: 21172980 Extra blank line appearing on EBA Transactional Export
 * May 03rd 2021 Rohit Aryan     - Case : 21886522 - Update NA Update to the Finance Export Tab script [Accounting Rules]
 * Jun 22nd 2021 Herbert Oliveira- W-032457: POC for new file extract format (Subscription and Non-Subscription products) 
 ******/
public class ExportBatchExtractProcessController {
    public List<string[]> reportDisplayList  {get; set;} // Added by Richard
    public String csvContent  {get; set;} // Added by Richard
    public enum exportFileTypes {DPCustomerFile,DPFile,RPMFile, SummitFile, RoyaltiesFile,PartnerFile,CustomerFile, PMM,APACSummitFile,EBATransFile,EBACustomerFile,EBATransFileNew,EBATransCreditFile,SubscriptionFile}    // Added by Richard
    public static Id generatedBatchId {get; set;} 
    public Boolean isComplete {get; set;}
    private set<string> memoLnTypeOfSaleLSet{ get; set;}
    private set<string> memoLnTypeOfSaleISet{ get; set;}
    private string userRegion {get; set;}   
    private boolean isUSRegion {get; set;}
    public String operatingUnitName='';
    public string DPcurrOrderID = 'First';
    public integer DPordernumber =0;
    public id Schedule_BatchID = null;
    public string CSVString {get; set;}
    
    public string EBACustomerIorU;
   
    public string getfileName() {
        User currentUser = [SELECT Region__c,Country__c, ID FROM User WHERE ID =: UserInfo.getUserId()];
        if (currentUser!= null) {
            userRegion = (currentUser.Region__c != null) ? currentUser.Region__c : '';
            if (currentUser.Country__c!= null) {
                if (currentUser.Country__c == 'US' ||
                    currentUser.Country__c == 'USA' || 
                    currentUser.Country__c == 'United States' ||
                    currentUser.Country__c == 'United States of America') {
                    operatingUnitName = 'EXP_US_EHI_OU';
                } else if (currentUser.Country__c == 'UK' || 
                			currentUser.Country__c == 'United Kingdom' ) {
                    operatingUnitName='EXP_UK_ELI_OU';
                } else if (currentUser.Country__c == 'FR' || 
                               currentUser.Country__c == 'France' ) {
                    operatingUnitName='EXP_FR_ECS_OU';
                } else if (currentUser.Country__c == 'NZ' || 
                    		   currentUser.Country__c == 'New Zealand' ) {
                    operatingUnitName='EXP_NZ_EAP_OU'; 
                } else if (currentUser.Country__c == 'SGP' || 
                    			currentUser.Country__c == 'Singapore' ) {
                    operatingUnitName='EXP_SG_EAP_OU';
                } else if (currentUser.Country__c == 'AU' || 
                    		   currentUser.Country__c == 'Australia' ) {
					operatingUnitName='EXP_AU_EAP_OU';
                } else if (currentUser.Country__c == 'NL' || 
                           currentUser.Country__c == 'Netherlands' ) {
					operatingUnitName='EXP_NL_ENL_OU';
				}
            } 
            //getOperatingUnitValue();
        } 
        String currentFileType = ApexPages.currentPage().getParameters().get('ExportFile');
        String requestFormat = ApexPages.currentPage().getParameters().get('Format');
        
        if (currentFileType == exportFileTypes.SubscriptionFile.name()) {
            return 'POC_SubscriptionLines_'+Datetime.now().format('ddMMyyyyHHMMSS');
        } else if (requestFormat != null && requestFormat=='PMM') {
            if (currentFileType==exportFileTypes.CustomerFile.name()) {
                return 'EXP_UN_CUSTOMERS_TARGETING_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.PartnerFile.name()){
                return 'EXP_UN_PARTNER_COMMISSION_TARGETING_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.RoyaltiesFile.name()){
                return 'EXP_UN_ROYALTIES_TARGETING_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.SummitFile.name()){ 
                return 'EXP_UN_TRANSACTION_TARGETING_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.APACSummitFile.name()){ 
                return 'EXP_UN_TRANSACTION_TARGETING_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.PMM.name()){
                return 'EXP_UN_TRANSACTION_TARGETING_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.RPMFile.name()){
                return 'EXP_RPM_'+Datetime.now().format('ddMMyyyyHHMMSS');
            }
        } else if (requestFormat != null && requestFormat=='EBA'){
            // EBA W-013923
            if (currentFileType==exportFileTypes.EBATransFile.name()){
                return 'EXP_EBA_TRANS_'+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.EBACustomerFile.name()){
                return 'EXP_EBA_CUSTOMERS_'+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.EBATransFileNew.name()){
                //return 'EXP_EBA_TRANS_NEW'+Datetime.now().format('ddMMyyyyHHMMSS');
                return 'EBAOrders'+Datetime.now().format('ddMMyyyyHHMMSS')+'.csv'; // I5554 Changes- Sunil
            } else if (currentFileType==exportFileTypes.EBATransCreditFile.name()){
                //return 'EXP_EBA_TRANS_CREDIT'+Datetime.now().format('ddMMyyyyHHMMSS'); 
                return  'EBACredits'+Datetime.now().format('ddMMyyyyHHMMSS')+'.csv'; // I5554 Changes- Sunil
            }
        } else {
            if (currentFileType==exportFileTypes.CustomerFile.name()) {
                return 'EXP_UN_CUSTOMERS_QAS_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.PartnerFile.name()){
                return 'EXP_UN_PARTNER_COMMISSION_QAS_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.RoyaltiesFile.name()){
                return 'EXP_UN_ROYALTIES_QAS_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.SummitFile.name()){ 
                return 'EXP_UN_TRANSACTION_QAS_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.APACSummitFile.name()){ 
                return 'EXP_UN_TRANSACTION_QAS_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.PMM.name()){
                return 'EXP_UN_TRANSACTION_TARGETING_'+operatingUnitName+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.RPMFile.name()){
                return 'EXP_RPM_'+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.DPFile.name()){
                return 'EXP_DP_'+Datetime.now().format('ddMMyyyyHHMMSS');
            } else if (currentFileType==exportFileTypes.DPCustomerFile.name()){
                return 'EXP_UN_CUSTOMERS_SGDP_'+Datetime.now().format('ddMMyyyyHHMMSS');
            }
        }
        return Datetime.now().format('ddMMyyyyHHMMSS');
    }
    
    public PageReference exportFileProcess() {
        isComplete=false;
        
        String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
        String currentFileType = ApexPages.currentPage().getParameters().get('ExportFile');
        
        getfileName();
        
        if (userRegion == 'APAC'  || userRegion == 'EMEA' ) {
            isUSRegion= false;
        } else {        
            isUSRegion= true;
        }
        
        if(currentBatchId!=null && currentBatchId!= ''){
            if (currentFileType==exportFileTypes.SubscriptionFile.name()) {
                exportSubscriptionFile();
                isComplete=true;
            } else if (currentFileType==exportFileTypes.CustomerFile.name()) {   
                exportCustFile();   
                // ApexPages.currentPage().getParameters().put('ExportFile', 'PartnerFile'); 
                return  null;
            } else if (currentFileType==exportFileTypes.PartnerFile.name()) {
                exportPartnerFile();
                //ApexPages.currentPage().getParameters().put('ExportFile', 'RoyaltiesFile'); 
                return  null;
            } else if (currentFileType==exportFileTypes.RoyaltiesFile.name()) {
                exportRoyaltyFile();
                //ApexPages.currentPage().getParameters().put('ExportFile', 'SummitFile'); 
                return  null;
            } else if (currentFileType==exportFileTypes.SummitFile.name()) { 
                exportSummitFile();
                //ApexPages.currentPage().getParameters().put('ExportFile', 'RPMFile'); 
                return  null;
            } else if (currentFileType==exportFileTypes.APACSummitFile.name()) { //APACSummitFile
                exportAPACSummitFile();
                //ApexPages.currentPage().getParameters().put('ExportFile', 'RPMFile'); 
                return  null;
            } else if (currentFileType==exportFileTypes.PMM.name()) {
                exportPMMFile ();
                //ApexPages.currentPage().getParameters().put('ExportFile', 'RPMFile'); exportPMMFile 
                return  null;
            } else if (currentFileType==exportFileTypes.RPMFile.name()) {
                exportRPMFile();
                isComplete=true;
                //ApexPages.currentPage().getParameters().put('ExportFile', 'PartnerFile'); 
                //return  null;
            } else if (currentFileType==exportFileTypes.DPFile.name()) {
                exportDPFile();
                isComplete=true;
                //ApexPages.currentPage().getParameters().put('ExportFile', 'PartnerFile'); 
                //return  null;
            } else if (currentFileType==exportFileTypes.DPCustomerFile.name()) {
                exportDPCustomerFile();
                isComplete=true;
                //ApexPages.currentPage().getParameters().put('ExportFile', 'PartnerFile'); 
                //return  null;
                //EBA W-013923
            } else if (currentFileType==exportFileTypes.EBATransFile.name()) {
                exportEBATransFile();
                return  null;
            } else if (currentFileType==exportFileTypes.EBATransFileNew.name()) {
                exportEBATransNewFile();
                return  null;
            } else if (currentFileType==exportFileTypes.EBATransCreditFile.name()) {
                exportEBATransCreditFile();
                return  null;
            } else if (currentFileType==exportFileTypes.EBACustomerFile.name()) {
                exportEBACustomerFile();
                isComplete=true;
            }
        }
        return null;
    }
   
  //===========================================================================
  // Method to generate EDQ Customer File - Richard Joseph
  //=========================================================================== 
  public PageReference exportCustFile () {

    Report_Extract_Templates__c reportExtractTemplateRec= Report_Extract_Templates__c.getValues('Oracle Customer File');

    Integer fieldCount = 1;
    String queryFieldsStr = '';
    String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>(); //17523752

    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform')
      && !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') 
                  && !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') 
       ){
         //17523752
         String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' )); 
         if (!fieldSet.Contains(fieldName)) {
           queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
           fieldSet.add(fieldName );
         }
       }     
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve01: ' +queryFieldsStr );
  
    String filterStr = 'where Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';

    String soqlStr = 'Select '+queryFieldsStr +' ID,Owner_Region__c,Ownerid,Owner_Country__c,Billing_Address__r.Country__c,Billing_Address__r.State__c,Billing_Address__r.EDQ_Integration_Id__c,Account__r.Global_Unique_ID__c   From Order__c '+filterStr ;

    system.debug('SOQL to Fetch01: ' +sOQLStr );
    
    generateCSVFile(exportFileTypes.CustomerFile,sOQLStr,reportExtractTemplateRec );
 
    PageReference reDirected = new PageReference('/apex/ExportBatchExtractProcess?BatchID='+currentBatchId+'&ExportFile=RPMFile');
    return reDirected;
    //return null;
   
  } 
  
    
  
   //===========================================================================
    // Method to generate DP file - Malcolm Russell
    //=========================================================================== 
  public PageReference exportDPFile () {

    Report_Extract_Templates__c reportExtractTemplateRec= Report_Extract_Templates__c.getValues('DP File');

    Integer fieldCount = 1;
    String queryFieldsStr = '';
    String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    Integer seqNumber = 0; 
    String todayDate= Datetime.now().format('ddMMyyyy'); 
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') ) { 
        String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
        if( !fieldSet.Contains(fieldName )) {      
          queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
          fieldSet.add(fieldName );
        }
      }
      //queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve0: ' +queryFieldsStr );
  
    String filterStr = 'where Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';
    //RJ - Case # 568901 changes
    String soqlStr = 'Select '+queryFieldsStr +' ID,Order__r.Billing_Address__r.Country__c,Order__r.Account__r.billingcountry,Order__r.Billing_Address__r.EDQ_Integration_Id__c,Order__r.Account__r.Name,order__r.Account__r.Experian_Company__c,order__r.Owner_country__c,End_Date__c,Users_From__c,Users_To__c,Quantity_Type__c,Start_Date__c,order__r.owner.firstname, order__r.owner.lastname,order__r.close_date__c,order__r.billing_contact__r.account.DP_Customer_Id__c  From Order_Line_Item__c '+filterStr ;

    system.debug('SOQL to Fetch02: ' +sOQLStr );
    
    generateCSVFile(exportFileTypes.DPFile,sOQLStr,reportExtractTemplateRec );
  
    //System.debug(reportDisplayList);
    
    PageReference reDirected = new PageReference('/apex/ExportBatchExtractProcess?BatchID='+currentBatchId+'&ExportFile=RoyaltiesFile');
    return reDirected;
    //return null;
    //return page.BatchOrderList;
    
  }
  
   //===========================================================================
    // Method to generate DP file - Malcolm Russell
    //=========================================================================== 
  public PageReference exportDPCustomerFile () {

    Report_Extract_Templates__c reportExtractTemplateRec= Report_Extract_Templates__c.getValues('DP Customer File');

    Integer fieldCount = 1;
    String queryFieldsStr = '';
    String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    Integer seqNumber = 0; 
    String todayDate= Datetime.now().format('ddMMyyyy'); 
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') ) { 
        String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
        if( !fieldSet.Contains(fieldName )) {      
          queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
          fieldSet.add(fieldName );
        }
      }
      //queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve: ' +queryFieldsStr );
  
    String filterStr = 'where Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';
    //RJ - Case # 568901 changes
    String soqlStr = 'Select '+queryFieldsStr +' ID,Order__r.Billing_Address__r.Country__c,Order__r.Account__r.billingcountry,Order__r.Billing_Address__r.EDQ_Integration_Id__c,Order__r.Account__r.Name,order__r.Account__r.Experian_Company__c,order__r.Owner_country__c,End_Date__c,Users_From__c,Users_To__c,Quantity_Type__c,Start_Date__c,order__r.owner.firstname, order__r.owner.lastname,order__r.close_date__c,order__r.billing_contact__r.account.DP_Customer_Id__c From Order_Line_Item__c '+filterStr ;

    system.debug('SOQL to Fetch03: ' +sOQLStr );
    
    generateCSVFile(exportFileTypes.DPCustomerFile,sOQLStr,reportExtractTemplateRec );
  
    //System.debug(reportDisplayList);
    
    PageReference reDirected = new PageReference('/'+currentBatchId);
    return reDirected;
    //return null;
    //return page.BatchOrderList;
    
  } 
  
  //===========================================================================
    // Method to generate EBA Trans file - Malcolm Russell
    //=========================================================================== 
  public PageReference exportEBATransFile () {

    Report_Extract_Templates__c reportExtractTemplateRec= Report_Extract_Templates__c.getValues('EBA Trans');

    Integer fieldCount = 1;
    String queryFieldsStr = '';
    string currentBatchId;
    if (Schedule_BatchID != null){
      currentBatchId = Schedule_BatchID;
    }
    else{
      currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    }
    Integer seqNumber = 0; 
    String todayDate = Datetime.now().format('d-MMM-yy');  
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    string transDate;
            if(label.EBA_Transaction_date == 'N/A'){
              transDate= datetime.now().format('yyyy-MM-dd');
            }
            else {
              transDate= string.valueof(label.EBA_Transaction_date.substring(4)+'-'+label.EBA_Transaction_date.substring(2,4)+'-'+ label.EBA_Transaction_date.substring(0,2));
            } 
    system.debug('transDate ' + transDate);
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') &&
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('GQ--') ) { 
        String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
        if( !fieldSet.Contains(fieldName )) {      
          queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
          fieldSet.add(fieldName );
        }
      }
      //queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve: ' +queryFieldsStr );
  
    String filterStr = 'where Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';
    //RJ - Case # 568901 changes
    //String soqlStr = 'Select '+queryFieldsStr +' ID,Order__r.Billing_Address__r.Country__c,Order__r.Account__r.billingcountry,Order__r.Billing_Address__r.EDQ_Integration_Id__c,Order__r.Account__r.Name,order__r.Account__r.Experian_Company__c,order__r.Owner_country__c,End_Date__c,Users_From__c,Users_To__c,Quantity_Type__c,Start_Date__c,order__r.owner.firstname, order__r.owner.lastname,order__r.close_date__c,Order__r.order_number__c,Order__r.payment_method__c,Order__r.billing_contact__r.account.Company_Registration__c,Order__r.billing_contact__r.account.EBA_Customer_Site_Ref__c,Order__r.billing_contact__r.account.Global_Unique_ID__c,Order__r.billing_contact__r.account.Country_of_Registration__c  From Order_Line_Item__c '+filterStr ;
    String soqlStr = 'Select '+queryFieldsStr +' ID,order__r.owner.firstname, order__r.owner.lastname,order__r.close_date__c,Order__r.order_number__c,Order__r.payment_method__c,Order__r.account__r.Company_Registration__c,Order__r.account__r.EBA_Customer_Site_Ref__c,Order__r.account__r.Global_Unique_ID__c,Order__r.account__r.Country_of_Registration__c,Order__r.billing_contact__r.account.Country_of_Registration__c,(Select id,Revenue__c,Scheduled_Date__c,EBA_VAT_Default__c from Order_Revenue_Schedules__r  where Scheduled_Date__c = ' + transDate + ' limit  1 ) From Order_Line_Item__c '+filterStr ; // RJ updated with Rev Schd Details

    system.debug('SOQL to Fetch04: ' +sOQLStr );
    
     CSVString=generateCSVFile(exportFileTypes.EBATransFile,sOQLStr,reportExtractTemplateRec );
  
    //System.debug(reportDisplayList);
    
    PageReference reDirected = new PageReference('/apex/ExportBatchExtractProcess?BatchID='+currentBatchId+'&ExportFile=EBACustomerFile' + '&Format=EBA');
    return reDirected;
    //return null;
    //return page.BatchOrderList;
    
  }

  //===========================================================================
    // Method to generate EBA Trans file - Chaldrin Cruz
    //=========================================================================== 
    public PageReference exportEBATransNewFile () {

      Report_Extract_Templates__c reportExtractTemplateRec= Report_Extract_Templates__c.getValues('EBA Trans New');
  
      Integer fieldCount = 1;
      String queryFieldsStr = '';
      string currentBatchId;
      if (Schedule_BatchID != null){
        currentBatchId = Schedule_BatchID;
      }
      else{
        currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
      }
      Integer seqNumber = 0; 
      String todayDate = Datetime.now().format('d-MMM-yy');  
      //Richard TestData 
      //currentBatchId=generatedBatchId;
      
      string transDate;
              if(label.EBA_Transaction_date == 'N/A'){
                transDate= datetime.now().format('yyyy-MM-dd');
              }
              else {
                transDate= string.valueof(label.EBA_Transaction_date.substring(4)+'-'+label.EBA_Transaction_date.substring(2,4)+'-'+ label.EBA_Transaction_date.substring(0,2));
              } 
      system.debug('transDate ' + transDate);
      reportDisplayList = new list<string[]>();
      String fieldValue ='';
      Set<String> fieldSet = new Set<String>();
      while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
        if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
            !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
            !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
            !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
            !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') &&
            !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('GQ--') ) { 
          String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
          if( !fieldSet.Contains(fieldName )) {      
            queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
            fieldSet.add(fieldName );
          }
        }
        //queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
        fieldCount++;
      }
    
      system.debug('Fields to Retrieve: ' +queryFieldsStr );
    
      String filterStr = 'where Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';
      //String soqlStr = 'Select '+queryFieldsStr +' ID,order__r.owner.firstname, order__r.owner.lastname,order__r.close_date__c,Order__r.order_number__c,Order__r.payment_method__c,Order__r.account__r.Company_Registration__c,Order__r.account__r.EBA_Customer_Site_Ref__c,Order__r.account__r.Global_Unique_ID__c,Order__r.account__r.Country_of_Registration__c,Order__r.billing_contact__r.account.Country_of_Registration__c,(Select id,Revenue__c,Scheduled_Date__c,EBA_VAT_Default__c from Order_Revenue_Schedules__r  where Scheduled_Date__c = ' + transDate + ' limit  1 ) From Order_Line_Item__c '+filterStr ; // RJ updated with Rev Schd Details
      String soqlStr = 'Select ' + queryFieldsStr + ' ID From Order_Line_Item__c ' + filterStr;
  
      system.debug('SOQL to Fetch04a: ' +sOQLStr );
      
       CSVString=generateCSVFile(exportFileTypes.EBATransFileNew,sOQLStr,reportExtractTemplateRec );
    
      //System.debug(reportDisplayList);
      
      PageReference reDirected = new PageReference('/apex/ExportBatchExtractProcess?BatchID='+currentBatchId+'&ExportFile=EBACustomerFile' + '&Format=EBA');
      return reDirected;
      //return null;
      //return page.BatchOrderList;
      
    }
  
      //===========================================================================
      // Method to generate EBA Trans Credit file - Chaldrin Cruz
      //=========================================================================== 
    public PageReference exportEBATransCreditFile () {
  
      Report_Extract_Templates__c reportExtractTemplateRec= Report_Extract_Templates__c.getValues('EBA Trans Credits');
  
      Integer fieldCount = 1;
      String queryFieldsStr = '';
      string currentBatchId;
      if (Schedule_BatchID != null){
        currentBatchId = Schedule_BatchID;
      }
      else{
        currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
      }
      Integer seqNumber = 0; 
      String todayDate = Datetime.now().format('d-MMM-yy');  
      //Richard TestData 
      //currentBatchId=generatedBatchId;
      
      string transDate;
              if(label.EBA_Transaction_date == 'N/A'){
                transDate= datetime.now().format('yyyy-MM-dd');
              }
              else {
                transDate= string.valueof(label.EBA_Transaction_date.substring(4)+'-'+label.EBA_Transaction_date.substring(2,4)+'-'+ label.EBA_Transaction_date.substring(0,2));
              } 
      system.debug('transDate ' + transDate);
      reportDisplayList = new list<string[]>();
      String fieldValue ='';
      Set<String> fieldSet = new Set<String>();
      while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
        if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
            !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
            !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
            !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
            !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') &&
            !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('GQ--') ) { 
          String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
          if( !fieldSet.Contains(fieldName )) {      
            queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
            fieldSet.add(fieldName );
          }
        }
        //queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
        fieldCount++;
      }
    
      system.debug('Fields to Retrieve: ' +queryFieldsStr );
    
      String filterStr = 'where Order_Line_Item__r.Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';
      //String soqlStr = 'Select '+queryFieldsStr +' ID,order__r.owner.firstname, order__r.owner.lastname,order__r.close_date__c,Order__r.order_number__c,Order__r.payment_method__c,Order__r.account__r.Company_Registration__c,Order__r.account__r.EBA_Customer_Site_Ref__c,Order__r.account__r.Global_Unique_ID__c,Order__r.account__r.Country_of_Registration__c,Order__r.billing_contact__r.account.Country_of_Registration__c,(Select id,Revenue__c,Scheduled_Date__c,EBA_VAT_Default__c from Order_Revenue_Schedules__r  where Scheduled_Date__c = ' + transDate + ' limit  1 ) From Order_Line_Item__c '+filterStr ; // RJ updated with Rev Schd Details
      String soqlStr = 'Select ' + queryFieldsStr + ' ID From Order_Line_Item_Credit__c ' + filterStr;
  
      system.debug('SOQL to Fetch04b: ' +sOQLStr );
      
       CSVString=generateCSVFile(exportFileTypes.EBATransCreditFile,sOQLStr,reportExtractTemplateRec );
    
      //System.debug(reportDisplayList);
      
      PageReference reDirected = new PageReference('/apex/ExportBatchExtractProcess?BatchID='+currentBatchId+'&ExportFile=EBACustomerFile' + '&Format=EBA');
      return reDirected;
      //return null;
      //return page.BatchOrderList;
    }
  
  //===========================================================================
    // Method to generate EBA Customer file - Malcolm Russell
    //=========================================================================== 
  public PageReference exportEBACustomerFile () {

    Report_Extract_Templates__c reportExtractTemplateRec= Report_Extract_Templates__c.getValues('EBA Customer');

    Integer fieldCount = 1;
    String queryFieldsStr = '';
    string currentBatchId;
    if (Schedule_BatchID != null){
      currentBatchId = Schedule_BatchID;
    }
    else{
      currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    }
    Integer seqNumber = 0; 
    String todayDate = Datetime.now().format('d-MMM-yy');  
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    //reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') ) { 
        String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
        if( !fieldSet.Contains(fieldName )) {      
          queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
          fieldSet.add(fieldName );
        }
      }
      //queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve: ' +queryFieldsStr );
  
    String filterStr = 'where Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';
    //RJ - Case # 568901 changes
    //String soqlStr = 'Select '+queryFieldsStr +' ID,Order__r.Account__r.billingcountry,Order__r.Billing_Address__r.EDQ_Integration_Id__c,order__r.Account__r.Experian_Company__c,order__r.Owner_country__c,End_Date__c,Users_From__c,Users_To__c,Quantity_Type__c,Start_Date__c,order__r.owner.firstname, order__r.owner.lastname,order__r.close_date__c,Order__r.account__r.EBA_Customer_Site_Ref__c,Order__r.account__r.Global_Unique_ID__c,Order__r.account__r.Company_Registration__c,Order__r.order_number__c,Order__r.payment_method__c,Order__r.Account__C  From Order_Line_Item__c '+filterStr ;
    String soqlStr = 'Select '+queryFieldsStr +' ID,Order__r.Account__r.billingcountry,Order__r.Billing_Address__r.EDQ_Integration_Id__c,order__r.Account__r.Experian_Company__c,order__r.Owner_country__c,End_Date__c,Users_From__c,Users_To__c,Quantity_Type__c,Start_Date__c,order__r.owner.firstname, order__r.owner.lastname,order__r.close_date__c,Order__r.account__r.EBA_Customer_Site_Ref__c,Order__r.account__r.Global_Unique_ID__c,Order__r.order_number__c,Order__r.payment_method__c,Order__r.Account__c  From Order_Line_Item__c '+filterStr ;

    system.debug('SOQL to Fetch05: ' +sOQLStr );
    
    CSVString=generateCSVFile(exportFileTypes.EBACustomerFile,sOQLStr,reportExtractTemplateRec );
  
    //System.debug(reportDisplayList);
    
    PageReference reDirected = new PageReference('/'+currentBatchId);
    return reDirected;
    //return null;
    //return page.BatchOrderList;
    
  }
  
   //===========================================================================
    // Method to generate EDQ RPM file - Richard Joseph
    //=========================================================================== 
  public PageReference exportRPMFile () {

    Report_Extract_Templates__c reportExtractTemplateRec= Report_Extract_Templates__c.getValues('RPM File');

    Integer fieldCount = 1;
    String queryFieldsStr = '';
    String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    Integer seqNumber = 0; 
    String todayDate= Datetime.now().format('ddMMyyyy'); 
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') ) { 
        String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
        if( !fieldSet.Contains(fieldName )) {      
          queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
          fieldSet.add(fieldName );
        }
      }
      //queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve: ' +queryFieldsStr );
  
    String filterStr = 'where Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';
    //RJ - Case # 568901 changes
    String soqlStr = 'Select '+queryFieldsStr +'ID,Order__r.Billing_Address__r.Country__c,Order__r.Account__r.Name,End_Date__c,Users_From__c,Users_To__c,Quantity_Type__c,Start_Date__c,Product_Finance_BU__c,EDQ_Memo_Line__c,CPQ_Quantity__c,Quantity__c,Order__r.Billing_Contact_Name__c From Order_Line_Item__c '+filterStr ;

    system.debug('SOQL to Fetch06: ' +sOQLStr );
    
    generateCSVFile(exportFileTypes.RPMFile,sOQLStr,reportExtractTemplateRec );
  
    //System.debug(reportDisplayList);
    
    PageReference reDirected = new PageReference('/apex/ExportBatchExtractProcess?BatchID='+currentBatchId+'&ExportFile=RoyaltiesFile');
    return reDirected;
    //return null;
    //return page.BatchOrderList;
    
  }
   //===========================================================================
    // Method to generate EDQ Royalties File - Richard Joseph
    //=========================================================================== 
  public PageReference exportRoyaltyFile () {

    Report_Extract_Templates__c reportExtractTemplateRec= Report_Extract_Templates__c.getValues('Oracle Royalties File');

    Integer fieldCount = 1;
    String queryFieldsStr = '';
    String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    Integer seqNumber = 0; 
    String todayDate= Datetime.now().format('ddMMyyyy');
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') ) {
        String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
        if( !fieldSet.Contains(fieldName )) {
          queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
          fieldSet.add(fieldName );
        }
      }
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve: ' +queryFieldsStr );
  
    String filterStr = 'where Amount__c != 0 AND Order_line_Item__r.Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';

    String soqlStr = 'Select '+queryFieldsStr +' ID,Order_line_Item__r.Product__r.Types_of_Sale__c,Order_line_Item__r.Type_of_Sale__c, Order_line_Item__r.Product__r.Family,Order_line_Item__r.Order__r.Type__c,Order_line_Item__r.EDQ_Memo_Line__c,Royalty_Group_Reference__c,Order_line_Item__r.Order__r.Status__c From Royalty__c '+filterStr ;

    system.debug('SOQL to Fetch07: ' +sOQLStr );
    
    generateCSVFile(exportFileTypes.RoyaltiesFile,sOQLStr,reportExtractTemplateRec );   
    
    //System.debug(reportDisplayList);
    
    PageReference reDirected = new PageReference('/apex/ExportBatchExtractProcess?BatchID='+currentBatchId+'&ExportFile=PartnerFile');
    return reDirected;
    //return null;
    //return page.BatchOrderList;
  }


  //===========================================================================
    // Method to generate EDQ Patner File - Richard Joseph
    //=========================================================================== 
  public PageReference exportPartnerFile () {

    Report_Extract_Templates__c reportExtractTemplateRec= Report_Extract_Templates__c.getValues('Oracle Partner File');

    Integer fieldCount = 1;
    String queryFieldsStr = '';
    String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    Integer seqNumber = 0; 
    String todayDate= Datetime.now().format('ddMMyyyy');
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != null && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') ) {
        String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
        if( !fieldSet.Contains(fieldName )) {      
          queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
          fieldSet.add(fieldName );
        }
      }
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve: ' +queryFieldsStr );
  
    String filterStr = 'where Partner_Amount__c >0 AND Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';

    String soqlStr = 'Select '+queryFieldsStr +'name,Order__r.Account__r.BillingCountry,Product__r.Types_of_Sale__c, Product__r.Family,'+
                        'Order__r.Type__c,Type_of_Sale__c,EDQ_Memo_Line__c,Order__r.Partner__r.Experian_ID__c,Order__r.Status__c From Order_Line_Item__c '+filterStr ;

    system.debug('SOQL to Fetch08: ' +sOQLStr );
    
    
    generateCSVFile(exportFileTypes.PartnerFile,sOQLStr,reportExtractTemplateRec );
    //System.debug(reportDisplayList);

    PageReference reDirected = new PageReference('/apex/ExportBatchExtractProcess?BatchID='+currentBatchId+'&ExportFile=SummitFile');
    return reDirected;
    //return null;
    //return page.BatchOrderList;
  }

  //===========================================================================
  // Method to generate EDQ Summit File - Richard Joseph
  //=========================================================================== 
  public PageReference exportSummitFile () {
  
    Report_Extract_Templates__c reportExtractTemplateRec;
    Report_Extract_Templates__c reportExtractTemplateHdr;
    if(isUSRegion) {  
      reportExtractTemplateRec= Report_Extract_Templates__c.getValues('Oracle Transaction (Summit) File');
       // reportExtractTemplateHdr= Report_Extract_Templates__c.getValues('Oracle Transaction (Summit) Hdrs'); // RJ Commented WIP
    }
    else {
      reportExtractTemplateRec= Report_Extract_Templates__c.getValues('Oracle Trans (Summit) NON US');
      // reportExtractTemplateHdr= Report_Extract_Templates__c.getValues('Oracle Trans (Summit) NON US Hdrs'); // RJ Commented WIP
    }
    Integer fieldCount = 1;
    String queryFieldsStr = '';
    String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    Integer seqNumber = 0; 
    String todayDate= Datetime.now().format('ddMMyyyy');
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SF--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('GQ--') ) {
        String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
        if (!fieldSet.Contains(fieldName)) {
             queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
          fieldSet.add(fieldName );
          
         
          
        }
      }
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve: ' +queryFieldsStr );
  
    String filterStr = 'where Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';
    String soqlStr = '';
if(isUSRegion) { 
   soqlStr = 'Select '+queryFieldsStr +'name, id, Product_Upgrade__c, Contract_Term__c, Start_Date__c, Order__r.id, Operating_System__c,Product__r.Name, Product__r.Types_of_Sale__c, Product__r.Family,Order__r.Type__c,Order__r.Shipping_Contact__c,'+
                        'Type_of_Sale__c,Users_To__c, Users_From__c, End_Date__c,Quantity_Type__c,Order__r.Owner_Country__c,Order__r.Contact__r.email,Order__r.Billing_Contact__r.email,'+
                        'Order__r.Billing_Address__c, Order__r.Shipping_Address__c,Order__r.Account__r.Global_Unique_ID__c,Order__r.Shipping_Address__r.State__c,'+
                        'Order__r.Billing_Address__r.EDQ_Integration_Id__c,Product_Family__c,Product_Finance_BU__c,EDQ_Memo_Line__c,CPQ_Quantity__c,Quantity__c From Order_Line_Item__c '+filterStr + ' Order by Order__r.Name , Name' ;
}else
{
     soqlStr = 'Select '+queryFieldsStr +'name, id, Product_Upgrade__c, Contract_Term__c, Start_Date__c, Order__r.id, Operating_System__c,Product__r.Name, Product__r.Types_of_Sale__c, Product__r.Family,Order__r.Type__c,Order__r.Shipping_Contact__c,'+
                        'Type_of_Sale__c,Users_To__c, Users_From__c,   Quantity_Type__c,Order__r.Owner_Country__c,Order__r.Contact__r.email,Order__r.Billing_Contact__r.email,Order__r.PO_Number__c,'+
                        'Order__r.Billing_Address__c, Order__r.Shipping_Address__c,Order__r.Account__r.Global_Unique_ID__c,Order__r.Shipping_Address__r.State__c,Order__r.Opportunity__r.Oppty_ID_18_chars__c,'+
                        'End_Date__c,Order__r.Billing_Address__r.EDQ_Integration_Id__c,Product_Family__c,Product_Finance_BU__c,EDQ_Memo_Line__c,CPQ_Quantity__c,Quantity__c,order__r.close_date__c From Order_Line_Item__c '+filterStr + ' Order by Order__r.Name , Name' ;
}//Case #01266714 James Wills: Added End_Date__c to the else soqlStr to stop related test class from failing.
//RJ : Added Order__r.Opportunity__r.Oppty_ID_18_chars__c  and Order__r.PO_Number__c
    system.debug('SOQL to Fetch09: ' +sOQLStr );
        
    generateCSVFile(exportFileTypes.SummitFile,sOQLStr,reportExtractTemplateRec );
    //System.debug(reportDisplayList);

    PageReference reDirected = new PageReference('/'+currentBatchId);
    return reDirected;
    //return null;
    
  }
  //RJ - Added to split APAC Summit file
  //===========================================================================
  // Method to generate EDQ APAC Summit File - Richard Joseph
  //=========================================================================== 
  public PageReference exportAPACSummitFile () {
  
    Report_Extract_Templates__c reportExtractTemplateRec;
    if(isUSRegion) {  
      reportExtractTemplateRec= Report_Extract_Templates__c.getValues('Oracle Transaction (Summit) File');
    }
    else {
      reportExtractTemplateRec= Report_Extract_Templates__c.getValues('Oracle Trans (Summit) APAC');
    }
    Integer fieldCount = 1;
    String queryFieldsStr = '';
    String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    Integer seqNumber = 0; 
    String todayDate= Datetime.now().format('ddMMyyyy');
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SF--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('GQ--') ) {
        String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
        if (!fieldSet.Contains(fieldName)) {
          queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
          fieldSet.add(fieldName );
        }
      }
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve: ' +queryFieldsStr );
  
    String filterStr = 'where Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';
    String soqlStr = '';
if(isUSRegion) { 
   soqlStr = 'Select '+queryFieldsStr +'name,id ,Order__r.id,Contract_Term__c, Operating_System__c,Product__r.Types_of_Sale__c, Product__r.Family,Order__r.Type__c,Order__r.Shipping_Contact__c,'+
                        'Type_of_Sale__c,Users_To__c, Users_From__c, End_Date__c,Start_Date__c,Quantity_Type__c,Order__r.Owner_Country__c,Order__r.Contact__r.email,Order__r.Billing_Contact__r.email,IFRS15_Secondary_Revenue_Subaccount_Code__c,IFRS15_Primary_Revenue_Subaccount_Code__c,EDQ_Memo_Line__c,'+// RJ added IFRS15 changes IFRS15_Primary_Revenue_Subaccount_Code__c,IFRS15_Secondary_Revenue_Subaccount_Code__c
                        'Order__r.Billing_Address__c, Order__r.Shipping_Address__c,Order__r.Account__r.Global_Unique_ID__c,Order__r.Shipping_Address__r.State__c,Product_Upgrade__c,'+
                        'Order__r.Billing_Address__r.EDQ_Integration_Id__c,Product_Family__c,CPQ_Quantity__c,Product_Finance_BU__c,Quantity__c,Order__r.Billing_Country__c From Order_Line_Item__c '+filterStr + ' Order by Order__r.Name , Name' ;
}else
{
     soqlStr = 'Select '+queryFieldsStr +'name,id ,Order__r.id, Operating_System__c,Product__r.Types_of_Sale__c, Product__r.Family,Order__r.Type__c,Order__r.Shipping_Contact__c,'+
                        'Type_of_Sale__c,Users_To__c, Users_From__c, Quantity_Type__c,Order__r.Owner_Country__c,Order__r.Contact__r.email,Order__r.Billing_Contact__r.email,End_date__c,Start_Date__c,IFRS15_Secondary_Revenue_Subaccount_Code__c,IFRS15_Primary_Revenue_Subaccount_Code__c,EDQ_Memo_Line__c,'+// RJ added IFRS15 changes IFRS15_Primary_Revenue_Subaccount_Code__c,IFRS15_Secondary_Revenue_Subaccount_Code__c
                        'Order__r.Billing_Address__c, Order__r.Shipping_Address__c,Order__r.Account__r.Global_Unique_ID__c,Order__r.Shipping_Address__r.State__c,Product_Upgrade__c,'+
                        'Order__r.Billing_Address__r.EDQ_Integration_Id__c,Product_Family__c,Product_Finance_BU__c,CPQ_Quantity__c,Quantity__c,Order__r.Billing_Country__c From Order_Line_Item__c '+filterStr + ' Order by Order__r.Name , Name' ;
}
    system.debug('SOQL to Fetch10: ' +sOQLStr );
        
    generateCSVFile(exportFileTypes.APACSummitFile,sOQLStr,reportExtractTemplateRec );
    //System.debug(reportDisplayList);

    PageReference reDirected = new PageReference('/'+currentBatchId);
    return reDirected;
    //return null;
    
  }
   //RJ Added it for APAC PMM
    //===========================================================================
  // Method to generate PMM File - Richard Joseph
  //=========================================================================== 
  public PageReference exportPMMFile () {
  
    Report_Extract_Templates__c reportExtractTemplateRec;
     
      reportExtractTemplateRec= Report_Extract_Templates__c.getValues('APACPMM');
   
    Integer fieldCount = 1;
    String queryFieldsStr = '';
    String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
    Integer seqNumber = 0; 
    String todayDate= Datetime.now().format('ddMMyyyy');
    //Richard TestData 
    //currentBatchId=generatedBatchId;
    
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      if (String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) !=null && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('Transform') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('HC--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('DT--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SQ--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('SF--') && 
          !String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')).contains('GQ--') ) {
        String fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ));
        if (!fieldSet.Contains(fieldName)) {
          queryFieldsStr=queryFieldsStr +String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c' ))+',';
          fieldSet.add(fieldName );
        }
      }
      fieldCount++;
    }
  
    system.debug('Fields to Retrieve: ' +queryFieldsStr );
  
    String filterStr = 'where Order__r.Finance_Invoice_Export_Batch__c = \''+currentBatchId +'\'';

    String soqlStr = 'Select '+queryFieldsStr +'name,id ,Order__r.id, Operating_System__c,Product__r.Types_of_Sale__c, Product__r.Family,Order__r.Type__c,Order__r.Shipping_Contact__c,'+
                        'Type_of_Sale__c,Users_To__c, Users_From__c,Quantity_Type__c,Order__r.Owner_Country__c,Order__r.Contact__r.email,Order__r.Billing_Contact__r.email,Product_Upgrade__c,EDQ_Memo_Line__c,IFRS15_Secondary_Revenue_Subaccount_Code__c,IFRS15_Primary_Revenue_Subaccount_Code__c,'+// RJ added IFRS15_Primary_Revenue_Subaccount_Code__c,IFRS15_Secondary_Revenue_Subaccount_Code__c
                        'Order__r.Billing_Address__c, Order__r.Shipping_Address__c,Order__r.Account__r.Global_Unique_ID__c,Order__r.Shipping_Address__r.State__c,Order__r.Opportunity__r.Description,Product__r.PD_Code__c,'+
                        'Order__r.Billing_Address__r.EDQ_Integration_Id__c,CPQ_Quantity__c,Quantity__c From Order_Line_Item__c '+filterStr + ' Order by Order__r.Name , Name' ;

    system.debug('SOQL to Fetch11: ' +sOQLStr );
        
    generateCSVFile(exportFileTypes.PMM,sOQLStr,reportExtractTemplateRec );
    //System.debug(reportDisplayList);

    PageReference reDirected = new PageReference('/'+currentBatchId);
    return reDirected;
    //return null;
    
  }
     
    //===========================================================================
    // Method to generate Subscription file - Hebrert Oliveira
    //=========================================================================== 
    public PageReference exportSubscriptionFile () {
        
        String currentBatchId = ApexPages.currentPage().getParameters().get('BatchID');
                
        String soqlStr = 'SELECT Id, Type, Owner.Email, Contract_Term__c, AccountId, Account.Status__c, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.Company_Registration__c, Account.VBM_Code__c, ';
        soqlStr += '(SELECT Name, Fair_Use_Limit_Percentage__c, RPM_Product_Journey_Identifier__c, Subscription_Invoice_Line_Description__c, Tier_1_Lower_Threshold__c, Tier_1_Monthly_Subscription_Fee__c, Tier_1_Upper_Threshold__c, Tier_2_Lower_Threshold__c, Tier_2_Monthly_Subscription_Fee__c, Tier_2_Upper_Threshold__c, Tier_3_Lower_Threshold__c, Tier_3_Monthly_Subscription_Fee__c, Tier_3_Upper_Threshold__c, Tier_4_Lower_Threshold__c, Tier_4_Monthly_Subscription_Fee__c, Tier_4_Upper_Threshold__c, Tier_Num__c FROM Opportunity_Subscription__r), ';
		soqlStr += '(SELECT Id, Order_Id_18_Characters__c, Type__c, Close_Date__c, Contract_Start_Date__c, Contract_End_Date__c, PO_Required__c, PO_Number__c FROM Orders__r), ';
	  	soqlStr += '(SELECT Id, Order_Item_ID_18__c, RPM_Product_Group__c, UnitPrice, Description FROM OpportunityLineItems WHERE RPM_Product_Group__c != null LIMIT 6), ';
        soqlStr += '(SELECT Id, Contact.Email FROM OpportunityContactRoles WHERE Role = \'Bill-To\' LIMIT 1) ';
	  	soqlStr += 'FROM Opportunity ';
        soqlStr += 'WHERE Id IN (SELECT Opportunity__c FROM Order__c WHERE Finance_Invoice_Export_Batch__c = \''+ currentBatchId +'\')';
		        
        generateSubscriptionCSVFile(soqlStr);
        
        PageReference reDirected = new PageReference('/'+currentBatchId);
    	return reDirected;       
        
    }
    
    //=========================================================================
    // Method to generate the Subscription CSV File (POC) - Herbert Oliveira
    // ========================================================================
    public string generateSubscriptionCSVFile(string queryString) {
        String fileHeader = '"Customer Status","SFDC Customer ID","Company Registration Number","Limited Company","Name","Address Line 1","Address Line 2","Address Line 3","Town / City","Postcode","Country Code","Sort Code","Bank Account","VBM","Sales Area","Customer Email Address","Invoice Email or Post","SFDC Order ID","SFDC Opportunity ID","Order Type","Sales Reference","Contract Type","Order Date","Contract Start Date","Contract Duration","Contract Notice Period","PO Required","PO Number","SFDC Opportunity ID","Journey Name","RPM Product Journey Identifier","Fair Use Limit Perentage","Subscription Invoice Line Description","Tier Sequence","Tier Lower Threshold","Tier Upper Threshold","Tier Monthly Subscription Fee","Tier Sequence","Tier Lower Threshold","Tier Upper Threshold","Tier Monthly Subscription Fee","Tier Sequence","Tier Lower Threshold","Tier Upper Threshold","Tier Monthly Subscription Fee","Tier Sequence","Tier Lower Threshold","Tier Upper Threshold","Tier Monthly Subscription Fee","SFDC Opportunity Line ID","RPM Product Group","Product Price","Product Invoice Line Description","SFDC Opportunity Line ID","RPM Product Group","Product Price","Product Invoice Line Description","SFDC Opportunity Line ID","RPM Product Group","Product Price","Product Invoice Line Description","SFDC Opportunity Line ID","RPM Product Group","Product Price","Product Invoice Line Description","SFDC Opportunity Line ID","RPM Product Group","Product Price","Product Invoice Line Description","SFDC Opportunity Line ID","RPM Product Group","Product Price","Product Invoice Line Description","EOR"\n';
        String fileBody = '';
        csvContent = '';
        
        List<Opportunity> oppList = Database.query(queryString);
        
        for (Opportunity opp : oppList) {
        	
            Order__c ord = opp.Orders__r[0];
            Opportunity_Subscription__c oppSub = (opp.Opportunity_Subscription__r.size()>0) ? opp.Opportunity_Subscription__r[0] : null;
            OpportunityContactRole oppContactRole = (opp.OpportunityContactRoles.size()>0) ? opp.OpportunityContactRoles[0] : null;
        	            
            String customerInfo = '', orderInfo = '', journeyInfo = '', nonSubscription = '';
            Integer numNonSubProds = opp.OpportunityLineItems.size();
            String customerStatus = (opp.Type == 'New From Existing') ? 'NEW' : 'EXISTING';
            String orderType = (ord.Type__c == 'New from New' || ord.Type__c == 'New from Existing') ? 'NEW' : 'RENEWAL'; 
            String customerEmail = (oppContactRole != null) ? oppContactRole.Contact.Email : '';
                        
            customerInfo = '"' + customerStatus + '","' + opp.AccountId + '","' + replaceNull(opp.Account.Company_Registration__c) + '","YES","' + opp.Account.Name + '","' + replaceNull(opp.Account.BillingStreet) + '","","","' + replaceNull(opp.Account.BillingCity) + '","' + replaceNull(opp.Account.BillingPostalCode) + '","' + replaceNull(opp.Account.BillingCountry) + '","","","' + replaceNull(opp.Account.VBM_Code__c) + '","' + opp.Owner.Email  + '","' + customerEmail + '","EMAIL"';  
            orderInfo = '"' + ord.Id + '","' + opp.Id + '","' + orderType + '","","SUB","' + setDateFormat(ord.Close_Date__c) + '","' + setDateFormat(ord.Contract_Start_Date__c) + '","' + opp.Contract_Term__c + '","3","' + ord.PO_Required__c + '","' + replaceNull(ord.PO_Number__c) + '"';
            if (oppSub != null) {
            	journeyInfo = '"' + opp.Id + '","' + oppSub.Name + '","' +  oppSub.RPM_Product_Journey_Identifier__c + '","' + oppSub.Fair_Use_Limit_Percentage__c + '","' + oppSub.Subscription_Invoice_Line_Description__c + '","1","' + oppSub.Tier_1_Lower_Threshold__c + '","' + oppSub.Tier_1_Upper_Threshold__c + '","' + oppSub.Tier_1_Monthly_Subscription_Fee__c + '","2","' + oppSub.Tier_2_Lower_Threshold__c + '","' + oppSub.Tier_2_Upper_Threshold__c + '","' + oppSub.Tier_2_Monthly_Subscription_Fee__c + '","3","' + oppSub.Tier_3_Lower_Threshold__c + '","' + oppSub.Tier_3_Upper_Threshold__c + '","' + oppSub.Tier_3_Monthly_Subscription_Fee__c + '","4","' + oppSub.Tier_4_Lower_Threshold__c + '","' + oppSub.Tier_4_Upper_Threshold__c + '","' + oppSub.Tier_4_Monthly_Subscription_Fee__c + '"';
            } else {
                journeyInfo = '"' + opp.Id + '","","","","","1","","","","2","","","","3","","","","4","","",""';
            }
            
            for (OpportunityLineItem oppLI : opp.OpportunityLineItems) {
                if (nonSubscription != '') { nonSubscription += ','; }
                nonSubscription += '"' + oppLI.Id + '","' + oppLI.RPM_Product_Group__c + '","' + oppLI.UnitPrice + '","' + replaceNull(oppLI.Description) + '"';
            }

            for (Integer i=0; i < (6-numNonSubProds); i++) {
            	if (nonSubscription != '') { nonSubscription += ','; }
                nonSubscription += '"","","",""';
            } 
            
            fileBody += customerInfo + ',' + orderInfo + ',' + journeyInfo + ',' + nonSubscription + ',"EOR"\n';
            
        } 
        
        csvContent = fileHeader + fileBody;
        
        return csvContent;
    }
    
    public string replaceNull(String value) {
        return (value != null) ? value : '';
    }
    
    public string setDateFormat(Date dt) {
    	return DateTime.newInstance(dt.year(), dt.month(), dt.day()).format('dd-MMM-yy');    
    }
    
  //===========================================================================
  // Method to generate CSV File - Richard Joseph
  //=========================================================================== 
  public string generateCSVFile (exportFileTypes fileType , string queryString, Report_Extract_Templates__c reportExtractTemplateRec) {

    system.debug('SOQL to Fetch12: ' +queryString );

    Integer fieldCount = 1;
    Integer seqNumber = 0; 
    String todayDate= Datetime.now().format('ddMMyyyy');
    reportDisplayList = new list<string[]>();
    String fieldValue ='';
    Set<String> fieldSet = new Set<String>();
    Integer orderGroupNumber = 1;
    String runningOrderId =null;
    String prevOrderId= null;
    Map<String,String> countryCodeMap = new Map<String,String>();
    Map<String,String> stateCodeMap = new Map<String,String>();
    set<id> setEBACustIDs = new set<Id>(); //RJ added for w-013923
    //getfileName();
    
    List<sObject> sobjList = Database.query(queryString );
    csvContent = '';
    //prerequisite
    //to get OU 
    getOperatingUnitValue();
    // to populate memoLnTypeOfSaleISet and memoLnTypeOfSaleLSet  
    Report_Extract_Templates__c MemoLnTypeOfSale= Report_Extract_Templates__c.getValues('MemoLnTypeOfSaleI');
    //To Populate Country Code from Custom Setting.
    List<Country_Codes__c> countryCodesList = Country_Codes__c.getall().values();
    for (Country_Codes__c countryCodesRec:countryCodesList) {
      if (countryCodesRec.Name!= null && countryCodesRec.Country_Code__c != null) {
        countryCodeMap.put(countryCodesRec.Name,countryCodesRec.Country_Code__c);
      }
    }  
    
    //To Populate State Code from Custom Setting.
    List<State_Codes__c> stateCodesList = State_Codes__c.getall().values();
    for (state_Codes__c stateCodesRec:stateCodesList) {
      if (stateCodesRec.Name!= null && stateCodesRec.state_Code__c != null) {
        stateCodeMap.put(stateCodesRec.Name,stateCodesRec.state_Code__c);
      }
    }   
    memoLnTypeOfSaleISet = new Set<string>();
    while (fieldCount < 100  && String.valueOf(MemoLnTypeOfSale.get('Col'+fieldCount+'__c')) != 'EOF' ) {   
      String saleTypeValue = String.valueOf(MemoLnTypeOfSale.get('Col'+fieldCount+'__c' ));
      if(memoLnTypeOfSaleISet != null &&  !memoLnTypeOfSaleISet.Contains(saleTypeValue ) && saleTypeValue != null) {      
        memoLnTypeOfSaleISet.add(saleTypeValue);
      }
      fieldCount++;
    }
    
    fieldCount = 1;
    MemoLnTypeOfSale= Report_Extract_Templates__c.getValues('MemoLnTypeOfSaleL');
    memoLnTypeOfSaleLSet = new Set<string>();
    while (fieldCount < 100  && String.valueOf(MemoLnTypeOfSale.get('Col'+fieldCount+'__c')) != 'EOF' ) {
      String saleTypeValue = String.valueOf(MemoLnTypeOfSale.get('Col'+fieldCount+'__c' ));
      if(memoLnTypeOfSaleLSet != null &&  !memoLnTypeOfSaleLSet.Contains(saleTypeValue ) && saleTypeValue != null) {      
        memoLnTypeOfSaleLSet.add(saleTypeValue);
      }
      fieldCount++;
    }
     
    //Extract all RPM codes
    Map<String, RPM_Product_Code__c> rpmCodes= RPM_Product_Code__c.getAll();      

    /*
    // add headers for summit files
    if(fileType == exportFileTypes.SummitFile || fileType == exportFileTypes.APACSummitFile){
      Report_Extract_Templates__c reportExtractTemplateHdr;
      if(fileType==exportFileTypes.SummitFile){
        if(isUSRegion){
          reportExtractTemplateHdr = Report_Extract_Templates__c.getValues('Oracle Transaction (Summit) Hdrs');
        }
        else{
          reportExtractTemplateHdr = Report_Extract_Templates__c.getValues('Oracle Trans (Summit) NON US Hdrs');
        }
      }
      else{
        reportExtractTemplateHdr = Report_Extract_Templates__c.getValues('Oracle Trans (Summit) APAC Hdrs');
      }
      String cloneCSVRowContent = '';
      String fieldName= '';
      fieldCount = 1;
      while (fieldCount < 100  && String.valueOf(reportExtractTemplateHdr.get('Col'+fieldCount+'__c')) != 'EOF' ) {
        fieldName = String.valueOf(reportExtractTemplateHdr.get('Col'+fieldCount+'__c'));
        if (fieldName!= null && (fieldName.contains('HC--') )) {
          csvContent =csvContent +'\"'+fieldName.split('HC--')[1]+'\",';
        }
        else{
          csvContent =csvContent +'\"\",';
        }
        fieldCount++;
      }
      csvContent =csvContent +'\n' ;
    }
  */ // RJ Commented WIP
  
    // Content Generation  
    for (sObject sObjectRec:sobjList) {
      //RJ added for w-013923
      //RJ - to retain only unique Customer in EBA customer file.
        if(fileType == exportFileTypes.EBACustomerFile)
        {
                Order_Line_Item__c newOrdLnRec = (Order_Line_Item__c)sObjectRec ;
                If(setEBACustIDs.size() > 0 && setEBACustIDs.contains(newOrdLnRec.Order__r.Account__C))
                   continue;
                   setEBACustIDs.add(newOrdLnRec.Order__r.Account__C);

        }
      //RJ changes end
      List<string> displayLine = new List<String>();
      fieldCount = 1;
      String cloneCSVRowContent = '';
      String fieldName= '';
      fieldValue='';
      while (fieldCount < 100  && String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c')) != 'EOF' ) {
        fieldName = String.valueOf(reportExtractTemplateRec.get('Col'+fieldCount+'__c'));
        if (fieldName!=null && 
            !fieldName.contains('Transform') && 
            !fieldName.contains('HC--') && 
            !fieldName.contains('DT--') && 
            !fieldName.contains('SQ--') && 
            !fieldName.contains('DT--') && 
            !fieldName.contains('SF--') && 
            !fieldName.contains('GQ--') ) {
          if (!fieldName.contains('.')) {
            fieldValue = (String.valueOf(sObjectRec.get(fieldName)) != null ? String.valueOf(sObjectRec.get(fieldName)) : '');
            if( fieldName != null && fieldName.contains('_Date_')) {
              //displayLine.add(datetime.valueof(fieldValue).format('ddMMyyyy') );
              csvContent =csvContent +'\"'+datetime.valueof(fieldValue).format('ddMMyyyy')+'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+datetime.valueof(fieldValue).format('ddMMyyyy')+'\",';
            }
            else if( fieldName == 'Total__c') {
              //displayLine.add(String.valueOf(sObjectRec.get(fieldName)));
              csvContent =csvContent +'\"'+fieldValue +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"-'+fieldValue +'\",';
            }
            else if (((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) )&& (fieldName  == 'CRM_Product_Name__c') ) {
              if(fieldValue != null ) {
                fieldValue = fieldValue  + ' '+  (String.valueOf(sObjectRec.get('Operating_System__c')) != null ? String.valueOf(sObjectRec.get('Operating_System__c')) : '');
              }
              String licStr = 'License Period to:';
              if (!isUSRegion) {
                fieldValue =fieldValue+ '|'+ 'License Period to:';
                If(fileType == exportFileTypes.SummitFile)
                fieldValue =fieldValue+(String.valueOf(sObjectRec.get('End_Date__c')) != null ? datetime.valueof(String.valueOf(sObjectRec.get('End_Date__c'))).format('dd/MM/yyyy') : ''  ); //RJ changed from ('MM/dd/YYYY') to ('dd/MM/YYYY') case #  01116004 
                else
                 fieldValue =fieldValue+(String.valueOf(sObjectRec.get('End_Date__c')) != null ? datetime.valueof(String.valueOf(sObjectRec.get('End_Date__c'))).format('MM/dd/yyyy') : ''  ); //RJ changed 
                 
                fieldValue =fieldValue+'|'; 
                fieldValue = fieldValue +(String.valueOf(sObjectRec.get('CPQ_Quantity__c')) != null ? String.valueOf(sObjectRec.get('CPQ_Quantity__c')) : ''  ) + ' ';
                fieldValue = fieldValue +(String.valueOf(sObjectRec.get('Quantity_Type__c')) != null ? String.valueOf(sObjectRec.get('Quantity_Type__c')) : ''  ) ;
              }
              licStr=licStr+(String.valueOf(sObjectRec.get('End_Date__c')) != null ? datetime.valueof(String.valueOf(sObjectRec.get('End_Date__c'))).format('MM/dd/yyyy') : ''  ) + ',';
              licStr = licStr +(String.valueOf(sObjectRec.get('CPQ_Quantity__c')) != null ? String.valueOf(sObjectRec.get('CPQ_Quantity__c')) : ''  ) + ' ';
              licStr = licStr +(String.valueOf(sObjectRec.get('Quantity_Type__c')) != null ? String.valueOf(sObjectRec.get('Quantity_Type__c')) : ''  );
              // displayLine.add(fieldValue );
             // displayLine.add(fieldValue );
              csvContent =csvContent +'\"'+fieldValue +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+licStr +'\",';
             
            }  
            else if ((fileType == exportFileTypes.PMM) && (fieldName  == 'CRM_Product_Name__c') ) {
              if(fieldValue != null ) {
                   csvContent =csvContent +'\"'+fieldValue +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
              }
              else{
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
              }
              }
            else if ((fieldName == 'Delivery_Method__c') && ((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) )) {
              String delvryMethod = '';
              //RJ - Made change to male Electronic as the default value
              //If(fieldValue!=null && fieldValue!='')
              //{
              if (fieldValue == null || 
                  fieldValue == '' || 
                  fieldValue == 'E - Mail' || 
                  fieldValue == 'FTP Download' ||
                  fieldValue.contains('Electronic') || 
                  fieldValue == 'Not Required') {
                fieldValue='ELECTRONIC';
              }
              else {
                fieldValue='TANGIBLE';
              }
              //} 
              // displayLine.add(fieldValue);
              csvContent =csvContent +'\"'+fieldValue +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
            }
            else if ((fieldName == 'Sales_Price__c') && ((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) )) {
              //RJ- Case 00607717
              //if(sObjectRec.getSobject('Order__r')!= null && sObjectRec.getSobject('Order__r').get('status__c') == 'Credited' )
              if (sObjectRec.getSobject('Order__r')!= null && sObjectRec.getSobject('Order__r').get('status__c') == 'Credit Note' ) {
                // displayLine.add(fieldValue);
                //RJ -Case # 00607717 Changed Credited process to behave the same way as normal order
                //csvContent =csvContent +'\"-'+fieldValue +'\",';
                //cloneCSVRowContent =cloneCSVRowContent +'\"-'+fieldValue +'\",';
                csvContent =csvContent +'\"'+fieldValue +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
              }
              else {
                //displayLine.add(fieldValue);
                csvContent =csvContent +'\"'+fieldValue +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
              }
            }
            else if(( fieldName == 'Partner_Amount__c') && (fileType == exportFileTypes.PartnerFile)) {
              //RJ- Case 00607717
              //if(sObjectRec.getSobject('Order__r')!= null && sObjectRec.getSobject('Order__r').get('status__c') == 'Credited' ){
              if(sObjectRec.getSobject('Order__r')!= null && sObjectRec.getSobject('Order__r').get('status__c') == 'Credit Note' ) {
                //displayLine.add(fieldValue);
                // //RJ -Case # 00607717 Changed Credited process to behave the same way as normal order
                //csvContent =csvContent +'\"-'+fieldValue +'\",';
                //cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
                csvContent =csvContent +'\"'+fieldValue +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"-'+fieldValue +'\",';
              }
              else {
                //displayLine.add(fieldValue);
                csvContent =csvContent +'\"'+fieldValue +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"-'+fieldValue +'\",';
              }
            }
            else if( (fieldName == 'Amount__c') && (fileType == exportFileTypes.RoyaltiesFile)) {
              //RJ- Case 00607717
              //if(sObjectRec.getSobject('Order_Line_item__r')!= null && sObjectRec.getSobject('Order_Line_item__r').getSobject('Order__r')!= null&& sObjectRec.getSobject('Order_Line_item__r').getSobject('Order__r').get('status__c') == 'Credited' )
              if (sObjectRec.getSobject('Order_Line_item__r')!= null && 
                  sObjectRec.getSobject('Order_Line_item__r').getSobject('Order__r')!= null && 
                  sObjectRec.getSobject('Order_Line_item__r').getSobject('Order__r').get('status__c') == 'Credit Note') {
                //displayLine.add(fieldValue);
                //RJ -Case # 00607717 Changed Credited process to behave the same way as normal order
                //csvContent =csvContent +'\"-'+fieldValue +'\",';
                //cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
                csvContent =csvContent +'\"'+fieldValue +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"-'+fieldValue +'\",';
              }
              else {
                //displayLine.add(fieldValue);
                csvContent =csvContent +'\"'+fieldValue +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"-'+fieldValue +'\",';
              }
            }
            else if((fileType == exportFileTypes.EBATransCreditFile)&&(fieldName  =='Amount__c') ){
                    
              csvContent =csvContent +'\"-'+fieldValue +'\",';
          cloneCSVRowContent =cloneCSVRowContent  +'\"'+fieldValue +'\",';
              
          }
            else if ((fileType == exportFileTypes.RPMFile) && (fieldName  == 'CRM_Product_Name__c') ) {
              String licStr='';
              if (fieldValue != null ) {                 
                licStr = fieldValue+',  ' ;
              }
              licStr = licStr +(String.valueOf(sObjectRec.get('CPQ_Quantity__c')) != null ? String.valueOf(sObjectRec.get('CPQ_Quantity__c')) : ''  ) + ' ';
              licStr = licStr +(String.valueOf(sObjectRec.get('Quantity_Type__c')) != null ? String.valueOf(sObjectRec.get('Quantity_Type__c')) : ''  ) + ', ';
              licStr = licStr + 'License Period From '; 
              licStr = licStr +(String.valueOf(sObjectRec.get('Start_Date__c')) != null ? datetime.valueof(String.valueOf(sObjectRec.get('Start_Date__c'))).format('dd/MM/yyyy') : ''  ) + ' ';
              licStr = licStr + 'to ';  
              licStr = licStr +(String.valueOf(sObjectRec.get('End_Date__c')) != null ? datetime.valueof(String.valueOf(sObjectRec.get('End_Date__c'))).format('dd/MM/yyyy') : ''  ) + ',  ';
              if (sObjectRec.getSobject('Order__r')!= null && 
                  sObjectRec.getSobject('Order__r').getSobject('Account__r')!= null && 
                  sObjectRec.getSobject('Order__r').getSobject('Account__r').get('Name')!= null) {
                licStr=licStr + String.valueof(sObjectRec.getSobject('Order__r').getSobject('Account__r').get('Name')) +', ';
              }
              licStr = licStr + 'Commercial Contact - '; 
              if (sObjectRec.getSobject('Order__r')!= null) {
                licStr=licStr + String.valueof(sObjectRec.getSobject('Order__r').get('Billing_Contact_Name__c'));
              }
              
              //displayLine.add(licStr);
              csvContent =csvContent +'\"'+licStr+'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+licStr +'\",';
            }
            else {
              //displayLine.add(String.valueOf(sObjectRec.get(fieldName)));
              csvContent =csvContent +'\"'+fieldValue +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
            }
          }
          else {
            // System.debug(fieldName);
            //system.debug(String.valueOf(sObjectRec.getSObject((fieldName.split('\\.')[0])).get(fieldName.split('\\.')[1])));
            if (fieldName.contains('.') && 
                sObjectRec.getSObject((fieldName.split('\\.')[0])) != null) {
              //upto 3 related objects 
              if (((fieldName.split('\\.')[1]).contains('.') || 
                   (fieldName.split('\\.').size() > 3)) ) {
                if (sObjectRec.getSObject((fieldName.split('\\.')[0])).getSObject((fieldName.split('\\.')[1])) != null && 
                    sObjectRec.getSObject((fieldName.split('\\.')[0])).getSObject((fieldName.split('\\.')[1])).getSObject((fieldName.split('\\.')[2])) != null) {  
                  fieldValue =((String.valueOf(sObjectRec.getSObject((fieldName.split('\\.')[0])).getSObject((fieldName.split('\\.')[1])).getSObject((fieldName.split('\\.')[2])).get(fieldName.split('\\.')[3]))) != null ? (String.valueOf(sObjectRec.getSObject((fieldName.split('\\.')[0])).getSObject((fieldName.split('\\.')[1])).getSObject(fieldName.split('\\.')[2]).get(fieldName.split('\\.')[3]))) : '' );
                  if (fieldName != null && 
                      fieldName.contains('_Date_')) {
                    //displayLine.add(datetime.valueof(fieldValue).format('ddMMyyyy') );
                    csvContent =csvContent +'\"'+datetime.valueof(fieldValue).format('ddMMyyyy')+'\",';
                    cloneCSVRowContent =cloneCSVRowContent +'\"'+datetime.valueof(fieldValue).format('ddMMyyyy')+'\",';
                  }
                  else {
                    //displayLine.add(fieldValue );
                    csvContent =csvContent +'\"'+fieldValue +'\",';
                    cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
                  }
                }              
                else {
                  csvContent =csvContent +'\"\",';
                  cloneCSVRowContent =cloneCSVRowContent +'\"\",';
                }
              }
              //upto 2 related objects
              else if (((fieldName.split('\\.')[1]).contains('.') || 
                        (fieldName.split('\\.').size() > 2)) ) {    
                if(sObjectRec.getSObject((fieldName.split('\\.')[0])).getSObject((fieldName.split('\\.')[1])) != null ) {
                  fieldValue =((String.valueOf(sObjectRec.getSObject((fieldName.split('\\.')[0])).getSObject((fieldName.split('\\.')[1])).get(fieldName.split('\\.')[2]))) != null ? (String.valueOf(sObjectRec.getSObject((fieldName.split('\\.')[0])).getSObject((fieldName.split('\\.')[1])).get(fieldName.split('\\.')[2]))) : '' );
                  if ((fieldName  == 'Order__r.Account__r.Experian_ID__c') && 
                      ((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) )) {
                    //RJ - Case # 00554006- To change the process to refer Global_Unique_ID__c if the Experian_ID__c is SFDC ID. If its EDQ ID then will pass the same.
                    String processedFieldValue = fieldValue;
                    if (isUSRegion) {
                      if (fieldValue != null && 
                          fieldValue != '' && 
                          fieldValue.Length()> 14 && 
                          sObjectRec.getSObject('Order__r')!= null && 
                          sObjectRec.getSObject('Order__r').getSObject('Account__r') != null) {
                        processedFieldValue='QAS-'+ (String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Global_Unique_ID__c')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Global_Unique_ID__c')) );
                      }
                      else{
                        processedFieldValue = 'QAS-' + fieldValue ;
                      }
                    }
                    else {
                      //RJ - Case 00584024- To change Experian id to all upper case for APAC/EMEA .
                      if (processedFieldValue !=null && processedFieldValue !=''){
                        processedFieldValue = processedFieldValue.toUpperCase();
                      }
                    }
                    //displayLine.add(processedFieldValue  );
                    csvContent =csvContent +'\"'+processedFieldValue +'\",';
                    cloneCSVRowContent =cloneCSVRowContent +'\"'+processedFieldValue +'\",';
                  }
                  else if ( fieldName != null && fieldName.contains('_Date_') ) {
                    //displayLine.add(datetime.valueof(fieldValue).format('ddMMyyyy') );
                    csvContent =csvContent +'\"'+datetime.valueof(fieldValue).format('ddMMyyyy')+'\",';
                    cloneCSVRowContent =cloneCSVRowContent +'\"'+datetime.valueof(fieldValue).format('ddMMyyyy')+'\",';
                  } 
                  else if ( fieldName != null && fieldName.contains('Shipping_Address__r') && isUSregion ) {
                    if (sObjectRec.getSObject('Order__r')!= null && 
                        sObjectRec.getSObject('Order__r').get('Shipping_Address__c') != null &&
                        sObjectRec.getSObject('Order__r').get('Billing_Address__c') != null && 
                        String.valueOf(sObjectRec.getSObject('Order__r').get('Billing_Address__c')) == String.valueOf(sObjectRec.getSObject('Order__r').get('Shipping_Address__c')) ) {
                      //displayLine.add('' );
                      csvContent =csvContent +'\"\",';
                      cloneCSVRowContent =cloneCSVRowContent +'\"\",';
                    }
                    else {
                      if (fieldName == 'Order__r.Shipping_Address__r.PostCode__c' && 
                          sObjectRec.getSObject('Order__r') != null && 
                          sObjectRec.getSObject('Order__r').getSObject('Shipping_Address__r')!= null && 
                         ((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) )) {
                        string stateValue =(String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Shipping_Address__r').get('State__c')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Shipping_Address__r').get('State__c')) );
                        String stateCodeStr = stateValue ;
                        if (stateCodeMap.size()>0 && stateValue != '' && stateCodeMap.containsKey(stateValue )) {
                          stateCodeStr =stateCodeMap.get(stateValue );
                        }
                        stateCodeStr = stateCodeStr +' '+ fieldValue ;
                        //displayLine.add(stateCodeStr ); 
                        csvContent = csvContent +'\"'+stateCodeStr +'\",';
                        cloneCSVRowContent =cloneCSVRowContent +'\"'+stateCodeStr +'\",';
                      }
                      else {
                        //displayLine.add(fieldValue );
                        csvContent =csvContent +'\"'+fieldValue +'\",';
                        cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
                      }
                    }
                  }
                  else {
                    //displayLine.add(fieldValue );
                    csvContent =csvContent +'\"'+fieldValue +'\",';
                    cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
                  }
                }
                else {
                  csvContent =csvContent +'\"\",';
                  cloneCSVRowContent =cloneCSVRowContent +'\"\",';
                }
              }
              //1 related object
              else if (sObjectRec.getSObject((fieldName.split('\\.')[0])) != null) {
                fieldValue =((String.valueOf(sObjectRec.getSObject((fieldName.split('\\.')[0])).get(fieldName.split('\\.')[1]))) != null ? (String.valueOf(sObjectRec.getSObject((fieldName.split('\\.')[0])).get(fieldName.split('\\.')[1]))) : '' );
                if (fieldName  == 'Order__r.Status__c') {
                  //RJ- Case 00607717
                  //if(fieldValue != null &&  fieldValue  =='Credited')
                  if(fieldValue != null &&  fieldValue  =='Credit Note') {
                    fieldValue = 'CREDIT MEMO';
                  }
                  else {
                    fieldValue  = 'INVOICE';
                  }
                  //displayLine.add(fieldValue  );
                  csvContent =csvContent +'\"'+fieldValue +'\",';
                  cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
                }
                //RJ - Case # 00554006- To change the process to refer Global_Unique_ID__c if the Experian_ID__c is SFDC ID. If its EDQ ID then will pass the same.
                else if (fieldName  == 'Account__r.Experian_ID__c' && isUSRegion) {
                  if (fieldValue != null && 
                      fieldValue != '' && 
                      (fileType == exportFileTypes.CustomerFile ) && 
                      sObjectRec.getSObject('Account__r') != null && 
                      fieldValue.length()>14 ) {
                    fieldValue  = (String.valueOf(sObjectRec.getSObject('Account__r').get('Global_Unique_ID__c')) == null ? '': String.valueOf(sObjectRec.getSObject('Account__r').get('Global_Unique_ID__c')) );
                  }
                  //displayLine.add(fieldValue  );
                  csvContent =csvContent +'\"'+fieldValue +'\",';
                  cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
                }
                //RJ - Changes for case  # 00562967 
                else if (((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile)  ) && 
                         (fieldName  == 'Product__r.Name')) {
                  if (fieldValue != null) {
                    fieldValue = fieldValue  + ' '+  (String.valueOf(sObjectRec.get('Operating_System__c')) != null ? String.valueOf(sObjectRec.get('Operating_System__c')) : ''  );
                  }
                  
                  String licStr = 'License Period to:';
                  if (!isUSRegion ) {
                    fieldValue = fieldValue + '|'+ 'License Period to:';
                    fieldValue = fieldValue + (String.valueOf(sObjectRec.get('End_Date__c')) != null ? datetime.valueof(String.valueOf(sObjectRec.get('End_Date__c'))).format('MM/dd/yyyy') : ''  ); 
                    fieldValue = fieldValue + '|';
                    fieldValue = fieldValue + (String.valueOf(sObjectRec.get('Users_From__c')) != null ? String.valueOf(sObjectRec.get('Users_From__c')) : ''  );
                    fieldValue = fieldValue + ' to ';
                    fieldValue = fieldValue + (String.valueOf(sObjectRec.get('Users_To__c')) != null ? String.valueOf(sObjectRec.get('Users_To__c')) : ''  ) + ' ';
                    fieldValue = fieldValue + (String.valueOf(sObjectRec.get('Quantity_Type__c')) != null ? String.valueOf(sObjectRec.get('Quantity_Type__c')) : ''  ) ;
                  }
                  licStr=licStr+(String.valueOf(sObjectRec.get('End_Date__c')) != null ? datetime.valueof(String.valueOf(sObjectRec.get('End_Date__c'))).format('MM/dd/yyyy') : ''  ) + ' , ';
                  licStr=licStr+(String.valueOf(sObjectRec.get('Users_From__c')) != null ? String.valueOf(sObjectRec.get('Users_From__c')) : ''  ) + ' to ';
                  licStr=licStr+(String.valueOf(sObjectRec.get('Users_To__c')) != null ? String.valueOf(sObjectRec.get('Users_To__c')) : ''  ) + ' ';
                  licStr=licStr+(String.valueOf(sObjectRec.get('Quantity_Type__c')) != null ? String.valueOf(sObjectRec.get('Quantity_Type__c')) : ''  ) + ' ';
                  //displayLine.add(fieldValue );
                  csvContent =csvContent +'\"'+fieldValue +'\",';
                  cloneCSVRowContent =cloneCSVRowContent +'\"'+licStr +'\",';
                }
                else if ((fileType == exportFileTypes.PMM) && (fieldName  == 'Product__r.Name') ) {
              if(fieldValue != null ) {
                  if( sObjectRec.getSObject('Order__r') != null && 
                     sObjectRec.getSObject('Order__r').getSobject('Opportunity__r') != null)
                     {
               fieldValue = fieldValue  + ' | '+  (String.valueOf(sObjectRec.getSObject('Order__r').getSobject('Opportunity__r').get('Description')) != null ? String.valueOf(sObjectRec.getSObject('Order__r').getSobject('Opportunity__r').get('Description')) : ''  );
                   }
                   csvContent =csvContent +'\"'+fieldValue +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
              }
              else{
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
              }
              }
                //else if ((fileType == exportFileTypes.CustomerFile) && (fieldName  == 'Billing_Address__r.Country__c') ) {                 
                //  String countryCodeStr = fieldValue;
                //  if (countryCodeMap.size()>0 && fieldValue != '' && countryCodeMap.containsKey(fieldValue) ) {
                //    countryCodeStr=countryCodeMap.get(fieldValue);
                //  }
                //  displayLine.add(countryCodeStr  ); 
                //  csvContent =csvContent +'\"'+countryCodeStr +'\",';
                //  cloneCSVRowContent =cloneCSVRowContent +'\"'+countryCodeStr +'\",';
                //}
                //RJ - Included change for case # 568901 to limit PO number by 20 char
                else if ((fileType == exportFileTypes.RPMFile) && (fieldName  =='Order__r.PO_Number__c')) {
                  string pNumberStr = '';
                  Integer index = 20;
                  if (fieldValue!= null && fieldValue != '') { 
                    // Case #629393 : 042914 James Weatherall : Added check to see if FieldValue is > 20 chars
                    index = fieldValue.length() > 20 ? index : fieldValue.length();
                    pNumberStr = fieldValue.substring(0,index);
                  }
                  //displayLine.add(pNumberStr );
                  csvContent =csvContent +'\"'+pNumberStr +'\",';
                  cloneCSVRowContent =cloneCSVRowContent +'\"'+pNumberStr +'\",';
                }
                //RJ - Commented this to refer Descrption instead of Chart_of_Accounts_Product_Description__c field          
                //else if ((fileType == exportFileTypes.RPMFile) && (fieldName  == 'Product__r.Chart_of_Accounts_Product_Description__c') ){
                else if ((fileType == exportFileTypes.RPMFile) && (fieldName  == 'Product__r.Description') ) {
                  String RPMCode = '';
                  if (fieldValue != null &&  rpmCodes.containsKey(fieldValue)) {
                    RPMCode = rpmCodes.get(fieldValue ).RPM_Code__c;
                  }
                  //displayLine.add(RPMCode );
                  csvContent =csvContent +'\"'+RPMCode +'\",';
                  cloneCSVRowContent =cloneCSVRowContent +'\"'+RPMCode +'\",';
                }
                else if (fieldName != null && 
                         fieldName.contains('_Date_') && fieldValue != null && fieldValue !='' &&
                         !(((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) ) && fieldName == 'Order__r.Close_Date__c')) {
                  //displayLine.add(datetime.valueof(fieldValue).format('ddMMyyyy') );
                  csvContent =csvContent +'\"'+datetime.valueof(fieldValue).format('ddMMyyyy')+'\",';
                  cloneCSVRowContent =cloneCSVRowContent +'\"'+datetime.valueof(fieldValue).format('ddMMyyyy')+'\",';
                }
                else {
                  //displayLine.add(fieldValue );
                  csvContent =csvContent +'\"'+fieldValue +'\",';
                  cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
                }
              }
              else {
                csvContent =csvContent +'\"\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"\",';
              }
            }
            else {
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
            }
          }
        }
        else if (fieldName!= null && (fieldName.contains('Transform') )) {
          if (fieldName == 'Transform--CustomerSiteReferenceNumber' && 
             (fileType == exportFileTypes.CustomerFile || ((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) || (fileType == exportFileTypes.DPFile) ))) {
            string transValue = '';
            if (fileType == exportFileTypes.CustomerFile  && 
                sObjectRec.get('Owner_Country__c') != null) {
              transValue =((String.valueOf(sObjectRec.get('Owner_Country__c')) != null ? (String.valueOf(sObjectRec.get('Owner_Country__c'))) : '' ));
            } 
            else if (((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) || (fileType == exportFileTypes.DPFile) ) && 
                     sObjectRec.getSObject('Order__r') != null && 
                     sObjectRec.getSObject('Order__r').get('Owner_Country__c') != null) {
              transValue =((String.valueOf(sObjectRec.getSObject('Order__r').get('Owner_Country__c')) != null ? (String.valueOf(sObjectRec.getSObject('Order__r').get('Owner_Country__c'))) : '' ));
            }
            //if (transValue == 'USA' || transValue == 'United States of America' || transValue == 'United States' || transValue == 'US') {
            //  transValue='US';
            //}
            //else if (transValue == 'UK' || transValue == 'United Kingdom' ) {
            //  transValue='UK';
            //}
            //else if (transValue == 'FR' || transValue == 'France' ) {
            //  transValue='FR';
            //}
            //else if (transValue == 'NZ' || transValue == 'New Zealand' ) {
            //  transValue='NZ';
            //}
            //else if (transValue == 'SGP' || transValue == 'Singapore' ) {
            //  transValue='SGP';
            //}
            //else if (transValue == 'AU' || transValue == 'Australia' ) {
            //  transValue='AU';
            //}
            //else if (transValue == 'NL' || transValue == 'Netherlands' ) {
            //  transValue='NL';
            //}
            if (countryCodeMap.size() > 0 && 
                transValue != '' && 
                countryCodeMap.containsKey(transValue) ) {
              transValue=countryCodeMap.get(transValue);
            }
            if (isUSRegion) {
              //RJ - Case # 00554006- To change the process to refer Global_Unique_ID__c if the Experian_ID__c is SFDC ID. If its EDQ ID then will pass the same.
              string experianIdStr= '';
              if ((fileType == exportFileTypes.CustomerFile) && sObjectRec.getSObject('Account__r') != null) {
                //transValue=transValue+'-'+((String.valueOf(sObjectRec.getSObject('Account__r').get('Experian_ID__c')) != null ? (String.valueOf(sObjectRec.getSObject('Account__r').get('Experian_ID__c'))) : '' ));
                experianIdStr = ((String.valueOf(sObjectRec.getSObject('Account__r').get('Experian_ID__c')) != null ? (String.valueOf(sObjectRec.getSObject('Account__r').get('Experian_ID__c'))) : '' ));
                if (experianIdStr != null && 
                    experianIdStr != '' && 
                    experianIdStr.length() > 14) {
                  experianIdStr=(String.valueOf(sObjectRec.getSObject('Account__r').get('Global_Unique_ID__c')) == null ? '': String.valueOf(sObjectRec.getSObject('Account__r').get('Global_Unique_ID__c')) );
                }
                transValue = transValue+'-'+experianIdStr;
              }
              else if (((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) ) && 
                       sObjectRec.getSObject('Order__r') != null && 
                       sObjectRec.getSObject('Order__r').getSObject('Account__r') != null) {
                //transValue=transValue+'-'+((String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Experian_ID__c')) != null ? (String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Experian_ID__c'))) : '' ));
                experianIdStr=((String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Experian_ID__c')) != null ? (String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Experian_ID__c'))) : '' ));
                if (experianIdStr != null && 
                    experianIdStr != '' && 
                    experianIdStr.length() > 14) {
                  experianIdStr=((String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Global_Unique_ID__c')) != null ? (String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Global_Unique_ID__c'))) : '' ));
                }
                transValue=transValue+'-'+experianIdStr;
              } 
            } 
            else{
              //RJ - Included this change as per case 00553884. This is to derive customer site value based on billing EDQ Integration ID for UK.
              if (fileType == exportFileTypes.CustomerFile && 
                  sObjectRec.getSObject('Billing_Address__r') != null) {
                transValue = transValue + '-'+((String.valueOf(sObjectRec.getSObject('Billing_Address__r').get('EDQ_Integration_Id__c')) != null ? (String.valueOf(sObjectRec.getSObject('Billing_Address__r').get('EDQ_Integration_Id__c'))) : '' ));
              }
              else if (((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) || (fileType == exportFileTypes.DPFile)  ) && 
                       sObjectRec.getSObject('Order__r') != null && 
                       sObjectRec.getSObject('Order__r').getSObject('Billing_Address__r') != null) {
                transValue=transValue+'-'+((String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Billing_Address__r').get('EDQ_Integration_Id__c')) != null ? (String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Billing_Address__r').get('EDQ_Integration_Id__c'))) : '' ));
              }
            }      
            //displayLine.add('transValue');
            csvContent =csvContent +'\"'+transValue+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+transValue+'\",';
          }  
          else if ((fieldName=='Transform--Shipping_Address__r.Country__c' && (fileType == exportFileTypes.CustomerFile)) ||
                   ((fileType == exportFileTypes.PartnerFile && FieldName == 'Transform--Order__r.Account__r.BillingCountry')) ) {
            if (fileType == exportFileTypes.CustomerFile) {
              fieldValue =((String.valueOf(sObjectRec.getSObject(('Shipping_Address__r'))) != null ? (String.valueOf(sObjectRec.getSObject(('Shipping_Address__r')).get('Country__c'))) : '' ));
            }
            else if (fileType == exportFileTypes.PartnerFile && sObjectRec.getSObject(('Order__r')) != null && sObjectRec.getSObject('Order__r').getSObject('Account__r') != null) {
              fieldValue =((String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('BillingCountry')) != null ?String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('BillingCountry'))  : '' ));
            }
              
            if (fieldValue == 'US' ||
                fieldValue == 'USA' || 
                fieldValue == 'United States' || 
                fieldValue == 'United States of America') {
              //displayLine.add('EXP_US_EHI_OU');
              csvContent =csvContent + '\"EXP_US_EHI_OU\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"EXP_US_EHI_OU\",';
            }
            else if (fieldValue == 'UK' || 
                     fieldValue == 'United Kingdom' ) {
              //displayLine.add('EXP_UK_ELI_OU');
              csvContent =csvContent + '\"EXP_UK_ELI_OU\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"EXP_UK_ELI_OU\",';
            }
            else if (fieldValue == 'FR' || 
                     fieldValue == 'France' ) {
              //displayLine.add('EXP_FR_ECS_OU');
              csvContent =csvContent + '\"EXP_FR_ECS_OU\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"EXP_FR_ECS_OU\",';
            }
            else if (fieldValue == 'NZ' || 
                     fieldValue == 'New Zealand' ) {
              //displayLine.add('EXP_NZ_EAP_OU');
              csvContent =csvContent + '\"EXP_NZ_EAP_OU\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"EXP_NZ_EAP_OU\",';
            }
            else if (fieldValue == 'SGP' || 
                     fieldValue == 'Singapore' ) {
              //displayLine.add('EXP_SG_EAP_OU');
              csvContent =csvContent + '\"EXP_SG_EAP_OU\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"EXP_SG_EAP_OU\",';
            }
            else if (fieldValue == 'UK' || 
                     fieldValue == 'United Kingdom') {
              //displayLine.add('EXP_AU_EAP_OU');
              csvContent =csvContent + '\"EXP_AU_EAP_OU\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"EXP_AU_EAP_OU\",';
            }
            else if (fieldValue == 'NL' || 
                     fieldValue == 'Netherlands' ) {
              //displayLine.add('EXP_NL_ENL_OU');
              csvContent =csvContent + '\"EXP_NL_ENL_OU\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"EXP_NL_ENL_OU\",';
            }
            else {
              csvContent =csvContent +'\"'+fieldValue +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValue +'\",';
            }
          }
          else if (fieldName == 'Transform--Trans') {
            //displayLine.add('TRANS');
            csvContent =csvContent +'\"'+'TRANS'+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+'DESCRIPTOR'+'\",';
          }
          else if ((fieldName == 'Transform--TotalAmount') && ((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) )) {
            double transSalesValue = 0;
            double transQntyValue = 0;
            if (sObjectRec.get('Sales_Price__c') != null) {
              transSalesValue =(double.valueOf((String.valueOf(sObjectRec.get('Sales_Price__c')) != null ? (String.valueOf(sObjectRec.get('Sales_Price__c'))) : '0' )));
            }
            if (sObjectRec.get('CPQ_Quantity__c') != null) {
              transQntyValue =(double.valueOf((String.valueOf(sObjectRec.get('CPQ_Quantity__c')) != null ? (String.valueOf(sObjectRec.get('CPQ_Quantity__c'))) : '0' )));
            }
            //displayLine.add(String.valueof(transSalesValue*transQntyValue));
            csvContent =csvContent +'\"'+(transSalesValue*transQntyValue)+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+(transSalesValue*transQntyValue)+'\",';
          }
          else if(fieldName == 'Transform--MemoLn') {
            if ((fileType == exportFileTypes.PartnerFile)) {
              String memoLnValue= (String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')) == null ? '': String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')) );
              String partnerAccRefValue = '';
              if (sObjectRec.getSObject('Order__r') != null && 
                  sObjectRec.getSObject('Order__r').getSObject('Partner__r') != null) {
                partnerAccRefValue= (String.valueof(sObjectRec.getSObject('Order__r').getSObject('Partner__r').get('Experian_ID__c')) == null ? '':String.valueof(sObjectRec.getSObject('Order__r').getSObject('Partner__r').get('Experian_ID__c'))  );
              }
                // RJ Changed for IFRS15 changes for APAC Summit
               If (fileType == exportFileTypes.APACSummitFile) 
                   memoLnValue=(String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')) == null ? '': String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')) ) + '--' + (String.valueOf(sObjectRec.get('IFRS15_Secondary_Revenue_Subaccount_Code__c')) == null ? '': String.valueOf(sObjectRec.get('IFRS15_Secondary_Revenue_Subaccount_Code__c')) );
               
              //displayLine.add(String.valueof(memoLnValue ));
              csvContent =csvContent +'\"'+memoLnValue +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+partnerAccRefValue+'\",';
            } 
            // RJ Changed for IFRS15 changes for APAC Summit
            else If ( fileType == exportFileTypes.SummitFile ) {
             String    memoLnValue=(String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')) == null ? '': 'EDQ' + String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')) ) ;//+  (String.valueOf(sObjectRec.get('IFRS15_Secondary_Revenue_Subaccount_Code__c')) == null ? '': '--'+String.valueOf(sObjectRec.get('IFRS15_Secondary_Revenue_Subaccount_Code__c')) );
            
            csvContent =csvContent +'\"'+memoLnValue +'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+memoLnValue +'\",';
            }//changes end
            else If (fileType == exportFileTypes.APACSummitFile ) {
            string billCountry;
            String    memoLnValue;
            if (sObjectRec.getSObject('Order__r') != null && sObjectRec.getSObject('Order__r').get('Billing_Country__c') != null) {
                billCountry= (String.valueof(sObjectRec.getSObject('Order__r').get('Billing_Country__c')) == null ? '':String.valueof(sObjectRec.getSObject('Order__r').get('Billing_Country__c'))  );
              }
            
            if( billCountry !=null && (billCountry=='Australia' || billCountry=='New Zealand')){
             memoLnValue=(String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')) == null ? '': 'EDQ' + String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')) +'A' ) ;//+  (String.valueOf(sObjectRec.get('IFRS15_Secondary_Revenue_Subaccount_Code__c')) == null ? '': '--'+String.valueOf(sObjectRec.get('IFRS15_Secondary_Revenue_Subaccount_Code__c')) );
            }
            else{
              memoLnValue=(String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')) == null ? '': 'EDQ' + String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')) ) ;//+  (String.valueOf(sObjectRec.get('IFRS15_Secondary_Revenue_Subaccount_Code__c')) == null ? '': '--'+String.valueOf(sObjectRec.get('IFRS15_Secondary_Revenue_Subaccount_Code__c')) );
            }
             csvContent =csvContent +'\"'+memoLnValue +'\",';
             cloneCSVRowContent =cloneCSVRowContent +'\"'+memoLnValue +'\",';
             }
            else if (fileType == exportFileTypes.RoyaltiesFile) {
              String memoLnValue='';
              if (sObjectRec.getSObject(('Order_Line_Item__r')) != null ) {
                memoLnValue=String.valueof(sObjectRec.getSObject('Order_Line_Item__r').get('EDQ_Memo_Line__c')== null ?'':sObjectRec.getSObject('Order_Line_Item__r').get('EDQ_Memo_Line__c'));
              }
              String royaltyGrpRefValue = '';
              royaltyGrpRefValue=(String.valueOf(sObjectRec.get('Royalty_Group_Reference__c')) == null ? '': String.valueOf(sObjectRec.get('Royalty_Group_Reference__c')) );
              //displayLine.add(String.valueof(memoLnValue ));
              csvContent =csvContent +'\"'+memoLnValue +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+royaltyGrpRefValue+'\",';
            }
            // This below logic is altered and moved into orderLine trigger handler  
            //String memoLnValue= ''; 
            //String memoDupString='';
            //if ((fileType == exportFileTypes.PartnerFile)||(fileType == exportFileTypes.SummitFile)){
            //  if(sObjectRec.getSObject(('Order__r')) != null && sObjectRec.getSObject(('Product__r')) != null  ){
            //    //string productSaleType =String.valueOf(sObjectRec.getSObject('Product__r').get('Types_of_Sale__c'));
            //    string productSaleType =(String.valueOf(sObjectRec.get('Type_of_Sale__c')) == null ? '': String.valueOf(sObjectRec.get('Type_of_Sale__c')) );
            //    string orderType =String.valueOf(sObjectRec.getSObject('Order__r').get('Type__c'));
            //    string productFamily=String.valueOf(sObjectRec.getSObject('Product__r').get('Family'));
            //    //Order__r.Account__r.BillingCountry,Order__r.Product__r.Types_of_Sale__c, Order__r.Product__r.Family,Order__r.Type__c
            //    memoLnValue= generateMemoLn( productSaleType,  orderType, productFamily);
            //    if(fileType == exportFileTypes.PartnerFile) {
            //      memoDupString = (String.valueof(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Experian_ID__c')) == null ? '':String.valueof(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Experian_ID__c'))  );
            //    }
            //  }
            //}
            //else if (fileType == exportFileTypes.RoyaltiesFile){
            //  if(fileType == exportFileTypes.RoyaltiesFile &&sObjectRec.getSObject(('Order_Line_Item__r')) != null && sObjectRec.getSObject(('Order_Line_Item__r')) .getSObject(('Order__r')) != null && sObjectRec.getSObject(('Order_Line_Item__r')) .getSObject(('Product__r')) != null  ){
            //    //string productSaleType =String.valueOf(sObjectRec.getSObject('Order_Line_Item__r').getSObject('Product__r').get('Types_of_Sale__c'));
            //    string productSaleType =(String.valueOf(sObjectRec.getSObject('Order_Line_Item__r').get('Type_of_Sale__c')) == null ? '':String.valueOf(sObjectRec.getSObject('Order_Line_Item__r').get('Type_of_Sale__c'))  );
            //    string orderType =String.valueOf(sObjectRec.getSObject('Order_Line_Item__r').getSObject('Order__r').get('Type__c'));
            //    string productFamily=String.valueOf(sObjectRec.getSObject('Order_Line_Item__r').getSObject('Product__r').get('Family'));
            //    //Order__r.Account__r.BillingCountry,Order__r.Product__r.Types_of_Sale__c, Order__r.Product__r.Family,Order__r.Type__c
            //    memoLnValue= generateMemoLn( productSaleType,  orderType, productFamily);
            //    memoDupString = (String.valueof(sObjectRec.getSObject('Order_line_item__r').getSObject('Order__r').getSObject('Account__r').get('Experian_ID__c')) == null ? '':String.valueof(sObjectRec.getSObject('Order_line_item__r').getSObject('Order__r').getSObject('Account__r').get('Experian_ID__c'))  );
            //  } 
            //} 
            // 
            //csvContent =csvContent +'\"'+memoLnValue +'\",';
            //if(fileType == exportFileTypes.SummitFile) {
            //  cloneCSVRowContent =cloneCSVRowContent +'\"'+memoLnValue +'\",';
            //}
            //else {
            //  cloneCSVRowContent =cloneCSVRowContent +'\"'+memoDupString +'\",';
            //}
          }
          else if (fieldName == 'Transform--OperatingUnit') {
            //displayLine.add(operatingUnitName);
            csvContent =csvContent +'\"'+operatingUnitName+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+operatingUnitName+'\",';
          }
          else if (fieldName == 'Transform--StateCode') {
            if ((fileType == exportFileTypes.CustomerFile) && sObjectRec.getSObject(('Billing_Address__r')) != null) {
              string stateValue =(String.valueOf(sObjectRec.getSObject(('Billing_Address__r')).get('State__c')) == null ? '': String.valueOf(sObjectRec.getSObject(('Billing_Address__r')).get('State__c')) );
              String stateCodeStr = stateValue ;
              if (stateCodeMap.size() > 0 && 
                  stateValue != '' && 
                  stateCodeMap.containsKey(stateValue)) {
                stateCodeStr =stateCodeMap.get(stateValue );
              }
              //displayLine.add(stateCodeStr ); 
              csvContent =csvContent +'\"'+stateCodeStr +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+stateCodeStr +'\",';
            }
            else {
              //displayLine.add('');
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
            }
          }
          else if (fieldName == 'Transform--CountryCode') {
            if ((fileType == exportFileTypes.RPMFile || fileType == exportFileTypes.DPCustomerFile || fileType == exportFileTypes.EBACustomerFile)&& 
                sObjectRec.getSObject(('Order__r')) != null && 
                sObjectRec.getSObject('Order__r').getSObject(('Billing_Address__r')) != null) {
              string countryCode='';
              string countryValue =(String.valueOf(sObjectRec.getSObject('Order__r').getSObject(('Billing_Address__r')).get('Country__c')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').getSObject(('Billing_Address__r')).get('Country__c')) );
              if (countryCodeMap.size() > 0 && 
                  countryValue != '' && 
                  countryCodeMap.containsKey(countryValue)) {
                countryCode=countryCodeMap.get(countryValue );
              }    
              //displayLine.add(countryCode);
              csvContent =csvContent +'\"'+countryCode+'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+countryCode+'\",';
            }
            else if ((fileType == exportFileTypes.CustomerFile ) && sObjectRec.getSObject(('Billing_Address__r')) != null ){
              string countryValue =(String.valueOf(sObjectRec.getSObject(('Billing_Address__r')).get('Country__c')) == null ? '': String.valueOf(sObjectRec.getSObject(('Billing_Address__r')).get('Country__c')) );
              String countryCodeStr = countryValue;
              if (countryCodeMap.size() > 0 && 
                  countryValue != '' && 
                  countryCodeMap.containsKey(countryValue)) {
                countryCodeStr=countryCodeMap.get(countryValue );
              }
              //displayLine.add(countryCodeStr  ); 
              csvContent =csvContent +'\"'+countryCodeStr +'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+countryCodeStr +'\",';
            }
            else {
              //displayLine.add('');
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
            }
          }
          //RJ - Case # 00554006- To change the process to refer Global_Unique_ID__c if the Experian_ID__c is SFDC ID. If its EDQ ID then will pass the same.
          else if (fieldName == 'Transform-USExperianID') {
            if (IsUSRegion && (fileType == exportFileTypes.CustomerFile)) {
              string experianIDValue='';
              if ((fileType == exportFileTypes.CustomerFile ) && sObjectRec.getSObject('Account__r') != null) {
                experianIDValue=((String.valueOf(sObjectRec.getSObject('Account__r').get('Experian_ID__c')) != null ? (String.valueOf(sObjectRec.getSObject('Account__r').get('Experian_ID__c'))) : '' ));
              }
              //if(experianIDValue != null && experianIDValue !='' && experianIDValue.length() >14) {
              //  experianIDValue=(String.valueOf(sObjectRec.getSObject('Account__r').get('Global_Unique_ID__c')) == null ? '': String.valueOf(sObjectRec.getSObject('Account__r').get('Global_Unique_ID__c')) );
              //}
              //displayLine.add(experianIDValue);
              csvContent =csvContent +'\"'+experianIDValue+'\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+experianIDValue+'\",';
            }
            else {
              //displayLine.add('');
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
            }
          }
          else if (fieldName == 'Transform--Email' || fieldName == 'Transform--ContactEmail') {              
            if (((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) ) && sObjectRec.getSObject(('Order__r')) != null) {
              string emailHC='EMAIL';
              string contactEmail = '';
              //RJ- Case 00607717
              //if( (String.valueOf(sObjectRec.getSObject('Order__r').get('Status__c')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').get('Status__c')))  =='Credited')
              if ((String.valueOf(sObjectRec.getSObject('Order__r').get('Status__c')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').get('Status__c')))  =='Credit Note') {
                emailHC= 'NFD';
              }
              else {
                if (sObjectRec.getSObject(('Order__r')).getSObject(('Billing_Contact__r')) != null) {
                  contactEmail=(String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Billing_Contact__r').get('email')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Billing_Contact__r').get('email')));
                }                     
                if (contactEmail == '') {
                  emailHC = 'PRINT';
                }
              }
              if (fieldName == 'Transform--Email') {
                //displayLine.add(emailHC);
                csvContent =csvContent +'\"'+emailHC+'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+emailHC+'\",';
              }
              if (fieldName == 'Transform--ContactEmail') {
                //displayLine.add(contactEmail);
                csvContent =csvContent +'\"'+contactEmail+'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+contactEmail+'\",';
              }
            }
            else {
              //displayLine.add('');
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
            }
          }
          else if (fieldName == 'Transform--APACInvoicingRule' ) {   
          
          Date OrderLineStartDate = (Date.valueOf(sObjectRec.get('Start_date__c')));
           Date OrderLineEndDate = (Date.valueOf(sObjectRec.get('End_date__c')));
           
           If (OrderLineStartDate != null && OrderLineEndDate  != null)
           {
               String InvocingRule = 'Immediate';
               Integer diffInDaysClone =0;
               Integer diffInDays =diffInDaysClone= OrderLineStartDate.MonthsBetween(OrderLineEndDate );
               
               if (diffInDaysClone <= 1)
                InvocingRule ='In advance';
                
               else if (diffInDays >1 )
                   InvocingRule ='In advance';
                   
              csvContent =csvContent +'\"'+InvocingRule +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+InvocingRule +'\",';   
                   
           }else {
              //displayLine.add('');
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
          }
          
          }     
          else if (fieldName == 'Transform--StartDate' ) { 
          Date OrderLineStartDate = (Date.valueOf(sObjectRec.get('Start_date__c')));
           Date OrderLineEndDate = (Date.valueOf(sObjectRec.get('End_date__c')));
           Date orderCloseDate = (Date.valueOf(sObjectRec.get('End_date__c')));
           
           if (sObjectRec.getSObject(('Order__r')) != null) {
           orderCloseDate=(String.valueOf(sObjectRec.getSObject('Order__r').get('Close_Date__c')) == null ? null: Date.valueOf(sObjectRec.getSObject('Order__r').get('Close_Date__c')));
                }
            
           
           Boolean isProductUpgrade = ((Boolean)(sObjectRec.get('Product_Upgrade__c')));
           String memoLineStr  = (String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')));
           
            Date InvocingStartDate = (Date.valueOf(sObjectRec.get('Start_date__c')));
            
            
           If (OrderLineStartDate != null && OrderLineEndDate  != null && memoLineStr  != null && orderCloseDate != null)
           {
              
               if (memoLineStr   != '' || memoLineStr  != null){
                   
                   Date orderCloseDateClone = orderCloseDate ;
                   if(memoLineStr.endsWithIgnoreCase('I')){
                       orderCloseDateClone= orderCloseDate.addMonths(1);
                       InvocingStartDate =orderCloseDateClone.toStartOfMonth() ;
                       }
                    if(memoLineStr.endsWithIgnoreCase('L') && isProductUpgrade ){
                        orderCloseDateClone= orderCloseDate.addMonths(1);
                       InvocingStartDate =orderCloseDateClone.toStartOfMonth() ;
                       }
                    if(memoLineStr.equalsIgnoreCase('QASRPandoraL') ||memoLineStr.equalsIgnoreCase('QASNPandoraL') ){
                       //InvocingStartDate =orderCloseDateClone.toStartOfMonth() ;
                       //RJ commented above and added this  for Pandora changes Case #02350405
                       InvocingStartDate = OrderLineStartDate.toStartOfMonth();
                       }
                       
               }  
               //RJ Added this as part of iFRS15 changes.
               if(fileType == exportFileTypes.APACSummitFile)
                   InvocingStartDate = OrderLineStartDate.toStartOfMonth();
               
               
                       
               }  
               
               
               
                 
           
           
           csvContent =csvContent +'\"'+InvocingStartDate +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+InvocingStartDate +'\",'; 
          }
          else if (fieldName == 'Transform--EndDate' ) {
          Date OrderLineStartDate = (Date.valueOf(sObjectRec.get('Start_date__c')));
           Date OrderLineEndDate = (Date.valueOf(sObjectRec.get('End_date__c')));
           Date orderCloseDate = (Date.valueOf(sObjectRec.get('End_date__c')));
           
           if (sObjectRec.getSObject(('Order__r')) != null) {
           orderCloseDate=(String.valueOf(sObjectRec.getSObject('Order__r').get('Close_Date__c')) == null ? null: Date.valueOf(sObjectRec.getSObject('Order__r').get('Close_Date__c')));
                }
            
           
           Boolean isProductUpgrade = ((Boolean)(sObjectRec.get('Product_Upgrade__c')));
           String memoLineStr  = (String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')));
           
            Date InvocingEndDate = (Date.valueOf(sObjectRec.get('End_date__c')));
            
            
           If (OrderLineStartDate != null && OrderLineEndDate  != null && memoLineStr  != null && orderCloseDate != null)
           {
              
               if (memoLineStr   != '' || memoLineStr  != null){
                   
                    Date orderCloseDateClone = orderCloseDate ;
                   if(memoLineStr.endsWithIgnoreCase('I')){
                       orderCloseDateClone = orderCloseDate.addMonths(1) ; 
                       InvocingEndDate =orderCloseDateClone.toStartOfMonth().addMonths(1).addDays(-1) ;
                       }
                    if(memoLineStr.endsWithIgnoreCase('L') && isProductUpgrade ){
                         
                        orderCloseDateClone = orderCloseDate.addMonths(1) ; 
                       InvocingEndDate =orderCloseDateClone .toStartOfMonth().addMonths(1).addDays(-1) ;
                       }
                    if(memoLineStr.equalsIgnoreCase('QASRPandoraL') ||memoLineStr.equalsIgnoreCase('QASNPandoraL') ){
                       InvocingEndDate =orderCloseDateClone.toStartOfMonth().addMonths(1).addDays(-1);
                       }
                        //RJ Added this as part of iFRS15 changes.
               if(fileType == exportFileTypes.APACSummitFile)
                   InvocingEndDate = OrderLineEndDate.toStartOfMonth().addMonths(1).addDays(-1);
                       
               }  
               
               
               
                       
               }  
               
               
               
                 
           
           
           csvContent =csvContent +'\"'+InvocingEndDate +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+InvocingEndDate +'\",';  
          }
           else if (fieldName == 'Transform--OracleAccountingRules' ) {   
          
          Date OrderLineStartDate = (Date.valueOf(sObjectRec.get('Start_date__c')));
           Date OrderLineEndDate = (Date.valueOf(sObjectRec.get('End_date__c')));
           Boolean isProductUpgrade = ((Boolean)(sObjectRec.get('Product_Upgrade__c')));
           String memoLineStr  = (String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')));
           
           If (OrderLineStartDate != null && OrderLineEndDate  != null && memoLineStr  != null)
           {
               String InvocingRule = ' ';
               Integer diffInDaysClone =0;
               Integer diffInDays =diffInDaysClone= OrderLineStartDate.MonthsBetween(OrderLineEndDate );
               
               if((fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM)&& diffInDays !=null)
               diffInDays=diffInDays+1;
               
                if(diffInDaysClone <= 1)
                    InvocingRule='Immediate';
                
                else if (diffInDays >1 )
                   InvocingRule ='Equal_'+diffInDays +'_Periods';
                   else
                   InvocingRule='Immediate';
                   
                   
               if ((memoLineStr   != '' || memoLineStr  != null)&&(fileType == exportFileTypes.APACSummitFile)){
                 // RJ Changes for IFRS15
                   /*if(memoLineStr.endsWithIgnoreCase('I'))
                       InvocingRule='Immediate';
                    if(memoLineStr.endsWithIgnoreCase('L') && isProductUpgrade )
                       InvocingRule='Immediate';
                    if(memoLineStr.equalsIgnoreCase('QASRPandoraL') ||memoLineStr.equalsIgnoreCase('QASNPandoraL') )
                       InvocingRule='Immediate';
                       */
                       String IFRSSecRevCode = String.valueOf(sObjectRec.get('IFRS15_Secondary_Revenue_Subaccount_Code__c'));
                       
                       If (IFRSSecRevCode != Null){
                           /*if(IFRSSecRevCode.equalsIgnoreCase('REV52400'))
                               InvocingRule='Immediate';
                              else*/ //RJ changes for case # 16494509
                              if(IFRSSecRevCode.equalsIgnoreCase('REV52420'))
                               InvocingRule='Immediate';
                              else if(IFRSSecRevCode.equalsIgnoreCase('REV52460'))
                               InvocingRule='Immediate';
                              else if(IFRSSecRevCode.equalsIgnoreCase('REV52470'))
                               InvocingRule='Immediate';
                              else if(IFRSSecRevCode.equalsIgnoreCase('REV52200'))
                               InvocingRule='Immediate'; 
                              else if(IFRSSecRevCode.equalsIgnoreCase('REV52100'))
                               InvocingRule='Immediate';
                              else if(IFRSSecRevCode.equalsIgnoreCase('REV52210')) //RJ changes for case # 16494509 - added REV52210
                               InvocingRule='Immediate'; 
                              else if(IFRSSecRevCode.equalsIgnoreCase('REV52430')) //RJ changes for case # 16494509 - changed to REV52430 to have Equal_36_Periods
                               InvocingRule='Equal_36_Periods';  
                                
                               
                               
               }  
                   
               }  
                   
              csvContent =csvContent +'\"'+InvocingRule +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+InvocingRule +'\",';   
                   
           }else {
              //displayLine.add('');
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
          }
          
          
          }
          else if (fieldName == 'Transform--QAS' ) {   
          
          string fieldValueQAS = 'QAS';
          String currencyIsoCodeStr= null;
          if (sObjectRec.getSObject(('Order__r')) != null) {
                  currencyIsoCodeStr=(String.valueOf(sObjectRec.getSObject('Order__r').get('CurrencyIsoCode')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').get('CurrencyIsoCode')));
                }                     
           
           If (currencyIsoCodeStr  != null)
           {
                
               If (currencyIsoCodeStr == 'AUD' )
                   fieldValueQAS= 'AU QAS Auto Invoice';
                If (currencyIsoCodeStr == 'NZD' )
                   fieldValueQAS= 'NZ QAS Auto Invoice';
                If (currencyIsoCodeStr == 'SGD' )
                   fieldValueQAS= 'SG QAS Auto Invoice';
                If (currencyIsoCodeStr == 'USD' )
                   fieldValueQAS= 'SG QAS Auto Invoice';   
                   
                   
                   
                   
              csvContent =csvContent +'\"'+fieldValueQAS +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValueQAS +'\",';   
                   
           }else {
              //displayLine.add('');
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
          }
          
          
          }
          else if (fieldName == 'Transform--PDCode' ) { 
              String pdCodeStr= '';
              if (sObjectRec.getSObject(('Product__r')) != null) {
           pdCodeStr = (String.valueOf(sObjectRec.getSObject('Product__r').get('PD_Code__c')) == null ? '': 'Targeting - '+String.valueOf(sObjectRec.getSObject('Product__r').get('PD_Code__c'))); 
           }
           csvContent =csvContent +'\"'+pdCodeStr+'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+pdCodeStr+'\",';  
          }
          else if (fieldName == 'Transform--PMM' ) {   
          
          string fieldValueQAS = 'PMM Auto Invoice';
          String currencyIsoCodeStr= null;
           String prodName = null;
          if (sObjectRec.getSObject(('Order__r')) != null) {
                  currencyIsoCodeStr=(String.valueOf(sObjectRec.getSObject('Order__r').get('CurrencyIsoCode')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').get('CurrencyIsoCode')));
                }                     
           if (sObjectRec.getSObject(('Product__r')) != null) {
           prodName = (String.valueOf(sObjectRec.getSObject('Product__r').get('Name')) == null ? '': String.valueOf(sObjectRec.getSObject('Product__r').get('Name'))); 
           }
           
           
           If (currencyIsoCodeStr  != null)
           {
                
               If (currencyIsoCodeStr == 'AUD' )
                   fieldValueQAS= 'AU PMM Auto Invoice';
                If (currencyIsoCodeStr == 'NZD' )
                   fieldValueQAS= 'NZ PMM Auto Invoice';
                If (currencyIsoCodeStr == 'SGD' )
                   fieldValueQAS= 'SG PMM Auto Invoice';
                If (currencyIsoCodeStr == 'USD' )
                   fieldValueQAS= 'SG PMM Auto Invoice';   
               
               If (prodName == 'DAS data consultancy')    
               {
                   
                    If (currencyIsoCodeStr == 'AUD' )
                   fieldValueQAS= 'AU DAS Auto Invoice';
                If (currencyIsoCodeStr == 'NZD' )
                   fieldValueQAS= 'NZ DAS Auto Invoice';
                If (currencyIsoCodeStr == 'SGD' )
                   fieldValueQAS= 'SG DAS Auto Invoice';
                If (currencyIsoCodeStr == 'USD' )
                   fieldValueQAS= 'SG DAS Auto Invoice'; 
                   
               }
                   
                   
                   
              csvContent =csvContent +'\"'+fieldValueQAS +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValueQAS +'\",';   
                   
           }else {
              //displayLine.add('');
              csvContent =csvContent +'\"\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"\",';
          }
          
          
          }//Transform--Memo_Line__c - PMM
          else if (fieldName == 'Transform--PMM_Memo_Line__c' ) {   
          
          string fieldValueQAS = 'Targeting - PMM - Auto Invoice';
          
           String prodName = null;
         /* if (sObjectRec.getSObject(('Order__r')) != null) {
                  currencyIsoCodeStr=(String.valueOf(sObjectRec.getSObject('Order__r').get('CurrencyIsoCode')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').get('CurrencyIsoCode')));
                }   */                  
           if (sObjectRec.getSObject(('Product__r')) != null) {
           prodName = (String.valueOf(sObjectRec.getSObject('Product__r').get('Name')) == null ? '': String.valueOf(sObjectRec.getSObject('Product__r').get('Name'))); 
           }
           
             If (prodName == 'DAS data consultancy')    
                   fieldValueQAS = 'Targeting - DAS - Auto Invoice';
                   
                   
                   
              csvContent =csvContent +'\"'+fieldValueQAS +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValueQAS +'\",';   
                   
          
          
          
          }
          //Transform--OptyOrderValue- EMEA Summit
          else if (fieldName == 'Transform--OptyOrderPOValue' ) {   
          
          string fieldValueQAS = '';
          
           String opptyId = '';
           String orderPO = '';
         /* if (sObjectRec.getSObject(('Order__r')) != null) {
                  currencyIsoCodeStr=(String.valueOf(sObjectRec.getSObject('Order__r').get('CurrencyIsoCode')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').get('CurrencyIsoCode')));
                }   */                  
           if (sObjectRec.getSObject(('Order__r')) != null && sObjectRec.getSObject('Order__r').getSObject('Opportunity__r') != null) {
           opptyId = (String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Opportunity__r').get('Oppty_ID_18_chars__c')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Opportunity__r').get('Oppty_ID_18_chars__c'))); 
           }
           
           if (sObjectRec.getSObject(('Order__r')) != null ) {
           orderPO = (String.valueOf(sObjectRec.getSObject('Order__r').get('PO_Number__c')) == null ? '': String.valueOf(sObjectRec.getSObject('Order__r').get('PO_Number__c'))); 
           }  
                   
              fieldValueQAS =   opptyId + '|'+  orderPO ;
                   
              csvContent =csvContent +'\"'+fieldValueQAS +'\",';
                cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldValueQAS +'\",';   
                   
          
          
          
          }
          else if(fieldname == 'Transform--VATTaxCode'){         
            string VatCode='';
            
            if (String.valueof(sObjectRec.getSObject('Order__r')) != null  && String.valueof(sObjectRec.getSObject('Order__r').getSObject('Account__r')) != null)
            {
            if(String.valueof(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('Experian_Company__c'))== 'true'){
              VatCode='SG EAP AR 0% EX';
            }
            else if(String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('billingcountry')) == 'Singapore'){
              VatCode='SG EAP AR 7%';
            }
            else{
              VatCode='SG EAP AR 0% ZR';
            }
            //VatCode =((String.valueOf(sObjectRec.getSObject('Order__r').getSObject('Account__r').get('billingcountry')) == 'Singapore' ?'SG EAP AR 7%'  : 'SG EAP AR 0% ZR' ));
           }
            csvContent =csvContent +'\"'+VatCode +'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+VatCode +'\",'; 
          }
          else if(fieldname == 'Transform--OwnerName'){         
            string ownerName;
            string ownFirstname;
            string ownLastname;
            
            if(String.valueof(sObjectRec.getSObject('Order__r')) != null && String.valueof(sObjectRec.getSObject('Order__r').getSObject('Owner')) != null)
            {
            ownFirstname = String.valueof(sObjectRec.getSObject('Order__r').getSObject('Owner').get('Firstname'));
            ownlastname = String.valueof(sObjectRec.getSObject('Order__r').getSObject('Owner').get('Lastname'));
            }
            ownername = ownlastname + ', ' + ownFirstname;
                      
           
            csvContent =csvContent +'\"'+OwnerName+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+OwnerName +'\",'; 
          }
          else if(fieldname == 'Transform--CloseDate'){         
            string strclosedate;
            if(String.valueof(sObjectRec.getSObject('Order__r')) != null)
            { 
                 
                date dateclosedate = date.valueof(sObjectRec.getSObject('Order__r').get('Close_Date__c'));
                datetime dtclosedate = datetime.newinstance(dateclosedate.year(),dateclosedate.month(),dateclosedate.day());
                
                if(filetype==exportFileTypes.SummitFile && !isUSRegion ){
                  string tz = string.valueof(UserInfo.getTimeZone()); 
                  strclosedate =dtclosedate.format('yyyy-MM-dd HH:mm:ss',tz);
                }
                else { 
                strclosedate = dtclosedate.format('dd-MMM-yy');
              }
            }
            csvContent =csvContent +'\"'+strclosedate+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+strclosedate+'\",'; 
          }
          else if(fieldname == 'Transform--DPCustomerID'){         
            string strDPCustomerID;
            string DPCustomerID;
            if(sObjectRec.getSObject('Order__r')!=null  && sObjectRec.getSObject('Order__r').getSObject('billing_contact__r')!=null &&
              sObjectRec.getSObject('Order__r').getSObject('billing_contact__r').getSObject('account')!=null){
               DPCustomerID = String.valueof(sObjectRec.getSObject('Order__r').getSObject('billing_contact__r').getSObject('account').get('DP_Customer_Id__c'));
             }
                      
            if (!string.isBlank(DPCustomerID)){   
            strDPCustomerID = 'DPI_D' +  DPCustomerID;
            }
            else{
                strDPCustomerID='Not Available';
            }
                                
            csvContent =csvContent +'\"'+strDPCustomerID+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+strDPCustomerID+'\",'; 
          }
          else if(fieldname == 'Transform--DPUniqueRef'){         

            string currDate= system.now().format('ddMMYY');
            string processorderid = string.valueof(sObjectRec.getSObject('Order__r').get('Id'));
            
            if(processorderid!=DPcurrorderID){
              DPcurrOrderid=processorderid;
              DPordernumber=DPordernumber+1;
            
            }
            
            string DPUniqueRef = 'DPI'+currdate +'M' + string.valueof(DPordernumber).leftpad(2,'0');
                   
                                
            csvContent =csvContent +'\"'+DPUniqueRef +'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+DPUniqueRef +'\",'; 
          }
          else if(fieldname == 'Transform--EBA_Trans_Header_Ref'){         
          
            string EBA_Trans_Header_Ref = '';
            if(string.valueof(sObjectRec.getSObject('Order__r')) != null )
             EBA_Trans_Header_Ref =string.valueof(sObjectRec.getSObject('Order__r').get('Order_Number__c')) + string.valueof(sObjectRec.getSObject('Order__r').get('Id')).right(8);
                                                 
            csvContent =csvContent +'\"'+EBA_Trans_Header_Ref+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+EBA_Trans_Header_Ref+'\",'; 
          }
          else if(fieldname == 'Transform--EBA_Trans_Type'){         
                       
            string EBA_Trans_Type=''; 
            
            if(string.valueof(sObjectRec.getSObject('Order__r')) != null && string.valueof(sObjectRec.getSObject('Order__r').get('Payment_Method__c')) == 'Credit Card'){
              EBA_Trans_Type='UK EBE Paid Inv';
            }
            else{
              EBA_Trans_Type='UK EBE Auto Inv';
            }
                                                   
            csvContent =csvContent +'\"'+EBA_Trans_Type+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+EBA_Trans_Type+'\",'; 
          }
          else if(fieldname == 'Transform--EBA_Transaction_Date'){         
                       
            String transDate;
            if(label.EBA_Transaction_date == 'N/A'){
              transDate= string.valueof(Datetime.now().addDays(-1).format('d-MMM-yy'));
            }
            else {
              transDate=datetime.newinstance(integer.valueof(label.EBA_Transaction_date.substring(4)),integer.valueof(label.EBA_Transaction_date.substring(2,4)), integer.valueof(label.EBA_Transaction_date.substring(0,2)),0,0,0).format('d-MMM-yy');
            } 
                                                   
            csvContent =csvContent +'\"'+transDate+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+transDate+'\",'; 
          }
          else if(fieldname == 'Transform--EBA_Cust_Head_Ref'){         
            string EBA_Cust_Head_Ref='';
            if (String.valueof(sObjectRec.getSObject('Order__r')) != null &&
                   String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r')) != null )//&&
                  // String.valueof(sObjectRec.getSObject('Order__r').getSObject('billing_contact__r').getSObject('account')) != null)        
                   {
            if( String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('Company_Registration__c')) != null){
              EBA_Cust_Head_Ref= 'R' +  String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('Company_Registration__c')); 
            }
            else if( String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('EBA_Customer_Site_Ref__c')) != null){
              EBA_Cust_Head_Ref='K' + String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('EBA_Customer_Site_Ref__c')).leftPad(9, '0');
            }
            else{
              EBA_Cust_Head_Ref='KE' + String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('Global_Unique_ID__c')).leftPad(9, '0');
            }
                }                                   
            csvContent =csvContent +'\"'+EBA_Cust_Head_Ref+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+EBA_Cust_Head_Ref+'\",'; 
          }
          else if(fieldname == 'Transform--EBA_Payment_Receipt'){         
             
            string EBA_Payment_Receipt=''; 
            
            if(string.valueof(sObjectRec.getSObject('Order__r')) != null && string.valueof(sObjectRec.getSObject('Order__r').get('Payment_Method__c')) == 'Direct Debit'){
              EBA_Payment_Receipt='RSK-GBP-Direct Debit(Remitted)';
            }
            
                                                   
            csvContent =csvContent +'\"'+EBA_Payment_Receipt+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+EBA_Payment_Receipt+'\",'; 
          }
           else if(fieldname == 'Transform--EBA_Cust_Site_Ref'){         
             
            string EBA_Cust_Site_Ref=''; 
             if (String.valueof(sObjectRec.getSObject('Order__r')) != null &&
                   String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r')) != null )//&&
                  // String.valueof(sObjectRec.getSObject('Order__r').getSObject('billing_contact__r').getSObject('account')) != null)        
                   {
            if(String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('EBA_Customer_Site_Ref__c')) != null){
              //EBA_Cust_Site_Ref='rsk-' + String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('EBA_Customer_Site_Ref__c'));
                EBA_Cust_Site_Ref= String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('EBA_Customer_Site_Ref__c'));
            }
            else{

              EBA_Cust_Site_Ref='rsk-E' + String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('Global_Unique_ID__c'));
            }
            }
                                                   
            csvContent =csvContent +'\"'+EBA_Cust_Site_Ref+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+EBA_Cust_Site_Ref+'\",'; 
          }
          else if(fieldname == 'Transform--EBA_Tax_Code'){         
             
            string EBA_Tax_Code; 
             if (String.valueof(sObjectRec.getSObject('Order__r')) != null &&
                 String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r')) != null )
                 //  String.valueof(sObjectRec.getSObject('Order__r').getSObject('billing_contact__r')) != null &&
                  // String.valueof(sObjectRec.getSObject('Order__r').getSObject('billing_contact__r').getSObject('account')) != null)        
                   {
             if(String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('Country_of_Registration__c')) =='United Kingdom'){
              EBA_Tax_Code = 'STANDARD UK VAT';
            }
            else if(Country_LookUp_Information_Helper.EU_Country(String.valueof(sObjectRec.getSObject('Order__r').getSObject('account__r').get('Country_of_Registration__c')))) {
              EBA_Tax_Code = 'EC SERVICES 0%';
            }
            else{
              EBA_Tax_Code = 'NON-EC SERVICES 0%';
            } 
            
            }
                                                   
            csvContent =csvContent +'\"'+EBA_Tax_Code+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+EBA_Tax_Code+'\",'; 
          }
          else if(fieldname == 'Transform--EBA_Payment_Terms'){         
             
            string EBA_Payment_Terms= '30-NET'; 
            
            date transDate;
            
            if(string.valueof(sObjectRec.getSObject('Order__r')) != null && string.valueof(sObjectRec.getSObject('Order__r').get('Payment_Method__c')) == 'Direct Debit'){
            
             if(label.EBA_Transaction_date == 'N/A'){
               transDate= Date.today().adddays(-1);
             }
             else {
              transDate= date.newinstance(integer.valueof(label.EBA_Transaction_date.substring(4)),integer.valueof(label.EBA_Transaction_date.substring(2,4)), integer.valueof(label.EBA_Transaction_date.substring(0,2)));
             }
             
             date CompareDate;
             date transdate20 = transdate.adddays(20);
             if (transdate20.day() <=7){
              CompareDate= date.newInstance(transdate20.year(), transdate20.month(), 7);
             }
             else if(transdate.adddays(20).day() >7 && transdate.adddays(20).day()<=21){
               CompareDate= date.newInstance(transdate20.year(), transdate20.month(), 21);
             }
             else{
               CompareDate= date.newInstance(transdate20.year(), transdate20.month()+1, 7);
             }
             
             
              EBA_Payment_Terms= string.valueof(transDate.daysBetween(CompareDate)) + '-NET';

            
            }
            
                                                   
            csvContent =csvContent +'\"'+EBA_Payment_Terms+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+EBA_Payment_Terms+'\",'; 
          }
          else if(fieldname == 'Transform--EBA_Insert_Update'){         
                                                  
            csvContent =csvContent +'\"'+EBACustomerIorU+'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+EBACustomerIorU+'\",'; 
          }
          else if(fieldname == 'Transform--EBA_Revenue_RevSch'){         
               
               Decimal EBARev =0.0;
                List<sobject> listOrderRev = sObjectRec.getSObjects('Order_Revenue_Schedules__r');
                if(listOrderRev != null){
                  for (sobject oderLnSch :listOrderRev  )
                  {
                      EBARev =((Order_Revenue_Schedule__c) oderLnSch).Revenue__c ;
                  }                                
            csvContent =csvContent +'\"'+EBARev +'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+EBARev +'\",'; 
            }
          }
           else if(fieldname == 'Transform--EBA_Tax_RevSch'){         
               
               Decimal EBARev =0.0;
                List<sobject> listOrderRev = sObjectRec.getSObjects('Order_Revenue_Schedules__r');
                if(listOrderRev != null){
                  for (sobject oderLnSch :listOrderRev  )
                  {
                      EBARev =((Order_Revenue_Schedule__c) oderLnSch).EBA_VAT_Default__c;
                  }                                
            csvContent =csvContent +'\"'+EBARev +'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+EBARev +'\",'; 
            }
          }
          else if(fieldname == 'Transform--NAEDQAcctRules'){
            if(sObjectRec.getSobject('Order__r')!= null && sObjectRec.getSobject('Order__r').get('status__c')=='Credit Note' ) {
              csvContent =csvContent +'\"Immediate\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"Immediate\",';
            }
            else if(sObjectRec.get('Product_Upgrade__c')!=null && sObjectRec.get('Product_Upgrade__c')==true){
              csvContent =csvContent +'\"Immediate\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"Immediate\",';
            }
            else if(sObjectRec.get('EDQ_Memo_Line__c')!=null ){
              
            string typSaleCode =   String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')).substring(String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')).length()-2);
            list<string> spreadLst = '02,05,06,07,08,13,14,15'.split(',');
            list<string> immediateLst = '09,10,11,12'.split(',');
            if(spreadLst.contains(typSaleCode)){
              Decimal contractTerm = (Decimal.valueOf(String.valueOf(sObjectRec.get('Contract_Term__c'))));
              String ruleLogic = 'Equal_' + String.valueOf(contractTerm.round(System.RoundingMode.HALF_DOWN)) + '_Periods';
              if(ruleLogic=='Equal_1_Periods' || ruleLogic=='Equal_0_Periods'){
                ruleLogic='Immediate';
              }
              csvContent =csvContent + '\"' + ruleLogic + '\",';
              cloneCSVRowContent =cloneCSVRowContent + '\"' + ruleLogic + '\",';

            }
            else if(immediateLst.contains(typSaleCode) ){
              csvContent =csvContent +'\"Immediate\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"Immediate\",';
            }
            // 21886522
            else if(typSaleCode == '03'){
              csvContent =csvContent +'\"First_80_Balance_20_12_months\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"First_80_Balance_20_12_months\",';
            }
            else if(typSaleCode == '99' ){
              csvContent =csvContent +'\"Equal_36_Periods\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"Equal_36_Periods\",';
            }
            else {
              csvContent =csvContent +'\"Failed Memo Line\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"Failed Memo Line\",';
            }                                                                                                                                                 
            }
            else {
              csvContent =csvContent +'\"Failed Memo Line\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"Failed Memo Line\",';
            } 
          }
          else if(fieldname == 'Transform--NAEDQAcctStartDate'){
           
              String startDate='';
              if(sObjectRec.get('Start_Date__c')!=null){
                startDate = String.valueOf(sObjectRec.get('Start_Date__c'));
              }
              csvContent =csvContent + '\"' + startDate + '\",';
              cloneCSVRowContent =cloneCSVRowContent + '\"' + startDate + '\",';
            
          }
          else if(fieldname == 'Transform--NAEDQDefGLCode'){
          
              string revAccount = '1370.US.370.000000.31002000.00000000.00000000.0000';
              
              if(sObjectRec.get('EDQ_Memo_Line__c')!=null ){             
                  string typSaleCode =   String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')).substring(String.valueOf(sObjectRec.get('EDQ_Memo_Line__c')).length()-2);
                  list<string> accSplitList = '06,07,08,09,10,11,99'.split(',');
                  
                   if(accSplitList.contains(typSaleCode)){
                     revAccount = '1370.US.370.000000.31002400.00000000.00000000.0000';
                   }
              }
              csvContent =csvContent +'\"' + revAccount + '\",';
              cloneCSVRowContent =cloneCSVRowContent +'\"'+ revAccount + '\",';
            
          }
          else if(fieldname == 'Transform--UserName'){                                  
            csvContent =csvContent +'\"'+ UserInfo.getName() +'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+ UserInfo.getName() + '\",'; 
         }
         else if(fieldname == 'Transform--ProductBU'){ 
            string productBU = 'NEWCONFIG';
            string pfbu =  String.valueof(sObjectRec.get('Product_Finance_BU__c'));
            map<string,string> ProductBUMap = new Map<String,String>();
            if(pfbu == '370' || pfbu == '373'){
              productBU = String.valueof(sObjectRec.get('EDQ_Memo_Line__c'));
            }
            else {
              for(EDQ_ProductBU__mdt pbu : [select label,Developername from EDQ_ProductBU__mdt]){
                ProductBUMap.put(pbu.label,pbu.Developername);
              }

              if(ProductBUMap.containsKey(pfbu)){
                productBU=ProductBUMap.get(pfbu);
              }

            }
            csvContent =csvContent +'\"'+ productBU +'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"\",'; 
          }
          else {
            //displayLine.add('');
            csvContent =csvContent +'\"\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"\",';
          }
        }
        else if (fieldName!= null && (fieldName.contains('HC--') )) {
          //displayLine.add(fieldName.split('HC--')[1]);
          csvContent =csvContent +'\"'+fieldName.split('HC--')[1]+'\",';
          if ( fieldName != 'HC--F') {
            cloneCSVRowContent =cloneCSVRowContent +'\"'+fieldName.split('HC--')[1]+'\",';
          }
          else {
            cloneCSVRowContent =cloneCSVRowContent +'\"'+''+'\",';
          }
        }
        else if (fieldName!= null && (fieldName.contains('SQ--'))) {
          seqNumber++;
          //displayLine.add(string.valueof(seqNumber) );
          csvContent =csvContent +'\"' +seqNumber +'\",';
          cloneCSVRowContent =cloneCSVRowContent +'\"' +seqNumber +'\",';
        }
        else if (fieldName!= null && (fieldName.contains('DT--TODAY') )) {    
          //displayLine.add(todayDate);
             if(fileType == exportFileTypes.EBATransFile){
               todayDate = Datetime.now().format('d-MMM-yy'); 
             }         
            csvContent =csvContent +'\"'+ todayDate +'\",';
            cloneCSVRowContent =cloneCSVRowContent +'\"'+ todayDate +'\",';
        }
        else if(fieldName!= null && (fieldName.contains('GQ--Order') )&& ((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM)||(fileType == exportFileTypes.EBATransFile) ) ) { 
          if (runningOrderId == null && prevOrderId == null && sObjectRec.getSObject(('Order__r')) != null ) {           
            runningOrderId=prevOrderId=String.Valueof(sObjectRec.getSObject(('Order__r')).get('id'));
            orderGroupNumber=1;
          }
          else {
            if (sObjectRec.getSObject(('Order__r')) != null) {
              runningOrderId=String.Valueof(sObjectRec.getSObject(('Order__r')).get('id'));
            }
            if (runningOrderId==prevOrderId) {
              orderGroupNumber++;
            }
            else {
              orderGroupNumber=1;
              prevOrderId=runningOrderId;
            }
          }
          //displayLine.add(todayDate);
          csvContent =csvContent +'\"'+ orderGroupNumber +'\",';
          cloneCSVRowContent =cloneCSVRowContent +'\"'+ orderGroupNumber +'\",';
        }
        else {
          //displayLine.add('');
          csvContent =csvContent +'\"\",';
          cloneCSVRowContent =cloneCSVRowContent +'\"\",';
        }
        fieldCount++;
      }
  
      //reportDisplayList.add (displayLine);
      if (fileType != exportFileTypes.CustomerFile && 
          fileType != exportFileTypes.RPMFile && 
          fileType != exportFileTypes.DPFile &&
          fileType != exportFileTypes.DPCustomerFile &&
           fileType != exportFileTypes.EBATransFile &&
           fileType != exportFileTypes.EBATransFileNew &&
           fileType != exportFileTypes.EBATransCreditFile &&
            fileType != exportFileTypes.EBACustomerFile &&
          !(((fileType == exportFileTypes.SummitFile) || (fileType == exportFileTypes.APACSummitFile) || (fileType == exportFileTypes.PMM) ) && (isUSRegion== false))) {
        csvContent =csvContent +'\n'+cloneCSVRowContent +'\n' ;
       // I5553 Changes- Sunil
      }else if(fileType == exportFileTypes.EBATransFileNew || fileType == exportFileTypes.EBATransCreditFile){
          csvContent = csvContent.removeEnd(',');
          csvContent = csvContent +'\n';
      }
      else {
        csvContent =csvContent +'\n' ;
      }
    }
    // Case: 21172980 starts here
    if((fileType == exportFileTypes.EBATransFileNew || fileType == exportFileTypes.EBATransCreditFile) && !String.isEmpty(csvContent)){        
      csvContent = csvContent.removeEnd('\n');
    }
    // Case: 21172980 ends here
    //RPM File Header Generation
    if (fileType == exportFileTypes.RPMFile) {
      Integer runningSeq= 0;
      Report_Extract_Templates__c RPMHDRTLRRec= Report_Extract_Templates__c.getValues('RPM HDRTLR');
      try{
        runningSeq = Integer.valueof(string.valueof((RPMHDRTLRRec.col5__c)).split('RunningSeq--')[1]);
      }
      catch (exception ex) {
        runningSeq=0;
      }
      runningSeq++;
      String header = '\"HDR\",'+'\"'+seqNumber+'\",'+'\"1484\",\"'+todayDate+'\",\"'+runningSeq+'\"';
      //csvContent = header + '\n';
      String trailer = '\"TLR\",'+'\"'+seqNumber+'\",'+'\"1484\",\"'+todayDate+'\",\"'+runningSeq+'\"';
      csvContent = header + '\n'+csvContent + Trailer + '\n';
      RPMHDRTLRRec.col5__c = 'RunningSeq--'+runningSeq;
      update RPMHDRTLRRec;
    }
    //System.debug(reportDisplayList);
    
    if (Schedule_BatchID != null){
    system.debug('before return : ' + csvContent);
      return csvContent;
    }
    
    return null;
    //return page.BatchOrderList;
  }
  
  
  //Method to generate Operating Unit value from  User
  @testVisible 
  private void getOperatingUnitValue() {
    User currentUser = [SELECT Region__c,Country__c, ID FROM User WHERE ID =: UserInfo.getUserId()];
    if (currentUser.Country__c!= null) {
      if (currentUser.Country__c == 'US' ||
          currentUser.Country__c == 'USA' || 
          currentUser.Country__c == 'United States' || 
          currentUser.Country__c == 'United States of America') {
        operatingUnitName = 'EXP_US_EHI_OU';
      }
      else if (currentUser.Country__c == 'UK' || 
               currentUser.Country__c == 'United Kingdom' ) {
        operatingUnitName='EXP_UK_ELI_OU';
      }
      else if (currentUser.Country__c == 'FR' || 
               currentUser.Country__c == 'France' ) {
        operatingUnitName='EXP_FR_ECS_OU';
      }
      else if (currentUser.Country__c == 'NZ' || 
               currentUser.Country__c == 'New Zealand' ) {
        operatingUnitName='EXP_NZ_EAP_OU'; 
      }
      else if (currentUser.Country__c == 'SGP' || 
               currentUser.Country__c == 'Singapore' ) {
        operatingUnitName='EXP_SG_EAP_OU';
      }
      else if (currentUser.Country__c == 'AU' || 
               currentUser.Country__c == 'Australia' ) {
        operatingUnitName='EXP_AU_EAP_OU';
      }
      else if (currentUser.Country__c == 'NL' || 
               currentUser.Country__c == 'Netherlands' ) {
        operatingUnitName='EXP_FR_ECS_OU';
      }
    } 
  }
  
  //Memo Line generation code - Move to Order Line trigger
  // PK: Not used anywhere, so commenting out.
  //public string generateMemoLn (string productSaleType, string orderType,string productFamily){
  //  string memoLnTxt = '';
  //  memoLnTxt= 'QAS';
  //  if (orderType== 'Renewal')
  //    memoLnTxt=memoLnTxt+'R';
  //  else 
  //    memoLnTxt=memoLnTxt+'N';
  //    //if (orderType== 'N')
  //  
  //    memoLnTxt= memoLnTxt+(productFamily == null ? '' : productFamily);
  //    
  //    if(productSaleType != null && !productSaleType.contains(';') )
  //    {
  //    if(memoLnTypeOfSaleLSet.contains(productSaleType))
  //      memoLnTxt=memoLnTxt+'L';
  //    else if (memoLnTypeOfSaleISet.contains(productSaleType))  
  //      memoLnTxt=memoLnTxt+'I';
  //    }
  //    else if (productSaleType != null && productSaleType.contains(';') )
  //    {
  //        List<string> saleTypeList = new list<string>();
  //        saleTypeList= productSaleType.split(';');
  //        for(string saleTypeValue : saleTypeList)
  //        {
  //          if(memoLnTypeOfSaleLSet.contains(saleTypeValue))
  //          {
  //            memoLnTxt=memoLnTxt+'L';
  //            break;
  //          }
  //          else if (memoLnTypeOfSaleISet.contains(saleTypeValue))
  //          { 
  //            memoLnTxt=memoLnTxt+'I';
  //            break;
  //          }
  //          
  //        }
  //        
  //    }
  //  
  //  
  //  return memoLnTxt;
  //}
}