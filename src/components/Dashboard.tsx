import { useAuthStore } from '../store/authStore';

export default function Dashboard() {
  const { user, logout } = useAuthStore();

  return (
    <div className="min-h-screen bg-gray-100 p-8">
      <header className="bg-white shadow rounded-lg mb-8">
        <div className="max-w-7xl mx-auto py-4 px-6 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-gray-900">Tasman Roofing Job Scheduler</h1>
          <div className="flex items-center gap-4">
            <span className="text-sm text-gray-600">
              {user?.name} ({user?.role})
            </span>
            <button
              onClick={() => logout()}
              className="px-3 py-1 text-sm text-red-600 hover:text-red-800"
            >
              Logout
            </button>
          </div>
        </div>
      </header>
      
      <div className="bg-white rounded-lg shadow p-6">
        <p className="text-center text-gray-600">
          Welcome to the Tasman Roofing Job Scheduler application. You are now logged in.
        </p>
      </div>
    </div>
  );
}