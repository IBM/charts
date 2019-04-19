// health

console.debug("Health check invoked");

var servicevars = require ('service-metadata');

servicevars.mpgw.skipBackside = true;

session.output.write({'a': 'Running'});
