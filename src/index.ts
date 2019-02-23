import { Elm } from "./Main"

import "./style.scss"
import { toChunks, setThxUrls } from "./emoji"

export const TOKEN_KEY = "ThanksyToken"

document.addEventListener("DOMContentLoaded", () => {
    const token = localStorage.getItem(TOKEN_KEY) || "123456"
    const app = Elm.Main.init({ flags: { token } })
    app.ports.parseText.subscribe(async d => app.ports.getThxPartial.send(await setThxUrls(toChunks(d))))
})
