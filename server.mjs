import { promisify } from 'util' 
import { exec } from 'child_process'
import fs from 'fs'

import Fastify from 'fastify'
import fastifyCors from '@fastify/cors'
import { encode } from 'borc'
import rawBody from 'raw-body'

const execWithPromise = promisify(exec)

const fastify = Fastify({
  logger: true
})

fastify.register(fastifyCors)

// https://stackoverflow.com/questions/61122089/how-do-i-access-the-raw-body-of-a-fastify-request

fastify.addContentTypeParser('binary/octet-stream', (req, done) => {
  rawBody(req, {
      length: req.headers['content-length'],
      limit: '1mb',
      // encoding: 'utf8', // Remove if you want a buffer
  }, (err, body) => {
      if (err) return done(err)
      // done(null, parse(body))
      done(null, body)
  })
})

let fileCounter = 0

fastify.post('/upload', async (request, reply) => {
  if (!request.body) {
    return (
      reply
        .code(400)
        .header('Content-Type', 'application/json; charset=utf-8')
        .send({
          error: 'Missing data'
        })
    )
  }

  const filename = `/tmp/file-${fileCounter++}.bin`

  try {
    fs.writeFileSync(filename, request.body)

    return {
      success: true,
      filename
    }
  } catch (e) {
    console.error('Exception:', e.message)
    console.error('Code:', e.code)
    console.error('stdout:\n', e.stdout)
    console.error('stderr:\n', e.stderr)
    return (
      reply
        .code(400)
        .header('Content-Type', 'application/json; charset=utf-8')
        .send({
          success: false,
          code: e.code,
          error: e.stderr
        })
    )
  }
})

// const port = process.env.PORT || 3000
const port = 4000

const start = async () => {
  try {
    await fastify.listen(port, '0.0.0.0')
  } catch (err) {
    fastify.log.error(err)
    process.exit(1)
  }
}
start()
