// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace MainDev {
    export interface App {
      ports: {
        getThxUpdate: {
          subscribe(callback: (data: { id: number; createdAt: string; body: string }) => void): void
        }
        updateThx: {
          send(data: any): void
        }
        setToken: {
          subscribe(callback: (data: string) => void): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: { token: string; apiUrl: string };
    }): Elm.MainDev.App;
  }
}