import { Elm } from "./Main"
import { toChunks, setThxUrls } from "./emoji"

import "./style.scss"

export const TOKEN_KEY = "ThanksyToken"

const init = () => {
    const token = localStorage.getItem(TOKEN_KEY) || ""
    const apiUrl = process.env.API_URL || ""
    console.log(apiUrl)
    const app = Elm.Main.init({ flags: { token, apiUrl } })

    app.ports.getThxUpdate.subscribe(async d => {
        const withUrls = await setThxUrls(toChunks(d))
        app.ports.updateThx.send(withUrls)
    })

    app.ports.setToken.subscribe(token => localStorage.setItem(TOKEN_KEY, token))
}

document.addEventListener("DOMContentLoaded", init)
