var https = require('https');
var util = require('util');
let AWS = require('aws-sdk');
let ssm = new AWS.SSM({ region: process.env.REGION });

function sleep(milliseconds) {
  const date = Date.now();
  let currentDate = null;
  do {
    currentDate = Date.now();
  } while (currentDate - date < milliseconds);
}

exports.handler = function(event, context) {
    console.log(JSON.stringify(event, null, 2));

        var eventMessage = JSON.parse(event.Records[0].Sns.Message);
        var alarmName = eventMessage.AlarmName;
        var alarmDescription = eventMessage.AlarmDescription;
        var newStateValue = eventMessage.NewStateValue;


        var environment = alarmName.split("__")[0];
        var metric = alarmName.split("__")[1];
        var severity = alarmName.split("__")[2];
        var channel = "${slack_channel}";
        var slack_token_ssm = "${slack_token_paramstore_name}"
        var icon_emoji=":twisted_rightwards_arrows:";
        

            if (severity=='alert' )
                icon_emoji = ":warning:";

            if (severity=='critical' )
               icon_emoji = ":alert:";

            if (severity=='severe' )
               icon_emoji = ":x:";

            if (severity=='OK' )
               sleep(2000);

            if (severity=='OK' )
               icon_emoji = ":white_check_mark:";

            if (severity=='OK' )
               newStateValue='OK';

            if (newStateValue=='OK' )
               icon_emoji = ":white_check_mark:";


 //environment	service	    tier	metric	severity	resolvergroup(s)

            console.log("Slack channel: " + channel);

           if (newStateValue=='ALARM' )
              var postData = {
                      "channel": "# " + channel,
                      "username": "AWS SNS via Lambda :: Alarm Notification",
                      "text": "**************************************************************************************************"
                      + "\n\nInfo: " + alarmDescription
                      + "\nAlarmState: " + newStateValue
                      +"\nMetric: " + metric
                      + "\nSeverity: " + severity
                      + "\nEnvironment: " + environment
                      ,
                      "icon_emoji": icon_emoji,
                      "link_names": "1"
                  };

           if (newStateValue=='OK' )
              var postData = {
                      "channel": "# " + channel,
                      "username": "AWS SNS via Lambda :: OK Notification",
                      "text": "**************************************************************************************************"
                      + "\n\nInfo: ALARM State is now OK. No Further Action Required!! The following info is for information purposes only: " + alarmDescription
                      + "\nAlarmState: " + newStateValue
                      +"\nMetric: " + metric
                      + "\nEnvironment: " + environment
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
