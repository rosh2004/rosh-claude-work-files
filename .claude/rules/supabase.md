---
paths:
  - "src/lib/supabase/**"
  - "supabase/**"
  - "*.sql"
---
When working with Supabase:
- Always use Row Level Security policies
- Use the generated types from supabase/types.ts
- Test RLS policies with different user roles
