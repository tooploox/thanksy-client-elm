import { Elm } from "./Main"
import { toChunks, setThxUrls } from "./emoji"
import * as elmMonitor from "elm-monitor"

import "./style.scss"

export const TOKEN_KEY = "ThanksyToken"

const init = () => {
    elmMonitor()
    const token = localStorage.getItem(TOKEN_KEY) || ""
    const apiUrl = process.env.API_URL || ""
    const app = Elm.Main.init({ flags: { token, apiUrl } })

    app.ports.getThxUpdate.subscribe(async d => {
        const withUrls = await setThxUrls(toChunks(d))
        app.ports.updateThx.send(withUrls)
    })

    app.ports.setToken.subscribe(v => localStorage.setItem(TOKEN_KEY, v))
}

document.addEventListener("DOMContentLoaded", init)
