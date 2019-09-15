import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';

import { MDBBootstrapModule, CarouselModule, WavesModule } from 'angular-bootstrap-md';
import { MaterialModule } from './material.component';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { LayoutModule } from '@angular/cdk/layout';

//app pages
import { MainNavComponent } from './main-nav/main-nav.component';
import { BylawsComponent } from './pages/bylaws/bylaws.component';
import { ContactComponent } from './pages/contact/contact.component';
import { HomeComponent } from './pages/home/home.component';
import { OfficersComponent } from './pages/officers/officers.component';
import { EventsComponent } from './pages/events/events.component';
import { MembershipComponent } from './pages/membership/membership.component';
import { ProfessionalComponent } from './pages/professional/professional.component';
import { EthicsComponent } from './pages/ethics/ethics.component';

@NgModule({
  declarations: [
    AppComponent,
    MainNavComponent,
    BylawsComponent,
    ContactComponent,
    HomeComponent,
    OfficersComponent,
    EventsComponent,
    MembershipComponent,
    ProfessionalComponent,
    EthicsComponent
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    AppRoutingModule,
    MDBBootstrapModule.forRoot(),
    CarouselModule, 
    WavesModule,
    LayoutModule,
    MaterialModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
