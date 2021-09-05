
const fs = require('fs')
let data = JSON.parse(fs.readFileSync("./data/Inputs_India.json", 'utf-8'))

console.log(data)

const Channels = data.Channels;
const Pathways = data.Pathways;
const Algs = data.Algorithms;
const Tools = data.Tools;


console.log(Tools)
console.log("KK")


let channel = "Channel 2";
let year = 2023






