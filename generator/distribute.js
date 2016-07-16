#!/usr/bin/env node

/* 
 * Taken from http://cruft.io/posts/node-command-line-utilities/
 */ 

var program = require('commander');
var request = require('request');
var chalk = require('chalk');
var _ = require('underscore');
var fs = require('fs');

function runDeploy(name, url, token) {
    var dirname = name + '-clone';
    fs.mkdir(dirname, function() {
        var deploySh = spawn('sh', [ 'deploy.sh' ], {
          cwd: process.env.PWD + '/' + dirname,
          env:_.extend(process.env, { GH_TOKEN: token, REPO_NAME: name, GH_REF: url })
        });
    })
}

program
    .version('1.0.0')
    .usage('[options]')
    .option('-t, --token [github token]', 'Github Token used to Push')
    .option('-f, --full', 'Return full JSON responses to the console')
    .parse(process.argv);

if(!program.token) {
    program.help();
} else {
    var url = 'https://api.github.com/repos/openactive/dataset-site-generator/forks';

    request({
        method: 'GET',
        headers: {
            'User-Agent': 'Dataset Site Generator Distribute Script',
            'Authorization': 'token ' + program.token
        },
        url: url
    }, function(error, response, body) {

        if (!error && response.statusCode == 200) {
            var body = JSON.parse(body);
            if(program.full) {
                console.log(body);
            } 

            for(var i = 0; i < body.length; i++) {
                console.log(chalk.magenta.bold('Name: ' + body[i].name ));
                console.log(chalk.grey('Desc: ' + body[i].description ));
                console.log(chalk.grey('Push: ' + body[i].permissions.push ));
                console.log(chalk.grey('Clone URL: ' + body[i].clone_url  + '\n'));

                if (body[i].permissions.push) {
                    console.log(chalk.cyan.bold('Attempting to upgrade: ' + body[i].clone_url  + '...\n'));

                }
            }
            process.exit(0);

        } else if (error) {
            console.log(chalk.red('Error: ' + error));
            process.exit(1);
        }
    });
}