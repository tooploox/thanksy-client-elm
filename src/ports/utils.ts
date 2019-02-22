export const remap = <T, S = any>(
    vs: SMap<T>,
    getKey: (t: T, key: string, index: number) => string,
    getValue: (t: T, key: string) => S,
    skipNullValue = false
): SMap<S> => {
    const res: SMap<S> = {}
    Object.keys(vs).forEach((k, index) => {
        const value = getValue(vs[k], k)
        if (!skipNullValue || value !== null) res[getKey(vs[k], k, index)] = value
    })
    return res
}

export const getter = <T, T2 extends keyof T>(obj: T, field: T2): T[T2] | null => (obj ? obj[field] : null)
