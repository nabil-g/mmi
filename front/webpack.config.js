var path = require("path");

var webpack = require("webpack");
var merge = require("webpack-merge");

var prod = "production";
var dev = "development";

// determine build env
var TARGET_ENV = process.env.npm_lifecycle_event === "build" ? prod : dev;
var isDev = TARGET_ENV == dev;
var isProd = TARGET_ENV == prod;

var outputPath = path.resolve(__dirname + "/dist");
var outputFilename = "appmmi.js";

console.log("WEBPACK GO! Building for " + TARGET_ENV);

// common webpack config
var commonConfig = {
    module: {
        noParse: /\.elm$/,
        rules: [],
    },

    output: {
        path: outputPath,
        filename: outputFilename,
        publicPath: "http://localhost:3002/",
    },

    performance: {
        hints: false,
    },

    resolve: {
        extensions: [".js", ".elm"],
        modules: ["node_modules"],
    },
};

// additional webpack settings for local env (when invoked by 'npm start')
if (isDev === true) {
    console.log("Serving locally...");

    module.exports = function(env) {
        var entry = "./static/index.js";

        return merge(commonConfig, {
            entry: entry,

            devServer: {
                // serve index.html in place of 404 responses
                historyApiFallback: true,
                headers: {
                    "Access-Control-Allow-Origin": "*",
                },
                stats: {
                    assets: false,
                    cached: false,
                    cachedAssets: false,
                    children: false,
                    chunks: false,
                    colors: true,
                    depth: true,
                    entrypoints: true,
                    errorDetails: true,
                    hash: false,
                    modules: true,
                    source: true,
                    timings: true,
                    version: false,
                    warnings: true,
                },
            },

            plugins: [
                function() {
                    if (typeof this.options.devServer.hot === "undefined") {
                        this.plugin("done", function(stats) {
                            if (
                                stats.compilation.errors &&
                                stats.compilation.errors.length
                            ) {
                                console.log(stats.compilation.errors);
                                process.exit(1);
                            }
                        });
                    }
                },
            ],

            module: {
                rules: [
                    {
                        test: /\.elm$/,
                        exclude: [/elm-stuff/, /node_modules/],
                        use: [
                            {
                                loader: "elm-hot-loader",
                            },
                            {
                                loader: "elm-webpack-loader",
                                options: {
                                    verbose: true,
                                    warn: true,
                                    debug: true,
                                },
                            },
                        ],
                    },
                ],
            },
        });
    };
}

// additional webpack settings for prod env (when invoked via 'npm run build')
if (isProd === true) {
    console.log("Building for prod...");

    module.exports = function(env) {
        if (!env || !env.appName || apps.indexOf(env.appName) === -1) {
            console.log("Error: you must provide an app name.");
            apps.forEach(function(app) {
                console.log("-", app);
            });
            return;
        }
        var entry = "./static/index.js";

        return merge(commonConfig, {
            entry: entry,

            module: {
                rules: [
                    {
                        test: /\.elm$/,
                        exclude: [/elm-stuff/, /node_modules/],
                        use: [
                            {
                                loader: "elm-webpack-loader",
                            },
                        ],
                    },
                ],
            },

            plugins: [
                new webpack.optimize.UglifyJsPlugin({
                    minimize: true,
                    compressor: {
                        warnings: false,
                    },
                }),
            ],
        });
    };
}

// var path = require("path");
// var webpack = require("webpack");
// var merge = require("webpack-merge");
// var entryPath = path.join(__dirname, "front/static/index.js");
// var outputPath = path.join(__dirname, "dist");
//
// console.log("WEBPACK GO!");
//
// // determine build env
// var TARGET_ENV =
//     process.env.npm_lifecycle_event === "build" ? "production" : "development";
// //var outputFilename = TARGET_ENV === 'production' ? '[name]-[hash].js' : '[name].js'
// var outputFilename = "appmmi.js";
//
// // common webpack config
// var commonConfig = {
//     output: {
//         path: outputPath,
//         filename: `/static/js/${outputFilename}`,
//         // publicPath: '/'
//     },
//
//     resolve: {
//         extensions: ["", ".js", ".elm"],
//     },
//
//     module: {
//         noParse: /\.elm$/,
//         loaders: [
//             {
//                 test: /\.(eot|ttf|woff|woff2|svg)$/,
//                 loader: "file-loader",
//             },
//         ],
//     },
//
//     plugins: [
//         new HtmlWebpackPlugin({
//             template: "front/static/index.html",
//             inject: "body",
//             filename: "index.html",
//         }),
//     ],
//
//     postcss: [autoprefixer({ browsers: ["last 2 versions"] })],
// };
//
// // additional webpack settings for local env (when invoked by 'npm start')
// if (TARGET_ENV === "development") {
//     console.log("Serving locally...");
//
//     module.exports = merge(commonConfig, {
//         entry: ["webpack-dev-server/client?http://localhost:3002", entryPath],
//
//         devServer: {
//             // serve index.html in place of 404 responses
//             historyApiFallback: true,
//             contentBase: "./front",
//         },
//
//         module: {
//             loaders: [
//                 {
//                     test: /\.elm$/,
//                     exclude: [/elm-stuff/, /node_modules/],
//                     loader:
//                         "elm-hot!elm-webpack?verbose=true&warn=true&debug=true",
//                 },
//                 {
//                     test: /\.(css|scss)$/,
//                     loaders: [
//                         "style-loader",
//                         "css-loader",
//                         "postcss-loader",
//                         "sass-loader",
//                     ],
//                 },
//             ],
//         },
//     });
// }
//
// // additional webpack settings for prod env (when invoked via 'npm run build')
// if (TARGET_ENV === "production") {
//     console.log("Building for prod...");
//
//     module.exports = merge(commonConfig, {
//         entry: entryPath,
//
//         module: {
//             loaders: [
//                 {
//                     test: /\.elm$/,
//                     exclude: [/elm-stuff/, /node_modules/],
//                     loader: "elm-webpack",
//                 },
//                 {
//                     test: /\.(css|scss)$/,
//                     loader: ExtractTextPlugin.extract("style-loader", [
//                         "css-loader",
//                         "postcss-loader",
//                         "sass-loader",
//                     ]),
//                 },
//             ],
//         },
//
//         plugins: [
//             new CopyWebpackPlugin([
//                 {
//                     from: "front/static/img/",
//                     to: "static/img/",
//                 },
//                 {
//                     from: "front/favicon.ico",
//                 },
//             ]),
//
//             new webpack.optimize.OccurenceOrderPlugin(),
//
//             // extract CSS into a separate file
//             new ExtractTextPlugin("static/css/[name]-[hash].css", {
//                 allChunks: true,
//             }),
//
//             // minify & mangle JS/CSS
//             new webpack.optimize.UglifyJsPlugin({
//                 minimize: true,
//                 compressor: { warnings: false },
//                 // mangle:  true
//             }),
//         ],
//     });
// }
