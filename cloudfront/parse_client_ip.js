'use strict';

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;
    request.origin.custom.customHeaders['x-realclient-ip'] = [{ key: 'x-realclient-ip', value: request.clientIp }];
    callback(null, request);
};