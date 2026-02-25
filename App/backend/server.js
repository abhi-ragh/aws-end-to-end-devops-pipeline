import express from 'express';
import path from 'path';
import bodyParser from 'body-parser';
import { sequelize as _sequelize } from './models/initModels';
import config from './config';

import userRoute from './routes/userRoute';
import productRoute from './routes/productRoute';
import orderRoute from './routes/orderRoute';
import uploadRoute from './routes/uploadRoute';

// Initialize and verify database connection
_sequelize
  .authenticate()
  .then(() => console.log('Database connection has been established successfully.'))
  .catch((err) => console.error('Unable to connect to the database:', err));

_sequelize.sync();

const app = express();

// Middleware
app.use(bodyParser.json());

// API Routes
app.use('/api/uploads', uploadRoute);
app.use('/api/users', userRoute);
app.use('/api/products', productRoute);
app.use('/api/orders', orderRoute);

app.get('/api/config/paypal', (req, res) => {
  res.send(config.PAYPAL_CLIENT_ID);
});

// Static uploads directory (if needed)
app.use('/uploads', express.static(path.join(__dirname, '/../uploads')));

// Optional: Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

// Start server
app.listen(config.PORT, () => {
  console.log(`Server started at http://localhost:${config.PORT}`);
});