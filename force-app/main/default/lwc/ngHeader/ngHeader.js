/**
 * @description       : DXP-9641 "NG Component: Header"
 * @author            : Vivek Kumar
 * @last modified on  : 26-05-2025
 * Modifications Log
 * Ver    Date        Author        Modification
 * 1.0    26-05-2025  Vivek Kumar   Initial Version
**/
import { LightningElement, wire } from 'lwc';
import companyLogo from '@salesforce/resourceUrl/ngLogo';
import searchIcon from '@salesforce/resourceUrl/notificationIcon';
import getCurrentUser from '@salesforce/apex/ngCaseAppointmentsController.getCurrentUser';


export default class NgHeader extends LightningElement {
     companyLogo = companyLogo;
     searchIcon = searchIcon;
     userName;
        
     @wire(getCurrentUser)
     wiredUser({ error, data }) {
          if (data) {
               this.userName = data.Name;
          } else if (error) {
               console.error('Error fetching user name', error);
          }
     }
    
   
}