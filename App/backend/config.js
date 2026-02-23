import dotenv from 'dotenv';

dotenv.config();

export default {
  PORT: process.env.PORT || 5000,
  DB_HOST: process.env.DB_HOST || '',
  DB_NAME: process.env.DB_NAME || 'database-1',
  DB_USER: process.env.DB_USER || 'admin',
  DB_PASSWORD: process.env.DB_PASSWORD || '12345678',
  DB_PORT: process.env.DB_PORT || 3306,
  DB_SSL: process.env.DB_SSL || 'false',
  DB_DIALECT: process.env.DB_DIALECT || 'mysql',
  JWT_SECRET: process.env.JWT_SECRET || 'somethingsecret',
  PAYPAL_CLIENT_ID: process.env.PAYPAL_CLIENT_ID || 'sb',
  accessKeyId: process.env.accessKeyId || '',
  secretAccessKey: process.env.secretAccessKey || '',
};
