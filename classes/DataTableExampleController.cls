public class DataTableExampleController {
    public List<List<CustomClass>> lstData{get;set;}
    public boolean isSearch{get;set;}
    public Salesforce_Environment__c objEn{get;set;}
    public Salesforce_Environment__c objEn1{get;set;}

    public ID caseId;
    public string objectName;
    public list<Case_Component__c> lstComponents{get;set;}
    public string strSelectedTab{get;set;}
    public boolean isDynamic{get;set;}
    public Metadata_Component__c objCreateMeta{get;set;}
    public Date strCreatedDate{get;set;}
    public Date strLastModDate{get;set;}

    public String CompCreatedDt { get; set; }
    public String CompCreatedBy { get; set; }
    public String CompLastMDt { get; set; }
    public String CompLastMBy { get; set; }
    public String compFolderName { get; set; } // added for Folder support
    public List<SelectOption> objSelectionList {get; set;}// add for object name support
    public String compObjectName { get; set; } // added for Object name support
    private ToolingApi         toolingApi           {get; set;}
    public String CompType { get; set; }
    public String compName { get; set; }
    public boolean section{get;set;}
    public String filteredCompType { get; set;}
    public static String sortBy {get; set;}
    public List<SelectOption> MetaDataTypes {get; set;}
    public string DefaultEnvironmentid;
    public string issueWorkId;
    private static final Integer METADATA_API_VERSION =
    Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));
    public boolean isCPQ{get;set;}
    public map<string, string> RMAConflicts{get;set;} 
    public boolean showConflicts{get;set;}

    Public set<string> IntMetaSet {get;set;}

     //public void setfilteredCompType (String  filteredCompType ) {
            //system.debug('Richard Test setfilteredCompType  '+ MetadataRetrieveController.MetaDataType );
            //this.filteredCompType = filteredCompType ;
        //}


    public DataTableExampleController(ApexPages.StandardSetController controller) {
    objCreateMeta = new Metadata_Component__c();
    isCPQ=False;
    this.toolingApi = new ToolingApi();
        objCreateMeta.Name = 'Ignore(WillBeReplaced)';
        lstData = new List<List<CustomClass>>();
    objEn = new Salesforce_Environment__c();
    objEn1 = new Salesforce_Environment__c();
    List<Salesforce_Environment__c> lsten = [Select id from Salesforce_Environment__c where Name = 'GLOBAL - PRODUCTION'];
    if(!lsten.isEmpty()){
    DefaultEnvironmentid = lsten[0].id;
    objEn.Salesforce_Environment__c = DefaultEnvironmentid;
    }
    MetadataTypeListRet();
    strSelectedTab = 'name1';
    section = false;
    //objEn = new Deployment_Request__c();
        caseId = ApexPages.CurrentPage().getParameters().get('Id');
        if( caseId != null){
          objectName = String.valueOf(caseId.getsobjecttype());
        }
        lstComponents = new list<Case_Component__c>();
        lstComponents = [select id,Action__c, Is_Test__c, Component_Name__r.Component_API_Name__c, Component_Name__r.Component_Type__c,Manual_Step_details__c,Deployment_Type__c,Configuration_Type__c from Case_Component__c where Case_Number__c=:caseId OR User_Story_AA__c =:caseId OR Issue__c =:caseId OR Integration__c =:caseId order by CreatedDate];
        
        RMAConflicts = new map<string, string>();
        RMAConflicts = RMAImprovement_FindConflicts.findConflicts(lstComponents,caseId);
        showConflicts = false;
        if(RMAConflicts.size() > 0){
            showConflicts =true;
        }
        
        if(objectName=='Case'){
            list<Case> lstCases = [select id, Technical_Impact_CPQ__c from Case where Id=:caseId];
            if(!lstCases.isEmpty()){
                isCPQ = lstCases[0].Technical_Impact_CPQ__c;
            }
        }else if(objectName=='Issue__c'){
            list<Issue__c> lstIssues = [select id, Work__r.Technical_Impact_CPQ__c,Work__c from Issue__c where Id=:caseId];
            if(!lstIssues.isEmpty()){
                isCPQ = lstIssues[0].Work__r.Technical_Impact_CPQ__c;
                issueWorkId = lstIssues[0].Work__c;
            }
        }else if(objectName=='agf__ADM_work__c'){
            list<agf__ADM_work__c> lstWork = [select id, Technical_Impact_CPQ__c from agf__ADM_work__c where Id=:caseId];
            if(!lstWork.isEmpty()){
                isCPQ = lstWork[0].Technical_Impact_CPQ__c;
            }
        }     
    }
    public PageReference Search(){

        isSearch = true;
        lstData = new List<List<CustomClass>>();

       // system.debug('Richard Test '+ MetadataRetrieveController.filteredCompType );

        if(objEn.Salesforce_Environment__c == DefaultEnvironmentid || objEn.Component_Type__c == 'CPQComponent'|| filteredCompType == 'Role'){
           if(filteredCompType == 'Role' && objEn.Salesforce_Environment__c != DefaultEnvironmentid && objEn.Salesforce_Environment__c!=null){
               lstData = getRoles();
           }else{
                lstData = populateData();
           }
        }else{
            lstData=listComponentItems();
        }
        return null;
    }
    //Get roles
    public List<List<CustomClass>> getRoles(){

        List<List<CustomClass>> lstData = new List<List<CustomClass>>();
        List<CustomClass> customClassList = new List<CustomClass>();

        list<Salesforce_Environment__c> lstEnv = [Select Login_URL__c,Password__c ,Username__c,ID, Client_Id__c, Client_Secret__c from Salesforce_Environment__c where ID= :objEn.Salesforce_Environment__c ];
        if(lstEnv!=null && !lstEnv.isEmpty() && string.isNotBlank(lstEnv[0].Client_Id__c) && string.isNotBlank(lstEnv[0].Client_Secret__c) && string.isNotBlank(lstEnv[0].Username__c) && string.isNotBlank(lstEnv[0].Password__c)){
            HttpRequest req = new HttpRequest();
            string endpoint ='https://test.salesforce.com/services/oauth2/token';
            endpoint = endpoint +'?grant_type=password&client_id='+lstEnv[0].Client_Id__c+'&client_secret='+lstEnv[0].Client_Secret__c+'&username='+lstEnv[0].Username__c+'&password='+lstEnv[0].Password__c ;
            req.setEndpoint(endpoint );
            req.setMethod('POST');

            req.setbody('test');

            // Create a new http object to send the request object
            // A response object is generated as a result of the request

            Http http = new Http();
            HTTPResponse res = http.send(req);
            authenticationProcess authtoken = (authenticationProcess)JSON.deserialize(res.getBody(), authenticationProcess.class);
            string accesstoken = authtoken.access_token;
            System.debug('................'+accesstoken);

            HttpRequest datareq = new HttpRequest();
            string datareqendpoint = authtoken.instance_URL+'/services/apexrest/userRoleData';
            datareq.setEndpoint(datareqendpoint );
            datareq.setMethod('GET');
            datareq.setHeader('Authorization', 'OAuth '+accesstoken );
            datareq.setHeader('Content-Type', 'application/json' );

            Http datareqhttp = new Http();
            list<UserRole> lstRoles = new list<UserRole>();
            if(!Test.isRunningTest()){
                HTTPResponse datares = datareqhttp.send(datareq);
    
                System.debug('................'+datares.getBody());
                lstRoles = (list<UserRole>)JSON.deserialize(datares.getBody(),list<UserRole>.class);
                System.debug('lstRoles................'+lstRoles);
            }else{
                lstRoles = [SELECT Id, Name, DeveloperName,lastmodifiedby.Name,lastmodifieddate, PortalType FROM UserRole where PortalType='None'];
            }
            set<string> setExistingRoles = new set<string>();
            for(Metadata_Component__c meta:[select id, Name, Component_API_Name__c from Metadata_Component__c where Component_Type__c='Role']){
                setExistingRoles.add(meta.Component_API_Name__c);
            }
            list<Metadata_Component__c> lstMetada = new list<Metadata_Component__c>();

            /*for(UserRole ur:lstRoles){
                if(!setExistingRoles.contains(ur.DeveloperName)){
                    Metadata_Component__c comp = new Metadata_Component__c();
                    comp.Name = ur.DeveloperName;
                    comp.Component_API_Name__c = ur.DeveloperName;
                    comp.Component_Type__c = 'Role';

                    comp.Unique__c ='Role - '+ur.DeveloperName;
                    lstMetada.add(comp);
                }
            }
            if(!lstMetada.isEmpty())
                upsert lstMetada Unique__c;*/

            for(UserRole ur:lstRoles){
            
                boolean fltrName ,fltrLastMBy ,fltrCreatedBY,fltrLtMDate, fltrCreateDate;
                fltrName =fltrLastMBy =fltrCreatedBY=fltrLtMDate= fltrCreateDate = false;

                string creator = ur.LastModifiedBy.Name;
                string modifier = ur.LastModifiedBy.Name;                

                if (string.isNotBlank(compName) && compName.startsWith('%') && ur.DeveloperName.containsIgnoreCase(compName.removeStart('%').trim())){
                    fltrName =true;
                }
                else if (string.isNotBlank(compName) && (ur.DeveloperName.startsWithIgnoreCase(compName))){
                    fltrName =true;
                }

                if (string.isNotBlank(CompLastMBy) &&string.isNotBlank(modifier) && modifier.containsIgnoreCase(CompLastMBy) ){
                    fltrLastMBy=true;
                }

                if (string.isNotBlank(CompCreatedBy) && string.isNotBlank(creator) && creator.containsIgnoreCase(CompCreatedBy) ){
                    fltrCreatedBY=true;
                }

                if (objEn.Temp_Date__c!= null &&  ur.lastModifiedDate >= objEn.Temp_Date__c )
                    fltrLtMDate = true;

                if (objEn1.Temp_Date__c!= null &&  ur.lastModifiedDate>= objEn1.Temp_Date__c )
                    fltrCreateDate = true;

                if (((string.isNotBlank(compName) && fltrName )|| string.isBlank(compName)) && ( string.isBlank(CompLastMBy) || ( string.isNotBlank(CompLastMBy) && fltrLastMBy)) && ((string.isNotBlank(CompCreatedBy) && fltrCreatedBY)||string.isBlank(CompCreatedBy) ) &&
                   (objEn.Temp_Date__c == null || (objEn.Temp_Date__c!= null && fltrLtMDate  )) && (objEn1.Temp_Date__c == null || (objEn1.Temp_Date__c!= null && fltrCreateDate   ))
                ){
                    customClassList.add(new CustomClass(false,ur.DeveloperName,ur.DeveloperName,'','','Role',ur.LastModifiedBy.Name,ur.LastModifiedDate.format('yyyy-MM-dd'),ur.LastModifiedBy.Name,ur.LastModifiedDate.format('yyyy-MM-dd'),false));
                }else if(string.isBlank(compName)  && objEn.Temp_Date__c== null && objEn1.Temp_Date__c == null && string.isBlank(CompCreatedBy) && string.isBlank(CompLastMBy) ){
                    customClassList.add(new CustomClass(false,ur.DeveloperName,ur.DeveloperName,'','','Role',ur.LastModifiedBy.Name,ur.LastModifiedDate.format('yyyy-MM-dd'),ur.LastModifiedBy.Name,ur.LastModifiedDate.format('yyyy-MM-dd'),false));
                }                

                if(customClassList.size()>=50){

                    lstData.add(customClassList);

                    customClassList = new List<CustomClass>();
                }
            }
            lstData.add(customClassList);
            customClassList = new List<CustomClass>();
            return lstData;
        }
        return null;
    }
    public List<List<CustomClass>> populateData(){
        List<List<CustomClass>> lstData = new List<List<CustomClass>>();
        List<CustomClass> customClassList = new List<CustomClass>();
        string strQuery = 'SELECT Id, Name, Metadata_Member__c, Component_API_Name__c ,Component_Type__c,Object_API_Name__c,Folder__c,CreatedDate,  CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name FROM Metadata_Component__c where Id!=null ';
        //Adding all fields for concatenate search if not empty.
        if(string.isNotBlank(compName) &&  compName.startsWith('%')){
            strQuery+=' AND Component_API_Name__c like \'%'+compName+'%\'';
        }
        else if(string.isNotBlank(compName)){
            strQuery+=' AND Component_API_Name__c like \''+compName+'%\'';
        }
       // filteredCompType = objEn.Component_Type__c;
        if(string.isNotBlank(filteredCompType)&& IsCPQ ==false){
            strQuery+=' AND Component_Type__c = \''+filteredCompType+'\'';
        }
        system.debug('objen@@@@'+objen.CPQ_Component_Type__c );
        if(string.isNotBlank(objEn.CPQ_Component_Type__c)&& IsCPQ == True){
            string strCPQComp = objEn.CPQ_Component_Type__c;
            strQuery+=' AND Component_Type__c = \''+strCPQComp+'\'';
        }
        if(string.isNotBlank(CompLastMBy)){
            strQuery+=' AND LastModifiedBy.Name like \'%'+CompLastMBy+'%\'';
        }
        if(string.isNotBlank(CompCreatedBy)){
            strQuery+=' AND CreatedBy.Name like \'%'+CompCreatedBy+'%\'';
        }
        if(objEn.Temp_Date__c!=null){
            Date dtL = objEn.Temp_Date__c;
            Date dtL1 = dtL.addDays(1);
            system.debug('dtL@@@'+dtL);
            strQuery+=' AND LastModifiedDate>=:dtL AND LastModifiedDate<=:dtL1';
        }
        if(objEn1.Temp_Date__c!=null){
            Date dtC = objEn1.Temp_Date__c;
            Date dtC1 = dtC.addDays(1);
            strQuery+=' AND CreatedDate>=:dtC AND CreatedDate<=:dtC1';
        }
        strQuery+=' Order by LastModifiedDate DESC,Name limit 2000';//limiting 2000 rows
        system.debug('strQuery@@'+strQuery);
        IntMetaSet = new set<string>();
        if(string.isNotBlank(filteredCompType)&& IsCPQ ==false){       
          for (Metadata_Component__c mc : [select id,Component_API_Name__c from Metadata_Component__c where Component_Type__c = : filteredCompType and  Integration_Flag__c=true]){
            IntMetaSet.add(mc.Component_API_Name__c);
          }
        }
        for(Metadata_Component__c metaComp:Database.Query(strQuery)){
            customClassList.add(new CustomClass(false,metaComp.Component_API_Name__c,metaComp.Metadata_Member__c,metaComp.Object_API_Name__c,metaComp.Folder__c,metaComp.Component_Type__c,metaComp.LastModifiedBy.Name,metaComp.LastModifiedDate.format('yyyy-MM-dd'),metaComp.CreatedBy.Name,metaComp.CreatedDate.format('yyyy-MM-dd'), IntMetaSet!= null ? IntMetaSet.contains(metaComp.Component_API_Name__c) : false));

            if(customClassList.size()>=50){

                lstData.add(customClassList);

                customClassList = new List<CustomClass>();
            }
        }
        lstData.add(customClassList);
        customClassList = new List<CustomClass>();
        return lstData;
    }

    public class CustomClass {

        public Boolean isSelect{get;set;}
        public String CompName{get;set;}
        public String CompAPIName{get;set;}
        public string objAPIName{get;set;}
        public string FolderName{get;set;}
        public String CompType{get;set;}
        public String CompLastMBy{get;set;}
        public String CompLastMDt{get;set;}
        public String CompCreatedBy{get;set;}
        public String CompCreatedDt{get;set;}
        public Boolean IntUse{get;set;}

        public CustomClass(boolean isCheck, String cAPIName, String cname, String oName,String fName,String ctype, String lby, String ldt, String cby, String cdt,Boolean iu){
            this.isSelect = isCheck;
            this.CompName = cname;
            this.CompAPIName = cAPIName;//STore the component API name
            this.objAPIName = oName;//store Component object API name
            this.FolderName = fName;
            this.CompType = ctype;
            this.CompLastMBy = lby;
            this.CompLastMDt = ldt;
            this.CompCreatedBy = cby;
            this.CompCreatedDt = cdt;
            this.IntUse = iu;
        }

        public Integer compareTo(object compareTo) {

            if (DataTableExampleController.sortBy == null)
                DataTableExampleController.sortBy= 'CompLastMDt';
         CustomClass CustomClass = (CustomClass)compareTo;
          if (DataTableExampleController.sortBy.equals('CompLastMDt')) {
            if (date.parse(this.CompLastMDt).isSameDay(date.parse(CustomClass.CompLastMDt))) return 0;
            if (date.parse(this.CompLastMDt).daysBetween(date.parse(CustomClass.CompLastMDt)) > 0) return 1;
            return -1;
         } else {
              return 0;
         }
      }
    }

    public PageReference saveComponents(){
        list<Metadata_Component__c> lstcseComp = new list<Metadata_Component__c>();
        set<string> setApexClass = new set<string>();
        for(list<CustomClass> lstCompData:lstData){
            for(CustomClass cdata:lstCompData){
                system.debug('cdata@@@'+cdata);
                if(cdata.isSelect == true){
                    system.debug('cdataSelected@@@'+cdata);
                    Metadata_Component__c comp = new Metadata_Component__c();
                     if(cdata.CompName.length()> = 80){
                        comp.Name = cdata.CompName.substring(0,79);
                    }else{
                        comp.Name = cdata.CompName;
                    }
                    comp.Component_API_Name__c = cdata.CompAPIName;
                    comp.Component_Type__c = cdata.CompType;
                    comp.Object_API_Name__c = cdata.objAPIName;
                    comp.Folder__c = cdata.FolderName;
                    
                    if(cdata.CompType == 'ApexClass'){
                        setApexClass.add(cdata.CompAPIName);
                    }

                    string strMember = comp.Component_API_Name__c;
                    if(string.isNotBlank(comp.Folder__c) && (comp.Component_Type__c == 'EmailTemplate' || comp.Component_Type__c == 'Report' || comp.Component_Type__c == 'Document')){
                        strMember = comp.Folder__c+'/'+comp.Component_API_Name__c;
                    }
                    if(string.isNotBlank(comp.Object_API_Name__c)){
                        if(comp.Component_Type__c == 'Layout' || comp.Component_Type__c == 'CustomObjectTranslation'){
                            strMember = comp.Object_API_Name__c+'-'+comp.Component_API_Name__c;
                        }else{
                            strMember = comp.Object_API_Name__c+'.'+comp.Component_API_Name__c;
                        }
                    }

                    comp.Unique__c = cdata.CompType+' - '+strMember;

                    lstcseComp.add(comp);
                    cdata.isSelect = false;
                }
            }
        }
        if(!lstcseComp.isEmpty())
            upsert lstcseComp Unique__c;
        
        set<string> testClassesSet = new set<string>();    
        for(ApexClass ac:[SELECT Id, Name, Body FROM ApexClass where Name IN:setApexClass]){
            if(ac.Body.contains('@isTest')){
                testClassesSet.add(ac.Name);
            }
        }
        
        list<Case_Component__c> lstItems = new list<Case_Component__c>();
        for(Metadata_Component__c comp:lstcseComp){
            Case_Component__c itm = new Case_Component__c();
            itm.Action__c = 'Update';
            itm.Deployment_Type__c = 'Automated Deployment';
            if(isCPQ == true){
                itm.Deployment_Type__c = 'CPQ Package';
            }
            if(objectName=='Case')
                itm.Case_Number__c = caseId;

            else if(objectName=='Issue__c'){
                itm.Issue__c = caseId;
                if(string.isNotBlank(issueWorkId))
                  itm.User_Story_AA__c = issueWorkId;
            }else if(objectName=='agf__ADM_work__c'){
                itm.User_Story_AA__c = caseId;
            }
            else if(objectName=='Integration__c'){
                itm.Integration__c = caseId;
            }
            
            if(testClassesSet.contains(comp.Component_API_Name__c)){
                itm.is_Test__c = true;
            }
            
            itm.Component_Name__c = comp.Id;

            lstItems.add(itm);
        }
        if(!lstItems.isEmpty())
            upsert lstItems ;

        lstComponents = new list<Case_Component__c>();
        lstComponents = [select id,Action__c,Is_Test__c, Component_Name__r.Component_API_Name__c,Component_Name__r.Component_Type__c,Manual_Step_details__c,Deployment_Type__c,Configuration_Type__c from Case_Component__c where Case_Number__c=:caseId OR User_Story_AA__c=:caseId OR Issue__c=:caseId OR Integration__c=:caseId order by CreatedDate];
        
        list<Case_Component__c> lstInsrtedComp = [select id,Action__c, Is_Test__c,Component_Name__r.Component_API_Name__c,Component_Name__r.Component_Type__c,Manual_Step_details__c,Deployment_Type__c,Configuration_Type__c from Case_Component__c where Id IN:lstItems];
        map<string, string> RMAConflictsTemp = new map<string, string>();
        RMAConflictsTemp = RMAImprovement_FindConflicts.findConflicts(lstInsrtedComp,caseId);
        
        string strConflicts = '';
        for(string strC:RMAConflictsTemp.keySet()){
            strConflicts += '<b>'+strC+'</b> is already existed in following case/work/issue:'+RMAConflictsTemp.get(strC)+'<br/>';
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Saved Successfully!!'));
        
        if(string.isNotBlank(strConflicts)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'<table><tr><td><b>Conflicts:</b></td></tr></table><table><thead><tr><th><b>Record Id</b></th><th><b>Status</b></th><th><b>Owner</b></th></tr></thead><tbody>'+strConflicts+'</tbody></table>'));
        } 
        
        RMAConflicts = new map<string, string>();
        RMAConflicts = RMAImprovement_FindConflicts.findConflicts(lstComponents,caseId);
        showConflicts = false;
        if(RMAConflicts.size() > 0){
            showConflicts =true;
        }
        return null;
    }

    public PageReference Cancel(){
        PageReference pf = new PageReference('/'+caseId);
        return pf;
    }

    public PageReference saveSelectedComponents(){
        try{
            map<Id,Case_Component__c> mapItems = new map<Id,Case_Component__c>([select id,Action__c,Is_Test__c,Component_Name__r.Component_API_Name__c, Component_Name__r.Component_Type__c,Manual_Step_details__c,Deployment_Type__c,Configuration_Type__c from Case_Component__c where Case_Number__c=:caseId OR User_Story_AA__c=:caseId OR Issue__c=:caseId OR Integration__c=:caseId order by CreatedDate]);

            list<Case_Component__c> lstUpdateItms = new list<Case_Component__c>();
            for(Case_Component__c itm:lstComponents){
                if(mapItems.containsKey(itm.Id)){
                    Case_Component__c oldItm = mapItems.get(itm.Id);
                    if(itm.Action__c!=oldItm.Action__c || itm.Deployment_Type__c!=oldItm.Deployment_Type__c || itm.Configuration_Type__c!=oldItm.Configuration_Type__c || itm.Manual_Step_details__c!=oldItm.Manual_Step_details__c){
                        lstUpdateItms.add(itm);
                    }
                    if(itm.Deployment_Type__c == 'Manual step' && (string.isBlank(itm.Configuration_Type__c) || string.isBlank(itm.Manual_Step_details__c))){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'If Deployment type is Manual, then configuration and Manual step details are required'));
                        return null;
                    }                 
                }
            }
            if(!lstUpdateItms.isEmpty())
                update lstUpdateItms;

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Updated Successfully!!'));
            return null;
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            return null;
        }
    }


    public PageReference saveNewComponents(){
        try{
            if(isCPQ == true){
                objCreateMeta.Component_Type__c = objEn1.CPQ_Component_Type__c;
            }else{
                objCreateMeta.Component_Type__c = objEn1.Component_Type__c;
            }
            string strMember = objCreateMeta.Component_API_Name__c;
            if(string.isNotBlank(objCreateMeta.Folder__c) && (objCreateMeta.Component_Type__c == 'EmailTemplate' || objCreateMeta.Component_Type__c == 'Report' || objCreateMeta.Component_Type__c == 'Document')){
                strMember = objCreateMeta.Folder__c+'/'+objCreateMeta.Component_API_Name__c;
            }
            if(string.isNotBlank(objCreateMeta.Object_API_Name__c)){
                if(objCreateMeta.Component_Type__c == 'Layout' || objCreateMeta.Component_Type__c == 'CustomObjectTranslation'){
                    strMember = objCreateMeta.Object_API_Name__c+'-'+objCreateMeta.Component_API_Name__c;
                }else{
                    strMember = objCreateMeta.Object_API_Name__c+'.'+objCreateMeta.Component_API_Name__c;
                }
            }

            objCreateMeta.Unique__c = objCreateMeta.Component_Type__c+' - '+strMember;
            upsert objCreateMeta Unique__c;

            Case_Component__c itm = new Case_Component__c();
            itm.Action__c = 'Update';
            itm.Deployment_Type__c = 'Automated Deployment';
            if(isCPQ == true){
                itm.Deployment_Type__c = 'CPQ Package';
            }
            if(objectName=='Case')
                itm.Case_Number__c = caseId;

            else if(objectName=='Issue__c'){
                itm.Issue__c = caseId;
                if(string.isNotBlank(issueWorkId))
                  itm.User_Story_AA__c = issueWorkId;
            }else if(objectName=='agf__ADM_work__c'){
                itm.User_Story_AA__c = caseId;
            }
            else if(objectName=='Integration__c'){
                itm.Integration__c= caseId;
            }
            
            itm.Component_Name__c = objCreateMeta.Id;

            upsert itm;

            lstComponents = new list<Case_Component__c>();
            lstComponents = [select id,Action__c,Is_Test__c,Component_Name__r.Component_API_Name__c, Component_Name__r.Component_Type__c,Manual_Step_details__c,Deployment_Type__c,Configuration_Type__c from Case_Component__c where Case_Number__c=:caseId OR User_Story_AA__c =:caseId OR Integration__c=:caseId order by CreatedDate];
            
            list<Case_Component__c> lstInsrtedComp = [select id,Action__c,Is_Test__c, Component_Name__r.Component_API_Name__c,Component_Name__r.Component_Type__c,Manual_Step_details__c,Deployment_Type__c,Configuration_Type__c from Case_Component__c where Id =:itm.Id];
            map<string, string> RMAConflictsTemp = new map<string, string>();
            RMAConflictsTemp = RMAImprovement_FindConflicts.findConflicts(lstInsrtedComp,caseId);
            
            string strConflicts = '';
            for(string strC:RMAConflictsTemp.keySet()){
                strConflicts += '<b>'+strC+'</b> is already existed in following case/work/issue:'+RMAConflictsTemp.get(strC)+'<br/>';
            }
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Saved Successfully!!'));
            
            if(string.isNotBlank(strConflicts)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'<table><tr><td><b>Conflicts:</b></td></tr></table><table><thead><tr><th><b>Record Id</b></th><th><b>Status</b></th><th><b>Owner</b></th></tr></thead><tbody>'+strConflicts+'</tbody></table>'));
            } 
            
            RMAConflicts = new map<string, string>();
            RMAConflicts = RMAImprovement_FindConflicts.findConflicts(lstComponents,caseId);
            showConflicts = false;
            if(RMAConflicts.size() > 0){
                showConflicts =true;
            }
            
            strSelectedTab = 'name2';
            
            return null;
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,ex.getMessage()));
            return null;
        }
    }

    public List<List<CustomClass>> listComponentItems()
    {
      try{
        // List Metadata items for the selected Metadata Type
        //MetaDataItems = new List<SelectOption>();
         List<List<CustomClass>> lstData = new List<List<CustomClass>>();
            List<CustomClass> customClassList = new List<CustomClass>();
        MetadataService.MetadataPort service = createService(objEn);
        IntMetaSet = new set<string>();
        for (Metadata_Component__c mc : [select id,Component_API_Name__c from Metadata_Component__c where Component_Type__c = : filteredCompType and  Integration_Flag__c=true]){
            IntMetaSet.add(mc.Component_API_Name__c);
        }

        if (filteredCompType == 'CustomField') {
            ///yet to code
            /*//Checking for namespace
    MetadataService.DescribeMetadataResult describeRes = service.describeMetadata(36);
    if(describeRes!=null){
        List<MetadataService.DescribeMetadataObject> objectList = describeRes.MetadataObjects;
        String namespace = describeRes.organizationNamespace;

        if(filteredCompType.contains('__c')) {
            if(namespace != null && namespace !='') {
                filteredCompType=namespace+'__'+filteredCompType;
            }
        }
    }*/

             /*

            list<string> objLst = new list<string>();
            objLst.add(compObjectName);

            MetadataService.IReadResult readResult = service.readMetadata('CustomObject', new String[] {compObjectName});
            system.debug('richard readResult:'+ readResult);
            MetadataService.Metadata[] mdInfo = readResult.getRecords();
            system.debug('richard mdInfo:'+ mdInfo);

            for (MetadataService.Metadata md : mdInfo) {
                MetadataService.CustomObject obj = (MetadataService.CustomObject) md;
                system.debug('richard obj:'+ obj);
                system.debug('richard obj.fields:'+ obj.fields);
                if(obj.fields != null) {
                    for(MetadataService.CustomField field : obj.fields) {
                        customClassList.add(new CustomClass(false,obj.fullname+'.'+field.fullName,obj.fullname+'.'+field.fullName,'','',filteredCompType,'','','','' ));
                    }

                    }
            }
            if(customClassList.size()>0)
            lstData.add(customClassList);
            lstData.sort();
            */  // rj Commented it

            map<Id,User> mapUsers = new map<Id,User>([select id, Name from User where License__c = 'Salesforce']);
            
            toolingAPI.QueryResult qr = toolingAPI.query('SELECT Id,  DeveloperName,  LastModifiedById, CreatedById, CreatedDate, LastModifiedDate, EntityDefinition.QualifiedApiName, TableEnumOrId FROM CustomField Where EntityDefinition.QualifiedApiName IN (\''+compObjectName +'\') Order By LastModifiedDate Desc');
              
            for(ToolingAPI.CustomField customField : (List<ToolingAPI.CustomField>)qr.records)
            {
                boolean fltrName ,fltrLastMBy ,fltrCreatedBY,fltrLtMDate, fltrCreateDate;
                fltrName =fltrLastMBy =fltrCreatedBY=fltrLtMDate= fltrCreateDate = false;

                string creator = '';
                string modifier = '';
                if(mapUsers.containsKey(customField.CreatedById)){
                    creator = mapUsers.get(customField.CreatedById).Name;
                }
                if(mapUsers.containsKey(customField.LastModifiedById)){
                    modifier = mapUsers.get(customField.LastModifiedById).Name;
                }

                if (string.isNotBlank(compName) && compName.startsWith('%') && customField.DeveloperName.containsIgnoreCase(compName.removeStart('%').trim())){
                    fltrName =true;
                }
                else if (string.isNotBlank(compName) && (customField.DeveloperName.startsWithIgnoreCase(compName))){
                    fltrName =true;
                }

                if (string.isNotBlank(CompLastMBy) &&string.isNotBlank(modifier) && modifier.containsIgnoreCase(CompLastMBy) ){
                    fltrLastMBy=true;
                }


                if (string.isNotBlank(CompCreatedBy) && string.isNotBlank(creator) && creator.containsIgnoreCase(CompCreatedBy) ){
                    fltrCreatedBY=true;
                }



                if (  objEn.Temp_Date__c!= null &&  customField.lastModifiedDate >= objEn.Temp_Date__c )
                    fltrLtMDate = true;

                if (  objEn1.Temp_Date__c!= null &&  customField.CreatedDate>= objEn1.Temp_Date__c )
                    fltrCreateDate = true;

                if (((string.isNotBlank(compName) && fltrName )|| string.isBlank(compName)) && ( string.isBlank(CompLastMBy) || ( string.isNotBlank(CompLastMBy) && fltrLastMBy)) && ((string.isNotBlank(CompCreatedBy) && fltrCreatedBY)||string.isBlank(CompCreatedBy) ) &&
                   (objEn.Temp_Date__c == null || (objEn.Temp_Date__c!= null && fltrLtMDate  )) && (objEn1.Temp_Date__c == null || (objEn1.Temp_Date__c!= null && fltrCreateDate   ))
                ){
                    customClassList.add(new CustomClass(false,compObjectName+'.'+customField.DeveloperName + '__c',compObjectName+'.'+customField.DeveloperName + '__c','','',filteredCompType,modifier,customField.lastModifiedDate.format('yyyy-MM-dd'),creator,customField.CreatedDate.format('yyyy-MM-dd'),IntMetaSet.contains(compObjectName+'.'+customField.DeveloperName + '__c')));
                }else if(string.isBlank(compName)  && objEn.Temp_Date__c== null && objEn1.Temp_Date__c == null && string.isBlank(CompCreatedBy) && string.isBlank(CompLastMBy) ){
                    customClassList.add(new CustomClass(false,compObjectName+'.'+customField.DeveloperName + '__c',compObjectName+'.'+customField.DeveloperName + '__c','','',filteredCompType,modifier,customField.lastModifiedDate.format('yyyy-MM-dd'),creator,customField.CreatedDate.format('yyyy-MM-dd'),IntMetaSet.contains(compObjectName+'.'+customField.DeveloperName + '__c')));
                }

            }
            if(customClassList.size()>0)
            {
                lstData.add(customClassList);
                lstData.sort();
            }

        }
        else{
        /*map<string,integer> mapFlows = new map<string,integer>();
          if(filteredCompType == 'Flow'){
              toolingAPI.QueryResult qr = toolingAPI.query('SELECT Id,  DeveloperName, MasterLabel, ActiveVersion.VersionNumber FROM FlowDefinition Order By LastModifiedDate Desc');
              system.debug('qr@@'+qr);

              for(ToolingAPI.FlowDefinition fl : (List<ToolingAPI.FlowDefinition>)qr.records)
              {
                  mapFlows.put(fl.DeveloperName,1);
                  if(fl.ActiveVersion!=null){
                      mapFlows.put(fl.DeveloperName,fl.ActiveVersion.VersionNumber);
                  }
              }
              system.debug('mapFlows@@'+mapFlows);
          }*/

        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        //if(MetaDataFolder!=null && MetaDataFolder.length()>0)
        if (filteredCompType == 'EmailTemplate' || filteredCompType == 'Report' || filteredCompType == 'Document')
          queryLayout.folder = (string.Isblank(compFolderName) ? 'unfiled$public' :compFolderName); // rj changes
          else
          queryLayout.folder=null;
        /*queryLayout.type_x = MetadataRetrieveController.filteredCompType ;
        queryLayout.type_x='ApexClass';*/
        queryLayout.type_x=filteredCompType;
        queries.add(queryLayout);
       //system.debug('Richard Test '+ MetadataRetrieveController.filteredCompType + '$$' +filteredCompType+'$$' +queries);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, METADATA_API_VERSION);
       system.debug('Richard fileProperties '+ fileProperties );
        // Sort
        List<String> fullNames = new List<String>();
       // List<List<CustomClass>> lstData = new List<List<CustomClass>>();
         //   List<CustomClass> customClassList = new List<CustomClass>();
            if(Test.isRunningTest()){
                fileProperties = new list<MetadataService.FileProperties>();
                MetadataService.FileProperties fp = new MetadataService.FileProperties();
                fp.createdById = Userinfo.getUserId();
                fp.createdByName = Userinfo.getName();
                fp.createdDate = system.now(); 
                fp.lastModifiedById = Userinfo.getUserId();
                fp.lastModifiedByName = Userinfo.getName();
                fp.lastModifiedDate = system.now();
                fp.fullName = 'Test';
                fileProperties.add(fp);
            }
        if(fileProperties!=null)
        {

          for(MetadataService.FileProperties fileProperty : fileProperties)
          {
          /*if(mapFlows.containsKey(fileProperty.fullName)){
                 fileProperty.fullName = fileProperty.fullName+'-'+mapFlows.get(fileProperty.fullName);
             }*/
            //fullNames.add(fileProperty.fullName);
            if (customClassList.size()< 999) {


            //system.debug('Richard Test2 '+ fileProperty);
            boolean fltrName ,fltrLastMBy ,fltrCreatedBY,fltrLtMDate, fltrCreateDate;
            fltrName =fltrLastMBy =fltrCreatedBY=fltrLtMDate= fltrCreateDate = false;

           if (string.isNotBlank(compName) && compName.startsWith('%') && fileProperty.fullName.containsIgnoreCase(compName.removeStart('%').trim())){
             fltrName =true;

            }
            else if (string.isNotBlank(compName) && (fileProperty.fullName.startsWithIgnoreCase(compName))){
            fltrName =true;
            }




            if (string.isNotBlank(CompLastMBy) &&string.isNotBlank(fileProperty.lastModifiedByName) && fileProperty.lastModifiedByName.containsIgnoreCase(CompLastMBy) ){
            fltrLastMBy=true;
            }


            if (string.isNotBlank(CompCreatedBy) && string.isNotBlank(fileProperty.createdByName) && fileProperty.createdByName.containsIgnoreCase(CompCreatedBy) ){
            fltrCreatedBY=true;

            }



            if (  objEn.Temp_Date__c!= null &&  fileProperty.lastModifiedDate >= objEn.Temp_Date__c )
            fltrLtMDate = true;

            if (  objEn1.Temp_Date__c!= null &&  fileProperty.CreatedDate>= objEn1.Temp_Date__c )
            fltrCreateDate = true;


            /*If (( string.isNotBlank(CompLastMBy) && fltrLastMBy))
            {
                system.debug('RIchard Test 3' +compName+ fltrName +CompLastMBy+ fltrLastMBy+ CompCreatedBy +fltrCreatedBY );
                system.debug('Richard Tets 4 ' + string.isNotBlank(compName) + fltrName + string.isNotBlank(CompLastMBy) + fltrLastMBy + string.isNotBlank(CompCreatedBy) + fltrCreatedBY );

             }*/

            if (((string.isNotBlank(compName) && fltrName )|| string.isBlank(compName)) && ( string.isBlank(CompLastMBy) || ( string.isNotBlank(CompLastMBy) && fltrLastMBy)) && ((string.isNotBlank(CompCreatedBy) && fltrCreatedBY)||string.isBlank(CompCreatedBy) ) &&
               (objEn.Temp_Date__c == null || (objEn.Temp_Date__c!= null && fltrLtMDate  )) && (objEn1.Temp_Date__c == null || (objEn1.Temp_Date__c!= null && fltrCreateDate   ))
            )
                customClassList.add(new CustomClass(false,fileProperty.fullName,fileProperty.fullName,'','',fileProperty.type_x,fileProperty.lastModifiedByName,fileProperty.lastModifiedDate.format('yyyy-MM-dd'),fileProperty.createdByName,fileProperty.CreatedDate.format('yyyy-MM-dd'),IntMetaSet.contains(fileProperty.fullName)));
            else if(string.isBlank(compName)  && string.isBlank(CompLastMDt) && string.isBlank(CompLastMBy) && string.isBlank(CompCreatedBy) && string.isBlank(CompLastMBy) )
                customClassList.add(new CustomClass(false,fileProperty.fullName,fileProperty.fullName,'','',fileProperty.type_x,fileProperty.lastModifiedByName,fileProperty.lastModifiedDate.format('yyyy-MM-dd'),fileProperty.createdByName,fileProperty.CreatedDate.format('yyyy-MM-dd'),IntMetaSet.contains(fileProperty.fullName)));

            //if ((compName!= null && compName.contains(fileProperty.fullName) )||(CompCreatedBy != null && CompCreatedBy .contains(fileProperty.createdByName) ))
            //customClassList.add(new CustomClass(false,fileProperty.fullName,'','','',fileProperty.type_x,fileProperty.lastModifiedByName,fileProperty.lastModifiedDate.format('yyyy-MM-dd'),fileProperty.createdByName,fileProperty.CreatedDate.format('yyyy-MM-dd')));
                }

            }
            if(customClassList.size()>0)
            lstData.add(customClassList);
            lstData.sort();
          //fullNames.sort();
          //for(String fullName : fullNames)
            //MetaDataItems.add(new SelectOption(fullName,EncodingUtil.urlDecode(fullName, 'UTF-8')));
        }
        }



        return lstData;
         }Catch(Exception e){
         }
        return null;
    }


  public PageReference retriveObjectList(){

    if (filteredCompType == 'CustomField') {
        // List Metadata items for the selected Metadata Type
        //MetaDataItems = new List<SelectOption>();
        MetadataService.MetadataPort service = createService(objEn);
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        //if(MetaDataFolder!=null && MetaDataFolder.length()>0)
          queryLayout.folder = 'unfiled$public';
        /*queryLayout.type_x = MetadataRetrieveController.filteredCompType ;
        queryLayout.type_x='ApexClass';*/
        queryLayout.type_x='CustomObject';
        queries.add(queryLayout);

        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, METADATA_API_VERSION);

        // Sort
        List<String> fullNames = new List<String>();
       objSelectionList = new List<SelectOption>();
        if(fileProperties!=null)
        {

          for(MetadataService.FileProperties fileProperty : fileProperties)
          {
            //fullNames.add(fileProperty.fullName);
            if (objSelectionList.size()< 999) {
                objSelectionList.add(new SelectOption(fileProperty.fullName,fileProperty.fullName));
            }
          }
        }

        objSelectionList.sort();
    }
        return null;
    }


    private PageReference MetadataTypeListRet()
    {
      try{
        // List available Metadata Types via the 'describeMetadata' API call
        MetadataService.MetadataPort service = createService( objEn);
        MetadataService.DescribeMetadataResult describeResult = service.describeMetadata(METADATA_API_VERSION);
        List<String> metadataTypeNames = new List<String>();
        for(MetadataService.DescribeMetadataObject metadataObject : describeResult.metadataObjects)
        {
            metadataTypeNames.add(metadataObject.xmlName);
            // Include child Metadata Types (such as CustomField, ValidationRule etc..)
            if(metadataObject.childXmlNames!=null)
                for(String childXmlName : metadataObject.childXmlNames)
                    if(childXmlName!=null)
                        metadataTypeNames.add(childXmlName);
        }

        // Sort Metadata Types
        metadataTypeNames.sort();
        MetaDataTypes = new List<SelectOption>();
        for(String metadataTypeName : metadataTypeNames)
            MetaDataTypes.add(new SelectOption(metadataTypeName, metadataTypeName));

         //Adding CPQ Component Type.
         //MetaDataTypes.add(new SelectOption('CPQComponent' ,'CPQComponent'));//Commented as this will move to CPQ components

        // Default to first Metadata Type returned
        filteredCompType = MetaDataTypes[2].getValue();
        // Retrieve Metadata items for the selected Metadata Type
          }Catch(Exception e){
         }
        return Null;
    }

    public static MetadataService.MetadataPort createService(Salesforce_Environment__c objEn)
    {

      try{
        system.debug('Richard objEn'+ objEn);
        string endpoint,UserNameString, PwdStr = null;
         Salesforce_Environment__c sfdcEnVRec = new Salesforce_Environment__c();
      if (objEn!= null && objEn.Salesforce_Environment__c != null)
              sfdcEnVRec=[Select Login_URL__c,Password__c ,Username__c,ID from Salesforce_Environment__c where ID= :objEn.Salesforce_Environment__c ];


        HttpRequest request = new HttpRequest();
        If (sfdcEnVRec!= null && sfdcEnVRec.Login_URL__c != null)
        request.setEndpoint(sfdcEnVRec.Login_URL__c+'/services/Soap/u/'+Label.RMA_Dynamic_API_Version);

        else
        request.setEndpoint('https://test.salesforce.com/services/Soap/u/'+Label.RMA_Dynamic_API_Version);

        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        //not escaping username and password because we're setting those variables above
        //in other words, this line "trusts" the lines above
        //if username and password were sourced elsewhere, they'd need to be escaped below
           If (sfdcEnVRec!= null && sfdcEnVRec.Username__c != null &&  sfdcEnVRec.Password__c != null)
           {
        UserNameString=sfdcEnVRec.Username__c;
          PwdStr=sfdcEnVRec.Password__c;
          }
        //request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + 'bfs.api.user2@experian.global.baudev18'+ '</username><password>' + 'Experian@2018'+ '</password></login></Body></Envelope>');
        system.debug('UserNameString' + UserNameString);
        request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + UserNameString+ '</username><password>' + PwdStr+ '</password></login></Body></Envelope>');
        Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement()
          .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
          .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
          .getChildElement('result', 'urn:partner.soap.sforce.com');

        //-------------------------------
        // Grab session id and server url
        //--------------------------------
        final String SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com') .getText().split('/services')[0];
        final String SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com') .getText();

        system.debug('Richard Test '+ SERVER_URL  + SESSION_ID  );


        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.endpoint_x= SERVER_URL  +'/services/Soap/m/'+Label.RMA_Dynamic_API_Version;
        ToolingAPI.baseURL=SERVER_URL;
        service.SessionHeader = new MetadataService.SessionHeader_element();
        //service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.SessionHeader.sessionId = SESSION_ID;
        toolingAPI.extSessionId=SESSION_ID;
        return service;
         }Catch(Exception e){
         }
          return null;
    }
    Public class authenticationProcess {
        Public string access_token;
        Public string token_type;
        Public string expires_in;
        Public string scope;
        Public string instance_URL;
    }
}