import { Elm as ElmDev } from "./MainDev"
import { Elm as ElmProd } from "./MainProd"
import { toChunks, setThxUrls } from "./emoji"
import * as elmMonitor from "elm-monitor"

import "./style.scss"

export const TOKEN_KEY = "ThanksyToken"

const init = () => {
    const flags = { token: localStorage.getItem(TOKEN_KEY) || "", apiUrl: process.env.API_URL || "" }
    const isProd = process.env.MODE === "prod"

    const app = (isProd ? ElmProd.MainProd : ElmDev.MainDev).init({ flags })
    if (!isProd) elmMonitor()

    app.ports.getThxUpdate.subscribe(async d => {
        const withUrls = await setThxUrls(toChunks(d))
        app.ports.updateThx.send(withUrls)
    })

    app.ports.setToken.subscribe(v => localStorage.setItem(TOKEN_KEY, v))
}

document.addEventListener("DOMContentLoaded", init)
