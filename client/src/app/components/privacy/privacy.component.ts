import { Component, OnInit } from '@angular/core';

import { Router } from '@angular/router';

import { TokenService } from '../../services/token.service';
import { SessionService } from '../../services/session.service';

@Component({
  selector: 'app-privacy',
  templateUrl: './privacy.component.html',
  styleUrls: ['./privacy.component.scss']
})
export class PrivacyComponent implements OnInit {

  sampleToken: any = {
    "aud": "retro",
    "exp": 1590402813,
    "iat": 1587983613,
    "iss": "retro",
    "jti": "dab7c336-6aa5-46ef-9247-b0dbec5a06a0",
    "nbf": 1587983612,
    "sub": {
      "is_creator": true,
      "session": "f818c2a9-0cac-48fb-8c80-d848eeb97078",
      "user": "78af15f6-9255-4a5d-a704-36a44d008706"
    },
    "typ": "access"
  }

  constructor(
    private tokenService: TokenService,
    private sessionService: SessionService,
    private router: Router
  ) { }

  ngOnInit() {
  }

  revokeCookieSettings() {
    this.tokenService.revokePermissionToSetCookies();

    if (this.tokenService.hasToken()) {
      this.sessionService.deleteParticpant();
    }

    this.router.navigate(['start']);
  }
}
