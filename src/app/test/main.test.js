const request = require('supertest');
const app = require('../main');

describe('Index Tests', () => {
    describe('GET /', () => {
        it('Should return version message', (done) => {
            request(app)
                .get('/')
                .expect(200)
                .expect(JSON.stringify('This is version 1.0'))
                .end(done);
        });
    });
});
