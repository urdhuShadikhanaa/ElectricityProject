public with sharing class NGMCP_UserManagementFlowJsonParser {

    @InvocableMethod

     public static void parse(List<NGMCPUserFlowRequest> requests) {
       for (NGMCPUserFlowRequest r : requests) {
           r.users = (List<NGMCPFlowUserPayload>)
               JSON.deserialize(r.payloadJson, List<NGMCPFlowUserPayload>.class);
       }
   }

}