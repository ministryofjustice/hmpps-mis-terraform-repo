var https = require('https');
var util = require('util');
let AWS = require('aws-sdk');
let ssm = new AWS.SSM({ region: process.env.REGION });

exports.handler = function(event, context) {
    console.log(JSON.stringify(event, null, 2));

        const environment = process.env.ENVIRONMENT_TYPE;
        var heading = "ClamAV Notification";
        var bodytext = "ClamAV found some files to be infected. Please review infected folder in DFI bucket for the environment";
        var channel = "${slack_channel}"
        var slack_token_ssm = "${slack_token_paramstore_name}"
        var icon_emoji = ":sign-warning:";
            console.log("Slack channel: " + channel);

               var postData = {
                       "channel": "# " + channel,
                       "username": "AWS SNS via Lambda :: ClamAV Notification",
                       "text": "**************************************************************************************************"
                       + "\nInfo: "  + heading
                       + "\nDetails: "  + bodytext
                       + "\nEnvironment: "  + environment

                       ,
                       "icon_emoji": icon_emoji,
                       "link_names": "1"
                   };

    ssm.getParameters({Name: slack_token_ssm, WithDecryption: true }, function(err, data) {
      if (err) {
        console.log("Unable to get webhook URL token for Slack", slack_token_ssm, err); // an error occurred
        return context.fail("Unable to get webhook URL token for Slack");
      };
      else 
        url_path = console.log(data)
    });

    var options = {
        method: 'POST',
        hostname: 'hooks.slack.com',
        port: 443,
        path: url_path
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
