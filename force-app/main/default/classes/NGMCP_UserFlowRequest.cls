public class NGMCP_UserFlowRequest {
   @InvocableVariable(required=true)
   public String payloadJson;
   @InvocableVariable
   public List<NGMCPFlowUserPayload> users;
}