var https = require('https');
var util = require('util');

exports.handler = function(event, context) {
    console.log(JSON.stringify(event, null, 2));

    var postData = {
        "channel": "# delius-aws-ops-alerts",
        "username": "AWS SNS via Lambda :: Alarm notification",
        "text": "*" + event.Records[0].Sns.Subject +"*",
        "icon_emoji": ":aws:"
    };

    postData.attachments = [
        {
            "color": "Warning",
            "text": event.Records[0].Sns.Message
        }
    ];

    var options = {
        method: 'POST',
        hostname: 'hooks.slack.com',
        port: 443,
        path: '/services/T02DYEB3A/BGJ1P95C3/f1MBtQ0GoI6kbGUztiSpkOut'
    };

    var req = https.request(options, function(res) {
      res.setEncoding('utf8');
      res.on('data', function (chunk) {
        context.done(null);
      });
    });

    req.on('error', function(e) {
      console.log('problem with request: ' + e.message);
    });

    req.write(util.format("%j", postData));
    req.end();
};
