var path = require("path");
var webpack = require("webpack");
var merge = require("webpack-merge");
var HtmlWebpackPlugin = require("html-webpack-plugin");
var CopyWebpackPlugin = require("copy-webpack-plugin");
var autoprefixer = require("autoprefixer");
var ExtractTextPlugin = require("extract-text-webpack-plugin");
var CopyWebpackPlugin = require("copy-webpack-plugin");
var entryPath = path.join(__dirname, "./static/index.js");
var outputPath = path.resolve(__dirname + "/dist");

console.log("WEBPACK GO!");

// determine build env
var TARGET_ENV =
    process.env.npm_lifecycle_event === "build" ? "production" : "development";
//var outputFilename = TARGET_ENV === 'production' ? '[name]-[hash].js' : '[name].js'
var outputFilename = "appmmi.js";

// common webpack config
var commonConfig = {
    output: {
        path: outputPath,
        filename: outputFilename,
        publicPath: "http://localhost:3002/",
    },

    resolve: {
        extensions: ["", ".js", ".elm"],
    },

    module: {
        noParse: /\.elm$/,
        loaders: [
            {
                test: /\.(eot|ttf|woff|woff2|svg)$/,
                loader: "file-loader",
            },
        ],
    },

    plugins: [
        new HtmlWebpackPlugin({
            template: "./static/index.html",
            inject: "body",
            filename: "index.html",
        }),
        new CopyWebpackPlugin([
       { from: './static/climacons', to: 'img' }
     ])
    ],

    postcss: [autoprefixer({ browsers: ["last 2 versions"] })],
};

// additional webpack settings for local env (when invoked by 'npm start')
if (TARGET_ENV === "development") {
    console.log("Serving locally...");

    module.exports = merge(commonConfig, {
        entry: ["webpack-dev-server/client?http://localhost:3002", entryPath],

        devServer: {
            // serve index.html in place of 404 responses
            historyApiFallback: true,
            contentBase: "./src",
        },
        module: {
            loaders: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    loader:
                        "elm-hot!elm-webpack?verbose=true&warn=true&debug=true",
                },
                {
                    test: /\.(css|scss)$/,
                    loaders: [
                        "style-loader",
                        "css-loader",
                        "postcss-loader",
                        "sass-loader",
                    ],
                },
            ],
        },
    });
}

// additional webpack settings for prod env (when invoked via 'npm run build')
if (TARGET_ENV === "production") {
    console.log("Building for prod...");

    module.exports = merge(commonConfig, {
        entry: entryPath,

        module: {
            loaders: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    loader: "elm-webpack",
                },

                {
                    test: /\.(css|scss)$/,
                    loader: ExtractTextPlugin.extract("style-loader", [
                        "css-loader",
                        "postcss-loader",
                        "sass-loader",
                    ]),
                },
            ],
        },

        plugins: [
            new CopyWebpackPlugin([
                {
                    from: "./static/img/",
                    to: "./static/img/",
                },
                {
                    from: "src/favicon.ico",
                },
            ]),

            new webpack.optimize.OccurenceOrderPlugin(),

            // extract CSS into a separate file
            new ExtractTextPlugin("./static/css/[name]-[hash].css", {
                allChunks: true,
            }),

            // minify & mangle JS/CSS
            new webpack.optimize.UglifyJsPlugin({
                minimize: true,
                compressor: { warnings: false },
                // mangle:  true
            }),
        ],
    });
}
