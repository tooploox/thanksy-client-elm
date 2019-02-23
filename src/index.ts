import { Elm } from "./Main"

import "./style.scss"

export const TOKEN_KEY = "ThanksyToken"

document.addEventListener("DOMContentLoaded", () => {
    const token = localStorage.getItem(TOKEN_KEY) || "123456"
    const app = Elm.Main.init({ flags: { token } })
    document.addEventListener("mousemove", app.ports.onMouseMove.send)
})
