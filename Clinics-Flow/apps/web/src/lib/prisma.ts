import { PrismaClient } from '@prisma/client'

// Initialize Prisma Client
// The Prisma Client is generated in node_modules/.prisma/client/
const prisma = new PrismaClient()

export default prisma

// Type-safe Prisma queries
export { PrismaClient as Prisma } from '@prisma/client'
