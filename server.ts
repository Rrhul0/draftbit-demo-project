import 'dotenv/config'
import { Client } from 'pg'
import express from 'express'
import waitOn from 'wait-on'
import onExit from 'signal-exit'
import cors from 'cors'
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

// Add your routes here
const setupApp = (client: Client): express.Application => {
	const app: express.Application = express()

	app.use(cors())

	app.use(express.json())

	return app
}

// Waits for the database to start and connects
const connect = async (): Promise<Client> => {
	console.log('Connecting')
	const resource = `tcp:${process.env.PGHOST}:${process.env.PGPORT}`
	console.log(`Waiting for ${resource}`)
	await waitOn({ resources: [resource] }, () => {})
	console.log('Initializing client')
	const client = new Client()
	await client.connect()
	console.log('Connected to database')

	// Ensure the client disconnects on exit
	onExit(async () => {
		console.log('onExit: closing client')
		await client.end()
	})

	return client
}

const main = async () => {
	const client = await connect()
	const app = setupApp(client)
	const port = parseInt(process.env.SERVER_PORT || '3000')
	app.listen(port, () => {
		console.log(
			`Draftbit Coding Challenge is running at http://localhost:${port}/`
		)
	})
}

main()
