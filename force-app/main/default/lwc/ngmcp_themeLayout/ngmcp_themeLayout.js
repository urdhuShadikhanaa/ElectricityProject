import { LightningElement } from 'lwc';

export default class CustomThemeLayout extends LightningElement {
  connectedCallback() {
    const path = window.location.pathname;
    if (path.includes('/login')) {
      document.body.classList.add('login-page');
    } else {
      document.body.classList.remove('login-page');
    }
  }
}