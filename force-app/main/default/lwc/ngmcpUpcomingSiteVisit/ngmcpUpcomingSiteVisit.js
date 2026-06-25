import { LightningElement } from 'lwc';

export default class SiteVisitsCustom extends LightningElement {
  visits = [
    {
      id: 1,
      code: 'UWR',
      contact: '6549889678',
      name: 'Unit 2a, Skyway',
      address: 'AB24 5BR',
      date: '15.10.2025',
      time: '08:00 - 12:00'
    },
    {
      id: 2,
      code: 'WR',
      contact: '2334455667',
      name: 'The Hilton',
      address: 'BB77 4R5',
      date: '17.10.2025',
      time: '12:00 - 16:00'
    },
    {
      id: 3,
      code: 'WR',
      contact: '4565768799',
      name: 'Site name',
      address: 'Postal code',
      date: '18.10.2025',
      time: '08:00 - 12:00'
    },
    {
      id: 4,
      code: 'DQ',
      contact: '1212132456',
      name: 'Site name',
      address: 'Postal code',
      date: '19.10.2025',
      time: '12:00 - 16:00'
    }
  ];
}