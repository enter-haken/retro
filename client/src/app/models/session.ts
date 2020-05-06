import { Participant } from './participant';
import { Entry } from './entry';

export class Session {
  id: string;
  participants: Array<Participant>;
  entries: Array<Entry>;
  latest_activity: number;
}
