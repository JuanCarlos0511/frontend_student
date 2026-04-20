const { Pool } = require('pg');
const pool = new Pool({ connectionString: 'postgres://postgres:postgres@localhost:5432/uni_social' });
pool.query(`
ALTER TABLE communities 
ADD COLUMN IF NOT EXISTS is_course BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS course_modules JSONB DEFAULT '[]'::jsonb;
`).then(() => { console.log('OK'); pool.end(); }).catch(e => { console.error(e); pool.end(); });
