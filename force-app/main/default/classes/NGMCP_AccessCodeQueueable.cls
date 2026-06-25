public with sharing class NGMCP_AccessCodeQueueable implements Queueable, Database.AllowsCallouts{


    // If using Named Credential with Basic auth (recommended), keep client creds out of the body.
    private static final String TOKEN_ENDPOINT = 'callout:NGMCP_Mulesoft_Integration/b5d83618-97ea-48ec-b0be-8d4a7d678322/oauth2/token';

    // Optional scope
    private static final String DEFAULT_SCOPE = 'https://graph.microsoft.com/.default'; //null; // e.g., 'openid profile'

    // If your provider requires client_id/client_secret in the body, set this true and fill values.
    private static final Boolean SEND_CLIENT_IN_BODY = true;
    private static final String CLIENT_ID  =  System.Label.NGMCP_Mulesoft_Access_Code_Username; //''; // Only used if SEND_CLIENT_IN_BODY = true
    private static final String CLIENT_SECRET = System.Label.NGMCP_Mulesoft_Access_Code_Password; //'';

    // How long before actual expiry we consider the token "stale"
    private static final Integer REFRESH_BUFFER_SECONDS = 60;
    // If token is valid for > this many minutes, we skip calling the endpoint
    private static final Integer SKIP_IF_VALID_FOR_MINUTES = 5;

    public void execute(QueueableContext qc) {



        // 1) If an org-level token exists and still valid for >5 min, skip
        /*NGMCP_Mulesoft_Access_Code__c cur = getMAC();
        if (cur != null && cur.NGMCP_Expires_At__c != null && cur.NGMCP_Expires_At__c > System.now().addMinutes(SKIP_IF_VALID_FOR_MINUTES)) {
            System.debug('Access token still valid — skipping refresh.');
            return;
        }*/

        // 2) Build x-www-form-urlencoded body
        Map<String,String> form = new Map<String,String>{
            'grant_type' => 'client_credentials'
        };
        if (DEFAULT_SCOPE != null) form.put('scope', DEFAULT_SCOPE);

        if (SEND_CLIENT_IN_BODY) {
            if (String.isBlank(CLIENT_ID) || String.isBlank(CLIENT_SECRET)) {
                throw new NGMCP_MulesoftIntegrationController.CalloutException('CLIENT_ID/CLIENT_SECRET must be configured when SEND_CLIENT_IN_BODY = true.');
            }
            form.put('client_id', CLIENT_ID);
            form.put('client_secret', CLIENT_SECRET);
        }
        //form.put('x-transaction-id', 'fghjh');
        
        // 3) Call the token endpoint
        String raw = NGMCP_MulesoftIntegrationController.postFormUrlEncoded(TOKEN_ENDPOINT, form, /*headers*/ null);
        
        // 4) Parse JSON response
        Map<String,Object> json = (Map<String,Object>) JSON.deserializeUntyped(raw);
        
        String accessToken = (String) json.get('access_token');
        String tokenType   = (String) json.get('token_type');

        // expires_in can be Integer, Long, or String depending on API
        Integer expiresIn = 3600; // default 1h
        Object exp = json.get('expires_in');
        if (exp != null) {
            if (exp instanceof Integer){
                expiresIn = (Integer) exp;
            }     
            else if (exp instanceof Long){
                expiresIn = Integer.valueOf(String.valueOf(exp));
            }    
            else{
                expiresIn = Integer.valueOf(String.valueOf(exp));
            }                              
        }

        
    // 5) Compute expiry with a small safety buffer
        Integer buffered = Math.max(REFRESH_BUFFER_SECONDS, expiresIn - REFRESH_BUFFER_SECONDS);
        DateTime expiresAt = System.now().addSeconds(buffered);

        // 6) Save to Hierarchy Custom Setting
        if (String.isBlank(accessToken)) {
            throw new NGMCP_MulesoftIntegrationController.CalloutException('Token endpoint did not return access_token. Body: ' + raw);
        }
        NGMCP_MulesoftIntegrationController.upsertMAC(accessToken, tokenType, expiresAt, raw);
        System.debug('Access token refreshed. Expires at (buffered): ' + expiresAt);

    }



}