'use client'

import { useTodayTasks, useMarkTaskComplete } from '@/hooks/useTasks'
import { TasksTable } from '@/components/TasksTable'

function LoadingSkeleton() {
  return (
    <div className="container mx-auto p-6">
      <div className="animate-pulse">
        <div className="h-8 bg-gray-200 rounded w-48 mb-6"></div>
        <div className="bg-white rounded-lg shadow p-6">
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="h-16 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

function ErrorState({ error, onRetry }: { error: Error; onRetry: () => void }) {
  return (
    <div className="container mx-auto p-6">
      <div className="bg-red-50 border border-red-200 rounded-lg p-6">
        <h2 className="text-xl font-semibold text-red-800 mb-2">Error Loading Tasks</h2>
        <p className="text-red-600 mb-4">{error.message}</p>
        <button
          onClick={onRetry}
          className="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700"
        >
          Retry
        </button>
      </div>
    </div>
  )
}

function EmptyState() {
  return (
    <div className="container mx-auto p-6">
      <div className="bg-white rounded-lg shadow p-12 text-center">
        <h2 className="text-2xl font-semibold text-gray-800 mb-2">No Tasks Due Today</h2>
        <p className="text-gray-600">You&apos;re all caught up! No tasks are due today.</p>
      </div>
    </div>
  )
}

export default function TodayDashboard() {
  const { data: tasks, isLoading, isError, error, refetch } = useTodayTasks()
  const markComplete = useMarkTaskComplete()

  if (isLoading) {
    return <LoadingSkeleton />
  }

  if (isError) {
    return <ErrorState error={error as Error} onRetry={refetch} />
  }

  if (!tasks || tasks.length === 0) {
    return <EmptyState />
  }

  return (
    <div className="container mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Today&apos;s Tasks</h1>
      <TasksTable 
        tasks={tasks} 
        onMarkComplete={(taskId) => markComplete.mutate(taskId)}
        isMarking={markComplete.isPending}
      />
    </div>
  )
}

