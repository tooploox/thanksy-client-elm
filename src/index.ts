import { Elm } from "./Main"

import "./style.scss"
import { toChunks, setThxUrls } from "./emoji"

export const TOKEN_KEY = "ThanksyToken"

const init = () => {
    const token = localStorage.getItem(TOKEN_KEY) || "123456"
    const app = Elm.Main.init({ flags: { token } })

    app.ports.getThxUpdate.subscribe(async d => {
        const withUrls = await setThxUrls(toChunks(d))
        app.ports.updateThx.send(withUrls)
    })
}

document.addEventListener("DOMContentLoaded", init)
