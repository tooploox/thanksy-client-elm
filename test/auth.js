module.exports = (req, res, next) => {
    try {
        const res = /Bearer (.*)/.exec(req.headers.authorization || "")
        const token = res && res.length >= 1 ? res[1] : ""
        if (token !== "123456") throw new Error()
        next()
    } catch (err) {
        res.status(401).json({ error: "You have to provide a valid access token." })
    }
}
