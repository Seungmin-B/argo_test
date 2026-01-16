const http = require('http');

const port = process.env.PORT || '8080';
const version = process.env.APP_VERSION || 'dev';

const server = http.createServer((req, res) => {
  if (req.url === '/healthz') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('ok\n');
    return;
  }

  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end(`hello from git+jenkins+helm+argo demo (version=${version})\n`);
});

server.listen(parseInt(port, 10), () => {
  console.log(`listening on :${port}`);
});
