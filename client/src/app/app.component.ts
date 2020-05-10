import { Component, OnInit } from '@angular/core';

import { Router } from '@angular/router';

import { SessionService } from './services/session.service';
import { TokenService } from './services/token.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {

  public isLoggedIn: boolean;
  public isCreator: boolean;

  public sessionId: string;

  public modalStateYourNameIsActive: boolean;
  public modalLeaveIsActive: boolean;

  constructor(
    private sessionService: SessionService,
    private tokenService: TokenService,
    private router: Router
  ){
  }

  ngOnInit() {
    this.tokenService.isLoggedIn.subscribe(value => {
      this.isLoggedIn = value;

      if (this.isLoggedIn) {
        this.sessionId = this.tokenService.getSessionId();
        this.isCreator = this.tokenService.isCreator();
      }
    });
  }

  toggleStateYourNameModal() {
    this.modalStateYourNameIsActive = !this.modalStateYourNameIsActive;
  }

  toggleLeaveModal() {
    this.modalLeaveIsActive = !this.modalLeaveIsActive;
  }

  leave() {
    this.sessionService.deleteParticpant();
    this.modalLeaveIsActive = false;
  }

  scrollToTheTop(event) {
    window.scroll(0,0);
  }

  updateParticipant(nameField) {
    this.sessionService.updateParticipant(nameField.value);

    this.modalStateYourNameIsActive = false;
  }

  copyToClipboard(inputElement) {
    inputElement.select();
    document.execCommand('copy');
    inputElement.setSelectionRange(0, 0);
  }
}
