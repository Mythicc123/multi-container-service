require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const config = require('./config');
const todosRouter = require('./routes/todos');

const app = express();

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Todo routes
app.use('/todos', todosRouter);

const start = async () => {
  try {
    await mongoose.connect(config.mongoUrl);
    console.log('Connected to MongoDB');
    app.listen(config.port, () => {
      console.log(`Server running on port ${config.port}`);
    });
  } catch (err) {
    console.error('Failed to connect to MongoDB:', err.message);
    process.exit(1);
  }
};

start();
