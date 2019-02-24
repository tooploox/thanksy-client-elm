// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Main {
    export interface App {
      ports: {
        parseText: {
          subscribe(callback: (data: { id: number; createdAt: string; body: string }) => void): void
        }
        getThxPartial: {
          send(data: any): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: { token: string };
    }): Elm.Main.App;
  }
}