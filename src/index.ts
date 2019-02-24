import { Elm } from "./Main"

import "./style.scss"
import { toChunks, setThxUrls } from "./emoji"

export const TOKEN_KEY = "ThanksyToken"

const init = () => {
    const token = localStorage.getItem(TOKEN_KEY) || "123456"
    const app = Elm.Main.init({ flags: { token } })
    app.ports.getThxUpdate.subscribe(async d => app.ports.updateThx.send(await setThxUrls(toChunks(d))))
}

document.addEventListener("DOMContentLoaded", init)
