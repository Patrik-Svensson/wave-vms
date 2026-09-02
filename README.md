# vms-flow

**vms-flow** is an open-source VMS (Vendor Management System).

It is built to be self-hosted and freely modified. The goal is a clean, modern VMS that anyone can run, extend, and contribute to without vendor lock-in.

## Tech stack

- [TanStack Start](https://tanstack.com/start) with [TanStack Router](https://tanstack.com/router) (file-based routing)
- [React 19](https://react.dev/) and TypeScript
- [Tailwind CSS](https://tailwindcss.com/)
- [Supabase](https://supabase.com/) for database and auth
- [Vite](https://vite.dev/) for dev server and builds

## Getting started

1. Install dependencies:

   ```bash
   npm install
   ```

2. Create a `.env` file in the project root with your Supabase credentials. You can find these in the Supabase dashboard under **Project Settings → API keys**:

   ```bash
   VITE_SUPABASE_URL=https://your-project.supabase.co
   VITE_SUPABASE_PUBLISHABLE_KEY=your-publishable-key
   ```

3. Start the dev server:

   ```bash
   npm run dev
   ```

   The app runs at [http://localhost:3000](http://localhost:3000).

## Scripts

| Command                   | Description                                |
| ------------------------- | ------------------------------------------ |
| `npm run dev`             | Start the development server on port 3000  |
| `npm run build`           | Build for production                       |
| `npm run preview`         | Preview the production build               |
| `npm run lint`            | Run ESLint                                 |
| `npm run format`          | Format with Prettier and fix ESLint issues |
| `npm run check`           | Check formatting with Prettier             |
| `npm run generate-routes` | Regenerate the TanStack Router route tree  |

## Project structure

```
src/
  routes/        File-based routes (TanStack Router)
  lib/supabase/  Supabase client and server helpers
  router.tsx     Router setup
  styles.css     Global styles (Tailwind)
```

## Contributing

Contributions are welcome. Open an issue to discuss larger changes, or send a pull request for fixes and small improvements. Please run `npm run format` and `npm run lint` before submitting.

## License

vms-flow is open source. See the `LICENSE` file for details.
