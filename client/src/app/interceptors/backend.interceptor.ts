import { Injectable, isDevMode } from '@angular/core';
import {
  HTTP_INTERCEPTORS,
  HttpErrorResponse,
  HttpEvent,
  HttpHandler,
  HttpInterceptor,
  HttpRequest,
  HttpResponse,
} from '@angular/common/http';

import { Router } from '@angular/router';
import { Observable, of, throwError } from 'rxjs';
import {
  delay,
  mergeMap,
  materialize,
  dematerialize,
  tap,
} from 'rxjs/operators';

import { environment } from '../../environments/environment';

import { TokenService } from '../services/token.service';

@Injectable()
export class BackendInterceptor implements HttpInterceptor {
  constructor(
    private router: Router,
    private tokenService: TokenService
  ) {}

  intercept(
    request: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    if (
      isDevMode() &&
      this.hasApiUrlInEnvironment() &&
      this.isApiCall(request.url)
    ) {
      request = request.clone({ url: this.getApiUrlFrom(request.url) });
    }

    return next.handle(request).pipe(
      tap(() => {},
        (err: any) => {
          if (err instanceof HttpErrorResponse) {
            if (err.status !== 401) {
              return;
            }
            this.tokenService.logout();
            this.router.navigate(['start']);
          }
        }));
  }

  private isApiCall(url): boolean {
    return url.startsWith('api') || url.startsWith('/api');
  }

  private hasApiUrlInEnvironment(): boolean {
    return environment.apiUrl !== '';
  }

  private getApiUrlFrom(url): string {
    if (url.startsWith('/')) {
      url = url.substring(1);
    }

    return `${environment.apiUrl}/${url}`;
  }
}
