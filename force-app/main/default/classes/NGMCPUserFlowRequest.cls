public class NGMCPUserFlowRequest {
    @InvocableVariable(required=true)
   public String payloadJson;
   @InvocableVariable
   public List<NGMCPFlowUserPayload> users;
}