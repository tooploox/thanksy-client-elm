import { Elm } from "./Main"

import "./style.scss"
import { toChunks, setThxUrls } from "./emoji"

export const TOKEN_KEY = "ThanksyToken"

const init = () => {
    const token = localStorage.getItem(TOKEN_KEY) || "12345"
    const app = Elm.Main.init({ flags: { token, apiUrl: "http://localhost:3000" } })

    app.ports.getThxUpdate.subscribe(async d => {
        const withUrls = await setThxUrls(toChunks(d))
        app.ports.updateThx.send(withUrls)
    })

    app.ports.setToken.subscribe(token => localStorage.setItem(TOKEN_KEY, token))
}

document.addEventListener("DOMContentLoaded", init)
