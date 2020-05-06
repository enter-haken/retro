import { Component, OnInit, Input, Output, EventEmitter, ElementRef, ViewChild } from '@angular/core';

import { NgForm } from '@angular/forms';

import { Entry } from '../../models/entry';
import { Participant } from '../../models/participant';

import { TokenService } from '../../services/token.service';

@Component({
  selector: 'app-entry',
  templateUrl: './entry.component.html',
  styleUrls: ['./entry.component.scss']
})
export class EntryComponent implements OnInit {
  //@ViewChild('entryContent') entryContent: ElementRef;

  @Input() entry: Entry;
  @Input() mode: string = "shouldBeVisible";
  @Input() placeholder: string = "What do you want to add?";

  @Output() hasCreationCandidate = new EventEmitter<Entry>();
  @Output() hasChangeCandidate = new EventEmitter<Entry>();
  @Output() hasDeletionCandidate = new EventEmitter<Entry>();

  public canModify: boolean;

  public isEmpty: boolean;
  public isNotEmpty: boolean;

  public shouldShowEditor: boolean;

  public content: string = '';

  constructor(private tokenService: TokenService) { }

  ngOnInit() {
    this.canModify = this.isAuthor() || this.tokenService.isCreator();

    this.isEmpty = this.entry == null
    this.isNotEmpty = !this.isEmpty;
    this.shouldShowEditor = this.mode == "shouldBeEditable";

    if (this.entry) {
      this.content = this.entry.text;
    } 
  }

  public toggleMode() {
    this.shouldShowEditor = !this.shouldShowEditor;
  }

  public submit(form: NgForm) {
    if(this.isEmpty) {
      this.addEntry(form.value.text);
    }
    else
    {
      this.changeEntry(form.value.text);
    }
  }

  public addEntry(text: any) {
    console.log(text);

    const entry = new Entry();
    entry.text = text;

    this.hasCreationCandidate.emit(entry);

    this.content = '';
  }

  public changeEntry(text: string) {
    this.entry.text = text;
    this.hasChangeCandidate.emit(this.entry);
  }

  public deleteEntry() {
    this.hasDeletionCandidate.emit(this.entry);
  }

  private isAuthor(): boolean {
    if (this.entry == null){
      return false;
    }
    return this.tokenService.getUserId() == this.entry.participant.id;
  }
}
