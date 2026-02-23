import { getToken, isAuth, isAdmin } from '../util';

describe('Util Functions', () => {
  describe('getToken', () => {
    it('should generate a valid JWT token', () => {
      const user = {
        _id: 1,
        name: 'Test User',
        email: 'test@example.com',
        isAdmin: false,
      };
      
      const token = getToken(user);
      expect(token).toBeDefined();
      expect(typeof token).toBe('string');
      expect(token.split('.')).toHaveLength(3); // JWT has 3 parts
    });

    it('should include user data in token payload', () => {
      const user = {
        _id: 1,
        name: 'Admin User',
        email: 'admin@example.com',
        isAdmin: true,
      };
      
      const token = getToken(user);
      const payload = token.split('.')[1];
      const decoded = JSON.parse(Buffer.from(payload, 'base64').toString());
      
      expect(decoded._id).toBe(user._id);
      expect(decoded.name).toBe(user.name);
      expect(decoded.email).toBe(user.email);
      expect(decoded.isAdmin).toBe(user.isAdmin);
    });
  });
});
