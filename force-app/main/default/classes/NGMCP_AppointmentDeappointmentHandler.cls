public with sharing class NGMCP_AppointmentDeappointmentHandler {
    
    @AuraEnabled
    /**
     * Submit a Appointment/Deappointment (Service Request create) to Maximo.
     * Writes back the SR ticket id and full response to NGMCP_Request__c for auditability.
     *
     * Performance:
     * - Captures duration for troubleshooting downstream latency.
     *
     * @param requestBody JSON body defining the SR payload.
     * @param requestId   NGMCP_Request__c Id to store status/response/ticket id.
     * @return Raw response body string on success.
     * @throws AuraHandledException on non-2xx responses.
     */
    public static Object  submitAppntDeappnt(String requestBody, Id requestId) {
        String relativePath;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        if (!String.isEmpty(requestBody)) {
            relativePath = '/NGME_LIRY_APPT_DAPPT?relativeuri=1&lean=1&ignorekeyref=1&ignorecollectionref=1';
            
        }
        request.setEndpoint('callout:NGMCP_Maximo_Named_Credential' + relativePath);
        request.setMethod('POST');
        request.setHeader('properties', 'ngme_headerid, ticketid, ticketuid');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        // Start time
        Long startTime = System.currentTimeMillis();
        
        HttpResponse response = http.send(request);
        
        Long endTime = System.currentTimeMillis();
        Long duration = endTime - startTime;
        
        // 200/201 treated as success for create
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            //Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            List<NGMCP_Request__c> updateRequest =[
                SELECT Id, NGMCP_Callout_Status__c, NGMCP_Callout_Response__c, NGMCP_SR_Ticket__c, NGMCP_Header_Id__c
                FROM NGMCP_Request__c
                WHERE Id = :requestId AND NGMCP_Callout_Status__c = 'In Progress'
                with user_mode
                LIMIT 1
            ];
            // Update request tracking record if still in-progress
            if (!updateRequest.isEmpty()) {
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Status__c.isUpdateable()){
                	updateRequest[0].NGMCP_Callout_Status__c = 'Completed';
                }
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Response__c.isUpdateable()){
                	updateRequest[0].NGMCP_Callout_Response__c = response.getBody();
                }
                //updateRequest[0].NGMCP_Header_Id__c = String.valueOf(result.get('ngme_headerid'));
                if(Schema.sObjectType.NGMCP_Request__c.isUpdateable()){
                	update updateRequest;
                }
            }
            return response.getBody();
        } else {
            
            // Surface a user-friendly exception to Lightning consumers
            throw new AuraHandledException('Failed to create appointment/de-appointment. Status: ' + response.getBody());
        }
        
    }

    /**
     * @method createDataQueryRecord
     * @description Creates a new Data Query record in Salesforce.
     * @param requestBody - JSON string containing data query details.
     * @return Id - The Id of the newly created NGMCP_Request__c record.
     */

         @AuraEnabled
        public static Id  createAppntDeappntRecord(String requestBody) {
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            
            //List<NGMCP_Request__c>
            List<NGMCP_Request__c> requestObjList = new List<NGMCP_Request__c>();
            String result;
            Id recordTypeId = Schema.SObjectType.NGMCP_Request__C.RecordTypeInfosByName.get('Appointment/Deappointment').RecordTypeId;
            if (!payload.isEmpty()) {                
                NGMCP_Request__c requestObj = new NGMCP_Request__c();
                if(Schema.sObjectType.NGMCP_Request__c.fields.RecordTypeId.isCreateable()){
        			requestObj.RecordTypeId = recordTypeId;
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_File_Type__c.isCreateable()){
        			requestObj.NGMCP_File_Type__c = (String) payload.get('ngme_file_type');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Creation_Date__c.isCreateable()){
        			requestObj.NGMCP_Creation_Date__c = (String) payload.get('ngme_creation_date');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Supplier_Id__c.isCreateable()){
        			requestObj.NGMCP_Supplier_Id__c = (String) payload.get('ngme_originator_id');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Recipient_Role__c.isCreateable()){
        			requestObj.NGMCP_Recipient_Role__c = (String) payload.get('ngme_recipient_role');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Status__c.isCreateable()){
        			requestObj.NGMCP_Status__c = (String) payload.get('ngme_status');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Transaction_Count__c.isCreateable()){
        			requestObj.NGMCP_Transaction_Count__c = payload.get('ngme_transaction_count').toString();
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Integration_Type__c.isCreateable()){
        			requestObj.NGMCP_Integration_Type__c = (String) payload.get('ngme_integration_type');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Creation_Time__c.isCreateable()){
        			requestObj.NGMCP_Creation_Time__c = (String) payload.get('ngme_creation_time');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Request_Date__c.isCreateable()){
        			requestObj.NGMCP_Request_Date__c = (String) payload.get('ngme_reqrecdate');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Record_Count__c.isCreateable()){
        			requestObj.NGMCP_Record_Count__c = payload.get('ngme_record_count').toString();
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Record_Identifier__c.isCreateable()){
        			requestObj.NGMCP_Record_Identifier__c = (String) payload.get('ngme_record_identifier');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Recipient_Id__c.isCreateable()){
        			requestObj.NGMCP_Recipient_Id__c = (String) payload.get('ngme_recipient_id');
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_File_Identifier__c.isCreateable()){
        			 requestObj.NGMCP_File_Identifier__c = (String) payload.get('ngme_file_identifier');
        		}
               
                Map<String, Object> trans = (Map<String, Object>) payload.get('ngme_trans');
                
                if(!trans.isEmpty()){
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Reason_Code__c.isCreateable()){
        				requestObj.NGMCP_Reason_Code__c = (String) trans.get('ngme_reason_code');
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_MPRN__c.isCreateable()){
        				requestObj.NGMCP_MPRN__c = (String) trans.get('ngme_reference');
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Type_Code__c.isCreateable()){
        				requestObj.NGMCP_Type_Code__c = (String) trans.get('ngme_type_code');
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Market_Sector_Code__c.isCreateable()){
        				requestObj.NGMCP_Market_Sector_Code__c = (String) trans.get('ngme_sector_code');
        			}
                    
                    //requestObj.NGMCP_Target_Start__c = (String) trans.get('ngme_record_identifier');
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Contract_Reference__c.isCreateable()){
        				requestObj.NGMCP_Contract_Reference__c = (String) trans.get('ngme_contract_ref');
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_From_Date__c.isCreateable()){
        				requestObj.NGMCP_From_Date__c = trans.get('ngme_from_date') != null ? (String) trans.get('ngme_from_date') : '';
        			}
                    if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_To_Date__c.isCreateable()){
        				requestObj.NGMCP_To_Date__c = trans.get('ngme_to_date') != null ? (String) trans.get('ngme_to_date') : '';
        			}
                    
                    Map<String, Object> mtpnt = (Map<String, Object>) trans.get('ngme_mtpnt');
                    if(!mtpnt.isEmpty() && mtpnt.get('ngme_addrs') != null){
                        System.debug('Inside mtpnt');
                        Map<String, Object> addrs = (Map<String, Object>) mtpnt.get('ngme_addrs');
                        if(!addrs.isEmpty()){
                            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Building_Number__c.isCreateable()){
        						requestObj.NGMCP_Building_Number__c = (String) addrs.get('ngme_building_no');
        					}
                            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Dependent_Locality__c.isCreateable()){
        						requestObj.NGMCP_Dependent_Locality__c = (String) addrs.get('ngme_dependent_locality');
        					}
                            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Postal_Town__c.isCreateable()){
        						requestObj.NGMCP_Postal_Town__c = (String) addrs.get('ngme_post_town');
        					}
                            if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Postal_Code__c.isCreateable()){
        						requestObj.NGMCP_Postal_Code__c = (String) addrs.get('ngme_post_code');
        					}
                            
                            
                        }
                    }
                }
                /*requestObj.NGMCP_Description_Long_Description__c = (String) payload.get('description_longdescription');
                requestObj.NGMCP_Engineer_Visit__c = (String) payload.get('ngme_engvisit');
                requestObj.NGMCP_Target_Start__c = (String) payload.get('targetstart');
                requestObj.NGMCP_Postal_Code__c = (String) payload.get('postcode');
                requestObj.NGMCP_Time__c = (String) payload.get('ngme_time');
                requestObj.NGMCP_Affectedphone__c = (String) payload.get('ngme_consphone');
                requestObj.NGMCP_Dependent_Locality__c = (String) payload.get('deplocal');
                requestObj.NGMCP_Above_Threshold__c = (String) payload.get('ngme_threshold');
                requestObj.NGMCP_MPRN__c = (String) payload.get('location');
                requestObj.NGMCP_Reported_Email__c = (String) payload.get('reportedemail');
                requestObj.NGMCP_Enquiry_Type__c = (String) payload.get('category');
                requestObj.NGMCP_Enquiry_Reason_Code__c = (String) payload.get('subcategory');*/
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_Callout_Status__c.isCreateable()){
        			requestObj.NGMCP_Callout_Status__c = 'In Progress';
        		}
                if(Schema.sObjectType.NGMCP_Request__c.fields.NGMCP_API_Callout__c.isCreateable()){
        			requestObj.NGMCP_API_Callout__c = 'Create Appointment/De-appointment callout';
        		}
                
                requestObjList.add(requestObj);
                
            }
            if (!requestObjList.isEmpty() && Schema.sObjectType.NGMCP_Request__c.isCreateable()) {
                insert requestObjList;
            }
            return requestObjList[0].Id;
        }

        /**
     * @method getSupplierInfo
     * @description Fetch supplier information from NGMCP_Supplier_Information__mdt
     * @return NGMCP_Supplier_Information__mdt - Supplier's contract information
     */
    
    @AuraEnabled
    public static NGMCP_Supplier_Information__mdt getSupplierInfo(String customer) {
       List<NGMCP_Supplier_Information__mdt> supplierList = [SELECT DeveloperName, MasterLabel, 
        NGMCP_Rental_Contract__c, NGMCP_Works_Contract__c, NGMCP_AMR_Contract__c	
        FROM NGMCP_Supplier_Information__mdt
        WHERE MasterLabel  = :customer 
        with user_mode                                                     
        LIMIT 1]; 
       
        if(!supplierList.isEmpty()){
            return supplierList[0];
        }
        else{
            return null;
        }
    
    }
}