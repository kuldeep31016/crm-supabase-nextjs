import Link from 'next/link'

export default function Home() {
  return (
    <main className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold mb-4">LearnLynk CRM</h1>
        <p className="text-gray-600 mb-8">Welcome to the LearnLynk CRM system</p>
        <Link 
          href="/dashboard/today"
          className="inline-block px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          View Today&apos;s Tasks
        </Link>
      </div>
    </main>
  )
}

