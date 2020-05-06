import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

import { Observable } from 'rxjs';

import { Session } from '../models/session';
import { Participant } from '../models/participant';
import { Authentication } from '../models/authentication';
import { Response } from '../models/response';

@Injectable({
  providedIn: 'root'
})
export class ParticipantService {

  constructor(
    private http: HttpClient
  ) { }

  public createParticipant(sessionId: string, name: string): Observable<Response<Authentication>> {
    return this.http.post<Response<Authentication>>(`/api/session/${sessionId}/participant`,{
      name: name 
    });
  }  

  public deleteParticipant(sessionId: string, participantId: string): Observable<Response<Participant>> {
    return this.http.delete<Response<Participant>>(`/api/session/${sessionId}/participant/${participantId}`);
  }  

}
