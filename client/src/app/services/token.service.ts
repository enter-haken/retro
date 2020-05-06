import { Injectable } from '@angular/core';

import { BehaviorSubject } from 'rxjs';

import { JwtHelperService } from '@auth0/angular-jwt';

@Injectable({
  providedIn: 'root'
})
export class TokenService {

  public isLoggedIn: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(false);

  constructor() {
    if (this.hasToken()) {
      this.isLoggedIn.next(true);
    }
    else
    {
      this.isLoggedIn.next(false);
    }

  }

  public hasPermissionToSetCookies(): boolean {

    let hasPermission = localStorage.getItem("hasPermissionToSetCookies")
    if (hasPermission) {
      return JSON.parse(hasPermission);
    }

    return false;
  }
  
  public setPermissionToSetCookies(): void {
    localStorage.setItem("hasPermissionToSetCookies", "true");
  }

  public revokePermissionToSetCookies(): void {
    localStorage.removeItem("hasPermissionToSetCookies");
  }

  public getToken(): string {
    return localStorage.getItem('token');
  }

  public hasToken(): boolean {
    return this.getToken() != null;
  }

  public login(token): void {
    localStorage.setItem('token', token);
    this.isLoggedIn.next(true);
  }

  public logout(): void {
    localStorage.removeItem('token');
    this.isLoggedIn.next(false);
  }

  public getSessionId(): string {
    return new JwtHelperService()
      .decodeToken(this.getToken())
      .sub.session;
  }

  public getUserId(): string {
    return new JwtHelperService()
      .decodeToken(this.getToken())
      .sub.user;
  }

  public isCreator(): boolean {
    return new JwtHelperService()
      .decodeToken(this.getToken())
      .sub.is_creator;
  }
}
