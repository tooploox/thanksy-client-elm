// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Main {
    export interface App {
      ports: {
        onMouseMove: {
          send(data: { x: number; y: number }): void
        }
        hello: {
          subscribe(callback: (data: string) => void): void
        }
        reply: {
          send(data: number): void
        }
      };
    }
    export function init(options: {
      node?: HTMLElement | null;
      flags: { token: string };
    }): Elm.Main.App;
  }
}