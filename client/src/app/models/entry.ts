import { Participant } from './participant';

export class Entry {
  id: string;
  text: string;
  markdown: string;
  entryKind: string;
  participant: Participant;
}

