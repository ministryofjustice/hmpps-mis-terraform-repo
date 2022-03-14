var https = require('https');
var util = require('util');

exports.handler = function(event, context) {
    console.log(JSON.stringify(event, null, 2));

        const environment = process.env.ENVIRONMENT_TYPE;
        var heading = "ClamAV Notification";
        var bodytext = "ClamAV found some files to be infected. Please review infected folder in DFI bucket for the environment";
        var channel = "${slack_channel}" // "ndmis-non-prod-alerts";
        var url_path = "${slack_url}" // "/services/T02DYEB3A/BS16X2JGY/r9e1CJYez7BDmwyliIl7WzLf";
        var icon_emoji = ":sign-warning:";

            //if (environment=='prod' )
            //   channel = "ndmis-alerts";

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
