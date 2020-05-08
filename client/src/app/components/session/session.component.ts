import { Component, OnInit, OnDestroy, isDevMode } from '@angular/core';
import { Router } from '@angular/router';

import { SessionService } from '../../services/session.service';
import { TokenService } from '../../services/token.service';

import { concat } from 'rxjs';
import { combineAll, switchMap } from 'rxjs/operators';

import { Session } from '../../models/session';
import { Entry } from '../../models/entry';

@Component({
  selector: 'app-session',
  templateUrl: './session.component.html',
  styleUrls: ['./session.component.scss']
})
export class SessionComponent implements OnInit {

  public isCreator: boolean;
  public shouldShowAdds: boolean;

  constructor(
    private router: Router,
    public  sessionService: SessionService,
    private tokenService: TokenService
  ) {
    this.shouldShowAdds = !isDevMode(); 
  }

  ngOnInit() {

    this.isCreator = this.tokenService.isCreator();

    this.sessionService.updateTrigger().subscribe(
      () => this.sessionService.getSession(),
      err => console.log("could not update session via sse",err)
    );

    this.sessionService.getSession();
  }

  addEntry(newEntry: Entry) {
    this.sessionService.createEntry(newEntry);
  }

  changeEntry(changedEntry: Entry) {
    this.sessionService.updateEntry(changedEntry);
  }

  deleteEntry(entryToDelete: Entry) {
    this.sessionService.deleteEntry(entryToDelete);
  }

  voteOnEntry(entryToVoteOn: Entry) {
    this.sessionService.voteOnEntry(entryToVoteOn);
  }
}
