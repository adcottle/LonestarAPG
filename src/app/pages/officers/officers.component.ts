import { Component, OnInit } from '@angular/core';
import { trigger, state, style, transition, animate } from '@angular/animations';


@Component({
  selector: 'app-officers',
  templateUrl: './officers.component.html',
  styleUrls: ['./officers.component.scss'],
  animations: [
    trigger('flipState', [
      state('active', style({
        transform: 'rotateY(179deg)'
      })),
      state('inactive', style({
        transform: 'rotateY(0)'
      })),
      transition('active => inactive', animate('500ms ease-out')),
      transition('inactive => active', animate('500ms ease-in'))
    ])
  ]
  
})
export class OfficersComponent implements OnInit {

  constructor() { }

  ngOnInit() {
  }

  flip: string = 'inactive';

  toggleFlip() {
    this.flip = (this.flip == 'inactive') ? 'active' : 'inactive';
  }

  flip2: string = 'inactive';

  toggleFlip2() {
    this.flip2 = (this.flip2 == 'inactive') ? 'active' : 'inactive';
  }
  
  flip3: string = 'inactive';

  toggleFlip3() {
    this.flip3 = (this.flip3 == 'inactive') ? 'active' : 'inactive';
  }

  flip4: string = 'inactive';

  toggleFlip4() {
    this.flip4 = (this.flip4 == 'inactive') ? 'active' : 'inactive';
  }

  flip5: string = 'inactive';

  toggleFlip5() {
    this.flip5 = (this.flip5 == 'inactive') ? 'active' : 'inactive';
  }



}
