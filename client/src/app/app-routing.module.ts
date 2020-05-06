import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import { StartComponent } from './components/start/start.component';
import { PrivacyComponent } from './components/privacy/privacy.component';
import { SessionComponent } from './components/session/session.component';

import { SessionGuard } from './guards/session.guard';


const routes: Routes = [
  { path: '', redirectTo: 'start', pathMatch: 'full'},
  { path: 'start', component: StartComponent },
  { path: 'privacy', component: PrivacyComponent },
  { path: 'session', component: SessionComponent, canActivate: [SessionGuard] },
];

@NgModule({
  imports: [RouterModule.forRoot(routes, {
    useHash: true
  })],
  exports: [RouterModule]
})

export class AppRoutingModule { }
