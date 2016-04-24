var express = require('express');
var app = express();

app.get('/', function (req, res) {
    res.json({ success: 5 });
});

app.get('/status/:status', function (req, res) {
    res.status(Number(req.params.status)).end();
});

app.listen(process.env.PORT || 3000, function () {
    console.log('Example app listening on port 3000!');
});
