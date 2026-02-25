import { sequelize, User, Product } from '../models/initModels';
import data from '../data';

async function seed() {
  try {
    await sequelize.authenticate();
    await sequelize.sync();

    // Seed admin user (create if not exists)
    const [adminUser] = await User.findOrCreate({
      where: { email: 'admin@example.com' },
      defaults: {
        name: 'Admin',
        email: 'admin@example.com',
        password: '1234',
        isAdmin: true,
      },
    });

    console.log('Admin user ensured:', adminUser.email);

    // Clear existing products and insert sample products
    await Product.destroy({ where: {} });
    const products = (data.products || []).map((p) => ({
      name: p.name,
      image: p.image,
      brand: p.brand || '',
      category: p.category || '',
      price: p.price || 0,
      countInStock: p.countInStock || 0,
      description: p.description || '',
      rating: p.rating || 0,
      numReviews: p.numReviews || 0,
    }));
    if (products.length > 0) {
      await Product.bulkCreate(products);
      console.log(`Inserted ${products.length} products`);
    } else {
      console.log('No sample products to insert');
    }

    console.log('Seeding complete');
    process.exit(0);
  } catch (err) {
    console.error('Seeding error:', err);
    process.exit(1);
  }
}

seed();
