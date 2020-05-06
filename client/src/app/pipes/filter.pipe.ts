import { Pipe, PipeTransform } from '@angular/core';

import { Entry } from '../models/entry';

@Pipe({
  name: 'filter'
})
export class FilterPipe implements PipeTransform {
  transform(entries: Entry[], entryKind: string): Entry[] {
    if (entries == null) {
      return new Array<Entry>(); 
    }
    return entries.filter(entry => entry.entryKind == entryKind );
  }
}
