const mongoose = require('mongoose');
const request = require('supertest');

const Todo = require('../src/models/Todo');
const app = require('../src/index');

beforeAll(async () => {
  await mongoose.connect(process.env.MONGO_URL || 'mongodb://localhost:27017/todos_test');
}, 30000);

afterAll(async () => {
  await mongoose.disconnect();
}, 15000);

beforeEach(async () => {
  await Todo.deleteMany({});
}, 15000);

describe('Todo API', () => {
  it('GET /todos returns empty array initially', async () => {
    const res = await request(app).get('/todos');
    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });

  it('POST /todos creates a new todo', async () => {
    const res = await request(app)
      .post('/todos')
      .send({ title: 'Learn Docker' });
    expect(res.status).toBe(201);
    expect(res.body.title).toBe('Learn Docker');
    expect(res.body.completed).toBe(false);
    expect(res.body._id).toBeDefined();
  });

  it('GET /todos/:id returns a single todo', async () => {
    const create = await request(app)
      .post('/todos')
      .send({ title: 'Write tests' });
    const id = create.body._id;

    const res = await request(app).get(`/todos/${id}`);
    expect(res.status).toBe(200);
    expect(res.body.title).toBe('Write tests');
  });

  it('GET /todos/:id returns 404 for unknown id', async () => {
    const fakeId = new mongoose.Types.ObjectId();
    const res = await request(app).get(`/todos/${fakeId}`);
    expect(res.status).toBe(404);
  });

  it('PUT /todos/:id updates a todo', async () => {
    const create = await request(app)
      .post('/todos')
      .send({ title: 'Old title' });
    const id = create.body._id;

    const res = await request(app)
      .put(`/todos/${id}`)
      .send({ title: 'New title', completed: true });
    expect(res.status).toBe(200);
    expect(res.body.title).toBe('New title');
    expect(res.body.completed).toBe(true);
  });

  it('PUT /todos/:id returns 404 for unknown id', async () => {
    const fakeId = new mongoose.Types.ObjectId();
    const res = await request(app)
      .put(`/todos/${fakeId}`)
      .send({ title: 'New title' });
    expect(res.status).toBe(404);
  });

  it('DELETE /todos/:id deletes a todo', async () => {
    const create = await request(app)
      .post('/todos')
      .send({ title: 'To delete' });
    const id = create.body._id;

    const res = await request(app).delete(`/todos/${id}`);
    expect(res.status).toBe(200);
    expect(res.body.message).toBe('Deleted successfully');

    const get = await request(app).get(`/todos/${id}`);
    expect(get.status).toBe(404);
  });

  it('DELETE /todos/:id returns 404 for unknown id', async () => {
    const fakeId = new mongoose.Types.ObjectId();
    const res = await request(app).delete(`/todos/${fakeId}`);
    expect(res.status).toBe(404);
  });
});
