# LearnLynk CRM System

A comprehensive CRM system built with Supabase, Next.js, and TypeScript for managing leads, applications, and tasks.

## Tech Stack

- **Database**: Supabase (PostgreSQL)
- **Backend**: Supabase Edge Functions (Deno/TypeScript)
- **Frontend**: Next.js 14 (App Router) with TypeScript
- **State Management**: TanStack React Query
- **Styling**: Tailwind CSS
- **Payments**: Stripe Checkout

## Project Structure

```
.
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql      # Database schema with tables, indexes, constraints
│   │   └── 002_rls_policies.sql        # Row Level Security policies
│   └── functions/
│       └── create-task/
│           └── index.ts                 # Edge Function for creating tasks
├── src/
│   ├── app/
│   │   ├── dashboard/
│   │   │   └── today/
│   │   │       └── page.tsx            # Today's tasks dashboard page
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── providers.tsx               # React Query provider
│   ├── components/
│   │   └── TasksTable.tsx              # Task table component
│   ├── hooks/
│   │   └── useTasks.ts                 # React Query hooks for tasks
│   ├── lib/
│   │   └── supabase.ts                 # Supabase client
│   └── types/
│       └── index.ts                    # TypeScript type definitions
└── docs/
    └── STRIPE_INTEGRATION.md           # Stripe Checkout integration guide
```

## Setup

### Prerequisites

- Node.js 18+ 
- Supabase account
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/kuldeep31016/crm-supabase-nextjs.git
cd crm-supabase-nextjs
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.local.example .env.local
```

Edit `.env.local` with your Supabase credentials:
```
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
```

4. Run database migrations:
   - In Supabase Dashboard, go to SQL Editor
   - Run `supabase/migrations/001_initial_schema.sql`
   - Run `supabase/migrations/002_rls_policies.sql`

5. Deploy Edge Functions:
```bash
supabase functions deploy create-task
```

6. Start the development server:
```bash
npm run dev
```

## Features

### Database Schema

- **Leads**: Manage potential customers with stages (new, contacted, qualified, converted, lost)
- **Applications**: Track applications linked to leads with payment status
- **Tasks**: Create and manage tasks (call, email, review) linked to applications
- **Teams**: Multi-tenant team management
- **User Teams**: Junction table for team membership

### Row Level Security (RLS)

- Counselors can only see leads assigned to them or their team
- Admins have full access to all records
- Proper policies for SELECT, INSERT, UPDATE, DELETE operations

### Edge Functions

- **create-task**: Creates tasks with validation and broadcasts Realtime events

### Dashboard

- View tasks due today
- Mark tasks as complete
- Real-time updates using React Query
- Loading and error states

### Stripe Integration

- Documented flow for Stripe Checkout integration
- Payment status tracking
- Application stage updates after payment

## Development

### Running Locally

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Building for Production

```bash
npm run build
npm start
```

## Testing

1. **Schema**: Verify all tables are created with correct constraints
2. **RLS**: Test that counselors can only see their leads
3. **Edge Function**: Test task creation with validation
4. **Dashboard**: Verify tasks display and mark complete functionality

## License

MIT

