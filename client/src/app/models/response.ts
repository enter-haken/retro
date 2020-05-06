export enum ResponseStatus {
  Ok = 'ok',
    Error = 'error'
}

export class Response<T> {
  status: ResponseStatus = ResponseStatus.Ok;
  result?: T;
  error?: string;

  static getResponseFrom<T>(rawResponse: any): Response<T> {
    return Object.assign(new Response<T>(), rawResponse);
  }

  hasError() {
    return this.status === ResponseStatus.Error;
  }

  isOk() {
    return this.status === ResponseStatus.Ok;
  }
}

