import { BrowserModule } from '@angular/platform-browser';
import { HttpClient, HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';

import { AppRoutingModule } from './app-routing.module';

import { AppComponent } from './app.component';
import { EntryComponent } from './components/entry/entry.component';
import { EntryListComponent } from './components/entry-list/entry-list.component';
import { SessionComponent } from './components/session/session.component';
import { StartComponent } from './components/start/start.component';
import { PrivacyComponent } from './components/privacy/privacy.component';

import { BackendInterceptor } from './interceptors/backend.interceptor';
import { JwtInterceptor } from './interceptors/jwt.interceptor';

import { environment } from '../environments/environment';

import { FilterPipe } from './pipes/filter.pipe';

@NgModule({
  declarations: [
    AppComponent,
    StartComponent,
    SessionComponent,
    EntryComponent,
    EntryListComponent,
    FilterPipe,
    PrivacyComponent
  ],
  imports: [
    // angular
    BrowserModule,
    FormsModule,
    HttpClientModule,

    AppRoutingModule,
  ],
  providers: [
    {provide: HTTP_INTERCEPTORS, useClass: JwtInterceptor, multi: true },
    {provide: HTTP_INTERCEPTORS, useClass: BackendInterceptor, multi: true }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
