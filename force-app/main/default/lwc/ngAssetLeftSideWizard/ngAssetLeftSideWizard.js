import { LightningElement, track } from 'lwc';
import homeIcon from '@salesforce/resourceUrl/homeIcon';
import commercialsIcon from '@salesforce/resourceUrl/commercialsIcon';
import reportsIcon from '@salesforce/resourceUrl/reportsIcon';
import settingsIcon from '@salesforce/resourceUrl/settingsIcon';
import backgroundImage from '@salesforce/resourceUrl/ngBackgroundImage';

export default class NgAssetLeftSideWizard extends LightningElement {
    @track selectedTab='';
    userName;

        
    backgroundStyle = `background-image: url(${backgroundImage}); background-size: cover; background-position: center;`;
    get tabs() {
        const tabList = [
            { name: 'home', label: 'Home', icon: homeIcon },
            // { name: 'commercials', label: 'Commercials', icon: commercialsIcon },
            { name: 'reports', label: 'Reports', icon: reportsIcon },
            { name: 'settings', label: 'Settings', icon: settingsIcon }
        ];

        return tabList.map(tab => ({
            ...tab,
            class: this.selectedTab === tab.name ? 'tab-item selected' : 'tab-item'
        }));
    }

    handleTabClick(event) {
        this.selectedTab = event.currentTarget.dataset.tab;
    }
  
    
    get backgroundStyle(){
            return `background-image: url(); background-size: cover; background-position: center;`;
        }
}