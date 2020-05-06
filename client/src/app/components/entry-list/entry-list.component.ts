import { Component, OnInit, Input, Output, EventEmitter } from '@angular/core';

import { NgForm } from '@angular/forms';

import { Entry } from '../../models/entry';

import { FilterPipe } from '../../pipes/filter.pipe';

@Component({
  selector: 'app-entry-list',
  templateUrl: './entry-list.component.html',
  styleUrls: ['./entry-list.component.scss'],
  providers: [FilterPipe]
})
export class EntryListComponent {

  @Input() title: string;
  @Input() kind: string;
  @Input() entries: Array<Entry>;

  @Output() entryAdded = new EventEmitter<Entry>();
  @Output() entryChanged = new EventEmitter<Entry>();
  @Output() entryDeleted  = new EventEmitter<Entry>();
  

  constructor() { }

  public createEntry(entry: Entry) {
    entry.entryKind = this.kind;

    this.entryAdded.emit(entry);
  }

  public changeEntry(entry: Entry) {
    this.entryChanged.emit(entry);
  }

  public deleteEntry(entry: Entry) {
    this.entryDeleted.emit(entry);
  }
}
