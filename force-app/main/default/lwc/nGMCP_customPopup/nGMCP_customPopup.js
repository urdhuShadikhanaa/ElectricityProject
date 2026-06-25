import { LightningElement, api } from 'lwc';

export default class NGMCP_customPopup extends LightningElement {
    @api isOpen = false; // Controls if the popup is open
    @api modalTitle = ''; // Dynamic title of the popup
    @api modalMessage = ''; // Dynamic content of the popup
    @api messageType = 'success'; // Type of message (success, warning, error)

    get messageClass() {
        // Depending on the messageType, apply different styles
        switch (this.messageType) {
            case 'error':
                return 'popup-message error';
            case 'warning':
                return 'popup-message warning';
            case 'success':
            default:
                return 'popup-message success';
        }
    }

    // Close the popup
    handleClose() {
        this.isOpen = false;
    }

    // Method to open the popup with dynamic content
    openPopup(title, message, type) {
        this.modalTitle = title;
        this.modalMessage = message;
        this.messageType = type;
        this.isOpen = true;
    }
}