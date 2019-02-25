declare var require: any
declare var process: any
type TMap<TKey extends string, TValue> = { [K in TKey]: TValue }
type SMap<TValue> = TMap<string, TValue>
type Emoji = { type: "emoji"; url: string; caption: string }
type TextChunk = { type: "text"; caption: string } | { type: "nickname"; caption: string } | Emoji
type ThxPartial = {
    chunks: TextChunk[]
    id: number
    createdAt: string
}

type ThxPartialRaw = { id: number; createdAt: string; body: string }
