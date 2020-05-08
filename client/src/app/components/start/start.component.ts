import { Component, OnInit, ElementRef, ViewChild, isDevMode } from '@angular/core';

import { Router } from '@angular/router';
import { NgForm } from '@angular/forms';

import { SessionService } from '../../services/session.service';
import { TokenService } from '../../services/token.service';

@Component({
  selector: 'app-start',
  templateUrl: './start.component.html',
  styleUrls: ['./start.component.scss']
})
export class StartComponent {

  invalidSessionIdModalIsActive: boolean;
  cookieAgreementTokenNotFoundIsActive: boolean;
  commingFromCreateSession: boolean;

  shouldShowAdds: boolean;

  @ViewChild('enterSessionButton', { static: true }) enterSessionButton: ElementRef<HTMLElement>; 

  constructor(
    private sessionService: SessionService,
    private tokenService: TokenService,
    private router: Router
  ) {
    if (this.tokenService.hasToken()) {
      this.router.navigate(['session'])
    }

    this.shouldShowAdds = !isDevMode();
  }

  startSession() {
    if (this.tokenService.hasPermissionToSetCookies()){
      this.sessionService.createSession()
    } else {
      this.toggleCookieAgreementTokenNotFoundIsActive();
      this.commingFromCreateSession = true;
    }
  }

  enterSession(form: NgForm) {
    if (this.tokenService.hasPermissionToSetCookies()){
      this.sessionService.enterSession(form.value.session).subscribe(
        authentication => {
          this.tokenService.login(authentication.result.token);
          console.log('session entered');

          this.router.navigate(['session']);
        },
        () => this.invalidSessionIdModalIsActive = true
      )} else {
        this.toggleCookieAgreementTokenNotFoundIsActive();
      }
  }

  aggreeToSetCookies() {
    this.tokenService.setPermissionToSetCookies();
    this.toggleCookieAgreementTokenNotFoundIsActive();
    if (this.commingFromCreateSession) {
      this.startSession(); 
    } else {
      this.enterSessionButton.nativeElement.click(); 
    }
  }

  toggleInvalidSessionIdModalIsActive() {
    this.invalidSessionIdModalIsActive = !this.invalidSessionIdModalIsActive;
  }

  toggleCookieAgreementTokenNotFoundIsActive() {
    this.cookieAgreementTokenNotFoundIsActive =
      !this.cookieAgreementTokenNotFoundIsActive;
  }
}
