let https = require('https');
let util = require('util');
let AWS = require('aws-sdk');
let ssm = new AWS.SSM({ region: process.env.REGION });

exports.handler = function(event, context) {
    console.log(JSON.stringify(event, null, 2));

        const environment = process.env.ENVIRONMENT_TYPE;
        var heading = "ClamAV Notification";
        var bodytext = "ClamAV found some files to be infected. Please review infected folder in DFI bucket for the environment";
        var icon_emoji = ":sign-warning:";
            console.log("Slack channel: " + process.env.SLACK_CHANNEL);

               var postData = {
                       "channel": "# " + process.env.SLACK_CHANNEL,
                       "username": "AWS SNS via Lambda :: ClamAV Notification",
                       "text": icon_emoji + " AWS SNS via Lambda :: *\OK Notification\* "
                       + "\n**************************************************************************************************"
                       + "\nInfo: "  + heading
                       + "\nDetails: "  + bodytext
                       + "\nEnvironment: "  + environment

                       ,
                       "icon_emoji": icon_emoji,
                       "link_names": "1"
                   };

  ssm.getParameter({ Name: process.env.SLACK_TOKEN, WithDecryption: true }, function(err, data) {
    if (err) {
      console.log("Unable to get webhook URL token for Slack", process.env.SLACK_TOKEN, err);
      return context.fail("Unable to get webhook URL token for Slack");
    }

    const req = https.request({
        method: 'POST',
        hostname: 'hooks.slack.com',
        port: 443,
        path: data.Parameter.Value,
        headers: {
            "Content-Type": "application/json"
        }
      }, function(res) {
        res.setEncoding('utf8');
        res.on('data', function (chunk) {
          console.log("Response received", chunk)
          return context.done(null)
      });
    });
    req.on('error', function(e) {
      console.log('problem with request: ', e);
      return context.fail("Unable to post message to Slack");
    });
    req.write(util.format("%j", postData));
    req.end();
  });
};
