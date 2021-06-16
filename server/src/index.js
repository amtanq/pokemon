const http = require('http')
const server = http.createServer(router)
const io = require('socket.io')(server)
const shortid = require('shortid')
const games = {}

function router (req, res) {
  res.end('POKE SERVER')
}

io.on('connection', socket => {
  socket.on('create', () => {
    const id = shortid.generate()
    socket.game = id
    socket.type = 'host'
    socket.other = 'client'
    games[id] = { host: socket.id, client: null }
    socket.emit('create', id)
  })

  socket.on('enter', id => {
    if (!games[id] || games[id].client) return
    socket.game = id
    socket.type = 'client'
    socket.other = 'host'
    games[id].client = socket.id
    io.to(games[id].host).emit('start')
    io.to(games[id].client).emit('start')
  })

  socket.on('score', score => {
    if (!games[socket.game]) return
    io.to(games[socket.game][socket.other]).emit('score', score)
  })

  socket.on('state', () => {
    if (!games[socket.game]) return
    io.to(games[socket.game][socket.other]).emit('state')
  })

  socket.on('disconnect', () => {
    if (!socket.game || !games[socket.game]) return
    games[socket.game][socket.type] = null
    io.to(games[socket.game][socket.other]).emit('state')
    delete games[socket.game]
  })
})

server.listen(process.env.PORT)
