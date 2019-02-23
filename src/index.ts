import { Elm } from "./Main"

import "./style.scss"

export const TOKEN_KEY = "ThanksyToken"

document.addEventListener("DOMContentLoaded", () => {
    const token = localStorage.getItem(TOKEN_KEY) || "123456"
    const app = Elm.Main.init({ flags: { token } })
    app.ports.parseText.subscribe(d => {
        app.ports.getThxPartial.send({
            id: d.id,
            createdAt: d.createdAt,
            chunks: [{ type: "nickname", caption: d.body }]
        })
    })
})
