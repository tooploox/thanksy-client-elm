const webpack = require("webpack")
const path = require("path")
const MODE = process.env.npm_lifecycle_event === "build" ? "production" : "development"
console.log({ MODE, npm: process.env.npm_lifecycle_event })
module.exports = function(env) {
    return {
        mode: MODE,
        entry: {
            index: "./src/index.ts"
        },
        output: {
            filename: "[name].bundle.js",
            path: path.resolve(__dirname, "dist")
        },
        optimization: {
            splitChunks: {
                chunks: "all"
            }
        },
        performance: {
            maxEntrypointSize: 512000,
            maxAssetSize: 512000
        },

        plugins:
            MODE === "development"
                ? [
                      // Suggested for hot-loading
                      new webpack.NamedModulesPlugin(),
                      // Prevents compilation errors causing the hot loader to lose state
                      new webpack.NoEmitOnErrorsPlugin()
                  ]
                : [],
        module: {
            rules: [
                {
                    test: /\.html$/,
                    exclude: /node_modules/,
                    loader: "file-loader?name=[name].[ext]"
                },
                {
                    test: [/\.elm$/],
                    exclude: [/elm-stuff/, /node_modules/],
                    use: [
                        { loader: "elm-hot-webpack-loader" },
                        {
                            loader: "elm-webpack-loader",
                            options: MODE === "production" ? {} : { debug: true, forceWatch: true }
                        }
                    ]
                },
                { test: /\.ts$/, loader: "ts-loader" },
                {
                    test: /\.scss$/,
                    use: ["style-loader", "css-loader", "sass-loader"]
                },
                {
                    test: /\.(jpe?g|png|gif|svg)$/,
                    use: [
                        {
                            loader: "url-loader"
                        },
                        "image-webpack-loader"
                    ]
                }
            ]
        },

        resolve: {
            extensions: [".js", ".ts", ".elm", ".json"]
        },
        serve: {
            inline: true,
            stats: "errors-only"
        }
    }
}
