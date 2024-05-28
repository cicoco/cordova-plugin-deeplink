var exec = require("cordova/exec");
var DEFAULT_IOS_EXCLUSIONS = [
    "com.apple.UIKit.activity.AddToReadingList",
    "com.apple.UIKit.activity.AirDrop"
];
var WebShare = {
  share: function (options, success, error) {
    if (!options.iosExcludedActivities) {
        options.iosExcludedActivities = DEFAULT_IOS_EXCLUSIONS;
    }
    exec(success, error, "WebShare", "share", [options]);
  }
};

module.exports = WebShare;