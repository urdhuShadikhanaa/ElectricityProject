import { LightningElement, track, wire } from 'lwc';
import bellIconResource from '@salesforce/resourceUrl/NGMCP_bellIcon';
import { loadScript } from 'lightning/platformResourceLoader';
import CometD from '@salesforce/resourceUrl/NGMCP_CometD';
import USER_ID from '@salesforce/user/Id';

import fetchSessionId from
    '@salesforce/apex/NGMCP_ServiceAppointmentTriggerHelper.fetchSessionId';

import getUnreadNotifications from
    '@salesforce/apex/NGMCPNotificationController.getUnreadNotifications';
import markAsRead from
    '@salesforce/apex/NGMCPNotificationController.markAsRead';
import createNotificationFromEvent from '@salesforce/apex/NGMCPNotificationController.createNotificationFromEvent';

export default class NgmcpNotifications extends LightningElement {

    bellIcon = bellIconResource;
    currentUserId = USER_ID;
    @track notifications = [];
    notificationMap = new Map();

    openPanel = false;

    showFloatingMessage = false;
    lastMessage = '';
    floatingTimer;

    sessionId;

    /* ================= INIT ================= */
    connectedCallback() {
       
        setTimeout(() => {
    this.loadServerNotifications();
}, 1500); 
        this._outsideClickHandler = this.handleOutsideClick.bind(this);
    }

    disconnectedCallback() {
        document.removeEventListener('click', this._outsideClickHandler);
    }


loadServerNotifications() {
    getUnreadNotifications()
        .then(result => {
        

            const serverIds = new Set();

            result.forEach(n => {
                serverIds.add(n.Id);

                this.notificationMap.set(n.Id, {
                    id: n.Id,
                    text: n.Message__c,
                    createdDate: this.timeAgo(n.CreatedDate),
                    fullDate: n.CreatedDate,
                    isServer: true,
                    pending: false
                });
            });

            // Optional: clean up stale pending notifications
            [...this.notificationMap.entries()].forEach(([key, notif]) => {
                if (notif.pending && !serverIds.has(key)) {
                    this.notificationMap.delete(key);
                }
            });

            this.syncNotifications();
        })
        .catch(error => {
            
        });
}





    /* ================= COMETD ================= */
    @wire(fetchSessionId)
    wiredSession({ data }) {
        if (!data) return;

        this.sessionId = data;
       
        loadScript(this, CometD).then(() => {
            const cometd = new window.org.cometd.CometD();

            cometd.configure({
                url: `${location.protocol}//${location.hostname}/cometd/58.0/`,
                requestHeaders: { Authorization: 'OAuth ' + this.sessionId },
                appendMessageTypeToURL: false
            });

            cometd.websocketEnabled = false;

            cometd.handshake(hs => {
                if (hs.successful) {
                    cometd.subscribe(
                        '/event/NGMCP_Notification_Event__e',
                        m => this.addNotification(m),
                        { ext: { replay: { '/event/NGMCP_Notification_Event__e': -1 } } }
                    );
                }
            });
        });
    }

    /* ================= REALTIME ================= */
addNotification(message) {
    const payload = message.data.payload;
    const replayId = message.data.event.replayId;    
     if (payload.NGMCP_User_Id__c !== this.currentUserId) {
        return;
    }
    // Floating popup (unchanged)
    this.lastMessage = payload.NGMCP_Message__c;
    this.showFloatingMessage = true;
   
    clearTimeout(this.floatingTimer);
    this.floatingTimer = setTimeout(() => {
        this.showFloatingMessage = false;
    }, 10000);

    const tempId = 'TEMP_' + replayId;

    this.notificationMap.set(tempId, {
        id: tempId,
        text: payload.NGMCP_Message__c,
        createdDate: 'Just now',
        fullDate: new Date().toISOString(),
        isServer: false,
        pending: true 
    });

    this.syncNotifications();

    createNotificationFromEvent({
    message: payload.NGMCP_Message__c,
    replayId: replayId,
    targetUserId: payload.NGMCP_User_Id__c
})
.then(serverId => {
   

    if (!serverId) {
        return;
    }

    const tempId = 'TEMP_' + replayId;

    //  Replace TEMP notification with SERVER notification
    if (this.notificationMap.has(tempId)) {
        const tempNotif = this.notificationMap.get(tempId);

        this.notificationMap.delete(tempId);
        this.notificationMap.set(serverId, {
            ...tempNotif,
            id: serverId,
            isServer: true
        });

        this.syncNotifications();
    }
})
.catch(error => {
   
});

}




    /* ================= UI ================= */
    togglePanel() {
        this.openPanel = !this.openPanel;

        if (this.openPanel) {
            setTimeout(() => {
                document.addEventListener('click', this._outsideClickHandler);
            }, 0);
        }
    }

    handleOutsideClick(e) {
        const popup = this.template.querySelector('.notif-popup');
        const bell = this.template.querySelector('.bell-wrapper');

        if (this.openPanel &&
            popup &&
            bell &&
            !popup.contains(e.target) &&
            !bell.contains(e.target)) {

            this.openPanel = false;
            document.removeEventListener('click', this._outsideClickHandler);
        }
    }

    stopPropagation(e) {
        e.stopPropagation();
    }

    /* ================= READ ================= */
handleMarkRead(event) {
    const id = event.currentTarget.dataset.id;

    if (!id || id.startsWith('TEMP_')) {
       
        return;
    }

    this.updateReadStatus([id]);
}



 handleMarkAllRead() {
    const ids = [...this.notificationMap.values()].map(n => n.id);
    this.updateReadStatus(ids);
}



  updateReadStatus(ids) {
    if (!ids.length) {
        
        return;
    }

    markAsRead({ notificationIds: ids })
        .then(() => {
            ids.forEach(id => this.notificationMap.delete(id));
            this.syncNotifications();
        })
        .catch(err => {
           
        });
}


    /* ================= HELPERS ================= */
    syncNotifications() {
        this.notifications = [...this.notificationMap.values()]
            .sort((a, b) => new Date(b.fullDate) - new Date(a.fullDate));
           
    }

    get unreadCount() {
        return this.notifications.length;
    }

    get hasUnread() {
        return this.unreadCount > 0;
    }

    timeAgo(date) {
        const diff = Date.now() - new Date(date).getTime();
        const m = Math.floor(diff / 60000);
        if (m < 1) return 'Just now';
        if (m < 60) return `${m} minutes ago`;
        const h = Math.floor(m / 60);
        if (h < 24) return `${h} hours ago`;
        return `${Math.floor(h / 24)} days ago`;
    }

 handleBellClick(event) {
    event.stopPropagation();
    this.togglePanel();
}


}