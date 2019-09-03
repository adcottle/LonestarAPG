import { Component, OnInit } from '@angular/core';
declare let L;
// import leaflet plugin
import '../../../../node_modules/leaflet-routing-machine/dist/leaflet-routing-machine.js';


@Component({
  selector: 'app-contact',
  templateUrl: './contact.component.html',
  styleUrls: ['./contact.component.scss']
})
export class ContactComponent implements OnInit {
  icon = {
    icon: L.icon({
      iconSize: [ 25, 41 ],
      iconAnchor: [ 13, 0 ],
      iconUrl: '../../../assets/leaflet/images/marker-icon.png',
      shadowUrl: '../../../assets/leaflet/images/marker-shadow.pnt'
    })
  };

  constructor() { }

  ngOnInit() {
    const map = L.map('map').setView([30.354992, -97.755636], 16);

        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map);

        // L.Routing.control({
        //     waypoints: [
        //         L.latLng(57.74, 11.94),
        //         L.latLng(57.6792, 11.949)
        //     ]
        // }).addTo(map);

        const marker = L.marker([30.354992, -97.755636], this.icon).addTo(map);
        marker.bindPopup("Lone Star Chapter APG").openPopup();
    }
  

}


