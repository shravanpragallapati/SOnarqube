/**

 Load Test Data: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_load_data.htm
 Mock HTTP Resp: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_restful_http_testing_httpcalloutmock.htm

 */

@isTest 
public class SFDCtoCPQProductIntegration_Test {

  @TestSetup
  static void setup(){
      CPQ_Settings__c cs = new CPQ_Settings__c();
      cs.Name = 'CPQ';
      cs.CPQ_API_UserName__c = 'test#test';
      cs.CPQ_API_Access_Word__c = 'test';
      cs.CPQ_API_Endpoint__c = 'test';
      cs.CPQ_API_Host__c = 'test';
      cs.Integration_Batchable_Time_Wait__c = 0;
      insert cs;

      // User testUser1 = Test_Utils.createUser(Constants.PROFILE_SYS_ADMIN);
      // insert testUser1;

      // IsDataAdmin__c ida = new IsDataAdmin__c();
      // ida.SetupOwnerId = testUser1.Id;
      // ida.IsDataAdmin__c = true;
      // insert ida;

    // System.runAs(testUser1) {

      ProductMasterTriggerHandler.aSyncRRecursiveRUN = true;
      Product_Master__c pm1 = Test_Utils.createProductMaster(false);
      pm1.Product_life_cycle__c = 'Development';
      pm1.Product_Name__c = 'test1';
      pm1.Product_description__c = 'test1';
      pm1.DRMID__c = 'test1';
      pm1.Segment_Global_Line__c = 'Experian Data Quality';
      insert pm1;

      CPQProductTriggerHandler.recursiveStop = true;
      CPQ_Product__c cParent = new CPQ_Product__c();
      cParent.System_Id__c = 'testParent';
      cParent.Architecture_Type__c = 'ALS'; // MAKING cParent an alias to copy from alias change 2020-09-15
      cParent.Region__c = 'North America';
      cParent.Active__c = true;
      cParent.External_Id__c = 'testParent';
      insert cParent;
      CPQProductTriggerHandler.recursiveStop = false;

      List<CPQ_Product__c> lcp = new List<CPQ_Product__c>();

      CPQ_Product__c c0 = new CPQ_Product__c(); // this is a new product, there's no record in support data
      c0.System_Id__c = 'test0';
      c0.External_Id__c = 'test0';
      c0.Architecture_Type__c = 'PRD';
      c0.Region__c = 'North America';
      c0.Active__c = true;
      c0.Product_Master__c = pm1.Id;
      lcp.add(c0);

      CPQ_Product__c c1 = new CPQ_Product__c();
      c1.System_Id__c = 'test1';
      c1.External_Id__c = 'test1';
      c1.Architecture_Type__c = 'PRD';
      c1.Region__c = 'North America';
      c1.Active__c = true;
      lcp.add(c1);

      CPQ_Product__c c2 = new CPQ_Product__c();
      c2.System_Id__c = 'test2';
      c2.External_Id__c = 'test2';
      c2.Architecture_Type__c = 'ALS';
      c2.Region__c = 'North America';
      c2.Active__c = true;
      c2.Parent_Template__c = cParent.Id;
      lcp.add(c2);

      CPQ_Product__c c3 = new CPQ_Product__c();
      c3.System_Id__c = 'test4';
      c3.External_Id__c = 'test4';
      c3.Architecture_Type__c = 'ALS';
      c3.Region__c = 'North America';
      c3.Active__c = true;
      c3.Parent_Template__c = cParent.Id;
      lcp.add(c3);

      insert lcp;
      System.debug('TEST:: Inserted from list: ' + JSON.serialize(lcp));
    // }
  }

  @isTest
  public static void run(){
    // User testUser1 = [SELECT Id FROM User LIMIT 1];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new SFDCtoCPQProductIntegration_Test.MockHttpResponseGenerator());
    // System.runAs(testUser1) {

      SFDCtoCPQProductIntegration cpBatch = new SFDCtoCPQProductIntegration([
        SELECT System_Id__c, External_Id__c, Architecture_Type__c, Region__c, Active__c,Start_Date__c,End_Date__c, Integration_Feedback__c,
        Product_Master__r.Segment_Global_Line__c, Product_Master__r.DRMID__c,
        Product_Master__r.Product_Name__c, Product_Master__r.Product_description__c,
        Parent_Template__r.System_Id__c
        FROM CPQ_Product__c
      ]);
      Database.executeBatch(cpBatch);

    // }
    Test.stopTest();
  }

  public class MockHttpResponseGenerator implements HttpCalloutMock {
      private Map<String,String> getRespMap = new Map<String,String> {
        'https://test/basic/api/token' => '{"access_token": "testToken","token_type": "bearer","expires_in": 86399}',
        'https://test/setup/api/v1/admin/products' => '{"pagedRecords":[{"id":1,"name":"test1","category":"test1","permissions":"test1","systemId":"test1","isProductAlias":false},{"id":2,"name":"test2","category":"test2","permissions":"test2","systemId":"test2","isProductAlias":true,"aliasParentProductId":1},{"id":3,"name":"test3","category":"test3","permissions":"test3","systemId":"test3","isProductAlias":true,"aliasParentProductId":1}],"totalNumberOfRecords":3}',
        'https://test/setup/api/v1/admin/products/1' => '{"id":1,"systemId":"test1","name":"test1","active":true,"permissionStartDate":"","permissionEndDate":"","externalId":"test1","descriptionLong":"test1"}',
        'https://test/setup/api/v1/admin/products/1/aliases/2' => '{"id":2,"alias":{"id":2,"systemId":"test2","name":"test2","active":true,"permissionStartDate":"","permissionEndDate":"","externalId":"test2","descriptionLong":"test2"},"productId":1,"productName":"test1"}'
      };
      private Map<String,String> postRespMap = new Map<String,String> {
        'https://test/setup/api/v1/admin/products/1' => '{"id": 4,"modifiedBy": "SDFC API","modifiedDate": "2020-07-02 5:10:45 PM"}',
        'https://test/setup/api/v1/admin/products/aliases' => '3'
      };
      // Implement this interface method
      public HTTPResponse respond(HTTPRequest req) {
          System.debug('TEST: endpoint: ' + req.getEndpoint() + '; method: ' + req.getMethod());

          // Create a fake response
          HttpResponse res = new HttpResponse();
          res.setHeader('Content-Type', 'application/json');
          
          if(req.getMethod() == 'GET'){
            if(getRespMap.containsKey(req.getEndpoint())){
              res.setBody(getRespMap.get(req.getEndpoint()));
            } else {
              res.setBody('{"example":"test get"}');
            }
          } else if (req.getMethod() == 'POST') {
            if(postRespMap.containsKey(req.getEndpoint())){
              res.setBody(postRespMap.get(req.getEndpoint()));
            } else {
              res.setBody('{"example":"test post"}');
            }
          }
          
          res.setStatusCode(200);
          return res;
      }
  }
}