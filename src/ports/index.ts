// tslint:disable-next-line: no-reference
/// <reference path="./index.d.ts" />

import { DateTime } from "luxon"
import { remap, getter } from "./utils"

const emojiRegex = require("emoji-regex")()
const emojilib = require("emojilib")
const twemoji = require("twemoji").default

const emojiByName = remap<{ char: string }>(emojilib.lib, (_, name) => `:${name}:`, v => v)
const emojiNameByUtf8 = remap<{ char: string }, string>(emojiByName, v => v.char, (_, name) => name)

const replaceEmoji = (name: string) => (emojiByName[name] ? emojiByName[name].char : name)
export const replaceUtf8Emoji = (text: string) => text.replace(emojiRegex, match => emojiNameByUtf8[match] || match)

export const Text = (caption: string): TextChunk => ({ type: "text", caption })
export const Nickname = (caption: string): TextChunk => ({ type: "nickname", caption: caption === "🥳" ? "" : caption })
export const Emoji = (caption: string, url: string = ""): TextChunk => ({ type: "emoji", caption, url })

export const parseTextRec = (text: string, acc: TextChunk[] = []): TextChunk[] => {
    const emojiRes = /(:[a-zA-Z_0-9+-]+:)/g.exec(text)
    const emojiIndex = emojiRes ? text.indexOf(emojiRes[0]) : -1
    const nicknameRes = /(@[a-zA-Z_0-9.-]+)/g.exec(text)
    const nicknameIndex = nicknameRes ? text.indexOf(nicknameRes[0]) : -1

    if (emojiRes && (emojiIndex < nicknameIndex || nicknameIndex === -1)) {
        if (emojiIndex !== 0) acc.push(Text(text.substr(0, emojiIndex)))
        acc.push(Emoji(emojiRes[0]))
        return parseTextRec(text.substring(emojiIndex + emojiRes[0].length), acc)
    }

    if (nicknameRes && (nicknameIndex < emojiIndex || emojiIndex === -1)) {
        if (nicknameIndex !== 0) acc.push(Text(text.substr(0, nicknameIndex)))
        acc.push(Nickname(nicknameRes[0]))
        return parseTextRec(text.substring(nicknameIndex + nicknameRes[0].length), acc)
    }
    return text ? [...acc, Text(text)] : acc
}

export const parseText = (text: string, acc: TextChunk[] = []) => {
    const noGroups = text.replace(/<!subteam.[A-Za-z0-9]+.(@[a-zA-Z0-9._-]+)[>]*/g, (_, g) => g)
    const noUtfEmoji = replaceUtf8Emoji(noGroups)
    return parseTextRec(noUtfEmoji, acc)
}

const emojiUrl = (name: string) => `https://twemoji.maxcdn.com/2/72x72/${name}.png`

const extEmoji = ({ caption }: Emoji, name: string) =>
    Emoji(getter(emojiByName[caption], "char") || caption, emojiUrl(name))

const setEmojiUrl = async (c: Emoji) => {
    if (c.type !== "emoji") return c
    const caption = replaceEmoji(c.caption)
    if (c.caption === caption) return new Promise<TextChunk>(res => res(c))
    return new Promise(res =>
        twemoji.parse(caption, {
            callback: (name: string) => res(extEmoji(c, name)),
            onerror: () => res(c)
        })
    )
}

export const setEmojiUrls = async (thxs: Thx[]) =>
    Promise.all(thxs.map(async t => ({ ...t, chunks: await Promise.all(t.chunks.map(setEmojiUrl)) })))

export const toChunks = (id: number, text: string, createdAt: string): Thx => {
    const d = DateTime.fromISO(createdAt)
    return {
        chunks: parseText(text),
        id,
        createdAt: `${d.toRelativeCalendar()} at ${d.toLocaleString(DateTime.TIME_SIMPLE)}`
    }
}
;(window as any).toChunks = toChunks
// tslint:disable-next-line: no-console
console.log("hello ts")
