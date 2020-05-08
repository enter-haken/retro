import { Injectable, NgZone, isDevMode } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';

import { Observable, BehaviorSubject, Subject, pipe, throwError } from 'rxjs';
import { catchError, tap, switchMap, delay } from 'rxjs/operators';

import { JwtHelperService } from '@auth0/angular-jwt';

import { TokenService } from './token.service';

import { Session } from '../models/session';
import { System } from '../models/system';
import { Entry } from '../models/entry';
import { Authentication } from '../models/authentication';
import { Response } from '../models/response';

import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class SessionService {

  private session: BehaviorSubject<Session> = new BehaviorSubject<Session>(null);
  private system: BehaviorSubject<System> = new BehaviorSubject<System>(null);


  session$ = this.session.asObservable();
  system$ = this.system.asObservable();

  constructor(
    private http: HttpClient,
    private router: Router,
    private tokenService: TokenService,
    private zone: NgZone
  ) {

  }

  updateTrigger(): Observable<boolean> {
    return Observable.create(observer => {

      //const eventSource = new EventSource(`http://hake.one:5050/api/hasChanges/${this.tokenService.getSessionId()}`);
      const eventSource = new EventSource(this.getEventSourceUrl(), {
        withCredentials: true
      });

      eventSource.onmessage = x => {
        this.zone.run(() => {
          console.log("got update from sse",x);
          observer.next(x);
        })
      };
      eventSource.onerror = (x: any) => {
        this.zone.run(() => {
          if (x.target.readyState === EventSource.CLOSED) {
            console.log(`SSE closed ${x.target.readyState}`);
          } else if (x.target.readyState === EventSource.CONNECTING) {
            console.log(`SSE reconnecting ${x.target.readyState}`);
          } else if (x.target.readyState === EventSource.OPEN) {
            console.log(`SSE open ${x.target.readyState}`);
          }

          observer.error(x);
        })
      }

      return () => {
        eventSource.close();
      };
    });
  }

  private getEventSourceUrl = () => {
    if (isDevMode) {
      return environment.apiUrl + `/api/hasChanges/${this.tokenService.getSessionId()}`;
    }

    return `/api/hasChanges/${this.tokenService.getSessionId()}`
  }

  getSession = () =>
    this.http.get<Response<Session>>(`/api/session/participant`)
      .subscribe(
        data => this.session.next(data.result),
        err => console.log("could not get session", err)
      );

  getSystem = () =>
    this.http.get<Response<System>>(`/api/system`)
      .subscribe(
        data => this.system.next(data.result),
        err => console.log("could not get system data", err)
      );

  createSession = () =>
    this.http.post<Response<Authentication>>(`/api/session`, {}).subscribe(
      authentication => {
        this.tokenService.login(authentication.result.token);
        this.router.navigate(['session']);
      },
      err => console.log("could not create session", err)
    );

  enterSession = (sessionId: string) =>
    this.http.post<Response<Authentication>>(`/api/session/${sessionId}`, {});

  deleteParticpant = () =>
    this.http.delete<Response<string>>(`/api/session/participant`)
      .subscribe(
        () => {
          this.tokenService.logout();
          console.log("user has logged out");

          this.router.navigate(['start']);
        },
        err => console.log("could not delete user", err)
      );

  updateParticipant = (name: string) =>
    this.http.put<Response<string>>(`/api/session/participant`, {
      name: name
    }) .subscribe(
      () => {
        console.log("user has changed");
      },
      err => console.log("could not update user", err)
    );

  createEntry = (entry: Entry) =>
    this.http.post<Response<Entry>>(`/api/session/participant/entry`,{
      text: entry.text,
      entryKind: entry.entryKind
    }).subscribe(
      () => console.log("entry cretated"),
      err => console.log("could not create entry", err)
    );

  updateEntry = (entry: Entry) =>
    this.http.put<Response<Entry>>(`/api/session/participant/entry`,{
      id: entry.id,
      text: entry.text
    }).subscribe(
      () => console.log("entry has been updated"),
      err => console.log("could not update entry", err)
    );

  voteOnEntry = (entry: Entry) =>
    this.http.put<Response<Entry>>(`/api/session/participant/entry/${entry.id}/vote`, {}).subscribe(
      () => console.log("entry has been voted on"),
      err => console.log("could not vote on entry", err)
    );

  deleteEntry = (entry: Entry) =>
    this.http.delete<Response<string>>(`/api/session/participant/entry/${entry.id}`)
      .subscribe(
        () => console.log("entry has been deleted"),
        err => console.log("could not delete entry")
      );
}
