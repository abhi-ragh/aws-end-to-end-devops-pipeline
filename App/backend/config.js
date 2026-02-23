import dotenv from 'dotenv';

dotenv.config();

function required(name) {
  if (!process.env[name]) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return process.env[name];
}

export default {
  PORT: process.env.PORT || 5000,

  DB_HOST: required('DB_HOST'),
  DB_NAME: required('DB_NAME'),
  DB_USER: required('DB_USER'),
  DB_PASSWORD: required('DB_PASSWORD'),
  DB_PORT: process.env.DB_PORT || 3306,
  DB_SSL: process.env.DB_SSL === 'true',
  DB_DIALECT: process.env.DB_DIALECT || 'mysql',

  JWT_SECRET: required('JWT_SECRET'),
  PAYPAL_CLIENT_ID: required('PAYPAL_CLIENT_ID')
};