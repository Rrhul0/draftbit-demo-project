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

	app.get('/getComponentStyle/:id', async (req, res) => {
		const { id } = req.params as { id: string }
		if (!id && isNaN(+id)) {
			res.json({ error: 'Id not provided' })
			return
		}
		let componentValues = await prisma.component.findUnique({
			where: { id: +id }
		})
		// just for the demo when component with id = 1
		// not present will add it.
		if (!componentValues) {
			componentValues = await prisma.component.create({})
		}
		res.json(componentValues)
	})

	app.post('/setComponentStyle/:id', async (req, res) => {
		const componentId = req.params.id as string
		const { styleName, value } = req.body as {
			styleName: string
			value: string
		}
		if (!componentId && isNaN(+componentId)) {
			res.json({ error: 'Id not provided' })
			return
		}
		try {
			const values = await prisma.component.update({
				where: { id: +componentId },
				data: { [styleName]: value }
			})
			res.json(values)
		} catch (error) {
			res.json({ error: 'something went wrong' })
		}
	})

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
