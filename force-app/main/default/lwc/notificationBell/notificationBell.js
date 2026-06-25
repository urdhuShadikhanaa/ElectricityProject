// import { LightningElement, track, wire } from 'lwc';
// import getNotifications from '@salesforce/apex/NGMCP_NotificationController.getNotifications';
// import markRead from '@salesforce/apex/NGMCP_NotificationController.markRead';
// import BELL_ICON from '@salesforce/resourceUrl/NGMCP_bellIcon';

// export default class NotificationBell extends LightningElement {
//     @track notifications = [];
//     @track unreadCount = 0;
//     @track showPopup = false;
//     bellIcon = BELL_ICON;
//     @wire(getNotifications)
//     wiredNotifications({ data, error }) {
//         if (data) {
//             this.notifications = data.map(n => ({
//                 ...n,
//                 appointmentUrl: `/s/appointment/${n.NGMCP_Service_Appointment_Id__c}`
//             }));

//             this.unreadCount = data.filter(n => !n.Is_Read__c).length;
//         }

//         if (error) {
//             console.error('Error getting notifications:', error);
//         }
//     }
//     togglePopup() {
//         this.showPopup = !this.showPopup;

//         if (this.showPopup && this.unreadCount > 0) {
//             markRead()
//                 .then(() => {
//                     this.unreadCount = 0;
//                 })
//                 .catch(err => console.error('Error marking read', err));
//         }
//     }
// }

import { LightningElement, track, wire } from 'lwc';
import getUnreadNotifications from '@salesforce/apex/NGMCPNotificationController.getUnreadNotifications';
import markAsRead from '@salesforce/apex/NGMCPNotificationController.markAsRead';
import BELL_ICON from '@salesforce/resourceUrl/NGMCP_bellIcon';
import { subscribe, unsubscribe, onError, setDebugFlag } from 'lightning/empApi';

export default class NotificationBell extends LightningElement {

    @track notifications = [];
    @track unreadCount = 0;
    @track showPopup = false;

    bellIconUrl = BELL_ICON;

    // EMP API
    subscription = {};
    channelName = '/event/NGMCP_Notification_Event__e';

    connectedCallback() {
        console.log('Connected Callback Invoked ..');
        this.loadNotifications();
        this.registerErrorListener();
        this.registerPushTopic();
    }

    disconnectedCallback() {
        // Unsubscribe when component is removed
        unsubscribe(this.subscription, response => {
            console.log('Unsubscribed from channel', response);
        });
    }

    loadNotifications() {
         console.log('Notification  Invoked ..');
        getUnreadNotifications()
            .then(data => {
                 console.log('data for notfications..', JSON.stringify(data));
                this.notifications = data.map(n => ({
                    ...n,
                    appointmentUrl: n.NGMCP_Request__c ? `/customerportal/s/request/${n.NGMCP_Request__c}` : null
                }));
                this.unreadCount = data.length;
            })
            .catch(err => console.error('Error loading notifications', err));
    }

    togglePopup() {
        this.showPopup = !this.showPopup;

        if (this.showPopup && this.unreadCount > 0) {
            const ids = this.notifications.map(n => n.Id);
            markAsRead({ notificationIds: ids }).then(() => this.unreadCount = 0)
                      .catch(err => console.error(err));
        }
    }

    registerPushTopic() {
            console.log('registerPushTopic invoked');
        const messageCallback = (response) => {
            console.log('New notification event received', response);
            this.loadNotifications();
        };

        subscribe(this.channelName, -1, messageCallback)
            .then(response => {
                console.log('Subscribed to channel: ', response.channel);
                this.subscription = response;
            });
    }

    registerErrorListener() {
         console.log('registerErrorListener  Invoked ..');
        onError(error => {
            console.error('EMP API error', error);
        });
    }
}