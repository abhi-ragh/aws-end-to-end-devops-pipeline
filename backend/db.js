import { Sequelize } from 'sequelize';
import config from './config';

const options = {
  host: config.DB_HOST,
  port: config.DB_PORT,
  dialect: config.DB_DIALECT,
  logging: false,
};

// Optionally enable SSL for AWS RDS if DB_SSL is set to 'true'
if (String(config.DB_SSL).toLowerCase() === 'true') {
  options.dialectOptions = {
    ssl: {
      require: true,
      // In some environments you may need to set rejectUnauthorized depending on your CA
      rejectUnauthorized: false,
    },
  };
}

const sequelize = new Sequelize(
  config.DB_NAME,
  config.DB_USER,
  config.DB_PASSWORD,
  options
);

export default sequelize;
