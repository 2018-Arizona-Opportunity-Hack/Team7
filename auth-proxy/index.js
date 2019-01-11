const express = require('express');
const app = express();
const proxy = require('express-http-proxy');
const path = require('path');
const uuidv4 = require('uuid/v4');
const bodyParse = require('body-parser').json();
const cookie = require('cookie-session');

app.use(cookie({
    path: '/',
    name: 'sssession',
    keys: ['a8c977f5-fc47-4dec-9898-05ff114052d9'],
    maxAge: 24*60*60*1000
}));

app.use(function(req, res, next) {
    const reqPath = req.originalUrl.split('?')[0];
    
    if (!reqPath.startsWith('/auth') && req.session && req.session.sessid) {
	next();
    } else {
	bodyParse(req, res, next);
    }
});

app.use('/', function(req, res, next) {
    const reqPath = req.originalUrl.split('?')[0];

    if (reqPath.startsWith('/auth')) {
	if (req.session && req.session.sessid && reqPath !== '/auth/logout') {
	    res.redirect('/');
	} else if (reqPath === '/auth/authenticate' && req.method === 'POST') {
	    if (req.body && req.body.un && req.body.pw) {
		if (req.body.un.toLowerCase() === process.env['USERNAME'].toLowerCase() && req.body.pw === process.env['PASSWORD']) {
		    req.session = {
			sessid: uuidv4()
		    };
		    res.send(JSON.stringify({ result: true }));
		    return;
		}
	    }
	    res.send(JSON.stringify({ result: false }));
	} else if (reqPath === '/auth/logout') {
	    if (req.session && req.session.sessid) {
		delete req.session.sessid;
	    }
	    res.redirect('/auth/login');
	} else if (reqPath === '/auth/login') {
	    res.sendFile(path.join(__dirname + '/static/index.html'));
	} else if (reqPath === '/auth/static/index.js') {
	    res.sendFile(path.join(__dirname + '/static/index.js'));
	} else if (reqPath === '/auth/static/index.css') {
	    res.sendFile(path.join(__dirname + '/static/index.css'));
	} else {
	    res.redirect('/auth/login');
	}
    } else {
	if (req.session && req.session.sessid) {
	    next();
	    return;
	}
	res.redirect('/auth/login');
    }
});

app.use('/', proxy('localhost:3838', {
    filter: function (req, res) {
	const reqPath = req.originalUrl.split('?')[0];
	    
	return (!reqPath.startsWith('/auth') && req.session && req.session.sessid);
    }
}));

app.listen(8080);
