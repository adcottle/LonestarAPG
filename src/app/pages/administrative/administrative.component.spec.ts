import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AdministrativeComponent } from './administrative.component';

describe('AdministrativeComponent', () => {
  let component: AdministrativeComponent;
  let fixture: ComponentFixture<AdministrativeComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AdministrativeComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AdministrativeComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
