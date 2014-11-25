#!/usr/bin/env node
/**
 * Created by Mikhail Zyatin on 23.11.14.
 */


/**
 * @param {string} fileName
 */
(function (fileName) {
    'use strict';

    var fs = require('fs'),
        rawData = fs.readFileSync(fileName),
        result = '';

    // Append raw Javascript string with variable assignment and evaluate it
    eval('result = ' + rawData);
    // Put data into stdout
    console.log(JSON.stringify(result, null, 4));
}(process.argv[2]));

