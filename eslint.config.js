// Os scripts em scripts/ rodam no Node e sao CommonJS. A regra que importa
// aqui e no-undef: foi assim que o `crypto` importado e nunca usado do
// generate_key.js passou despercebido por tanto tempo.
module.exports = [
    {
        files: ["scripts/**/*.js", "eslint.config.js"],
        languageOptions: {
            ecmaVersion: 2023,
            sourceType: "commonjs",
            globals: {
                require: "readonly",
                module: "writable",
                process: "readonly",
                console: "readonly",
                Buffer: "readonly",
                __dirname: "readonly",
                __filename: "readonly",
                URL: "readonly",
                TextDecoder: "readonly",
                TextEncoder: "readonly",
                setTimeout: "readonly",
                clearTimeout: "readonly",
            },
        },
        rules: {
            "no-undef": "error",
            "no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
            "no-empty": ["error", { allowEmptyCatch: false }],
            "no-fallthrough": "error",
            "no-constant-condition": ["error", { checkLoops: false }],
        },
    },
];
