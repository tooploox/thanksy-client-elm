# Elm version of thanksy project - [Work in progress]

[![elm version](https://img.shields.io/badge/Elm-v0.19-blue.svg?style=flat-square)](http://elm-lang.org)

For more details (and the bigger picture) you can visit our [landing page](https://tooploox.github.io/thanksy/) and check out our [backend repository](https://github.com/tooploox/thanksy-server).

Nevertheless, this is [thanksy client](https://tooploox.github.io/thanksy/). This project is written `Elm` (version 0.19). It was created as an experiment, to check how difictult is to rewrite `typescript` / `react` /`redux` / `redux-loop` project into Elm framework.

On the one hand, [Redux](https://redux.js.org/introduction/prior-art#elm) and [Redux loop](https://redux-loop.js.org/) have been highly inspired by the Elm Architecture. On the other hand, we love react's `Functional components` (no class included) and algebraic data types implemented in Typescript (plus `strictNullChecks` compiler flag), so switching into Elm wasn't so hard as one may expect.

Visit original project [here](https://github.com/tooploox/thanksy-client-ts). The experiment was successful and now we have both clients with the same functionalities.

## Setup

Install npm packages:

```bash
npm install
```

Start a local dev server

```bash
npm start
```

Load http://localhost:8080/

-- OR --

Bundle files for production:

```bash
npm run build # it transpiles all your Elm and ts into dist/index.bundle.js
```
