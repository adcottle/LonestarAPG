import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { BylawsComponent } from './pages/bylaws/bylaws.component';
import { ContactComponent } from './pages/contact/contact.component';
import { HomeComponent } from './pages/home/home.component';
import { OfficersComponent } from './pages/officers/officers.component';


const routes: Routes = [
  { path: 'home', component: HomeComponent },
  { path: 'bylaws', component: BylawsComponent },
  { path: 'contact', component: ContactComponent },
  { path: 'officers', component: OfficersComponent },
  // otherwise redirect to home
  { path: '',   redirectTo: '/home', pathMatch: 'full' },
  { path: '**', redirectTo: '/home', pathMatch: 'full' }

];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
